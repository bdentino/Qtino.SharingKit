#ifndef SMSCONTENT_H
#define SMSCONTENT_H

#include <QQuickItem>

class SmsContent : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(bool attachScreenshot READ attachScreenshot
               WRITE setAttachScreenshot NOTIFY attachScreenshotChanged)

public:
    SmsContent(QQuickItem* parent = 0);

    QString body();
    void setBody(QString body);

    bool attachScreenshot();
    void setAttachScreenshot(bool attach);

signals:
    void bodyChanged();
    void attachScreenshotChanged();

public slots:

private:
    QString m_body;
    bool m_attachScreenshot;
};
#endif // SMSCONTENT_H
