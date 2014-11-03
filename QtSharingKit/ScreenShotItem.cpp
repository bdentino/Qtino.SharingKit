#include "ScreenShotItem.h"
#include <QQuickWindow>
#include <QStandardPaths>
#include <QDir>
#include <QTimer>
#include <QDateTime>

QString ScreenShotItem::TEMP_DIRECTORY = "qtino.sharingkit.screenshots";
ScreenShotItem::GarbageCollector ScreenShotItem::GARBAGE_COLLECTOR;

ScreenShotItem::GarbageCollector::GarbageCollector()
{
    clearTempImages();
}

void ScreenShotItem::GarbageCollector::clearTempImages()
{
    QString folder = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    QDir dir(folder);
    if (!dir.exists(TEMP_DIRECTORY)) return;
    dir.cd(TEMP_DIRECTORY);
    dir.removeRecursively();
}

ScreenShotItem::ScreenShotItem(QObject* parent)
    : ShareableImageItem(parent),
      m_item(NULL),
      m_pendingGrab(NULL)
{
}

QQuickItem* ScreenShotItem::item()
{
    return m_item;
}

void ScreenShotItem::setItem(QQuickItem* item)
{
    m_item = item;
    emit itemChanged();
}

bool ScreenShotItem::ready()
{
    return m_ready;
}

void ScreenShotItem::capture()
{
    // Make sure we're in the event loop before capturing screen shots
    QTimer* runImmediate = new QTimer();
    runImmediate->setInterval(0);
    runImmediate->setSingleShot(true);
    QObject::connect(runImmediate, SIGNAL(timeout()), this, SLOT(prepareScreenShot()));
    QObject::connect(runImmediate, SIGNAL(timeout()), runImmediate, SLOT(deleteLater()));
    runImmediate->start();

    //Clear previous file
    if (m_pendingGrab && m_pendingGrab.data() != NULL)
    {
        QObject::disconnect(m_pendingGrab.data(), SIGNAL(ready()), this, SLOT(onCaptureReady()));
        m_pendingGrab.clear();
    }
    if (QFile::exists(m_tempFile))
        QFile(m_tempFile).remove();
    m_tempFile = "";
    m_ready = false;
    emit readyChanged();
    setUrl(QUrl());
}

bool ScreenShotItem::saveToFile(QString file)
{
    if (!QFile(m_tempFile).exists()) return false;
    return QFile::copy(m_tempFile, file);
}

void ScreenShotItem::prepareScreenShot()
{
    if (!m_item) return; // TODO: This should start a platform-dependent capture of the entire screen

    m_pendingGrab = m_item->grabToImage();
    QObject::connect(m_pendingGrab.data(), SIGNAL(ready()), this, SLOT(onCaptureReady()));
}

void ScreenShotItem::onCaptureReady()
{
    QQuickItemGrabResult* image = qobject_cast<QQuickItemGrabResult*>(QObject::sender());
    if (!image || image != m_pendingGrab.data()) return;

    QString folder = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    QDir dir(folder);
    if (!dir.exists(TEMP_DIRECTORY)) dir.mkdir(TEMP_DIRECTORY);
    dir.cd(TEMP_DIRECTORY);

    QString guid = QString("IMG_%1_%2.png")
                    .arg(QDateTime::currentMSecsSinceEpoch())
                    .arg((long)m_item);
    QString absolutePath = dir.absoluteFilePath(guid);

    if (!(image->saveToFile(absolutePath)))
    {
        qWarning("Couldn't save screenshot file!");
    }
    else
    {
        m_tempFile = absolutePath;
        setUrl(QUrl::fromLocalFile(absolutePath));
        m_ready = true;
        emit readyChanged();
    }

    QObject::disconnect(m_pendingGrab.data(), SIGNAL(ready()), this, SLOT(onCaptureReady()));
    m_pendingGrab.clear();
}
