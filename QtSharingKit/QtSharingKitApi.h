#ifndef QTSHARINGKITAPI_H
#define QTSHARINGKITAPI_H

#include <QQuickItem>

#ifdef QT_BUILD_SHARING_LIB
#define Q_SHARING_EXPORT Q_DECL_EXPORT
#else
#define Q_SHARING_EXPORT Q_DECL_IMPORT
#endif

class FBAppCredentials;
struct QtSharingKitPrivate;

class QtSharingKitApi : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)

public:
    QtSharingKitApi(QQuickItem* parent = 0);
    ~QtSharingKitApi();

    QString title() { return m_title; }
    void setTitle(QString title) {
        if (m_title == title) return;
        m_title = title;
        emit titleChanged();
    }

signals:
    void titleChanged();
    void sharingFinished();

public slots:
    void launchShareActivity();

private:
    QString m_title;
    QtSharingKitPrivate* m_privateData;
};

#endif // QTSHARINGKITAPI_H

