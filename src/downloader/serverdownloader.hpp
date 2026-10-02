#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QStringList>
#include <QUrl>
#include <functional>

class QJsonDocument;

class QNetworkReply;

class ServerDownloader : public QObject
{
    Q_OBJECT

  public:
    explicit ServerDownloader(QObject *parent = nullptr);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshLoaders(const QString &minecraftVersion);
    Q_INVOKABLE void download(const QString &kind, const QString &minecraftVersion,
                              const QString &loaderVersion = {},
                              const QString &installerVersion = {});

  signals:
    void minecraftVersionsChanged(const QStringList &versions);
    void loaderVersionsChanged(const QStringList &versions);
    void installerVersionsChanged(const QStringList &versions);
    void progressChanged(double progress);
    void completed(const QString &folderName);
    void failed(const QString &message);

  private:
    void fetchJson(const QUrl &url, std::function<void(const QJsonDocument &)> callback);
    void fetchFabricLoaders(const QString &minecraftVersion);
    void fetchInstallerVersions();
    void fetchMinecraftServer(const QString &version);
    void downloadJar(const QUrl &url, const QString &folderName);
    void reportError(QNetworkReply *reply);

    QNetworkAccessManager m_network;
    QStringList m_minecraftVersions;
    QStringList m_loaderVersions;
    QStringList m_installerVersions;
};
