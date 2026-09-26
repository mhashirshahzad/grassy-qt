#include "serverfiltermodel.hpp"
#include "qabstractitemmodel.h"
#include "qhashfunctions.h"
#include "qnamespace.h"
#include "qobject.h"
#include "qsortfilterproxymodel.h"
#include "servermodel.hpp"

ServerFilterModel::ServerFilterModel(QObject *parent) : QSortFilterProxyModel(parent) {}

void ServerFilterModel::refresh()
{
    auto *model = qobject_cast<ServerModel *>(sourceModel());
    if (model)
        model->refresh();
}

void ServerFilterModel::setSearchText(const QString &text)
{
    m_searchText = text;
    invalidate();
}

bool ServerFilterModel::renameServer(const QString &folder, const QString &name)
{
    auto *model = qobject_cast<ServerModel *>(sourceModel());
    return model && model->renameServer(folder, name);
}

bool ServerFilterModel::deleteServer(const QString &folder)
{
    auto *model = qobject_cast<ServerModel *>(sourceModel());
    return model && model->deleteServer(folder);
}

QString ServerFilterModel::serverProperties(const QString &folder) const
{
    auto *model = qobject_cast<ServerModel *>(sourceModel());
    return model ? model->serverProperties(folder) : QString();
}

bool ServerFilterModel::saveServerProperties(const QString &folder, const QString &contents)
{
    auto *model = qobject_cast<ServerModel *>(sourceModel());
    return model && model->saveServerProperties(folder, contents);
}

bool ServerFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_searchText.isEmpty())
        return true;

    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    const QString name = sourceModel()->data(index, ServerModel::NameRole).toString();
    const QString motd = sourceModel()->data(index, ServerModel::MotdRole).toString();

    return name.contains(m_searchText, Qt::CaseInsensitive) ||
           motd.contains(m_searchText, Qt::CaseInsensitive);
}
