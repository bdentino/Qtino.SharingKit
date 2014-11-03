import QtQuick 2.2
import QtQuick.Window 2.1
import Qtino.SharingKit 1.0

Window {
    visible: true
    width: 360
    height: 360

    property var appState: Qt.application.state

    onAppStateChanged: {
        var state = ""
        if (appState === Qt.ApplicationActive) {
            state = "Active"
        }
        else if (appState === Qt.ApplicationInactive) {
            state = "Inactive"
        }
        else if (appState === Qt.ApplicationSuspended) {
            state = "Suspended"
        }
        else if (appState === Qt.ApplicationHidden) {
            state = "Hidden"
        }
        console.log("App State: " + state)
    }

    Rectangle {
        id: root
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: {
                sharingView.x = mouse.x
                sharingView.y = mouse.y
                sharingView.open = true;
                sharingView.launchShareActivity()
            }
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { color: 'green'; position: 0 }
                GradientStop { color: 'yellow'; position: 1 }
            }
        }

        Image {
            id: logo
            height: 200
            width: 200
            sourceSize.height: height * 2
            sourceSize.width: width * 2
            anchors.centerIn: parent
            source: "Qt-logo.svg"
            Component.onCompleted: grow.start()
        }
        NumberAnimation { id: grow; target: logo; property: 'scale'; to: 1.5; onStopped: shrink.start(); }
        NumberAnimation { id: shrink; target: logo; property: 'scale'; duration: 1000; to: 1; onStopped: grow.start(); }
        Text {
            text: qsTr("Tap to Share Me!")
            anchors.horizontalCenter: logo.horizontalCenter
            anchors.top: logo.bottom
            anchors.margins: 10
            font.pointSize: 18
        }

        ScreenShotItem { id: rootScreenGrab; item: root }
        SharingKitView {
            id: sharingView

            title: "Share Something!"
            property bool open: false;

            onSharingFinished: { console.log("Sharing Finished!"); }

            TwitterContent { // for apps sharing via twitter (activity type)
                id: twitContentItem
                text: "Tweeting from Qml! Check out this library for #sharing on mobile - https://github.com/bdentino/QtSharingKit."
                ImageItem { source: rootScreenGrab.url }
            }

            EmailContent { // for apps handling "mailto:" uri (content type)
                id: emailContentItem
                subject: "I can share via email!"
                body: "This is just another email test."
                ImageItem { source: rootScreenGrab.url }
            }

            SmsContent { // for apps handling "sms:/mms:" uri (content type)
                id: smsContentItem
                body: "Lets see, who can I text this to without annoying too much..."
                ImageItem { source: rootScreenGrab.url }
            }

            DefaultContent { // for any other app capable of handling provided item types
                id: defaultContentItem
                ImageItem { source: rootScreenGrab.url }
                TextItem { text: "I can share anything with Qtino.SharingKit! http://github.com/bdentino/Qtino.SharingKit"; }
            }

            FacebookContent {
                appCredentials: FacebookAppCredentials {
                    appName: "QtSharingDemo"
                    appID: "771432599569387"
                }

                OpenGraphStory {
                    id: story
                    action: OpenGraphAction {
                        type: "qtino-sharing:test"
                        //publishProperties: ["git_repo"]
                        additionalProperties: {
                            "git_repo": repoObject,
                            "expires_in": 20
                        }
                    }
                    previewPropertyName: "git_repo"
                }
            }
        }
        OpenGraphObject {
            id: repoObject
            type: "qtino-sharing:git_repo"
            additionalProperties: {
                "title": "Qtino.SharingKit",
                        "description": "Qtino.SharingKit is a cross-platform, open source social sharing library written against the Qt framework",
                        "image": rootScreenGrab,
                        "url": "https://github.com/bdentino/Qtino.SharingKit"
            }
        }

        onWidthChanged: {
            if (sharingView.open) return;
            rootScreenGrab.capture();
            root.grabToImage( function(result) {
                console.log("Finished!");
            })
        }
    }
}
