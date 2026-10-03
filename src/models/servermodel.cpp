#include "servermodel.hpp"
#include "../core/logging.hpp"
#include "qdir.h"
#include "qhashfunctions.h"
#include "../core/serverconfig.hpp"
#include "../core/servermetadata.hpp"
#include "../core/servermetadata.hpp"
#include "../core/serverscripts.hpp"
#include "../core/utils.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QRegularExpression>
#include <limits>

namespace
{
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

qint64 memoryToBytes(const QString &value, bool *ok)
{
    static const QRegularExpression memoryPattern(QStringLiteral(R"(^(\d+)([kKmMgGtT]?)$)"));
    const auto match = memoryPattern.match(value.trimmed());
    if (!match.hasMatch())
    {
        *ok = false;
        return 0;
    }

    const qint64 amount = match.captured(1).toLongLong(ok);
    if (!*ok)
        return 0;

    const QString unit = match.captured(2).toLower();
    const qint64 multiplier = unit == "t" ? 1024LL * 1024 * 1024 * 1024
        : unit == "g"                         ? 1024LL * 1024 * 1024
        : unit == "m"                         ? 1024LL * 1024
        : unit == "k"                         ? 1024LL
                                              : 1;
    if (amount > std::numeric_limits<qint64>::max() / multiplier)
    {
        *ok = false;
        return 0;
    }
    return amount * multiplier;
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

    case TypeRole:
        return server.type;

    case InstallRequiredRole:
        return server.installRequired;

    case MetadataRole:
        return server.metadata;

    default:
        return {};
    }
}

QHash<int, QByteArray> ServerModel::roleNames() const
{
    return {{NameRole, "name"},
            {MotdRole, "motd"},
            {FolderRole, "folder"},
            {TypeRole, "serverTypeRole"},
            {InstallRequiredRole, "serverInstallRequired"},
            {MetadataRole, "serverMetadataText"}};
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
        GRASSY_WARNING() << "Servers directory does not exist:" << serversDir.absolutePath();
        serversDir.mkpath(".");
        endResetModel();
        return;
    }

    const QFileInfoList folders =
        serversDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    for (const QFileInfo &folder : folders)
    {
        const QDir serverDir(folder.filePath());
        const ServerMetadata metadata = readServerMetadata(folder.filePath());
        const bool hasMetadata =
            QFile::exists(serverDir.filePath(QStringLiteral("grassy-meta.ini")));
        const bool forgeServer = hasMetadata && metadata.type == QStringLiteral("forge");
        const bool fabricServer = hasMetadata && metadata.type == QStringLiteral("fabric");
        const bool officialServer = QFile::exists(serverDir.filePath(QStringLiteral("server.jar")));

        if (!officialServer && !hasMetadata)
        {
            GRASSY_INFO() << "Skipping directory without a recognized server:"
                          << folder.filePath();
            continue;
        }

        Server server;
        server.name = folder.fileName();
        server.folder = folder.filePath();
        server.type = forgeServer ? QStringLiteral("Forge")
            : fabricServer                   ? QStringLiteral("Fabric")
                                             : QStringLiteral("Minecraft");
        server.installRequired = hasMetadata && !metadata.installed;
        if (server.type == QStringLiteral("Minecraft"))
            server.metadata = QStringLiteral("Vanilla Minecraft");
        else
            server.metadata = QStringLiteral("%1 %2 • Loader %3")
                                  .arg(server.type, metadata.minecraftVersion,
                                       metadata.loaderVersion);

        const QString motd = readServerProperty(server.folder, QStringLiteral("motd"));
        server.motd = motd.isEmpty() ? QStringLiteral("A Minecraft Server") : motd;

        m_servers.append(server);
    }
    GRASSY_INFO() << "Found" << m_servers.size() << "server(s)";

    endResetModel();
}

bool ServerModel::renameServer(const QString &folder, const QString &name)
{
    const QString trimmedName = name.trimmed();
    QFileInfo current(folder);
    if (!current.exists() || trimmedName.isEmpty() || trimmedName == current.fileName() ||
        trimmedName.contains('/') || trimmedName.contains('\\'))
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
    QFile file(serverPropertiesPath(folder));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    return QString::fromUtf8(file.readAll());
}

bool ServerModel::saveServerProperties(const QString &folder, const QString &contents)
{
    QFile file(serverPropertiesPath(folder));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return false;

    const QByteArray encoded = contents.toUtf8();
    if (file.write(encoded) != encoded.size())
        return false;
    file.close();

    for (int row = 0; row < m_servers.size(); ++row)
    {
        if (m_servers[row].folder != folder)
            continue;

        const QString motd = readServerProperty(folder, QStringLiteral("motd"));
        m_servers[row].motd = motd.isEmpty() ? QStringLiteral("A Minecraft Server") : motd;
        const QModelIndex changed = index(row);
        emit dataChanged(changed, changed, {MotdRole});
        break;
    }
    return true;
}

bool ServerModel::setServerProperty(const QString &folder, const QString &key, const QString &value)
{
    const QString trimmedKey = key.trimmed();
    if (trimmedKey.isEmpty() || trimmedKey.contains('=') || trimmedKey.contains('\n') ||
        value.contains('\n'))
        return false;

    QFile file(serverPropertiesPath(folder));
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return false;

    QString contents = QString::fromUtf8(file.readAll());
    file.close();

    if (!writeProperty(contents, trimmedKey, value))
        return false;

    return saveServerProperties(folder, contents);
}

bool ServerModel::createStartScript(const QString &folder, const QString &minimumMemory,
                                    const QString &maximumMemory,
                                    const QString &javaExecutable)
{
    static const QRegularExpression memoryPattern(QStringLiteral(R"(^\d+[kKmMgGtT]?$)"));
    static const QRegularExpression javaPattern(QStringLiteral(R"(^[^"\r\n]+$)"));
    if (!memoryPattern.match(minimumMemory.trimmed()).hasMatch() ||
        !memoryPattern.match(maximumMemory.trimmed()).hasMatch() ||
        !javaPattern.match(javaExecutable.trimmed()).hasMatch())
        return false;

    bool minOk = false;
    bool maxOk = false;
    const qint64 minimumBytes = memoryToBytes(minimumMemory, &minOk);
    const qint64 maximumBytes = memoryToBytes(maximumMemory, &maxOk);
    if (minOk && maxOk && minimumBytes > maximumBytes)
        return false;

    ServerMetadata metadata = readServerMetadata(folder);
    metadata.javaBinary = javaExecutable.trimmed();
    metadata.minimumMemory = minimumMemory.trimmed();
    metadata.maximumMemory = maximumMemory.trimmed();
    if (!writeServerMetadata(folder, metadata))
        return false;

    return writeServerScripts(folder, metadata.javaBinary, minimumMemory.trimmed(),
                              maximumMemory.trimmed());
}

QVariantMap ServerModel::readStartScript(const QString &folder) const
{
    const ServerMetadata metadata = readServerMetadata(folder);
    QVariantMap result;
    result[QStringLiteral("minMemory")] = metadata.minimumMemory;
    result[QStringLiteral("maxMemory")] = metadata.maximumMemory;
    result[QStringLiteral("javaExecutable")] = QStringLiteral("java");
    result[QStringLiteral("exists")] = false;

    if (!metadata.javaBinary.isEmpty())
        result[QStringLiteral("javaExecutable")] = metadata.javaBinary;

    QStringList scriptNames;
#ifdef Q_OS_WIN
    scriptNames = {QStringLiteral("run.bat"), QStringLiteral("run.sh")};
#else
    scriptNames = {QStringLiteral("run.sh"), QStringLiteral("run.bat")};
#endif
    for (const QString &scriptName : scriptNames)
    {
        QFile script(QDir(folder).filePath(scriptName));
        if (!script.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;

        result[QStringLiteral("exists")] = true;
        const QString text = QString::fromUtf8(script.readAll());
        static const QRegularExpression javaRegex(
            QStringLiteral(R"(^\s*(?:exec\s+)?\"?([^\"\r\n]+?)\"?\s+-Xms)"),
            QRegularExpression::MultilineOption);
        static const QRegularExpression xmsRegex(QStringLiteral(R"(-Xms(\d+[kKmMgGtT]?))"));
        static const QRegularExpression xmxRegex(QStringLiteral(R"(-Xmx(\d+[kKmMgGtT]?))"));

        const auto xmsMatch = xmsRegex.match(text);
        if (xmsMatch.hasMatch())
            result[QStringLiteral("minMemory")] = xmsMatch.captured(1);

        const auto xmxMatch = xmxRegex.match(text);
        if (xmxMatch.hasMatch())
            result[QStringLiteral("maxMemory")] = xmxMatch.captured(1);
        const auto javaMatch = javaRegex.match(text);
        if (javaMatch.hasMatch())
            result[QStringLiteral("javaExecutable")] = javaMatch.captured(1);
        break;
    }
    return result;
}
