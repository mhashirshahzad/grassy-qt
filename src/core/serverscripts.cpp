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
        "TYPE=$(sed -n 's/^type=//p' grassy-meta.ini | head -n 1)\n"
        "if [ \"$TYPE\" = \"forge\" ] && ! grep -q '^installed=true' grassy-meta.ini; then\n"
        "  echo Running java -jar forge-installer.jar --installServer\n"
        "  \"" +
        java + "\" -jar forge-installer.jar --installServer\n"
        "  sed -i 's/^installed=.*/installed=true/' grassy-meta.ini\n"
               "  sed -i 's#^args_file=.*#args_file=libraries/net/minecraftforge/forge/'\"$(sed -n 's/^minecraft_version=//p' grassy-meta.ini)\"'-'\"$(sed -n 's/^loader_version=//p' grassy-meta.ini)\"'/unix_args.txt#' grassy-meta.ini\n"
               "fi\n"
               "if [ \"$TYPE\" = \"fabric\" ] && ! grep -q '^installed=true' grassy-meta.ini; then\n"
               "  echo Running " +
        java + " -jar fabric-installer.jar server -mcversion \"$(sed -n 's/^minecraft_version=//p' grassy-meta.ini)\""
               " -loader \"$(sed -n 's/^loader_version=//p' grassy-meta.ini)\" -downloadMinecraft\n"
               "  \"" +
        java + "\" -jar fabric-installer.jar server -mcversion \"$(sed -n 's/^minecraft_version=//p' grassy-meta.ini)\""
               " -loader \"$(sed -n 's/^loader_version=//p' grassy-meta.ini)\" -downloadMinecraft\n"
               "  sed -i 's/^installed=.*/installed=true/' grassy-meta.ini\n"
               "fi\n"
               "ARGS=$(sed -n 's/^args_file=//p' grassy-meta.ini | head -n 1)\n"
               "JAR=$(sed -n 's/^jar=//p' grassy-meta.ini | head -n 1)\n"
               "if [ -n \"$ARGS\" ] && [ -f \"$ARGS\" ]; then echo Running " +
        java + " @$ARGS nogui; exec \"" + java + "\" @$ARGS nogui; fi\n"
               "echo Running " +
        java + " -Xms" + xms + " -Xmx" + xmx + " -jar $JAR nogui\nexec \"" + java +
        "\" -Xms" + xms + " -Xmx" + xmx + " -jar \"$JAR\" nogui\n";

    const QByteArray windowsScript =
        "@echo off\r\n"
        "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"type=\" grassy-meta.ini') do set TYPE=%%B\r\n"
        "if /I \"%TYPE%\"==\"forge\" findstr /B \"installed=true\" grassy-meta.ini >nul || (\r\n"
        "  echo Running java -jar forge-installer.jar --installServer\r\n"
        "  \"" +
        java + "\" -jar forge-installer.jar --installServer\r\n"
        "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^installed=.*','installed=true' | Set-Content grassy-meta.ini\"\r\n"
        "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^args_file=.*','args_file=libraries/net/minecraftforge/forge/' + ((Get-Content grassy-meta.ini | Select-String '^minecraft_version=').ToString().Split('=')[1]) + '-' + ((Get-Content grassy-meta.ini | Select-String '^loader_version=').ToString().Split('=')[1]) + '/unix_args.txt' | Set-Content grassy-meta.ini\"\r\n"
               ")\r\n"
               "if /I \"%TYPE%\"==\"fabric\" findstr /B \"installed=true\" grassy-meta.ini >nul || (\r\n"
               "  echo Running " +
        java + " -jar fabric-installer.jar server -mcversion %MC_VERSION%"
               " -loader %LOADER_VERSION% -downloadMinecraft\r\n"
               "  for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"minecraft_version=\" grassy-meta.ini') do set MC_VERSION=%%B\r\n"
               "  for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"loader_version=\" grassy-meta.ini') do set LOADER_VERSION=%%B\r\n"
               "  \"" +
        java + "\" -jar fabric-installer.jar server -mcversion %MC_VERSION% -loader %LOADER_VERSION% -downloadMinecraft\r\n"
               "  powershell -NoProfile -Command \"(Get-Content grassy-meta.ini) -replace '^installed=.*','installed=true' | Set-Content grassy-meta.ini\"\r\n"
               ")\r\n"
               "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"args_file=\" grassy-meta.ini') do set ARGS=%%B\r\n"
               "for /f \"tokens=1,* delims==\" %%A in ('findstr /B \"jar=\" grassy-meta.ini') do set JAR=%%B\r\n"
               "if defined ARGS if exist \"%ARGS%\" (echo Running " +
        java + " @%ARGS% nogui & \"" + java + "\" @%ARGS% nogui & exit /b %ERRORLEVEL%)\r\n"
               "echo Running " +
        java + " -Xms" + xms + " -Xmx" + xmx + " -jar %JAR% nogui\r\n\"" + java +
        "\" -Xms" + xms + " -Xmx" + xmx + " -jar %JAR% nogui\r\n";

    return writeFile(QDir(serverFolder).filePath(QStringLiteral("run.sh")), unixScript, true) &&
           writeFile(QDir(serverFolder).filePath(QStringLiteral("run.bat")), windowsScript, false);
}
