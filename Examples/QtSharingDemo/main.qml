import QtQuick 2.2
import QtQuick.Window 2.1
import Qtino.SharingKit 1.0

Window {
    visible: true
    width: 360
    height: 360
    opacity: 0.2

    MouseArea {
        anchors.fill: parent
        onClicked: {
            sharingView.openShareSheetForContent("Share Your Score!",
                                                 "Beat My Bluu Score (1200)",
                                                 "Just scored 1200 in #Bluu. Bet you can't beat it!");
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
            appName: "Bluu"
            appID: "620462718052834"
        }

        facebookAppCredentials: fbCreds
    }
}
