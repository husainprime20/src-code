import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: iLoadingPopup
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    width:  iLoadingPopupLayout.implicitWidth + 2 * iShadow.shadowThickness
    minimumWidth: 200 + 2* iShadow.shadowThickness
    height: iLoadingPopupLayout.implicitHeight + 2 * iShadow.shadowThickness
    screen: transientParent.screen

    property string pText: qsTranslate("QObject", "Loading")

    UiShadowContainer {
        id: iShadow
        UiColumnLayout {
            id: iLoadingPopupLayout
            padding: 24
            spacing: 20
            anchors.left: parent.left
            anchors.right: parent.right
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary50
            UiImage {
                id: iLoader
                asset: "Loader_bright"
                pImageWidth: 20
                pImageHeight: 20
                cache: false
                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    duration: 2000
                    from: 0
                    to: 360
                    direction: RotationAnimation.Clockwise
                    running: iLoader.visible
                }
            }
            Text {
                text: iLoadingPopup.pText
                font: UiTheme.fonts.bodyLarge
                color: UiTheme.colors.primary20
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }
}
