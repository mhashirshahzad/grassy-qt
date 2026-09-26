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
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void setSearchText(const QString &text);
    Q_INVOKABLE bool renameServer(const QString &folder, const QString &name);
    Q_INVOKABLE bool deleteServer(const QString &folder);
    Q_INVOKABLE QString serverProperties(const QString &folder) const;
    Q_INVOKABLE bool saveServerProperties(const QString &folder, const QString &contents);
    Q_INVOKABLE bool setServerProperty(const QString &folder, const QString &key,
                                       const QString &value);

  private:
    QString m_searchText;
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
};
