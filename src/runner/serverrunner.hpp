#pragma once

#include <QObject>
#include <QProcess>
#include <QTimer>

class ServerRunner : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString serverName READ serverName NOTIFY serverNameChanged)
    Q_PROPERTY(QString serverFolder READ serverFolder WRITE setServerFolder NOTIFY serverFolderChanged)
    Q_PROPERTY(QString consoleText READ consoleText NOTIFY consoleTextChanged)
    Q_PROPERTY(QString consoleHtml READ consoleHtml NOTIFY consoleHtmlChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY usageChanged)
    Q_PROPERTY(qint64 memoryUsageKb READ memoryUsageKb NOTIFY usageChanged)

  public:
    explicit ServerRunner(QObject *parent = nullptr);
    ~ServerRunner() override;

    QString serverName() const;
    QString serverFolder() const;
    QString consoleText() const;
    QString consoleHtml() const;
    bool running() const;
    double cpuUsage() const;
    qint64 memoryUsageKb() const;

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void shutdown();
    Q_INVOKABLE void interrupt();
    Q_INVOKABLE void sendCommand(const QString &command);

  signals:
    void serverFolderChanged();
    void serverNameChanged();
    void consoleTextChanged();
    void consoleHtmlChanged();
    void runningChanged();
    void usageChanged();
    void outputReceived(const QString &text);

  private slots:
    void readOutput();
    void processFinished(int exitCode, QProcess::ExitStatus status);
    void processError(QProcess::ProcessError error);
    void updateUsage();

  private:
    void setServerFolder(const QString &serverFolder);
    void appendConsole(const QString &text);
    void appendConsoleHtml(const QString &text);

    QString m_serverFolder;
    QString m_serverName;
    QString m_consoleText;
    QString m_consoleHtml;
    QString m_sessionHeader;

    QProcess *m_process = nullptr;
    QTimer m_usageTimer;
    double m_cpuUsage = 0.0;
    qint64 m_memoryUsageKb = 0;
    quint64 m_previousProcessTicks = 0;
    quint64 m_previousSystemTicks = 0;
};
