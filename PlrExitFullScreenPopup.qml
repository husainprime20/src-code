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
    id: iExitFullScreenPopup
    width: iPopupContentRow.implicitWidth
    height: iPopupContentRow.implicitHeight
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    screen: transientParent.screen

    onActiveChanged: {
        if (iExitFullScreenPopup.activeFocusItem == null)
            fClosePopup()
    }

    UiColumnLayout {
        id: iPopupContentRow
        anchors.centerIn: parent
        color: UiTheme.colors.overLayGray
        border {
            color: UiTheme.colors.primary50
            width: 1
        }
        leftPadding: 40
        topPadding: 26
        bottomPadding: 26
        rightPadding: 20
        pMouseArea {
            anchors.fill: iPopupContentRow
            enabled: true
            hoverEnabled: true
            onClicked:  {
                fClosePopup()
                iAppwin.fUiShowNormal()
            }
        }
        UiRowLayout {
            id: iLayoutRow
            Layout.fillWidth: true

            UiImage {
                asset: "ExitFullScreen"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                pImageWidth: 16
                pImageHeight: 16
            }
            Text {
                leftPadding: 10
                rightPadding: 50
                text: qsTranslate("QObject", "Exit Fullscreen")
                font: UiTheme.fonts.titleSmall
                color: UiTheme.colors.primary10
            }
            UiImageButton {
                asset: "CloseIcon"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                pImageWidth: 16
                pImageHeight: 16


                onClicked: fClosePopup()
            }
        }
    }

    function fShowPopup() {
        iExitFullScreenPopup.x = iAppwin.x + ((iAppwin.width - iAppwin.pSidebarWidth) - iExitFullScreenPopup.width)/2
        iExitFullScreenPopup.y = iAppwin.y

        if (iExitFullScreenPopup.width > (iAppwin.width - iAppwin.pSidebarWidth)) {
            fClosePopup()
            return
        }
        iExitFullScreenPopup.show()
    }

    function fClosePopup() {
        iExitFullScreenPopup.close()
        iExitFullScreenPopup.destroy()
    }
}
