#ifndef OPENGRAPHOBJECT_H
#define OPENGRAPHOBJECT_H

#include <QObject>
#include <QQmlListProperty>
#include <QUrl>

#include "GraphObjectProperty.h"
#include "ShareableImageItem.h"

class OpenGraphObject : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString type READ type WRITE setType NOTIFY objectChanged)
    Q_PROPERTY(QVariantMap additionalProperties READ additionalProperties WRITE setAdditionalProperties NOTIFY objectChanged)

    Q_CLASSINFO("DefaultProperty", "properties")

public:
    OpenGraphObject(QObject* parent = 0);

    QString type();
    void setType(QString type);

    QVariantMap additionalProperties();
    void setAdditionalProperties(QVariantMap data);

signals:
    void objectChanged(OpenGraphObject* object);

public slots:

private:
    QString m_type;
    QVariantMap m_additional;
};

#endif // OPENGRAPHOBJECT_H
