// Standalone visual replacement based on the About page supplied by the user.
// Validate against the target player's Qt modules and compiled resource copy.
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: aboutPage
    objectName: "aboutSettings"

    // Keep the properties/callback signatures from the supplied page.
    // This visual page does not implement native update handling.
    property bool pUpdateAvailable: false
    property string pUpdateVersion: ""
    property string pMoreInfoURL: ""
    property string pDownloadURL: ""
    property bool pIsInCompatibleUpdateVersion: false
    property string pParentWindow: ""

    property string brandFontFamily: "Cambria Math"
    property string bodyFontFamily: "Segoe UI"
    property bool reducedMotion: false

    Flickable {
        id: scroller
        objectName: "voidAboutScroll"
        anchors.fill: parent
        contentWidth: width
        contentHeight: Math.max(height, contentCol.y + contentCol.implicitHeight + 16)
        flickableDirection: Flickable.VerticalFlick
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 4
            padding: 0
            contentItem: Rectangle { radius: 2; color: "#62626b" }
            background: Rectangle { radius: 2; color: "#161619" }
        }

        ColumnLayout {
            id: contentCol
            objectName: "voidAboutContent"
            width: Math.max(0, Math.min(560, scroller.width - 32))
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 16
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 112
                radius: 12
                color: "#111114"
                border.width: 1
                border.color: "#2a2a30"

                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.max(0, parent.width - 24)
                    spacing: 6

                    Text {
                        objectName: "voidAboutBrand"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "𝓥𝓞𝓘𝓓"
                        textFormat: Text.PlainText
                        color: "#ffffff"
                        font.family: aboutPage.brandFontFamily
                        font.pixelSize: 36
                    }

                    Text {
                        objectName: "voidAboutCredit"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "Developed By NOVA XIS"
                        textFormat: Text.PlainText
                        color: "#a4a4ae"
                        font.family: aboutPage.bodyFontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        wrapMode: Text.Wrap
                    }
                }
            }

            // A normal Button avoids requiring an inline QML component.
            Button {
                id: youtubeButton
                objectName: "voidAboutYoutube"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                padding: 0
                leftPadding: 16
                rightPadding: 16
                hoverEnabled: true
                focusPolicy: Qt.StrongFocus
                Accessible.name: "NOVA XIS on YouTube"
                onClicked: Qt.openUrlExternally("https://www.youtube.com/@nova_xis20")

                contentItem: RowLayout {
                    spacing: 12
                    Text {
                        Layout.fillWidth: true
                        text: "NOVA XIS on YouTube"
                        textFormat: Text.PlainText
                        color: "#ededf1"
                        font.family: aboutPage.bodyFontFamily
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    Text {
                        text: "↗"
                        textFormat: Text.PlainText
                        color: youtubeButton.hovered || youtubeButton.activeFocus ? "#ffffff" : "#92929d"
                        font.pixelSize: 18
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                background: Rectangle {
                    radius: 8
                    color: youtubeButton.down ? "#27272e" : youtubeButton.hovered ? "#1c1c22" : "#141418"
                    border.width: 1
                    border.color: youtubeButton.activeFocus ? "#eeeeef" : youtubeButton.hovered ? "#494952" : "#303037"
                    Behavior on color { ColorAnimation { duration: aboutPage.reducedMotion ? 0 : 120 } }
                    Behavior on border.color { ColorAnimation { duration: aboutPage.reducedMotion ? 0 : 120 } }
                }
            }
        }
    }

    // Reserved no-ops from the supplied custom page, not a native updater port.
    // Retain the real handlers when merging into an original player page.
    function fCheckForUpdateCallback(apiCallStatus, jsonData) {}
    function fUpdateShortDisplayName(displayName) {}
}
