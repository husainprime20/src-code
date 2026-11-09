/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Shapes 1.12

UiRowLayout {
    id: iToastRow

    readonly property real pDefaultTime: 3000
    property real pTime: pDefaultTime
    readonly property real pFadeTime: 300
    property bool pShowCross: true
    property real pMaximumWidth: Screen.desktopAvailableWidth * Screen.devicePixelRatio

    implicitWidth: Math.min(Math.max(162, iMessage.implicitWidth) + 10 + (pShowCross ? 16 : 0) + leftPadding + rightPadding,
                            pMaximumWidth)
    color: UiTheme.colors.overlayPrimary
    border.width: 1
    border.color: UiTheme.colors.primary50
    leftPadding: 10
    rightPadding: 10
    topPadding: 4
    bottomPadding: 4
    spacing: 10
    visible: false

    Text {
        id: iMessage
        Layout.fillWidth: true
        color: UiTheme.colors.primary10
        font: UiTheme.fonts.bodyExtraSmall
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Qt.AlignHCenter
    }

    UiImageButton {
        asset: "CloseSmall"
        pImageWidth: 12
        pImageHeight: 12
        visible: pShowCross
        onClicked: {
            iCloseAnimation.start()
            iToastRow.visible = false
        }
    }

    SequentialAnimation on opacity {
        id: iFullAnimation
        running: false
        NumberAnimation { to: 1; duration: pFadeTime }
        PauseAnimation { duration: pTime - 2 * pFadeTime }
        NumberAnimation { to: 0; duration: pFadeTime }
        onRunningChanged: {
            if(!running)
                iToastRow.visible = false
        }
    }

    SequentialAnimation on opacity {
        id: iCloseAnimation
        running: false
        NumberAnimation { to: 0; duration: pFadeTime }
        onRunningChanged: {
            if(!running)
                iToastRow.visible = false
        }
    }

    function fShow(text, duration) {
        iMessage.text = text;
        if (typeof duration !== "undefined") { // checks if parameter was passed
            pTime = Math.max(duration, 2 * pFadeTime);
        }
        else {
            pTime = pDefaultTime;
        }
        iToastRow.visible = true
        iFullAnimation.start();
    }
}
