#include "utils.hpp"
#include "qlogging.h"

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

Utils::Utils(QObject *parent) : QObject(parent) {}

bool Utils::isJavaInstalled() const { return ::isJavaInstalled(); }

QString getServersDir()
{
    const QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);

    const QString settingsFile = QDir(configDir).filePath("settings.txt");

    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    const QString defaultDir = QDir(dataDir).filePath("servers");

    // Try to read the saved directory
    QFile file(settingsFile);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        const QString saved = in.readAll().trimmed();

        if (!saved.isEmpty())
            return saved;
    }

    // No valid saved directory — create the default
    QDir().mkpath(defaultDir);

    // Save the default path

    saveServersDir(defaultDir);

    return defaultDir;
}

bool saveServersDir(const QString &path)
{
    const QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);

    if (!QDir().mkpath(configDir))
        return false;

    const QString settingsFile = QDir(configDir).filePath("settings.txt");

    QFile file(settingsFile);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;

    QTextStream out(&file);
    out << path;

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
    qInfo() << "[utils.cpp] Searching for java...";
    return !QStandardPaths::findExecutable("java").isEmpty();
}
