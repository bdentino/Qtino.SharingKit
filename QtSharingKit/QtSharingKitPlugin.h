#ifndef QTSHARINGKITPLUGIN_H
#define QTSHARINGKITPLUGIN_H

#include <QQmlExtensionPlugin>

class QtSharingKitPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif // QTSHARINGKITPLUGIN_H

