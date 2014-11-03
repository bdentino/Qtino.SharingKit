#ifndef OPENGRAPHACTION_H
#define OPENGRAPHACTION_H

#include <QObject>
#include <QQmlListProperty>

#include "GraphObjectProperty.h"
class OpenGraphAction : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString type READ type WRITE setType NOTIFY actionChanged)
    Q_PROPERTY(QVariantMap additionalProperties READ additionalProperties WRITE setAdditionalProperties NOTIFY actionChanged)
    Q_PROPERTY(QStringList publishProperties READ publishProperties WRITE setPublishProperties NOTIFY publishPropertiesChanged)

public:
    OpenGraphAction(QObject* parent = 0);

    QString type();
    void setType(QString type);

    QVariantMap additionalProperties();
    void setAdditionalProperties(QVariantMap data);

    QStringList publishProperties();
    void setPublishProperties(QStringList properties);

signals:
    void actionChanged(OpenGraphAction* action);
    void publishPropertiesChanged();

public slots:

private:
    QString m_type;
    QVariantMap m_additional;
    QStringList m_publishProperties;
};

#endif // OPENGRAPHACTION_H
