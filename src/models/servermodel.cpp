#include "servermodel.hpp"
#include "../core/logging.hpp"
#include "qdir.h"
#include "qhashfunctions.h"
#include "../core/utils.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>
#include <QTextStream>
#include <QRegularExpression>

namespace
{
QString propertiesFilePath(const QString &folder)
{
    return QDir(folder).filePath(QStringLiteral("server.properties"));
}

QString readProperty(const QString &contents, const QString &key)
{
    QTextStream stream(const_cast<QString *>(&contents), QIODevice::ReadOnly);
    while (!stream.atEnd())
    {
        const QString line = stream.readLine();
        if (line.isEmpty() || line.startsWith('#'))
            continue;

        const qsizetype separator = line.indexOf('=');
        if (separator >= 0 && line.left(separator).trimmed() == key)
            return line.mid(separator + 1);
    }
    return {};
}

bool writeProperty(QString &contents, const QString &key, const QString &value)
{
    QStringList lines = contents.split('\n');
    bool replaced = false;

    for (QString &line : lines)
    {
        if (line.isEmpty() || line.startsWith('#'))
            continue;

        const qsizetype separator = line.indexOf('=');
        if (separator >= 0 && line.left(separator).trimmed() == key)
        {
            line = line.left(separator + 1) + value;
            replaced = true;
            break;
        }
    }

    if (!replaced)
    {
        if (!contents.isEmpty() && !contents.endsWith('\n'))
            lines.append(QString());
        lines.append(key + '=' + value);
    }

    contents = lines.join('\n');
    return true;
}
} // namespace

ServerModel::ServerModel(QObject *parent) : QAbstractListModel(parent)
{
    refresh();
    // m_servers = {{"Survival", "A Minecraft Server", "/home/bongo/Minecraft/Survival"},
    //              {"Creative", "Creative World", "/home/bongo/Minecraft/Creative"},
    //              {"Test", "Testing server", "/home/bongo/Minecraft/Test"}};
}

int ServerModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_servers.size();
}

QVariant ServerModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_servers.size())
        return {};

    const Server &server = m_servers[index.row()];

    switch (role)
    {
    case NameRole:
        return server.name;

    case MotdRole:
        return server.motd;

    case FolderRole:
        return server.folder;

    default:
        return {};
    }
}

QHash<int, QByteArray> ServerModel::roleNames() const
{
    return {{NameRole, "name"}, {MotdRole, "motd"}, {FolderRole, "folder"}};
}

void ServerModel::refresh()
{
    beginResetModel();

    m_servers.clear();

    const QString serversPath = getServersDir();
    QDir serversDir(serversPath);
    GRASSY_INFO() << "Refreshing servers from:" << serversDir.absolutePath();

    if (!serversDir.exists())
    {
        GRASSY_WARNING() << "Servers directory does not exist:"
                         << serversDir.absolutePath();
        serversDir.mkpath(".");
        endResetModel();
        return;
    }

    const QFileInfoList folders =
        serversDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    for (const QFileInfo &folder : folders)
    {
        const QString serverJar = folder.filePath() + "/server.jar";

        if (!QFile::exists(serverJar))
        {
            GRASSY_INFO() << "Skipping directory without server.jar:" << folder.filePath();
            continue;
        }

        Server server;
        server.name = folder.fileName();
        server.folder = folder.filePath();
        server.motd = "A Minecraft Server";

        QFile propertiesFile(propertiesFilePath(folder.filePath()));
        if (propertiesFile.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            const QString contents = QString::fromUtf8(propertiesFile.readAll());
            const QString motd = readProperty(contents, QStringLiteral("motd"));
            if (!motd.isEmpty())
                server.motd = motd;
        }

        m_servers.append(server);
    }
    GRASSY_INFO() << "Found" << m_servers.size() << "server(s)";

    endResetModel();
}

bool ServerModel::renameServer(const QString &folder, const QString &name)
{
    const QString trimmedName = name.trimmed();
    QFileInfo current(folder);
    if (!current.exists() || trimmedName.isEmpty() ||
        trimmedName == current.fileName() || trimmedName.contains('/') ||
        trimmedName.contains('\\'))
        return false;

    QDir parent(current.absolutePath());
    const QString destination = parent.filePath(trimmedName);
    if (QFileInfo::exists(destination) || !parent.rename(current.fileName(), trimmedName))
        return false;

    refresh();
    return true;
}

bool ServerModel::deleteServer(const QString &folder)
{
    QDir directory(folder);
    if (!directory.exists() || !directory.removeRecursively())
        return false;

    refresh();
    return true;
}

QString ServerModel::serverProperties(const QString &folder) const
{
    QFile file(propertiesFilePath(folder));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    return QString::fromUtf8(file.readAll());
}

bool ServerModel::saveServerProperties(const QString &folder, const QString &contents)
{
    QFile file(propertiesFilePath(folder));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;
    return file.write(contents.toUtf8()) == contents.toUtf8().size();
}

bool ServerModel::setServerProperty(const QString &folder, const QString &key,
                                    const QString &value)
{
    const QString trimmedKey = key.trimmed();
    if (trimmedKey.isEmpty() || trimmedKey.contains('=') || trimmedKey.contains('\n') ||
        value.contains('\n'))
        return false;

    QFile file(propertiesFilePath(folder));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QString contents = QString::fromUtf8(file.readAll());
    file.close();

    if (!writeProperty(contents, trimmedKey, value))
        return false;

    return saveServerProperties(folder, contents);
}

bool ServerModel::createStartScript(const QString &folder, const QString &minimumMemory,
                                    const QString &maximumMemory)
{
    static const QRegularExpression memoryPattern(QStringLiteral(R"(^\d+[kKmMgGtT]?$)"));
    if (!memoryPattern.match(minimumMemory.trimmed()).hasMatch() ||
        !memoryPattern.match(maximumMemory.trimmed()).hasMatch())
        return false;

    bool minOk = false;
    bool maxOk = false;
    const qint64 minimumBytes = minimumMemory.trimmed().toLongLong(&minOk);
    const qint64 maximumBytes = maximumMemory.trimmed().toLongLong(&maxOk);
    if (minOk && maxOk && minimumBytes > maximumBytes)
        return false;

    const QString scriptPath = QDir(folder).filePath(QStringLiteral("start.sh"));
    QFile script(scriptPath);
    if (!script.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;

    const QByteArray contents =
        "#!/bin/sh\n"
        "exec java -Xms" + minimumMemory.trimmed().toUtf8() +
        " -Xmx" + maximumMemory.trimmed().toUtf8() +
        " -jar server.jar nogui\n";
    if (script.write(contents) != contents.size())
        return false;
    script.close();

    return script.setPermissions(script.permissions() | QFileDevice::ExeOwner |
                                 QFileDevice::ExeGroup | QFileDevice::ExeOther);
}
