#include "serverfiltermodel.hpp"
#include "qabstractitemmodel.h"
#include "qhashfunctions.h"
#include "qnamespace.h"
#include "qobject.h"
#include "qsortfilterproxymodel.h"
#include "servermodel.hpp"

ServerFilterModel::ServerFilterModel(QObject *parent) : QSortFilterProxyModel(parent) {}

void ServerFilterModel::setSearchText(const QString &text)
{
    m_searchText = text;
    invalidate();
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
