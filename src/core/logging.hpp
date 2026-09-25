#pragma once

#include <QDebug>
#include <QMessageLogger>
#include <QString>

#include <cstring>

namespace grassy::logging
{
inline const char *fileName(const char *path)
{
    const char *slash = std::strrchr(path, '/');
    const char *backslash = std::strrchr(path, '\\');
    const char *separator = slash > backslash ? slash : backslash;
    return separator == nullptr ? path : separator + 1;
}

inline QDebug info(const char *file, int line, const char *function)
{
    return QMessageLogger(file, line, function).info().noquote()
           << QStringLiteral("\033[36m[%1:%2]\033[0m")
                  .arg(QString::fromLocal8Bit(fileName(file)))
                  .arg(line);
}

inline QDebug warning(const char *file, int line, const char *function)
{
    return QMessageLogger(file, line, function).warning().noquote()
           << QStringLiteral("\033[33m[%1:%2]\033[0m")
                  .arg(QString::fromLocal8Bit(fileName(file)))
                  .arg(line);
}
} // namespace grassy::logging

#define GRASSY_INFO() ::grassy::logging::info(__FILE__, __LINE__, Q_FUNC_INFO)
#define GRASSY_WARNING() ::grassy::logging::warning(__FILE__, __LINE__, Q_FUNC_INFO)
