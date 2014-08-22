#ifndef FACEBOOKCONTENT_H
#define FACEBOOKCONTENT_H

#include <QQuickItem>

class FacebookContent : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QUrl link READ link WRITE setLink NOTIFY linkChanged)
    Q_PROPERTY(bool attachScreenshot READ attachScreenshot
               WRITE setAttachScreenshot NOTIFY attachScreenshotChanged)

public:
    FacebookContent(QQuickItem* parent = 0);

    QString text();
    void setText(QString text);

    QUrl link();
    void setLink(QUrl link);

    bool attachScreenshot();
    void setAttachScreenshot(bool attach);

signals:
    void textChanged();
    void linkChanged();
    void attachScreenshotChanged();

public slots:

private:
    QString m_text;
    QUrl m_link;
    bool m_attachScreenshot;
};

#endif // FACEBOOKCONTENT_H
