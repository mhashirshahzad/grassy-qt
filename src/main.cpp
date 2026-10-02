#include <QApplication>
#include <QDebug>
#include <QKeyEvent>
#include <QTimer>
#include <functional>
#include <utility>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>
#include <QtQml/qqml.h>

#include "models/serverfiltermodel.hpp"
#include "models/servermodel.hpp"
#include "runner/serverrunner.hpp"
#include "core/utils.hpp"

namespace
{
class QmlReloadFilter final : public QObject
{
  public:
    explicit QmlReloadFilter(std::function<void()> reload, QObject *parent = nullptr)
        : QObject(parent), m_reload(std::move(reload))
    {
    }

  protected:
    bool eventFilter(QObject *watched, QEvent *event) override
    {
        Q_UNUSED(watched);
        if (event->type() == QEvent::KeyPress)
        {
            auto *keyEvent = static_cast<QKeyEvent *>(event);
            if (keyEvent->key() == Qt::Key_R &&
                keyEvent->modifiers() == (Qt::ControlModifier | Qt::ShiftModifier))
            {
                m_reload();
                return true;
            }
        }
        return false;
    }

  private:
    std::function<void()> m_reload;
};
} // namespace

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

#ifdef QT_QML_DEBUG
    auto *reloadFilter = new QmlReloadFilter(
        [&engine] {
            const QList<QObject *> roots = engine.rootObjects();
            for (QObject *root : roots)
                root->deleteLater();

            engine.clearComponentCache();
            QTimer::singleShot(0, &engine, [&engine] {
                engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
            });
        },
        &app);
    app.installEventFilter(reloadFilter);
#endif

    return app.exec();
}
