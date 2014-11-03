#ifndef IMAGEITEM_H
#define IMAGEITEM_H

#include <QObject>
#include <QUrl>
#include "ShareableImageItem.h"

class ImageItem : public ShareableImageItem
{
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)

public:
    explicit ImageItem(QObject* parent = 0);

    QUrl source();
    void setSource(QUrl source);

signals:
    void sourceChanged(QUrl newSource);

public slots:

};

#endif // IMAGEITEM_H
