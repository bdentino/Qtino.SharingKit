#ifndef MICROBLOGCONTENT_H
#define MICROBLOGCONTENT_H

#include <QQuickItem>

class MicroblogContent : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(bool attachScreenshot READ attachScreenshot
               WRITE setAttachScreenshot NOTIFY attachScreenshotChanged)

public:
    MicroblogContent(QQuickItem* parent = 0);

    QString text();
    void setText(QString text);

    bool attachScreenshot();
    void setAttachScreenshot(bool attach);

signals:
    void textChanged();
    void attachScreenshotChanged();

public slots:

private:
    QString m_text;
    bool m_attachScreenshot;
};

#endif // MICROBLOGCONTENT_H
