#ifndef FBAPPCREDENTIALS_H
#define FBAPPCREDENTIALS_H

#include <QObject>

class FBAppCredentials : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString appName READ appName WRITE setAppName NOTIFY appNameChanged)
    Q_PROPERTY(QString appID READ appID WRITE setAppID NOTIFY appIDChanged)

public:
    FBAppCredentials(QObject* parent = 0);
    FBAppCredentials(QString appName, QString appID, QObject* parent = 0);

    QString appName();
    void setAppName(QString appName);

    QString appID();
    void setAppID(QString appID);

signals:
    void appNameChanged();
    void appIDChanged();

public slots:

private:
    QString m_appName;
    QString m_appID;
};

Q_DECLARE_METATYPE(FBAppCredentials*)

#endif // FBAPPCREDENTIALS_H
