#include "QtSharingKitApi.h"

QtSharingKitApi::QtSharingKitApi(QQuickItem *parent):
    QQuickItem(parent),
    m_privateData(NULL)
{
    qDebug() << "Created OSX OSKApi instance";
}

QtSharingKitApi::~QtSharingKitApi()
{
}

void QtSharingKitApi::launchShareActivity()
{
}
