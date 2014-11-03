#include "TextItem.h"

TextItem::TextItem(QObject* parent) :
    ShareableItem(parent)
{
}

QString TextItem::text()
{
    return m_text;
}

void TextItem::setText(QString text)
{
    if (m_text == text) return;
    m_text = text;
    emit textChanged();
}
