#ifndef GRAPHOBJECTREF_H
#define GRAPHOBJECTREF_H

#include <QObject>
#include <QUrl>

class GraphObjectRef : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit GraphObjectRef(QObject* parent = 0);

    QUrl url();
    void setUrl(QUrl url);

signals:
    void urlChanged(QUrl newUrl);

public slots:

};

#endif // GRAPHOBJECTREF_H
