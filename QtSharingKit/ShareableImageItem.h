#ifndef SHAREABLEIMAGEITEM_H
#define SHAREABLEIMAGEITEM_H

#include <QObject>
#include <QUrl>

#include "ShareableItem.h"

class ShareableImageItem : public ShareableItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url NOTIFY urlChanged)

public:
    explicit ShareableImageItem(QObject* parent = 0);

    QUrl url();

signals:
    void urlChanged(QUrl newUrl);

public slots:

protected:
    void setUrl(QUrl url);

private:
    QUrl m_url;
};

Q_DECLARE_METATYPE(ShareableImageItem*)

#endif // SHAREABLEIMAGEITEM_H
