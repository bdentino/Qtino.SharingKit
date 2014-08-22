import QtQuick 2.2
import QtQuick.Window 2.1
import Qtino.SharingKit 1.0

Window {
    id: root
    visible: true
    width: 360
    height: 360
    opacity: 0.2

    MouseArea {
        anchors.fill: parent
        onClicked: {
            sharingView.launchShareActivity()
        }
    }

    Text {
        text: qsTr("Hello World")
        anchors.centerIn: parent
    }

    SharingKitView {
        id: sharingView

        FacebookAppCredentials {
            id: fbCreds
            appName: "QtSharingDemo"
            appID: "771432599569387"
        }
        facebookAppCredentials: fbCreds
        title: "Share Something!"

        FacebookContent {
            id: fbContentItem
            text: "Facebook sharing is alright, (as long as it's open source)..."
            link: "https://github.com/bdentino/QtSharingKit"
            attachScreenshot: true
        }

        MicroblogContent {
            id: mbContentItem
            text: "Tweeting from Qml! Check out this library for #sharing on mobile - https://github.com/bdentino/QtSharingKit."
            attachScreenshot: true
        }

        EmailContent {
            id: emailContentItem
            subject: "I can share via email!"
            body: "This is just another email test."
            attachScreenshot: true
        }

        SmsContent {
            id: smsContentItem
            body: "Lets see, who can I text this to without annoying too much..."
            attachScreenshot: true
        }
    }
}
