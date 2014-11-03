#include "TwitterContent.h"
#include "DefaultContent.h"

TwitterContent::TwitterContent(QObject* parent)
    : DefaultContent(parent)
{
}

QString TwitterContent::text()
{
    return m_text;
}

void TwitterContent::setText(QString text)
{
    if (m_text == text) return;
    m_text = text;
    emit textChanged();
}

bool TwitterContent::attachScreenshot()
{
    return m_attachScreenshot;
}

void TwitterContent::setAttachScreenshot(bool attach)
{
    if (m_attachScreenshot == attach) return;
    m_attachScreenshot = attach;
    emit attachScreenshotChanged();
}
