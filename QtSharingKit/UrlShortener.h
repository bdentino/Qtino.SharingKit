#ifndef URLSHORTENER_H
#define URLSHORTENER_H

#include <QQuickItem>

class UrlShortener : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QUrl shortUrl READ shortUrl NOTIFY readyChanged)

    Q_PROPERTY(QUrl longUrl READ longUrl WRITE setLongUrl NOTIFY readyChanged)

public:
    explicit UrlShortener(QQuickItem* parent = 0);

    bool ready();
    QUrl shortUrl();
    QUrl longUrl();

    void setLongUrl(QUrl url);

signals:
    void readyChanged();

public slots:

private slots:
    void onShortUrlReady(QUrl url);

private:
    QUrl m_longUrl;
    QUrl m_shortUrl;
    bool m_ready;
};

#endif // URLSHORTENER_H
