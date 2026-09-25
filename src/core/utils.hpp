#pragma once

#include <QObject>
#include <QString>

class Utils final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool javaInstalled READ javaInstalled CONSTANT)

public:
    explicit Utils(QObject *parent = nullptr);

    bool javaInstalled() const;

private:
    bool m_javaInstalled;
};

bool isJavaInstalled();
bool saveServersDir(const QString &path);
QString getServersDir();
