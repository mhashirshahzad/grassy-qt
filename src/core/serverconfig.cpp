#include "serverconfig.hpp"
#include "logging.hpp"

#include <QDir>
#include <QFile>
#include <QTextStream>

namespace
{
QString eulaFilePath(const QString &serverFolder)
{
    return QDir(serverFolder).filePath(QStringLiteral("eula.txt"));
}

bool setEulaValue(QString &contents)
{
    QStringList lines = contents.split('\n');
    bool found = false;

    for (QString &line : lines)
    {
        if (line.trimmed().startsWith('#'))
            continue;

        const qsizetype separator = line.indexOf('=');
        if (separator < 0 || line.left(separator).trimmed() != QStringLiteral("eula"))
            continue;

        line = line.left(separator + 1) + QStringLiteral("true");
        found = true;
        break;
    }

    if (!found)
    {
        if (!contents.isEmpty() && !contents.endsWith('\n'))
            lines.append(QString());
        lines.append(QStringLiteral("eula=true"));
    }

    contents = lines.join('\n');
    return true;
}
} // namespace

bool ensureEulaAccepted(const QString &serverFolder)
{
    const QString path = eulaFilePath(serverFolder);
    QFile file(path);
    QString contents;

    if (file.exists())
    {
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        {
            GRASSY_WARNING() << "Unable to read EULA file:" << path << file.errorString();
            return false;
        }
        contents = QString::fromUtf8(file.readAll());
        file.close();
    }
    else
    {
        contents =
            QStringLiteral("#By changing the setting below to TRUE you are indicating your "
                           "agreement to our EULA (https://aka.ms/MinecraftEULA).\n");
    }

    setEulaValue(contents);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
    {
        GRASSY_WARNING() << "Unable to write EULA file:" << path << file.errorString();
        return false;
    }

    const QByteArray encoded = contents.toUtf8();
    if (file.write(encoded) != encoded.size())
    {
        GRASSY_WARNING() << "Unable to write complete EULA file:" << path
                         << file.errorString();
        return false;
    }

    GRASSY_INFO() << "Accepted Minecraft EULA for:" << serverFolder;
    return true;
}
