#ifndef SHAREABLEITEM_H
#define SHAREABLEITEM_H

#include <QObject>

class ShareableItem : public QObject
{
    Q_OBJECT

public:
    explicit ShareableItem(QObject* parent = 0);

signals:

public slots:

};

Q_DECLARE_METATYPE(ShareableItem*)

#endif // SHAREABLEITEM_H
