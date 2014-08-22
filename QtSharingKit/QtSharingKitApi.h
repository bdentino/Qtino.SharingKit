#ifndef QTSHARINGKITAPI_H
#define QTSHARINGKITAPI_H

#include <QQuickItem>

class FBAppCredentials;
//TODO: Abstract out OS-generic stuff so that we don't have to re-implement it
//      for each backend implementation
struct QtSharingKitPrivate;

class QtSharingKitApi : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(FBAppCredentials* facebookAppCredentials READ facebookAppCredentials
               WRITE setFacebookAppCredentials NOTIFY facebookAppCredentialsChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)

public:
    QtSharingKitApi(QQuickItem* parent = 0);
    ~QtSharingKitApi();

    FBAppCredentials* facebookAppCredentials();
    void setFacebookAppCredentials(FBAppCredentials* credentials);

    QString title() { return m_title; }
    void setTitle(QString title) {
        if (m_title == title) return;
        m_title = title;
        emit titleChanged();
    }

signals:
    void facebookAppCredentialsChanged();
    void titleChanged();

public slots:
    void launchShareActivity();

private:
    FBAppCredentials* m_fbCredentials;
    QString m_title;
    QtSharingKitPrivate* m_privateData;
};

#endif // QTSHARINGKITAPI_H

