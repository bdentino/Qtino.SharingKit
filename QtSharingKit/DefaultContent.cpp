#include "DefaultContent.h"

#include <QDebug>

DefaultContent::DefaultContent(QObject* parent)
    : QObject(parent)
{
}

QQmlListProperty<ShareableItem> DefaultContent::qmlAttachments()
{
    return QQmlListProperty<ShareableItem>(this,
                                           NULL,
                                           &DefaultContent::addAttachment,
                                           &DefaultContent::attachmentCount,
                                           &DefaultContent::attachmentAt,
                                           &DefaultContent::clearAttachments);
}

QList<ShareableItem *>& DefaultContent::attachments()
{
    return m_attachments;
}

void DefaultContent::addAttachment(QQmlListProperty<ShareableItem>* list, ShareableItem* item)
{
    DefaultContent* content = qobject_cast<DefaultContent*>(list->object);
    content->m_attachments.append(item);
}

int DefaultContent::attachmentCount(QQmlListProperty<ShareableItem>* list)
{
    return qobject_cast<DefaultContent*>(list->object)->m_attachments.count();
}

ShareableItem* DefaultContent::attachmentAt(QQmlListProperty<ShareableItem>* list, int index)
{
    return qobject_cast<DefaultContent*>(list->object)->m_attachments.at(index);
}

void DefaultContent::clearAttachments(QQmlListProperty<ShareableItem>* list)
{
    qobject_cast<DefaultContent*>(list->object)->m_attachments.clear();
}
