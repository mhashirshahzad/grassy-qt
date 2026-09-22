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
