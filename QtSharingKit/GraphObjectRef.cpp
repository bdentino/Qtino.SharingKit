#include "GraphObjectRef.h"

GraphObjectRef::GraphObjectRef(QObject* parent)
    : QObject(parent)
{

}

QUrl GraphObjectRef::url()
{
    return QUrl();
}

void GraphObjectRef::setUrl(QUrl url)
{

}
