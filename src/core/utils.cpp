#include "utils.hpp"
#include "logging.hpp"

#include <csignal> // actually SIGKILL IS DEFINED HERE, CLANG JUST GONE BONKERS!

#ifndef Q_OS_WIN
#include <unistd.h>
#endif

#include <QDir>
#include <QFile>
#include <QProcess>
#include <QStandardPaths>
#include <QTextStream>
#include <QDebug>

Utils::Utils(QObject *parent) : QObject(parent), m_javaInstalled(::isJavaInstalled()) {}

bool Utils::javaInstalled() const { return m_javaInstalled; }

static QString settingsFilePath()
{
    const QString configDir =
        QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)).filePath("grassy");

    if (!QDir().mkpath(configDir))
        GRASSY_WARNING() << "Unable to create config directory:" << configDir;

    return QDir(configDir).filePath("settings.txt");
}

QString getServersDir()
{
    const QString settingsFile = settingsFilePath();

    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    const QString defaultDir = QDir(dataDir).filePath("servers");

    // Try to read the saved directory
    QFile file(settingsFile);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        const QString saved = in.readAll().trimmed();

        if (!saved.isEmpty())
        {
            GRASSY_INFO() << "Using configured servers directory:" << saved;
            return saved;
        }
    }

    GRASSY_INFO() << "Using default servers directory:" << defaultDir;
    QDir().mkpath(defaultDir);
    saveServersDir(defaultDir);

    return defaultDir;
}

bool saveServersDir(const QString &path)
{
    const QString settingsFile = settingsFilePath();
    QFile file(settingsFile);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        GRASSY_WARNING() << "Unable to write settings file:" << settingsFile
                         << file.errorString();
        return false;
    }

    QTextStream out(&file);
    out << path;

    GRASSY_INFO() << "Saved servers directory:" << path;
    return true;
}

int killProcessOnPort(int port)
{
#ifdef Q_OS_WIN

    QProcess process;

    process.start("cmd", {"/C", QString("netstat -ano | findstr :%1").arg(port)});

    if (!process.waitForFinished())
        return 0;

    const QString output = QString::fromLocal8Bit(process.readAllStandardOutput());

    QSet<QString> pids;

    for (const QString &line : output.split('\n'))
    {
        const QStringList parts = line.simplified().split(' ');

        if (parts.size() >= 5)
            pids.insert(parts.last());
    }

    int killed = 0;

    for (const QString &pid : pids)
    {
        QProcess::execute("taskkill", {"/PID", pid, "/F"});

        ++killed;
    }

    return killed;

#else

    QProcess process;

    process.start("lsof", {"-t", QString("-i:%1").arg(port)});

    if (!process.waitForFinished())
        return 0;

    const QString output = QString::fromLocal8Bit(process.readAllStandardOutput());

    int killed = 0;

    for (const QString &pidString : output.split('\n', Qt::SkipEmptyParts))
    {

        bool ok = false;
        const qint64 pid = pidString.trimmed().toLongLong(&ok);

        if (!ok)
            continue;

        if (::kill(static_cast<pid_t>(pid), SIGKILL) == 0)
            ++killed;
    }

    return killed;

#endif
}

bool isJavaInstalled()
{
    GRASSY_INFO() << "Searching for java...";
    return !QStandardPaths::findExecutable("java").isEmpty();
}
