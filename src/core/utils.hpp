#pragma once

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkInterface>
#include <QStringList>
#include <QVariantMap>

class Utils final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool javaInstalled READ javaInstalled CONSTANT)
    Q_PROPERTY(QString serversDirectory READ serversDirectory NOTIFY serversDirectoryChanged)
    Q_PROPERTY(QString localIp READ localIp CONSTANT)
    Q_PROPERTY(QString publicIp READ publicIp NOTIFY publicIpChanged)
    Q_PROPERTY(QStringList themeNames READ themeNames NOTIFY themesChanged)
    Q_PROPERTY(QString selectedTheme READ selectedTheme NOTIFY themeChanged)
    Q_PROPERTY(QVariantMap themePalette READ themePalette NOTIFY themeChanged)

public:
    explicit Utils(QObject *parent = nullptr);

    bool javaInstalled() const;
    QString serversDirectory() const;
    QString localIp() const;
    QString publicIp() const;
    QStringList themeNames() const;
    QString selectedTheme() const;
    QVariantMap themePalette() const;

    Q_INVOKABLE bool saveServersDirectory(const QString &path);
    Q_INVOKABLE QString chooseDirectory(const QString &currentPath);
    Q_INVOKABLE bool copyToClipboard(const QString &text);
    Q_INVOKABLE void refreshPublicIp();
    Q_INVOKABLE QStringList javaExecutables() const;
    Q_INVOKABLE void setTheme(const QString &name);

signals:
    void serversDirectoryChanged();
    void publicIpChanged();
    void themesChanged();
    void themeChanged();

private:
    bool m_javaInstalled;
    QString m_publicIp;
    QNetworkAccessManager m_networkAccessManager;
    QStringList m_themeNames;
    QString m_selectedTheme;
    QVariantMap m_themePalette;
    void loadThemes();
};

bool isJavaInstalled();
bool saveServersDir(const QString &path);
QString getServersDir();
