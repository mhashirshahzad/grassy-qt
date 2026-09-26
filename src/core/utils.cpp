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
#include <QAbstractSocket>
#include <QClipboard>
#include <QGuiApplication>
#include <QNetworkInterface>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QFileDialog>

Utils::Utils(QObject *parent) : QObject(parent), m_javaInstalled(::isJavaInstalled()) {}

bool Utils::javaInstalled() const { return m_javaInstalled; }

QString Utils::serversDirectory() const { return getServersDir(); }

QString Utils::localIp() const
{
    const auto interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &interfaceInfo : interfaces)
    {
        if (!(interfaceInfo.flags() & QNetworkInterface::IsUp) ||
            !(interfaceInfo.flags() & QNetworkInterface::IsRunning) ||
            (interfaceInfo.flags() & QNetworkInterface::IsLoopBack))
            continue;

        for (const QNetworkAddressEntry &entry : interfaceInfo.addressEntries())
        {
            const QHostAddress address = entry.ip();
            if (address.protocol() == QAbstractSocket::IPv4Protocol &&
                address != QHostAddress::LocalHost)
                return address.toString();
        }
    }
    return QStringLiteral("Unavailable");
}

QString Utils::publicIp() const
{
    return m_publicIp.isEmpty() ? QStringLiteral("Loading...") : m_publicIp;
}

bool Utils::saveServersDirectory(const QString &path)
{
    const QString cleanPath = QDir(path.trimmed()).absolutePath();
    if (cleanPath.isEmpty() || !QDir().mkpath(cleanPath) || !saveServersDir(cleanPath))
        return false;

    emit serversDirectoryChanged();
    return true;
}

QString Utils::chooseDirectory(const QString &currentPath)
{
    return QFileDialog::getExistingDirectory(
        nullptr, QStringLiteral("Choose server folder"), currentPath,
        QFileDialog::ShowDirsOnly | QFileDialog::DontResolveSymlinks);
}

bool Utils::copyToClipboard(const QString &text)
{
    if (text.isEmpty() || text == QStringLiteral("Loading...") ||
        text == QStringLiteral("Unavailable"))
        return false;

    QGuiApplication::clipboard()->setText(text);
    return true;
}

void Utils::refreshPublicIp()
{
    QNetworkReply *reply =
        m_networkAccessManager.get(QNetworkRequest(QUrl(QStringLiteral("https://api.ipify.org"))));
    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        const QString address = QString::fromUtf8(reply->readAll()).trimmed();
        reply->deleteLater();
        if (address.isEmpty())
            return;
        m_publicIp = address;
        emit publicIpChanged();
    });
}

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

    const QString dataDir =
        QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    const QString defaultDir = QDir(dataDir).filePath("grassy");

    // Try to read the saved directory
    QFile file(settingsFile);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        const QString saved = in.readAll().trimmed();

        if (!saved.isEmpty())
        {
            const QString legacyDataDir =
                QDir(dataDir).filePath(QStringLiteral("grassy/grassy"));
            const QString legacyDefault =
                QDir(legacyDataDir).filePath(QStringLiteral("servers"));
            if (QDir::cleanPath(saved) == QDir::cleanPath(legacyDataDir) ||
                QDir::cleanPath(saved) == QDir::cleanPath(legacyDefault))
            {
                QDir().mkpath(defaultDir);
                saveServersDir(defaultDir);
                GRASSY_INFO() << "Migrated default servers directory to:" << defaultDir;
                return defaultDir;
            }
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
