#pragma once

#include <QString>

struct ServerMetadata
{
    QString type = QStringLiteral("official");
    QString minecraftVersion;
    QString loaderVersion;
    QString installerVersion;
    bool installed = true;
    QString installedAt;
    QString argsFile;
    QString jar = QStringLiteral("server.jar");
    QString javaBinary = QStringLiteral("java");
    QString minimumMemory = QStringLiteral("2G");
    QString maximumMemory = QStringLiteral("4G");
};

ServerMetadata readServerMetadata(const QString &serverFolder);
bool writeServerMetadata(const QString &serverFolder, const ServerMetadata &metadata);
