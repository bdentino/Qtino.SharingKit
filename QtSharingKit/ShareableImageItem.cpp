#include "ShareableImageItem.h"

ShareableImageItem::ShareableImageItem(QObject* parent)
    : ShareableItem(parent)
{

}

QUrl ShareableImageItem::url()
{
    return m_url;
}

void ShareableImageItem::setUrl(QUrl url)
{
    if (m_url == url) return;
    m_url = url;
    emit urlChanged(url);
}
