#include "FBAppCredentials.h"

FBAppCredentials::FBAppCredentials(QObject* parent)
    : QObject(parent)
{
}

FBAppCredentials::FBAppCredentials(QString appName, QString appID, QObject* parent)
    : QObject(parent),
      m_appName(appName),
      m_appID(appID)
{
}

QString FBAppCredentials::appName()
{
    return m_appName;
}

void FBAppCredentials::setAppName(QString appName)
{
    if (appName == m_appName) return;
    m_appName = appName;
    emit appNameChanged();
}

QString FBAppCredentials::appID()
{
    return m_appID;
}

void FBAppCredentials::setAppID(QString appID)
{
    if (appID == m_appID) return;

    m_appID = appID;
    emit appIDChanged();
}
