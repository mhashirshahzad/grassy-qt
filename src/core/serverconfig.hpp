#pragma once

#include <QString>

bool ensureEulaAccepted(const QString &serverFolder);

QString serverPropertiesPath(const QString &serverFolder);
QString readServerProperty(const QString &serverFolder, const QString &key);
int serverPort(const QString &serverFolder, int fallback = 25565);
