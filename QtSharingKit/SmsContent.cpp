#include "SmsContent.h"

SmsContent::SmsContent(QQuickItem* parent)
    : QQuickItem(parent)
{
}

QString SmsContent::body()
{
    return m_body;
}

void SmsContent::setBody(QString body)
{
    if (m_body == body) return;
    m_body = body;
    emit bodyChanged();
}

bool SmsContent::attachScreenshot()
{
    return m_attachScreenshot;
}

void SmsContent::setAttachScreenshot(bool attach)
{
    if (m_attachScreenshot == attach) return;
    m_attachScreenshot = attach;
    emit attachScreenshotChanged();
}
