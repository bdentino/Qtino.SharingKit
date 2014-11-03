#ifndef GRAPHOBJECTPROPERTY_H
#define GRAPHOBJECTPROPERTY_H

#include <QObject>
#include <QVariant>

class GraphObjectProperty : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    explicit GraphObjectProperty(QObject* parent = 0);

    QString name();
    void setName(QString name);

    QVariant value();
    void setValue(QVariant value);

signals:
    void nameChanged(QString newName);
    void valueChanged(QVariant newValue);

public slots:

};

#endif // GRAPHOBJECTPROPERTY_H
