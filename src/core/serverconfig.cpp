#include "serverconfig.hpp"
#include "logging.hpp"

#include <QDir>
#include <QFile>
#include <QTextStream>

namespace
{
QString eulaFilePath(const QString &serverFolder)
{
    return QDir(serverFolder).filePath(QStringLiteral("eula.txt"));
}

bool setEulaValue(QString &contents)
{
    QStringList lines = contents.split('\n');
    bool found = false;

    for (QString &line : lines)
    {
        if (line.trimmed().startsWith('#'))
            continue;

        const qsizetype separator = line.indexOf('=');
        if (separator < 0 || line.left(separator).trimmed() != QStringLiteral("eula"))
            continue;

        line = line.left(separator + 1) + QStringLiteral("true");
        found = true;
        break;
    }

    if (!found)
    {
        if (!contents.isEmpty() && !contents.endsWith('\n'))
            lines.append(QString());
        lines.append(QStringLiteral("eula=true"));
    }

    contents = lines.join('\n');
    return true;
}
} // namespace

QString serverPropertiesPath(const QString &serverFolder)
{
    return QDir(serverFolder).filePath(QStringLiteral("server.properties"));
}

QString readServerProperty(const QString &serverFolder, const QString &key)
{
    QFile file(serverPropertiesPath(serverFolder));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    while (!file.atEnd())
    {
        const QString line = QString::fromUtf8(file.readLine()).trimmed();
        if (line.isEmpty() || line.startsWith('#') || line.startsWith('!'))
            continue;

        const qsizetype separator = line.indexOf('=');
        if (separator > 0 && line.left(separator).trimmed() == key)
            return line.mid(separator + 1).trimmed();
    }

    return {};
}

int serverPort(const QString &serverFolder, int fallback)
{
    const QString value = readServerProperty(serverFolder, QStringLiteral("server-port"));
    if (value.isEmpty())
        return fallback;

    bool ok = false;
    const int port = value.toInt(&ok);
    if (!ok || port < 1 || port > 65535)
        return fallback;

    return port;
}

bool ensureEulaAccepted(const QString &serverFolder)
{
    const QString path = eulaFilePath(serverFolder);
    QFile file(path);
    QString contents;

    if (file.exists())
    {
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            GRASSY_WARNING() << "Unable to read EULA file:" << path << file.errorString();
            return false;
        }
        contents = QString::fromUtf8(file.readAll());
        file.close();
    }
    else
    {
        contents =
            QStringLiteral("#By changing the setting below to TRUE you are indicating your "
                           "agreement to our EULA (https://aka.ms/MinecraftEULA).\n");
    }

    setEulaValue(contents);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
    {
        GRASSY_WARNING() << "Unable to write EULA file:" << path << file.errorString();
        return false;
    }

    const QByteArray encoded = contents.toUtf8();
    if (file.write(encoded) != encoded.size())
    {
        GRASSY_WARNING() << "Unable to write complete EULA file:" << path
                         << file.errorString();
        return false;
    }

    GRASSY_INFO() << "Accepted Minecraft EULA for:" << serverFolder;
    return true;
}
