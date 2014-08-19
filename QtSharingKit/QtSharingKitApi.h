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

public:
    QtSharingKitApi(QQuickItem* parent = 0);
    ~QtSharingKitApi();

    FBAppCredentials* facebookAppCredentials();
    void setFacebookAppCredentials(FBAppCredentials* credentials);

signals:
    void facebookAppCredentialsChanged();

public slots:
    void openShareSheetForContent(QString title, QString blurb, QString text);

private:
    FBAppCredentials* m_fbCredentials;
    QtSharingKitPrivate* m_privateData;
};

#endif // QTSHARINGKITAPI_H

