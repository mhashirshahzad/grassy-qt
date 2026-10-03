#include "servermetadata.hpp"

#include <QDir>
#include <QSettings>

namespace
{
QString metadataPath(const QString &folder)
{
    return QDir(folder).filePath(QStringLiteral("grassy-meta.ini"));
}
} // namespace

ServerMetadata readServerMetadata(const QString &serverFolder)
{
    ServerMetadata metadata;
    QSettings settings(metadataPath(serverFolder), QSettings::IniFormat);
    metadata.type = settings.value(QStringLiteral("server/type"), metadata.type).toString();
    metadata.minecraftVersion =
        settings.value(QStringLiteral("server/minecraft_version")).toString();
    metadata.loaderVersion = settings.value(QStringLiteral("server/loader_version")).toString();
    metadata.installerVersion =
        settings.value(QStringLiteral("server/installer_version")).toString();
    metadata.installed = settings.value(QStringLiteral("state/installed"), metadata.installed)
                             .toBool();
    metadata.installedAt = settings.value(QStringLiteral("state/installed_at")).toString();
    metadata.argsFile = settings.value(QStringLiteral("launch/args_file")).toString();
    metadata.jar = settings.value(QStringLiteral("launch/jar"), metadata.jar).toString();
    metadata.javaBinary =
        settings.value(QStringLiteral("launch/java_binary"), metadata.javaBinary).toString();
    metadata.minimumMemory =
        settings.value(QStringLiteral("launch/minimum_memory"), metadata.minimumMemory).toString();
    metadata.maximumMemory =
        settings.value(QStringLiteral("launch/maximum_memory"), metadata.maximumMemory).toString();
    return metadata;
}

bool writeServerMetadata(const QString &serverFolder, const ServerMetadata &metadata)
{
    QSettings settings(metadataPath(serverFolder), QSettings::IniFormat);
    settings.setValue(QStringLiteral("server/type"), metadata.type);
    settings.setValue(QStringLiteral("server/minecraft_version"), metadata.minecraftVersion);
    settings.setValue(QStringLiteral("server/loader_version"), metadata.loaderVersion);
    settings.setValue(QStringLiteral("server/installer_version"), metadata.installerVersion);
    settings.setValue(QStringLiteral("state/installed"), metadata.installed);
    settings.setValue(QStringLiteral("state/installed_at"), metadata.installedAt);
    settings.setValue(QStringLiteral("launch/args_file"), metadata.argsFile);
    settings.setValue(QStringLiteral("launch/jar"), metadata.jar);
    settings.setValue(QStringLiteral("launch/java_binary"), metadata.javaBinary);
    settings.setValue(QStringLiteral("launch/minimum_memory"), metadata.minimumMemory);
    settings.setValue(QStringLiteral("launch/maximum_memory"), metadata.maximumMemory);
    settings.sync();
    return settings.status() == QSettings::NoError;
}
