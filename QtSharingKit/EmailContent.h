#ifndef EMAILCONTENT_H
#define EMAILCONTENT_H

#include <QObject>
#include "DefaultContent.h"

class EmailContent : public DefaultContent
{
    Q_OBJECT

    Q_PROPERTY(QString subject READ subject WRITE setSubject NOTIFY subjectChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(bool attachScreenshot READ attachScreenshot WRITE setAttachScreenshot
               NOTIFY attachScreenshotChanged)

public:
    EmailContent(QObject* parent = 0);

    QString subject();
    void setSubject(QString subject);

    QString body();
    void setBody(QString body);

    bool attachScreenshot();
    void setAttachScreenshot(bool attach);

signals:
    void subjectChanged();
    void bodyChanged();
    void attachScreenshotChanged();

public slots:

private:
    QString m_subject;
    QString m_body;
    bool m_attachScreenshot;
};

#endif // EMAILCONTENT_H
