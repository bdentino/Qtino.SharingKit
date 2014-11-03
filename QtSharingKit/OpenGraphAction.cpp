#include "OpenGraphAction.h"

OpenGraphAction::OpenGraphAction(QObject* parent) :
    QObject(parent)
{

}

QString OpenGraphAction::type()
{
    return m_type;
}

void OpenGraphAction::setType(QString type)
{
    if (m_type == type) return;
    m_type = type;
    emit actionChanged(this);
}

QVariantMap OpenGraphAction::additionalProperties()
{
    return m_additional;
}

void OpenGraphAction::setAdditionalProperties(QVariantMap data)
{
    if (m_additional == data) return;
    m_additional = data;
    emit actionChanged(this);
}

QStringList OpenGraphAction::publishProperties()
{
    return m_publishProperties;
}

void OpenGraphAction::setPublishProperties(QStringList properties)
{
    m_publishProperties = properties;
    emit publishPropertiesChanged();
}
