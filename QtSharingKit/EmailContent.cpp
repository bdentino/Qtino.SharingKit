#include "EmailContent.h"

EmailContent::EmailContent(QObject* parent)
    : DefaultContent(parent)
{
}

QString EmailContent::subject()
{
    return m_subject;
}

void EmailContent::setSubject(QString subject)
{
    if (m_subject == subject) return;
    m_subject = subject;
    emit subjectChanged();
}

QString EmailContent::body()
{
    return m_body;
}

void EmailContent::setBody(QString body)
{
    if (m_body == body) return;
    m_body = body;
    emit bodyChanged();
}

bool EmailContent::attachScreenshot()
{
    return m_attachScreenshot;
}

void EmailContent::setAttachScreenshot(bool attach)
{
    if (m_attachScreenshot == attach) return;
    m_attachScreenshot = attach;
    emit attachScreenshotChanged();
}
