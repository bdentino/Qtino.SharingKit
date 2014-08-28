#include "UrlShortener.h"

UrlShortener::UrlShortener(QQuickItem* parent) :
    QQuickItem(parent),
    m_ready(false)
{
}

bool UrlShortener::ready()
{
    return m_ready;
}

QUrl UrlShortener::shortUrl()
{
    return m_shortUrl;
}

QUrl UrlShortener::longUrl()
{
    return m_longUrl;
}

void UrlShortener::setLongUrl(QUrl url)
{
    m_longUrl = url;
    m_shortUrl = url;
    m_ready = false;
    emit readyChanged();
}

void UrlShortener::onShortUrlReady(QUrl url)
{
    m_ready = true;
    m_shortUrl = url;
    emit readyChanged();
}
