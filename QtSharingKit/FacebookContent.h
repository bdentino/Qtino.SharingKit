#ifndef FACEBOOKCONTENT_H
#define FACEBOOKCONTENT_H

#include <QObject>
#include <QUrl>
#include "FBAppCredentials.h"
#include "DefaultContent.h"

class FacebookContent : public DefaultContent
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QUrl link READ link WRITE setLink NOTIFY linkChanged)
    Q_PROPERTY(bool attachScreenshot READ attachScreenshot
               WRITE setAttachScreenshot NOTIFY attachScreenshotChanged)
    Q_PROPERTY(FBAppCredentials* appCredentials READ appCredentials
               WRITE setAppCredentials NOTIFY appCredentialsChanged)

public:
    FacebookContent(QObject* parent = 0);

    QString text();
    void setText(QString text);

    QUrl link();
    void setLink(QUrl link);

    bool attachScreenshot();
    void setAttachScreenshot(bool attach);

    FBAppCredentials* appCredentials();
    void setAppCredentials(FBAppCredentials* credentials);

signals:
    void textChanged();
    void linkChanged();
    void attachScreenshotChanged();
    void appCredentialsChanged();

public slots:

private:
    QString m_text;
    QUrl m_link;
    bool m_attachScreenshot;
    FBAppCredentials* m_fbCredentials;
};

#endif // FACEBOOKCONTENT_H
