#include <QApplication>
#include <QDebug>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QtQml/qqml.h>

#include "models/serverfiltermodel.hpp"
#include "models/servermodel.hpp"
#include "runner/serverrunner.hpp"
#include "core/utils.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    // so that later we can get ~/.config/grassy/settings.txt via qt's buitlin ways :3
    app.setOrganizationName("grassy");
    app.setApplicationName("grassy");

    QQmlApplicationEngine engine;
    QList<QQmlError> loadErrors;
    Utils utils;
    utils.refreshPublicIp();
    ServerModel serverModel;
    ServerFilterModel filteredServerModel;
    filteredServerModel.setSourceModel(&serverModel);

    engine.rootContext()->setContextProperty(QStringLiteral("utils"), &utils);
    engine.rootContext()->setContextProperty(QStringLiteral("serverModel"), &filteredServerModel);
    qmlRegisterType<ServerRunner>("Grassy", 1, 0, "ServerRunner");
    QObject::connect(
        &engine, &QQmlApplicationEngine::warnings,
        [&loadErrors](const QList<QQmlError> &warnings) {
            loadErrors.append(warnings);
            for (const QQmlError &warning : warnings)
                qWarning().noquote() << warning.toString();
        });
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        [](QObject *object, const QUrl &url) {
            if (!object)
                qWarning() << "Failed to create QML object:" << url;
        });
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "QML root object was not created";
        for (const QQmlError &error : loadErrors)
            qCritical().noquote() << error.toString();
        return -1;
    }

    return app.exec();
}
