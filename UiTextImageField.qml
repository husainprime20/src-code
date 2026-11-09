import QtQuick 2.0
import UiToolTipControl 1.0

UiTextField {
    id: iControl

    property string pAsset
    property bool pReadOnly : true
    property string pImageTooltip
    signal clicked

    readOnly: pReadOnly
    rightPadding: 20

    background: Rectangle {
        color: readOnly ? "transparent"  : iControl.pColorState.background
        border.width: readOnly ? 0 : 1
        border.color: iControl.pColorState.border
    }

    UiImageButton {
        UiToolTip.text: iControl.pImageTooltip
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4
        asset: iControl.pAsset
        pImageWidth: 12
        pImageHeight: 12
        visible: !iControl.readOnly
        onClicked: {
            pReadOnly = true
            iControl.clicked()
        }
    }
}
