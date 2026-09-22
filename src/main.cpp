#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "qqml.h"
#include "servermodel.hpp"
#include "utils.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // so that later we can get ~/.config/grassy/settings.txt via qt's buitlin ways :3
    app.setOrganizationName("grassy");
    app.setApplicationName("grassy");

    QQmlApplicationEngine engine;

    Utils utils;
    ServerModel serverModel;

    engine.rootContext()->setContextProperty(QStringLiteral("utils"), &utils);
    engine.rootContext()->setContextProperty(QStringLiteral("serverModel"), &serverModel);
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
