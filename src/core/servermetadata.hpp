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
};

ServerMetadata readServerMetadata(const QString &serverFolder);
bool writeServerMetadata(const QString &serverFolder, const ServerMetadata &metadata);
