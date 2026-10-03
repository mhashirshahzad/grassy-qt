#include "serverdownloader.hpp"

#include "../core/utils.hpp"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QProcess>
#include <QRegularExpression>
#include <QXmlStreamReader>
#include <QUrlQuery>

#include <algorithm>

/*
 * Server download URLs and version discovery:
 *
 * - Minecraft versions come from Mojang's version_manifest_v2.json. The selected
 *   version entry points to a second JSON document, whose downloads.server.url
 *   contains the official server JAR URL.
 * - Fabric versions are discovered from Fabric's loader API. Its server URL is
 *   constructed as:
 *   https://meta.fabricmc.net/v2/versions/loader/{MC}/{LOADER}/{INSTALLER}/server/jar
 * - Forge publishes one Maven metadata XML document. We read its <versions>
 *   entries, keep only versions beginning with "{MC_VERSION}-", and strip that
 *   prefix for display. The selected Forge version is then combined with the
 *   Minecraft version as:
 *   https://maven.minecraftforge.net/net/minecraftforge/forge/
 *   {MC_VERSION}-{FORGE_VERSION}/forge-{MC_VERSION}-{FORGE_VERSION}-installer.jar
 *   The downloaded Forge installer is executed with "java -jar ... --installServer"
 *   in the destination folder, because the installer must generate the actual
 *   server files before the folder can be started.
 */

ServerDownloader::ServerDownloader(QObject *parent) : QObject(parent) {}

void ServerDownloader::fetchJson(const QUrl &url,
                                  std::function<void(const QJsonDocument &)> callback)
{
    QNetworkReply *reply = m_network.get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply, callback] {
        if (reply->error() != QNetworkReply::NoError)
        {
            reportError(reply);
            return;
        }
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        reply->deleteLater();
        callback(document);
    });
}

void ServerDownloader::refresh()
{
    fetchJson(QUrl(QStringLiteral("https://piston-meta.mojang.com/mc/game/version_manifest_v2.json")),
              [this](const QJsonDocument &document) {
                  QStringList versions;
                  for (const QJsonValue &value : document.object()[QStringLiteral("versions")].toArray())
                  {
                      const QJsonObject version = value.toObject();
                      if (version[QStringLiteral("type")].toString() == QStringLiteral("release"))
                          versions.append(version[QStringLiteral("id")].toString());
                  }
                  m_minecraftVersions = versions;
                  emit minecraftVersionsChanged(versions);
              });

    fetchInstallerVersions();
}

void ServerDownloader::refreshLoaders(const QString &minecraftVersion)
{
    fetchFabricLoaders(minecraftVersion);
}

void ServerDownloader::refreshForgeVersions(const QString &minecraftVersion)
{
    fetchForgeVersions(minecraftVersion);
}

void ServerDownloader::fetchForgeVersions(const QString &minecraftVersion)
{
    QNetworkReply *reply = m_network.get(QNetworkRequest(QUrl(QStringLiteral(
        "https://maven.minecraftforge.net/releases/net/minecraftforge/forge/maven-metadata.xml"))));
    connect(reply, &QNetworkReply::finished, this, [this, reply, minecraftVersion] {
        if (reply->error() != QNetworkReply::NoError)
        {
            reportError(reply);
            return;
        }

        const QByteArray data = reply->readAll();
        reply->deleteLater();
        QXmlStreamReader xml(data);
        const QString prefix = minecraftVersion + QLatin1Char('-');
        QStringList versions;
        while (!xml.atEnd())
        {
            xml.readNext();
            if (!xml.isCharacters() || xml.isWhitespace())
                continue;
            const QString fullVersion = xml.text().toString();
            if (fullVersion.startsWith(prefix))
                versions.append(fullVersion.mid(prefix.size()));
        }
        if (xml.hasError())
        {
            emit failed(QStringLiteral("Could not read Forge version metadata."));
            return;
        }
        versions.removeDuplicates();
        std::sort(versions.begin(), versions.end(), std::greater<QString>());
        emit forgeVersionsChanged(versions);
    });
}

void ServerDownloader::fetchInstallerVersions()
{
    QNetworkReply *reply =
        m_network.get(QNetworkRequest(QUrl(QStringLiteral(
            "https://maven.fabricmc.net/net/fabricmc/fabric-installer/"))));
    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        if (reply->error() != QNetworkReply::NoError)
        {
            reportError(reply);
            return;
        }
        const QString html = QString::fromUtf8(reply->readAll());
        reply->deleteLater();
        QStringList versions;
        static const QRegularExpression pattern(QStringLiteral(R"(href="([0-9]+\.[0-9]+\.[0-9]+)/")"));
        auto matches = pattern.globalMatch(html);
        while (matches.hasNext())
            versions.append(matches.next().captured(1));
        versions.removeDuplicates();
        emit installerVersionsChanged(versions);
    });
}

void ServerDownloader::fetchFabricLoaders(const QString &minecraftVersion)
{
    fetchJson(QUrl(QStringLiteral("https://meta.fabricmc.net/v2/versions/loader/%1")
                      .arg(minecraftVersion)),
              [this](const QJsonDocument &document) {
                  QStringList versions;
                  for (const QJsonValue &value : document.array())
                  {
                      const QString version =
                          value.toObject()[QStringLiteral("loader")].toObject()
                              [QStringLiteral("version")]
                                  .toString();
                      if (!version.isEmpty())
                          versions.append(version);
                  }
                  versions.removeDuplicates();
                  emit loaderVersionsChanged(versions);
              });
}

void ServerDownloader::fetchMinecraftServer(const QString &version)
{
    fetchJson(QUrl(QStringLiteral("https://piston-meta.mojang.com/mc/game/version_manifest_v2.json")),
              [this, version](const QJsonDocument &document) {
                  for (const QJsonValue &value :
                       document.object()[QStringLiteral("versions")].toArray())
                  {
                      const QJsonObject item = value.toObject();
                      if (item[QStringLiteral("id")].toString() != version)
                          continue;
                      fetchJson(QUrl(item[QStringLiteral("url")].toString()),
                                [this, version](const QJsonDocument &metadata) {
                                    const QString url =
                                        metadata.object()[QStringLiteral("downloads")].toObject()
                                            [QStringLiteral("server")].toObject()
                                                [QStringLiteral("url")]
                                                    .toString();
                                    downloadJar(QUrl(url), version);
                                });
                      return;
                  }
                  emit failed(QStringLiteral("Minecraft version was not found."));
              });
}

void ServerDownloader::download(const QString &kind, const QString &minecraftVersion,
                                const QString &loaderVersion, const QString &installerVersion)
{
    if (minecraftVersion.isEmpty())
    {
        emit failed(QStringLiteral("Select a Minecraft version."));
        return;
    }
    if (kind == QStringLiteral("Minecraft"))
    {
        fetchMinecraftServer(minecraftVersion);
        return;
    }
    if (kind == QStringLiteral("Fabric") && !loaderVersion.isEmpty() &&
        !installerVersion.isEmpty())
    {
        const QUrl url(QStringLiteral(
                           "https://meta.fabricmc.net/v2/versions/loader/%1/%2/%3/server/jar")
                           .arg(minecraftVersion, loaderVersion, installerVersion));
        downloadJar(url, QStringLiteral("fabric_%1").arg(minecraftVersion));
        return;
    }
    if (kind == QStringLiteral("Forge") && !loaderVersion.isEmpty())
    {
        const QString fullVersion = minecraftVersion + QLatin1Char('-') + loaderVersion;
        const QUrl url(QStringLiteral(
                           "https://maven.minecraftforge.net/net/minecraftforge/forge/%1/"
                           "forge-%1-installer.jar")
                           .arg(fullVersion));
        downloadForgeInstaller(url, QStringLiteral("forge_%1").arg(minecraftVersion));
        return;
    }
    emit failed(kind == QStringLiteral("Forge")
                    ? QStringLiteral("Select a Forge version.")
                    : QStringLiteral("Select a Fabric loader version."));
}

void ServerDownloader::downloadForgeInstaller(const QUrl &url, const QString &folderName)
{
    if (!url.isValid())
    {
        emit failed(QStringLiteral("The Forge download URL is invalid."));
        return;
    }
    const QString folder = QDir(getServersDir()).filePath(folderName);
    if (!QDir().mkpath(folder))
    {
        emit failed(QStringLiteral("Could not create the server folder."));
        return;
    }

    QNetworkReply *reply = m_network.get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::downloadProgress, this,
            [this](qint64 received, qint64 total) {
                emit progressChanged(total > 0 ? static_cast<double>(received) / total : 0);
            });
    connect(reply, &QNetworkReply::finished, this, [this, reply, folder, folderName] {
        if (reply->error() != QNetworkReply::NoError)
        {
            reportError(reply);
            return;
        }

        const QString installerPath = QDir(folder).filePath(QStringLiteral("forge-installer.jar"));
        QFile installer(installerPath);
        if (!installer.open(QIODevice::WriteOnly) || installer.write(reply->readAll()) < 0)
        {
            emit failed(QStringLiteral("Could not write the Forge installer."));
            reply->deleteLater();
            return;
        }
        installer.close();
        reply->deleteLater();

        auto *process = new QProcess(this);
        process->setWorkingDirectory(folder);
        connect(process, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
                [this, process, installerPath, folderName](int exitCode,
                                                            QProcess::ExitStatus status) {
                    QFile::remove(installerPath);
                    const bool success = status == QProcess::NormalExit && exitCode == 0;
                    if (!success)
                    {
                        emit failed(QStringLiteral("Forge installation failed: %1")
                                        .arg(process->readAllStandardError().trimmed()));
                    }
                    else
                    {
                        emit progressChanged(1);
                        emit completed(folderName);
                    }
                    process->deleteLater();
                });
        process->start(QStringLiteral("java"),
                       {QStringLiteral("-jar"), QStringLiteral("forge-installer.jar"),
                        QStringLiteral("--installServer")});
        if (!process->waitForStarted(5000))
        {
            QFile::remove(installerPath);
            emit failed(QStringLiteral("Could not start Java for Forge installation."));
            process->deleteLater();
        }
    });
}

void ServerDownloader::downloadJar(const QUrl &url, const QString &folderName)
{
    if (!url.isValid())
    {
        emit failed(QStringLiteral("The server download URL is invalid."));
        return;
    }
    const QString folder = QDir(getServersDir()).filePath(folderName);
    if (!QDir().mkpath(folder))
    {
        emit failed(QStringLiteral("Could not create the server folder."));
        return;
    }

    QNetworkReply *reply = m_network.get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::downloadProgress, this,
            [this](qint64 received, qint64 total) {
                emit progressChanged(total > 0 ? static_cast<double>(received) / total : 0);
            });
    connect(reply, &QNetworkReply::finished, this, [this, reply, folder, folderName] {
        if (reply->error() != QNetworkReply::NoError)
        {
            reportError(reply);
            return;
        }
        QFile file(QDir(folder).filePath(QStringLiteral("server.jar")));
        if (!file.open(QIODevice::WriteOnly) || file.write(reply->readAll()) < 0)
        {
            emit failed(QStringLiteral("Could not write server.jar."));
            reply->deleteLater();
            return;
        }
        file.close();
        reply->deleteLater();
        emit progressChanged(1);
        emit completed(folderName);
    });
}

void ServerDownloader::reportError(QNetworkReply *reply)
{
    emit failed(reply->errorString());
    reply->deleteLater();
}
