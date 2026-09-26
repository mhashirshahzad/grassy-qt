#pragma once

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkInterface>

class Utils final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool javaInstalled READ javaInstalled CONSTANT)
    Q_PROPERTY(QString serversDirectory READ serversDirectory NOTIFY serversDirectoryChanged)
    Q_PROPERTY(QString localIp READ localIp CONSTANT)
    Q_PROPERTY(QString publicIp READ publicIp NOTIFY publicIpChanged)

public:
    explicit Utils(QObject *parent = nullptr);

    bool javaInstalled() const;
    QString serversDirectory() const;
    QString localIp() const;
    QString publicIp() const;

    Q_INVOKABLE bool saveServersDirectory(const QString &path);
    Q_INVOKABLE bool copyToClipboard(const QString &text);
    Q_INVOKABLE void refreshPublicIp();

signals:
    void serversDirectoryChanged();
    void publicIpChanged();

private:
    bool m_javaInstalled;
    QString m_publicIp;
    QNetworkAccessManager m_networkAccessManager;
};

bool isJavaInstalled();
bool saveServersDir(const QString &path);
QString getServersDir();
