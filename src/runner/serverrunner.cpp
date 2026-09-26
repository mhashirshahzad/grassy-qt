#include "serverrunner.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QRegularExpression>
#include <QThread>

#ifdef Q_OS_LINUX
#include <signal.h>
#include <QFile>
#include <sys/prctl.h>
#include <unistd.h>
#endif

namespace
{
QString highlightLogKeywords(const QString &escapedText)
{
    static const QRegularExpression keywords(
        QStringLiteral(
            R"(\b(warning|warn|info|error|exception|fatal|failed|failure|crash|crashed|exited|stopped|done|started|online)\b)"),
        QRegularExpression::CaseInsensitiveOption);

    QString highlighted;
    qsizetype start = 0;
    const auto matches = keywords.globalMatch(escapedText);

    auto match = matches;
    while (match.hasNext())
    {
        const auto current = match.next();
        highlighted += escapedText.mid(start, current.capturedStart() - start);

        const QString keyword = current.captured(1).toLower();
        QString color;

        // very stupid hardcoded colors
        if (keyword == "warning" || keyword == "warn")
            color = QStringLiteral("#ebcb8b");
        else if (keyword == "info")
            color = QStringLiteral("#81a1c1");
        else if (keyword == "error" || keyword == "exception" || keyword == "fatal" ||
                 keyword == "failed" || keyword == "failure" || keyword == "crash" ||
                 keyword == "crashed" || keyword == "exited" || keyword == "stopped")
            color = QStringLiteral("#bf616a");
        else
            color = QStringLiteral("#a3be8c");

        highlighted += QStringLiteral("<font color=\"%1\">%2</font>")
                           .arg(color, current.captured().toHtmlEscaped());
        start = current.capturedEnd();
    }

    highlighted += escapedText.mid(start);
    return highlighted;
}

QString ansiToHtml(const QString &text)
{
    QString html;
    QString color = QStringLiteral("#d8dee9");
    qsizetype start = 0;
    static const QRegularExpression ansi(
        QStringLiteral("\x1b\\[([0-9;]*)m|\\x{00A7}([0-9A-FK-ORa-fk-or])"));

    const auto matches = ansi.globalMatch(text);
    auto match = matches;
    while (match.hasNext())
    {
        const auto current = match.next();
        html +=
            highlightLogKeywords(text.mid(start, current.capturedStart() - start).toHtmlEscaped())
                .replace('\n', QStringLiteral("<br>"));

        QStringList codes;
        if (current.captured(1).isEmpty())
            codes.append(current.captured(2));
        else
            codes = current.captured(1).split(';', Qt::SkipEmptyParts);

        for (const QString &code : codes)
        {
            if (code == "0" || code.compare("r", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#d8dee9");
            else if (code == "30")
                color = QStringLiteral("#2e3440");
            else if (code == "31")
                color = QStringLiteral("#bf616a");
            else if (code == "32")
                color = QStringLiteral("#a3be8c");
            else if (code == "33")
                color = QStringLiteral("#ebcb8b");
            else if (code == "34")
                color = QStringLiteral("#81a1c1");
            else if (code == "35")
                color = QStringLiteral("#b48ead");
            else if (code == "36")
                color = QStringLiteral("#88c0d0");
            else if (code == "37")
                color = QStringLiteral("#eceff4");
            else if (code == "39")
                color = QStringLiteral("#d8dee9");
            else if (code.compare("a", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#55ffff");
            else if (code.compare("b", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#5555ff");
            else if (code.compare("c", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#ff5555");
            else if (code.compare("d", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#ff55ff");
            else if (code.compare("e", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#ffff55");
            else if (code.compare("f", Qt::CaseInsensitive) == 0)
                color = QStringLiteral("#ffffff");
        }

        start = current.capturedEnd();
    }

    html +=
        highlightLogKeywords(text.mid(start).toHtmlEscaped()).replace('\n', QStringLiteral("<br>"));
    static const QRegularExpression commandLine(
        QStringLiteral(R"(^Running:.*?(?:<br>|$))"));
    html.replace(commandLine, QStringLiteral("<font color=\"#b48ead\"><b>\\1</b></font>"));

    return QStringLiteral("<font color=\"%1\">%2</font>").arg(color, html);
}

qint64 javaMemoryLimitKb(const QString &command)
{
    static const QRegularExpression memoryOption(
        QStringLiteral(R"(-Xmx(\d+)([kKmMgGtT]?))"));
    const auto match = memoryOption.match(command);
    if (!match.hasMatch())
        return 4 * 1024 * 1024;

    bool ok = false;
    const qint64 amount = match.captured(1).toLongLong(&ok);
    if (!ok || amount <= 0)
        return 4 * 1024 * 1024;

    const QString unit = match.captured(2).toLower();
    if (unit == "t")
        return amount * 1024 * 1024 * 1024;
    if (unit == "g")
        return amount * 1024 * 1024;
    if (unit == "m")
        return amount * 1024;
    if (unit == "k")
        return amount;

    // A unitless -Xmx value is specified in bytes.
    return qMax<qint64>(1, amount / 1024);
}
} // namespace

ServerRunner::ServerRunner(QObject *parent) : QObject(parent), m_process(new QProcess(this))
{
    m_process->setProcessChannelMode(QProcess::MergedChannels);
#ifdef Q_OS_LINUX
    m_process->setChildProcessModifier(
        [] { setpgid(0, 0); prctl(PR_SET_PDEATHSIG, SIGTERM); });
#endif
    connect(m_process, &QProcess::readyRead, this, &ServerRunner::readOutput);
    connect(m_process, &QProcess::stateChanged, this,
            [this](QProcess::ProcessState) { emit runningChanged(); });
    connect(m_process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            &ServerRunner::processFinished);
    connect(m_process, &QProcess::errorOccurred, this, &ServerRunner::processError);
    m_usageTimer.setInterval(1000);
    connect(&m_usageTimer, &QTimer::timeout, this, &ServerRunner::updateUsage);
}

ServerRunner::~ServerRunner() { shutdown(); }

QString ServerRunner::serverName() const { return m_serverName; }

QString ServerRunner::serverFolder() const { return m_serverFolder; }

QString ServerRunner::consoleText() const { return m_consoleText; }

QString ServerRunner::consoleHtml() const { return m_consoleHtml; }

bool ServerRunner::running() const { return m_process->state() != QProcess::NotRunning; }

double ServerRunner::cpuUsage() const { return m_cpuUsage; }

qint64 ServerRunner::memoryUsageKb() const { return m_memoryUsageKb; }

qint64 ServerRunner::memoryLimitKb() const { return m_memoryLimitKb; }

int ServerRunner::cpuCoreCount() const { return qMax(1, QThread::idealThreadCount()); }

void ServerRunner::setServerFolder(const QString &serverFolder)
{
    if (m_serverFolder == serverFolder)
        return;

    m_serverFolder = serverFolder;
    m_serverName = QFileInfo(serverFolder).fileName();
    emit serverFolderChanged();
}

void ServerRunner::start()
{
    if (running())
        return;

    m_sessionHeader.clear();
    m_consoleText.clear();
    m_consoleHtml.clear();
    m_previousProcessTicks = 0;
    m_previousSystemTicks = 0;
    m_cpuUsage = 0.0;
    m_memoryUsageKb = 0;
    emit consoleTextChanged();
    emit consoleHtmlChanged();
    emit usageChanged();

    if (m_serverFolder.isEmpty())
    {
        appendConsole("Error: no server folder configured\n");
        return;
    }

    const QString jar = QDir(m_serverFolder).filePath("server.jar");
    if (!QFileInfo::exists(jar))
    {
        appendConsole("Error: server.jar not found\n");
        return;
    }

    m_process->setWorkingDirectory(m_serverFolder);

    const QString startScript = QDir(m_serverFolder).filePath("start.sh");
    if (QFileInfo::exists(startScript))
    {
        QString command = startScript;
        QFile script(startScript);
        if (script.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            const QString scriptText = QString::fromUtf8(script.readAll());
            static const QRegularExpression javaCommand(
                QStringLiteral(R"(^\s*(java\b.*)$)"),
                QRegularExpression::MultilineOption);
            const auto match = javaCommand.match(scriptText);
            if (match.hasMatch())
                command = match.captured(1).trimmed();
        }

        const qint64 memoryLimitKb = javaMemoryLimitKb(command);
        if (m_memoryLimitKb != memoryLimitKb)
        {
            m_memoryLimitKb = memoryLimitKb;
            emit limitsChanged();
        }
        m_sessionHeader = "Running: " + command + "\n";
        appendConsole(m_sessionHeader);
        m_process->start("/bin/sh", {startScript});
    }
    else
    {
        const QStringList args{"-Xms2G", "-Xmx4G", "-jar", jar, "nogui"};
        const qint64 memoryLimitKb = javaMemoryLimitKb(args.join(' '));
        if (m_memoryLimitKb != memoryLimitKb)
        {
            m_memoryLimitKb = memoryLimitKb;
            emit limitsChanged();
        }
        m_sessionHeader = "Running: java " + args.join(' ') + "\n";
        appendConsole(m_sessionHeader);
        m_process->start("java", args);
    }
    emit runningChanged();
        m_usageTimer.start();
}

void ServerRunner::stop()
{
    if (!running())
    {
        appendConsole("No server running\n");
        return;
    }

    sendCommand("stop");
}

void ServerRunner::shutdown()
{
    if (!running())
        return;

    sendCommand("stop");
    if (m_process->waitForFinished(3000))
        return;

#ifdef Q_OS_LINUX
    const qint64 processId = m_process->processId();
    if (processId > 0)
        ::kill(-static_cast<pid_t>(processId), SIGTERM);
    else
        m_process->terminate();
#else
    m_process->terminate();
#endif

    if (!m_process->waitForFinished(1000))
    {
#ifdef Q_OS_LINUX
        if (processId > 0)
            ::kill(-static_cast<pid_t>(processId), SIGKILL);
        else
            m_process->kill();
#else
        m_process->kill();
#endif
    }
    m_usageTimer.stop();
    m_cpuUsage = 0.0;
    m_memoryUsageKb = 0;
    emit usageChanged();
}

void ServerRunner::interrupt()
{
    if (!running())
        return;

#ifdef Q_OS_UNIX
    ::kill(static_cast<pid_t>(m_process->processId()), SIGINT);
#else
    m_process->terminate();
#endif
}

void ServerRunner::sendCommand(const QString &command)
{
    if (!running() || command.trimmed().isEmpty())
        return;

    m_process->write(command.toUtf8() + '\n');
}

void ServerRunner::readOutput()
{
    const QString text = QString::fromUtf8(m_process->readAll());
    if (text.isEmpty())
        return;

    appendConsole(text);
    emit outputReceived(text);
}

void ServerRunner::appendConsole(const QString &text)
{
    static const QRegularExpression clearScreen(
        QStringLiteral("\x1b\\[(?:2J|3J|H|[0-9;]+H)|\x0c"));

    QString remaining = text;
    qsizetype matchOffset = 0;
    auto matches = clearScreen.globalMatch(text);
    while (matches.hasNext())
    {
        const auto match = matches.next();
        const QString before = text.mid(matchOffset, match.capturedStart() - matchOffset);
        m_consoleText += before;
        m_consoleHtml += ansiToHtml(before);

        m_consoleText = m_sessionHeader;
        m_consoleHtml = ansiToHtml(m_sessionHeader);
        matchOffset = match.capturedEnd();
    }

    remaining = text.mid(matchOffset);
    m_consoleText += remaining;
    emit consoleTextChanged();
    m_consoleHtml += ansiToHtml(remaining);
    emit consoleHtmlChanged();
}

void ServerRunner::appendConsoleHtml(const QString &text)
{
    m_consoleHtml += ansiToHtml(text);
    emit consoleHtmlChanged();
}

void ServerRunner::processFinished(int exitCode, QProcess::ExitStatus status)
{
    const QString reason =
        status == QProcess::CrashExit ? QStringLiteral("crashed") : QStringLiteral("stopped");
    appendConsole(QString("\nServer %1 (exit code %2)\n").arg(reason).arg(exitCode));
    emit runningChanged();
    m_usageTimer.stop();
    m_cpuUsage = 0.0;
    m_memoryUsageKb = 0;
    emit usageChanged();
}

void ServerRunner::processError(QProcess::ProcessError error)
{
    Q_UNUSED(error);
    appendConsole("\nProcess error: " + m_process->errorString() + "\n");
    emit runningChanged();
}

void ServerRunner::updateUsage()
{
#ifdef Q_OS_LINUX
    if (!running())
        return;

    QFile systemStat(QStringLiteral("/proc/stat"));
    if (!systemStat.open(QIODevice::ReadOnly))
        return;

    const QList<QByteArray> systemFields = systemStat.readLine().simplified().split(' ');
    if (systemFields.size() <= 4)
        return;

    bool systemOk = false;
    quint64 systemTicks = 0;
    for (int i = 1; i < systemFields.size(); ++i)
        systemTicks += systemFields[i].toULongLong(&systemOk);

    const qint64 launcherPid = m_process->processId();
    qint64 launcherProcessGroup = launcherPid;
    QFile launcherStat(QStringLiteral("/proc/%1/stat").arg(launcherPid));
    if (launcherStat.open(QIODevice::ReadOnly))
    {
        const QByteArray contents = launcherStat.readAll();
        const qsizetype closeName = contents.lastIndexOf(')');
        if (closeName >= 0)
        {
            const QList<QByteArray> fields =
                contents.mid(closeName + 2).simplified().split(' ');
            bool groupOk = false;
            if (fields.size() > 2)
            {
                const qint64 processGroup = fields[2].toLongLong(&groupOk);
                if (groupOk)
                    launcherProcessGroup = processGroup;
            }
        }
    }

    quint64 processTicks = 0;
    qint64 memoryUsageKb = 0;
    struct ProcessInfo
    {
        qint64 pid;
        qint64 parentPid;
        qint64 processGroup;
        quint64 ticks;
        qint64 memoryKb;
    };
    QList<ProcessInfo> processInfo;
    QHash<qint64, qint64> parentByPid;
    QDir proc(QStringLiteral("/proc"));
    const QFileInfoList processes =
        proc.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    for (const QFileInfo &entry : processes)
    {
        bool pidOk = false;
        const qint64 pid = entry.fileName().toLongLong(&pidOk);
        if (!pidOk)
            continue;

        QFile stat(entry.filePath() + QStringLiteral("/stat"));
        if (!stat.open(QIODevice::ReadOnly))
            continue;

        const QByteArray contents = stat.readAll();
        const qsizetype closeName = contents.lastIndexOf(')');
        if (closeName < 0)
            continue;

        const QList<QByteArray> fields =
            contents.mid(closeName + 2).simplified().split(' ');
        if (fields.size() <= 14)
            continue;

        bool parentOk = false;
        const qint64 parentPid = fields[1].toLongLong(&parentOk);
        bool groupOk = false;
        const qint64 processGroup = fields[2].toLongLong(&groupOk);
        if (!parentOk || !groupOk)
            continue;

        bool userTicksOk = false;
        bool systemTicksOk = false;
        const quint64 userTicks = fields[11].toULongLong(&userTicksOk);
        const quint64 systemTicks = fields[12].toULongLong(&systemTicksOk);
        if (!userTicksOk || !systemTicksOk)
            continue;

        qint64 processMemoryKb = 0;
        QFile status(entry.filePath() + QStringLiteral("/status"));
        if (status.open(QIODevice::ReadOnly))
        {
            while (!status.atEnd())
            {
                const QByteArray line = status.readLine();
                if (!line.startsWith("VmRSS:"))
                    continue;
                const QList<QByteArray> memoryFields = line.simplified().split(' ');
                if (memoryFields.size() > 1)
                    processMemoryKb = memoryFields[1].toLongLong();
                break;
            }
        }
        if (processMemoryKb == 0)
        {
            QFile statm(entry.filePath() + QStringLiteral("/statm"));
            if (statm.open(QIODevice::ReadOnly))
            {
                const QList<QByteArray> memoryFields = statm.readAll().simplified().split(' ');
                bool residentOk = false;
                const quint64 residentPages =
                    memoryFields.size() > 1 ? memoryFields[1].toULongLong(&residentOk) : 0;
                if (residentOk)
                    processMemoryKb =
                        static_cast<qint64>((residentPages * ::sysconf(_SC_PAGESIZE)) / 1024);
            }
        }

        processInfo.append(
            {pid, parentPid, processGroup, userTicks + systemTicks, processMemoryKb});
        parentByPid.insert(pid, parentPid);
    }

    for (const ProcessInfo &process : processInfo)
    {
        bool belongsToLauncher = process.processGroup == launcherProcessGroup;
        qint64 parentPid = process.parentPid;
        for (int depth = 0; !belongsToLauncher && depth < 64; ++depth)
        {
            if (parentPid == launcherPid)
            {
                belongsToLauncher = true;
                break;
            }
            if (!parentByPid.contains(parentPid) || parentPid == parentByPid.value(parentPid))
                break;
            parentPid = parentByPid.value(parentPid);
        }

        if (belongsToLauncher)
        {
            processTicks += process.ticks;
            memoryUsageKb += process.memoryKb;
        }
    }

    if (systemOk && m_previousSystemTicks > 0 && systemTicks > m_previousSystemTicks)
    {
        const double deltaProcess = processTicks - m_previousProcessTicks;
        const double deltaSystem = systemTicks - m_previousSystemTicks;
        m_cpuUsage = (deltaProcess / deltaSystem) * 100.0;
    }
    m_previousProcessTicks = processTicks;
    m_previousSystemTicks = systemTicks;
    m_memoryUsageKb = memoryUsageKb;
    emit usageChanged();
#endif
}
