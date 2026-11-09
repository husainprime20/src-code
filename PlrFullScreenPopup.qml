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
    id: iFullScreenPopup
    property string pMessage : qsTranslate("QObject", "Press {%1} to exit fullscreen").arg("F11")
    property var pTips: pMessage.split("{")
    property var pInfo: pTips.length > 1 ? pTips[1].split("}") : ["", ""]
    property bool pIsCloseIconVisible: true
    property bool pIsFullScreenSettingVisible: false
    property bool pClosePopup: false

    width: iPopupContentRow.implicitWidth
    height: iPopupContentRow.implicitHeight
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    screen: transientParent.screen

    HoverHandler {
        id: iControlHover
        onHoveredChanged: {
            if(!hovered && pClosePopup)
                fClosePopup()
        }
    }

    UiColumnLayout {
        id: iPopupContentRow
        anchors.centerIn: parent
        color: UiTheme.colors.overlayPrimary
        border {
            color: UiTheme.colors.primary50
            width: 1
        }
        leftPadding: 20
        topPadding: 24
        bottomPadding: 20
        UiRowLayout {
            Layout.fillWidth: true
            UiRowLayout {
                spacing: 8
                Text {
                    text: pTips[0]
                    font: UiTheme.fonts.bodyLarge
                    color: UiTheme.colors.primary10
                }

                UiColumnLayout {
                    id: iKeyRect
                    border.color: UiTheme.colors.primary10
                    color: "transparent"
                    padding: 8
                    topPadding: 6
                    bottomPadding: 6
                    Text {
                        text: pInfo[0]
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodyLarge
                    }
                }

                Text {
                    id: iText2
                    text: pInfo[1]
                    font: UiTheme.fonts.bodyLarge
                    color: UiTheme.colors.primary10
                }
            }

            UiImageButton {
                asset: "CloseIcon"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                pImageWidth: 12
                pImageHeight: 12
                leftPadding: 30
                rightPadding: 12
                visible: pIsCloseIconVisible
                onClicked: fClosePopup()
            }
        }

        Rectangle {
            visible: pIsFullScreenSettingVisible
            Layout.rightMargin: 20
            Layout.topMargin: 20
            Layout.bottomMargin: 16
            height: 1
            color: UiTheme.colors.primary50
            Layout.fillWidth: true
        }

        UiRowLayout {
            visible: pIsFullScreenSettingVisible
            Layout.fillWidth: true
            UiText {
                Layout.fillWidth: true
                text: qsTranslate("QObject", "Always launch this game in fullscreen")
                color: UiTheme.colors.primary20
                font: UiTheme.fonts.bodySmall
            }
            UiToggleButton {
                id: iFullScreenToggleBtn
                pSize: UiTheme.toggleButtons.sizes.small
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                leftPadding: 30
                rightPadding: 20
                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                checked: plrBackend.getFullScreenSettingForApp("")
                onCheckedChanged: {
                    plrBackend.setLaunchInFullScreenForAppPkg(checked)
                }
            }
        }
    }

    Timer {
        id:iFullScreenPopupTimer
        repeat: false
        interval: 5000
        running: false
        onTriggered: {
            if(pIsFullScreenSettingVisible) {
                if(!iControlHover.hovered)
                    fClosePopup()
                else
                    pClosePopup = true
            }
            else
                fClosePopup()
        }
    }

    function fShowMessage(isVisible, isFullScreenSettingVisible = false) {
        pIsCloseIconVisible = isVisible
        pIsFullScreenSettingVisible = isFullScreenSettingVisible

        var newTips = iFullScreenPopup.pMessage.split("{")
        if (newTips.length > 1)
        {
            var newInfo = newTips[1].split("}")
            iKeyRect.visible = newInfo[0].length > 0
            iText2.visible = newInfo[1].length > 0
        }
        else
        {
            iKeyRect.visible = false
            iText2.visible = false
        }

        iFullScreenPopup.x = iAppwin.x + (iAppwin.width - iFullScreenPopup.width)/2 - (iAppwin.pSidebarWidth - adsBackend.pExtendedBannerAdWidth)/2
        iFullScreenPopup.y = iAppwin.y + 40

        if (iFullScreenPopup.width > (iAppwin.width - iAppwin.pSidebarWidth - adsBackend.pExtendedBannerAdWidth)) {
            fClosePopup()
            return
        }

        iFullScreenPopup.show()
        iFullScreenPopupTimer.start()
    }

    function fClosePopup() {
        pClosePopup = false
        iFullScreenPopupTimer.stop()
        iFullScreenPopup.close()
        iFullScreenPopup.destroy()
    }
}
