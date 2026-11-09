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

Window {
    property string pToastMessage: ""
    property alias pToastTimer: iToastPopupTimer

    width: iToastContentRow.implicitWidth
    height: iToastContentRow.implicitHeight
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    screen: transientParent.screen

    property alias pBackground: iToastContentRow

    UiRowLayout {
        id: iToastContentRow
        color: UiTheme.colors.overLayBlack
        radius: 14
        spacing: 14
        leftPadding: 20
        rightPadding: 20
        topPadding: 8
        bottomPadding: 8

        Text {
            id: iToastText
            text: pToastMessage
            color: UiTheme.colors.primary10
            font: UiTheme.fonts.bodyLarge
        }

        UiImageButton {
            visible: false
            asset: "CloseIcon"
            pImageWidth: 14
            pImageHeight: 14
            onClicked: fClosePopup()
        }
    }

    Timer {
        id:iToastPopupTimer
        repeat: false
        interval: 2000
        running: false
        onTriggered: fClosePopup()
    }

    function fShowMessage({widthOffset = (iAppwin.pSidebarWidth - adsBackend.pExtendedBannerAdWidth)/2, verticalOffsetRatio = 0.85} = {}) {
        this.x = this.transientParent.x + (this.transientParent.width - this.width)/2 - widthOffset
        this.y = this.transientParent.y + this.transientParent.height * verticalOffsetRatio
        this.show()
        iToastPopupTimer.start()
    }

    function fClosePopup() {
        iToastPopupTimer.stop()
        this.close()
        this.destroy()
    }
}
