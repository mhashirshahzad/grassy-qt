#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <QVariantMap>
#include <QtGlobal>

class ServerRunner : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString serverName READ serverName NOTIFY serverNameChanged)
    Q_PROPERTY(
        QString serverFolder READ serverFolder WRITE setServerFolder NOTIFY serverFolderChanged)
    Q_PROPERTY(QString consoleText READ consoleText NOTIFY consoleTextChanged)
    Q_PROPERTY(QString consoleHtml READ consoleHtml NOTIFY consoleHtmlChanged)
    Q_PROPERTY(QVariantMap themePalette READ themePalette WRITE setThemePalette NOTIFY themePaletteChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY usageChanged)
    Q_PROPERTY(qint64 memoryUsageKb READ memoryUsageKb NOTIFY usageChanged)
    Q_PROPERTY(qint64 memoryLimitKb READ memoryLimitKb NOTIFY limitsChanged)
    Q_PROPERTY(int port READ port NOTIFY portChanged)
    Q_PROPERTY(int cpuCoreCount READ cpuCoreCount CONSTANT)

  public:
    explicit ServerRunner(QObject *parent = nullptr);
    ~ServerRunner() override;

    QString serverName() const;
    QString serverFolder() const;
    QString consoleText() const;
    QString consoleHtml() const;
    QVariantMap themePalette() const;
    bool running() const;
    double cpuUsage() const;
    qint64 memoryUsageKb() const;
    qint64 memoryLimitKb() const;
    int port() const;
    int cpuCoreCount() const;

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void shutdown();
    Q_INVOKABLE void interrupt();
    Q_INVOKABLE void sendCommand(const QString &command);
    Q_INVOKABLE QString address() const;

  signals:
    void serverFolderChanged();
    void serverNameChanged();
    void consoleTextChanged();
    void consoleHtmlChanged();
    void runningChanged();
    void usageChanged();
    void limitsChanged();
    void portChanged();
    void outputReceived(const QString &text);
    void themePaletteChanged();

  private slots:
    void readOutput();
    void processFinished(int exitCode, QProcess::ExitStatus status);
    void processError(QProcess::ProcessError error);
    void updateUsage();

  private:
    void setServerFolder(const QString &serverFolder);
    void setThemePalette(const QVariantMap &themePalette);
    void updatePort();
    void appendConsole(const QString &text);
    void appendConsoleHtml(const QString &text);

    QString m_serverFolder;
    QString m_serverName;
    QString m_consoleText;
    QString m_consoleHtml;
    QString m_sessionHeader;
    QVariantMap m_themePalette;

    QProcess *m_process = nullptr;
    QTimer m_usageTimer;
    double m_cpuUsage = 0.0;
    qint64 m_memoryUsageKb = 0;
    qint64 m_memoryLimitKb = 4 * 1024 * 1024;
    int m_port = 0;
    quint64 m_previousProcessTicks = 0;
    quint64 m_previousSystemTicks = 0;
};
