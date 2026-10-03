#include "serverscripts.hpp"

#include <QDir>
#include <QFile>

namespace
{
bool writeFile(const QString &path, const QByteArray &contents, bool executable)
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate) ||
        file.write(contents) != contents.size())
        return false;
    file.close();
    return !executable ||
           file.setPermissions(file.permissions() | QFileDevice::ExeOwner |
                               QFileDevice::ExeGroup | QFileDevice::ExeOther);
}
} // namespace

bool writeServerScripts(const QString &serverFolder, const QString &javaExecutable,
                        const QString &minimumMemory, const QString &maximumMemory)
{
    const QByteArray java = javaExecutable.toUtf8();
    const QByteArray xms = minimumMemory.toUtf8();
    const QByteArray xmx = maximumMemory.toUtf8();

    const QByteArray unixScript =
        "#!/bin/sh\n"
        "set -e\n"
        "value() { sed -n \"s/^$1=//p\" grassy-meta.ini | head -n 1; }\n"
        "JAVA=$(value java_binary); JAVA=${JAVA:-" +
        java + "}\n"
        "XMS=$(value minimum_memory); XMS=${XMS:-" +
        xms + "}\n"
        "XMX=$(value maximum_memory); XMX=${XMX:-" +
        xmx + "}\n"
        "TYPE=$(value type)\n"
        "MC_VERSION=$(value minecraft_version)\n"
        "LOADER_VERSION=$(value loader_version)\n"
        "ARGS=$(value args_file)\n"
        "JAR=$(value jar); JAR=${JAR:-server.jar}\n"
        "if [ \"$TYPE\" = \"forge\" ] && ! grep -q '^installed=true' grassy-meta.ini; then\n"
        "  echo Running \"$JAVA\" -jar forge-installer.jar --installServer\n"
        "  \"$JAVA\" -jar forge-installer.jar --installServer\n"
        "  sed -i 's/^installed=.*/installed=true/' grassy-meta.ini\n"
        "  sed -i \"s#^args_file=.*#args_file=libraries/net/minecraftforge/forge/$MC_VERSION-$LOADER_VERSION/unix_args.txt#\" grassy-meta.ini\n"
        "  ARGS=\"libraries/net/minecraftforge/forge/$MC_VERSION-$LOADER_VERSION/unix_args.txt\"\n"
        "fi\n"
        "if [ \"$TYPE\" = \"fabric\" ] && ! grep -q '^installed=true' grassy-meta.ini; then\n"
        "  echo Running \"$JAVA\" -jar fabric-installer.jar server -mcversion \"$MC_VERSION\""
        " -loader \"$LOADER_VERSION\" -downloadMinecraft\n"
        "  \"$JAVA\" -jar fabric-installer.jar server -mcversion \"$MC_VERSION\""
        " -loader \"$LOADER_VERSION\" -downloadMinecraft\n"
        "  sed -i 's/^installed=.*/installed=true/' grassy-meta.ini\n"
        "fi\n"
        "if [ -n \"$ARGS\" ] && [ -f \"$ARGS\" ]; then\n"
        "  echo Running \"$JAVA\" @$ARGS nogui\n"
        "  exec \"$JAVA\" @$ARGS nogui\n"
        "fi\n"
        "echo Running \"$JAVA\" -Xms$XMS -Xmx$XMX -jar \"$JAR\" nogui\n"
        "exec \"$JAVA\" -Xms$XMS -Xmx$XMX -jar \"$JAR\" nogui\n";

    const QByteArray windowsScript =
        "@echo off\r\n"
        "set \"JAVA=" +
        java + "\"\r\n"
        "set \"XMS=" +
        xms + "\"\r\n"
        "set \"XMX=" +
        xmx + "\"\r\n"
        "set \"JAR=server.jar\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"java_binary=\" grassy-meta.ini') do set \"JAVA=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"minimum_memory=\" grassy-meta.ini') do set \"XMS=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"maximum_memory=\" grassy-meta.ini') do set \"XMX=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"type=\" grassy-meta.ini') do set \"TYPE=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"minecraft_version=\" grassy-meta.ini') do set \"MC_VERSION=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"loader_version=\" grassy-meta.ini') do set \"LOADER_VERSION=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"args_file=\" grassy-meta.ini') do set \"ARGS=%%B\"\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"jar=\" grassy-meta.ini') do set \"JAR=%%B\"\r\n"
        "if /I \"%TYPE%\"==\"forge\" findstr /B \"installed=true\" grassy-meta.ini >nul || (\r\n"
        "  echo Running \"%JAVA%\" -jar forge-installer.jar --installServer\r\n"
        "  \"%JAVA%\" -jar forge-installer.jar --installServer\r\n"
        "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^installed=.*','installed=true' | Set-Content grassy-meta.ini\"\r\n"
        "  set \"ARGS=libraries/net/minecraftforge/forge/%MC_VERSION%-%LOADER_VERSION%/unix_args.txt\"\r\n"
        "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^args_file=.*','args_file=libraries/net/minecraftforge/forge/%MC_VERSION%-%LOADER_VERSION%/unix_args.txt' | Set-Content grassy-meta.ini\"\r\n"
        ")\r\n"
        "if /I \"%TYPE%\"==\"fabric\" findstr /B \"installed=true\" grassy-meta.ini >nul || (\r\n"
        "  echo Running \"%JAVA%\" -jar fabric-installer.jar server -mcversion %MC_VERSION% -loader %LOADER_VERSION% -downloadMinecraft\r\n"
        "  \"%JAVA%\" -jar fabric-installer.jar server -mcversion %MC_VERSION% -loader %LOADER_VERSION% -downloadMinecraft\r\n"
        "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^installed=.*','installed=true' | Set-Content grassy-meta.ini\"\r\n"
        ")\r\n"
        "if defined ARGS if exist \"%ARGS%\" (\r\n"
        "  echo Running \"%JAVA%\" @%ARGS% nogui\r\n"
        "  \"%JAVA%\" @%ARGS% nogui\r\n"
        "  exit /b %ERRORLEVEL%\r\n"
        ")\r\n"
        "echo Running \"%JAVA%\" -Xms%XMS% -Xmx%XMX% -jar \"%JAR%\" nogui\r\n"
        "\"%JAVA%\" -Xms%XMS% -Xmx%XMX% -jar \"%JAR%\" nogui\r\n";

    return writeFile(QDir(serverFolder).filePath(QStringLiteral("run.sh")), unixScript, true) &&
           writeFile(QDir(serverFolder).filePath(QStringLiteral("run.bat")), windowsScript, false);
}
