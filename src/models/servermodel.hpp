#pragma once

#include <QAbstractListModel>
#include <QString>
#include <QList>

class ServerModel : public QAbstractListModel
{
    Q_OBJECT

  public:
    enum Roles
    {
        NameRole = Qt::UserRole + 1,
        MotdRole,
        FolderRole
    };

    explicit ServerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool renameServer(const QString &folder, const QString &name);
    Q_INVOKABLE bool deleteServer(const QString &folder);
    Q_INVOKABLE QString serverProperties(const QString &folder) const;
    Q_INVOKABLE bool saveServerProperties(const QString &folder, const QString &contents);
    Q_INVOKABLE bool setServerProperty(const QString &folder, const QString &key,
                                       const QString &value);
    QVariant data(const QModelIndex &index, int role) const override;

    QHash<int, QByteArray> roleNames() const override;

  private:
    struct Server
    {
        QString name;
        QString motd;
        QString folder;
    };

    QList<Server> m_servers;
};
