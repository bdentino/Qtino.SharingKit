#include "FacebookContent.h"

FacebookContent::FacebookContent(QQuickItem* parent)
    : QQuickItem(parent)
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
