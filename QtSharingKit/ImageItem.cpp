#include "ImageItem.h"

ImageItem::ImageItem(QObject *parent)
    : ShareableImageItem(parent)
{

}

QUrl ImageItem::source()
{
    return url();
}

void ImageItem::setSource(QUrl url)
{
    setUrl(url);
}
