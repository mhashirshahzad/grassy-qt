#include "serverrunner.hpp"

#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>

#ifdef Q_OS_LINUX
#include <signal.h>
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
    html.replace(commandLine, QStringLiteral("<font color=\"#b48ead\"><b>\\0</b></font>"));

    return QStringLiteral("<font color=\"%1\">%2</font>").arg(color, html);
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
}

ServerRunner::~ServerRunner() { shutdown(); }

QString ServerRunner::serverName() const { return m_serverName; }

QString ServerRunner::serverFolder() const { return m_serverFolder; }

QString ServerRunner::consoleText() const { return m_consoleText; }

QString ServerRunner::consoleHtml() const { return m_consoleHtml; }

bool ServerRunner::running() const { return m_process->state() != QProcess::NotRunning; }

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

    m_consoleText.clear();
    m_consoleHtml.clear();
    emit consoleTextChanged();
    emit consoleHtmlChanged();

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
        appendConsole("Running: " + startScript + "\n");
        m_process->start("/bin/sh", {startScript});
    }
    else
    {
        const QStringList args{"-Xms2G", "-Xmx4G", "-jar", jar, "nogui"};
        appendConsole("Running: java " + args.join(' ') + "\n");
        m_process->start("java", args);
    }
    emit runningChanged();
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

        m_consoleText.clear();
        m_consoleHtml.clear();
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
}

void ServerRunner::processError(QProcess::ProcessError error)
{
    Q_UNUSED(error);
    appendConsole("\nProcess error: " + m_process->errorString() + "\n");
    emit runningChanged();
}
