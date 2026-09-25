#include "servermodel.hpp"
#include "../core/logging.hpp"
#include "qdir.h"
#include "qhashfunctions.h"
#include "../core/utils.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>

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

        // TODO: load server.properties

        m_servers.append(server);
    }
    GRASSY_INFO() << "Found" << m_servers.size() << "server(s)";

    endResetModel();
}
