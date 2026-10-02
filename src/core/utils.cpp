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
#include <QDirIterator>
#include <QSettings>
#include <QGuiApplication>
#include <QPalette>

namespace
{
QString themeDirectory()
{
    return QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation))
        .filePath(QStringLiteral("grassy/themes"));
}

QString settingsFilePath()
{
    const QString configDirectory =
        QDir(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation))
            .filePath(QStringLiteral("grassy"));
    if (!QDir().mkpath(configDirectory))
        GRASSY_WARNING() << "Unable to create config directory:" << configDirectory;
    return QDir(configDirectory).filePath(QStringLiteral("settings.ini"));
}

QVariantMap readTheme(const QString &path)
{
    QSettings settings(path, QSettings::IniFormat);
    QVariantMap theme;
        settings.beginGroup(QStringLiteral("Theme"));
        for (const QString &key : settings.allKeys())
            theme.insert(key, settings.value(key));
        settings.endGroup();
    return theme;
}

QVariantMap systemTheme()
{
    const QPalette palette = QGuiApplication::palette();
    auto color = [&palette](QPalette::ColorRole role) {
        return palette.color(QPalette::Active, role).name(QColor::HexArgb);
    };
    QVariantMap theme;
    theme["background"] = color(QPalette::Window);
    theme["surface0"] = color(QPalette::Base);
    theme["surface1"] = color(QPalette::Window);
    theme["surface2"] = color(QPalette::AlternateBase);
    theme["surface3"] = color(QPalette::Mid);
    theme["overlay0"] = color(QPalette::Mid);
    theme["overlay1"] = color(QPalette::Button);
    theme["overlay2"] = color(QPalette::Light);
    theme["overlay3"] = color(QPalette::BrightText);
    theme["text"] = color(QPalette::Text);
    theme["textBright"] = color(QPalette::WindowText);
    theme["subtext0"] = color(QPalette::Mid);
    theme["subtext1"] = color(QPalette::Mid);
    theme["subtext2"] = color(QPalette::Dark);
    for (const QString &key : {"accent", "accentHover", "success", "warning", "failure", "info"})
        theme[key] = color(QPalette::Highlight);
    theme["accentPressed"] = color(QPalette::Dark);
    theme["accentMuted"] = color(QPalette::Mid);
    theme["successHover"] = theme["accent"];
    theme["successMuted"] = theme["accentMuted"];
    theme["warningHover"] = theme["accent"];
    theme["warningMuted"] = theme["accentMuted"];
    theme["failureHover"] = theme["accent"];
    theme["failureMuted"] = theme["accentMuted"];
    theme["infoHover"] = theme["accent"];
    theme["infoMuted"] = theme["accentMuted"];
    theme["border"] = color(QPalette::Mid);
    theme["borderHover"] = color(QPalette::Button);
    theme["selection"] = color(QPalette::Highlight);
    theme["selectionHover"] = theme["selection"];
    theme["disabled"] = color(QPalette::Mid);
    theme["disabledText"] = color(QPalette::Mid);
    theme["shadow"] = color(QPalette::Dark);
    theme["scrim"] = QStringLiteral("#73000000");
    return theme;
}
}

Utils::Utils(QObject *parent) : QObject(parent), m_javaInstalled(::isJavaInstalled())
{
    loadThemes();
}

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

QStringList Utils::themeNames() const { return m_themeNames; }
QString Utils::selectedTheme() const { return m_selectedTheme; }
QVariantMap Utils::themePalette() const { return m_themePalette; }

void Utils::loadThemes()
{
    QDir().mkpath(themeDirectory());
    QHash<QString, QVariantMap> themes;
    themes.insert(QStringLiteral("System"), systemTheme());
    for (const QString &path : {QStringLiteral(":/theme/TokyoNight.ini"),
                                QStringLiteral(":/theme/Nord.ini")})
    {
        const QFileInfo info(path);
        themes.insert(info.baseName(), readTheme(path));
    }
    const QDir userDir(themeDirectory());
    for (const QString &path : userDir.entryList({QStringLiteral("*.ini")}, QDir::Files))
        themes.insert(QFileInfo(path).baseName(), readTheme(userDir.filePath(path)));

    m_themeNames = themes.keys();
    m_themeNames.sort();
    QSettings settings(settingsFilePath(), QSettings::IniFormat);
    m_selectedTheme = settings.value(QStringLiteral("General/theme"),
                                      QStringLiteral("TokyoNight")).toString();
    if (!themes.contains(m_selectedTheme))
        m_selectedTheme = QStringLiteral("TokyoNight");
    m_themePalette = themes.value(m_selectedTheme);
}

void Utils::setTheme(const QString &name)
{
    if (!m_themeNames.contains(name) || name == m_selectedTheme)
        return;
    m_selectedTheme = name;
    m_themePalette = name == QStringLiteral("System") ? systemTheme() : m_themePalette;
    if (name != QStringLiteral("System"))
    {
        const QString builtIn = QStringLiteral(":/theme/%1.ini").arg(name);
        m_themePalette = readTheme(QFile::exists(builtIn)
                                       ? builtIn
                                       : QDir(themeDirectory()).filePath(name + ".ini"));
    }
    QSettings settings(settingsFilePath(), QSettings::IniFormat);
    settings.setValue(QStringLiteral("General/theme"), name);
    settings.sync();
    emit themeChanged();
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

QStringList Utils::javaExecutables() const
{
    QStringList paths;
    const QString pathJava = QStandardPaths::findExecutable(QStringLiteral("java"));
    if (!pathJava.isEmpty())
        paths.append(pathJava);

#ifdef Q_OS_UNIX
    QDirIterator iterator(QStringLiteral("/usr/lib/jvm"),
                          {QStringLiteral("java")}, QDir::Files,
                          QDirIterator::Subdirectories);
    while (iterator.hasNext())
    {
        const QString path = iterator.next();
        if (QFileInfo(path).isExecutable())
            paths.append(path);
    }
#endif

    paths.removeDuplicates();
    paths.sort();
    return paths;
}

QString getServersDir()
{
    const QString dataDir =
        QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    const QString defaultDir = QDir(dataDir).filePath("grassy");

    QSettings settings(settingsFilePath(), QSettings::IniFormat);
    const QString saved = settings.value(QStringLiteral("General/serversDirectory")).toString();
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

    GRASSY_INFO() << "Using default servers directory:" << defaultDir;
    QDir().mkpath(defaultDir);
    saveServersDir(defaultDir);

    return defaultDir;
}

bool saveServersDir(const QString &path)
{
    QSettings settings(settingsFilePath(), QSettings::IniFormat);
    settings.setValue(QStringLiteral("General/serversDirectory"), path);
    settings.sync();
    if (settings.status() != QSettings::NoError)
    {
        GRASSY_WARNING() << "Unable to write settings file:" << settings.fileName();
        return false;
    }

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
