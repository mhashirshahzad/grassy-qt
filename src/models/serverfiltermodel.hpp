#pragma once

#include "qabstractitemmodel.h"
#include "qobject.h"
#include "qsortfilterproxymodel.h"
#include "qtmetamacros.h"
#include <QSortFilterProxyModel>

class ServerFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

  public:
    explicit ServerFilterModel(QObject *parent = nullptr);
    Q_INVOKABLE void setSearchText(const QString &text);

  private:
    QString m_searchText;
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
};
