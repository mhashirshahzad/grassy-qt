#pragma once

#include <QObject>
#include <QString>

class Utils final : public QObject
{
    Q_OBJECT

public:
    explicit Utils(QObject *parent = nullptr);

    Q_INVOKABLE bool isJavaInstalled() const;
};

bool isJavaInstalled();
bool saveServersDir(const QString &path);
QString getServersDir();
