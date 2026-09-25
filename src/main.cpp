#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "models/serverfiltermodel.hpp"
#include "models/servermodel.hpp"
#include "runner/serverrunner.hpp"
#include "core/utils.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // so that later we can get ~/.config/grassy/settings.txt via qt's buitlin ways :3
    app.setOrganizationName("grassy");
    app.setApplicationName("grassy");

    QQmlApplicationEngine engine;

    Utils utils;
    ServerModel serverModel;
    ServerFilterModel filteredServerModel;
    ServerRunner serverRunner;
    filteredServerModel.setSourceModel(&serverModel);

    engine.rootContext()->setContextProperty(QStringLiteral("utils"), &utils);
    engine.rootContext()->setContextProperty(QStringLiteral("serverRunner"), &serverRunner);
    engine.rootContext()->setContextProperty(QStringLiteral("serverModel"), &filteredServerModel);
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
