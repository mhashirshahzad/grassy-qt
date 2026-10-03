#pragma once

#include <QString>

bool writeServerScripts(const QString &serverFolder, const QString &javaExecutable = QStringLiteral("java"),
                        const QString &minimumMemory = QStringLiteral("2G"),
                        const QString &maximumMemory = QStringLiteral("4G"));
