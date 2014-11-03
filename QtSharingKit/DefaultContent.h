#ifndef DEFAULTCONTENT_H
#define DEFAULTCONTENT_H

#include <QObject>
#include <QQmlListProperty>

#include "ShareableItem.h"

class DefaultContent : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQmlListProperty<ShareableItem> qmlAttachments READ qmlAttachments)
    Q_PROPERTY(QList<ShareableItem*> attachments READ attachments)
    Q_CLASSINFO("DefaultProperty", "qmlAttachments")

public:
    explicit DefaultContent(QObject* parent = 0);

    QQmlListProperty<ShareableItem> qmlAttachments();
    QList<ShareableItem *>& attachments();

signals:

public slots:

protected:
    static void addAttachment(QQmlListProperty<ShareableItem>* list, ShareableItem* item);
    static int attachmentCount(QQmlListProperty<ShareableItem>* list);
    static ShareableItem* attachmentAt(QQmlListProperty<ShareableItem>* list, int index);
    static void clearAttachments(QQmlListProperty<ShareableItem>* list);


private:
    QList<ShareableItem*> m_attachments;

};

#endif // DEFAULTCONTENT_H
