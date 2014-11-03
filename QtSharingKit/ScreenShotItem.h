#ifndef SCREENSHOTITEM_H
#define SCREENSHOTITEM_H

#include <QObject>
#include <QQuickItemGrabResult>
#include <QQuickItem>

#include "ShareableImageItem.h"

class ScreenShotItem : public ShareableImageItem
{
    Q_OBJECT

    Q_PROPERTY(QQuickItem* item READ item WRITE setItem NOTIFY itemChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)

public:
    explicit ScreenShotItem(QObject* parent = 0);

    QQuickItem* item();
    void setItem(QQuickItem* item);

    bool ready();

signals:
    void itemChanged();
    void readyChanged();

public slots:
    void capture();
    bool saveToFile(QString file);

private slots:
    void prepareScreenShot();
    void onCaptureReady();

private:
    QQuickItem* m_item;
    bool m_ready;
    QString m_tempFile;
    QSharedPointer<QQuickItemGrabResult> m_pendingGrab;

    class GarbageCollector {
    public:
        GarbageCollector();
        void clearTempImages();
    };

    static QString TEMP_DIRECTORY;
    static GarbageCollector GARBAGE_COLLECTOR;
};

Q_DECLARE_METATYPE(ScreenShotItem*)

#endif // SCREENSHOTITEM_H
