#ifndef TEXTITEM_H
#define TEXTITEM_H

#include <QObject>

#include "ShareableItem.h"

class TextItem : public ShareableItem
{
    Q_OBJECT

    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit TextItem(QObject* parent = 0);

    QString text();
    void setText(QString text);

signals:
    void textChanged();

public slots:

private:
    QString m_text;
};

Q_DECLARE_METATYPE(TextItem*)

#endif // TEXTITEM_H
