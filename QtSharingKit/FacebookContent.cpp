#include "FacebookContent.h"

FacebookContent::FacebookContent(QObject* parent)
    : DefaultContent(parent),
      m_fbCredentials(NULL)
{
}

QString FacebookContent::text()
{
    return m_text;
}

void FacebookContent::setText(QString text)
{
    if (m_text == text) return;
    m_text = text;
    emit textChanged();
}

QUrl FacebookContent::link()
{
    return m_link;
}

void FacebookContent::setLink(QUrl link)
{
    if (m_link == link) return;
    m_link = link;
    emit linkChanged();
}

bool FacebookContent::attachScreenshot()
{
    return m_attachScreenshot;
}

void FacebookContent::setAttachScreenshot(bool attach)
{
    if (m_attachScreenshot == attach) return;
    m_attachScreenshot = attach;
    emit attachScreenshotChanged();
}

FBAppCredentials* FacebookContent::appCredentials()
{
    return m_fbCredentials;
}

void FacebookContent::setAppCredentials(FBAppCredentials* credentials)
{
    if (m_fbCredentials == credentials) return;
    m_fbCredentials = credentials;
    emit appCredentialsChanged();
}
