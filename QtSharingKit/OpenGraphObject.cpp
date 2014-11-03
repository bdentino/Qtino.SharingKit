#include "OpenGraphObject.h"

OpenGraphObject::OpenGraphObject(QObject* parent)
    : QObject(parent),
      m_type("object")
{

}

QString OpenGraphObject::type()
{
    return m_type;
}

void OpenGraphObject::setType(QString type)
{
    if (type == m_type) return;
    m_type = type;
    emit objectChanged(this);
}

QVariantMap OpenGraphObject::additionalProperties()
{
    return m_additional;
}

void OpenGraphObject::setAdditionalProperties(QVariantMap data)
{
    if (data == m_additional) return;
    m_additional = data;
    emit objectChanged(this);
}
