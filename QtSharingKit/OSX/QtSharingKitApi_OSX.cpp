#include "QtSharingKitApi.h"

QtSharingKitApi::QtSharingKitApi(QQuickItem *parent):
    QQuickItem(parent),
    m_fbCredentials(NULL),
    m_privateData(NULL)
{
    qDebug() << "Created OSX OSKApi instance";
}

QtSharingKitApi::~QtSharingKitApi()
{
}

FBAppCredentials* QtSharingKitApi::facebookAppCredentials()
{
    return m_fbCredentials;
}

void QtSharingKitApi::setFacebookAppCredentials(FBAppCredentials* credentials)
{
    if (m_fbCredentials == credentials) return;
    m_fbCredentials = credentials;
    emit facebookAppCredentialsChanged();
}

void QtSharingKitApi::launchShareActivity()
{
}
