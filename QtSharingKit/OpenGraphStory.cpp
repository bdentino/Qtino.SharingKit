#include "OpenGraphStory.h"
#include "OpenGraphAction.h"
#include "GraphObjectProperty.h"

OpenGraphStory::OpenGraphStory(QObject* parent)
    : ShareableItem(parent),
      m_action(NULL)
{

}

OpenGraphAction* OpenGraphStory::action()
{
    return m_action;
}

void OpenGraphStory::setAction(OpenGraphAction* action)
{
    if (m_action == action) return;
    m_action = action;
    emit actionChanged(action);
}

QString OpenGraphStory::previewPropertyName()
{
    return m_previewPropertyName;
}

void OpenGraphStory::setPreviewPropertyName(QString property)
{
    if (m_previewPropertyName == property) return;
    m_previewPropertyName = property;
    emit previewPropertyNameChanged(property);
}
