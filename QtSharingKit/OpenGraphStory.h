#ifndef OPENGRAPHSTORY_H
#define OPENGRAPHSTORY_H

#include <QObject>

#include "ShareableItem.h"

class OpenGraphAction;
class GraphObjectProperty;
class OpenGraphStory : public ShareableItem
{
    Q_OBJECT

    Q_PROPERTY(OpenGraphAction* action READ action WRITE setAction NOTIFY actionChanged)
    Q_PROPERTY(QString previewPropertyName READ previewPropertyName WRITE setPreviewPropertyName NOTIFY previewPropertyNameChanged)

public:
    explicit OpenGraphStory(QObject* parent = 0);

    OpenGraphAction* action();
    void setAction(OpenGraphAction* action);

    QString previewPropertyName();
    void setPreviewPropertyName(QString property);

signals:
    void actionChanged(OpenGraphAction* newAction);
    void previewPropertyNameChanged(QString newName);

private:
    OpenGraphAction* m_action;
    QString m_previewPropertyName;
};

#endif // OPENGRAPHSTORY_H
