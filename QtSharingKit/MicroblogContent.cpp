#include "MicroblogContent.h"

MicroblogContent::MicroblogContent(QQuickItem* parent)
    : QQuickItem(parent)
{
}

QString MicroblogContent::text()
{
    return m_text;
}

void MicroblogContent::setText(QString text)
{
    if (m_text == text) return;
    m_text = text;
    emit textChanged();
}

bool MicroblogContent::attachScreenshot()
{
    return m_attachScreenshot;
}

void MicroblogContent::setAttachScreenshot(bool attach)
{
    if (m_attachScreenshot == attach) return;
    m_attachScreenshot = attach;
    emit attachScreenshotChanged();
}
