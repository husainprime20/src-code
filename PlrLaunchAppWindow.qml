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

import UiToolTipControl 1.0
import UiLaunchAppWindow 1.0
import UiOverlayControl 1.0

UiLaunchAppWindow {
    id: iAppInstallWindow
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Fle popup")
    width: 402 + 2 * iShadowContainer.shadowThickness
    height: iAppInstallLayout.implicitHeight + 2 * iShadowContainer.shadowThickness
    UiOverlay.overlayRect: Qt.rect(iAppInstallWindow.transientParent.x + plrBackend.plrWinOffsets[0] - adsBackend.pExtendedBannerAdWidth,
                                     iAppInstallWindow.transientParent.y + plrBackend.plrWinOffsets[2],
                                     iAppInstallWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1] + adsBackend.pExtendedBannerAdWidth,
                                     iAppInstallWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3])
    onVisibleChanged: {
        if (visible) {
            plrBackend.sendPopupStats("fle_gp", "impression", iAppInstallWindow.pAppPackage)
        }
    }

    onClosed: {
        iAppInstallWindow.destroy()
    }

    UiShadowContainer {
        id: iShadowContainer
        UiColumnLayout {
            id: iAppInstallLayout
            anchors.left: parent.left
            anchors.right: parent.right
            color: UiTheme.colors.primary70
            border.color: UiTheme.colors.primary60
            border.width: 1
            padding: 1
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: iCoverImage.implicitHeight
                color: UiTheme.colors.primary70
                clip: true
                UiImage {
                    id: iCoverImage
                    fillMode: Image.PreserveAspectCrop
                    anchors.centerIn: parent
                    source: iAppInstallWindow.pCoverImage
                    pImageWidth: 400
                    pImageHeight: 200
                }
                UiRowLayout {
                    id: iCloseBtn
                    anchors.right: parent != null ? parent.right : undefined
                    anchors.top: parent != null ? parent.top : undefined
                    anchors.margins: 16
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    padding: 8
                    color: UiTheme.colors.overLayGray
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    UiToolTip.visible: pMouseArea.containsMouse
                    pMouseArea {
                        anchors.fill: iCloseBtn
                        enabled: true
                        hoverEnabled: true
                        onClicked: {
                            plrBackend.sendPopupStats("fle_gp", "close_clicked", iAppInstallWindow.pAppPackage)
                            iAppInstallWindow.close()
                        }
                    }
                    UiImage {
                        asset: "CloseIcon" + (iCloseBtn.pMouseArea.pressed ? "_click" : (iCloseBtn.pMouseArea.containsMouse ? "_hover" : ""))
                        pImageWidth: 16
                        pImageHeight: 16
                    }
                }
            }
            UiImage {
                id: iAppIconImage
                source: iAppInstallWindow.pAppIconImage
                pImageWidth: 128
                pImageHeight: 128
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -(pImageHeight / 2)
            }
            UiColumnLayout {
                Layout.fillWidth: true
                spacing: 20
                padding: 20
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        text: iAppInstallWindow.pAppName
                        color: UiTheme.colors.white
                        font: UiTheme.fonts.titleExtraLarge
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: iAppInstallWindow.pAppCategory
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodyLarge
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                    }
                }
                UiButton {
                    Layout.alignment: Qt.AlignHCenter
                    pSize: UiTheme.buttons.sizes.extraLarge
                    pColor: UiTheme.buttons.colors.accent
                    text: qsTranslate("QObject", "Install from Google Play")
                    onClicked: {
                        iAppInstallWindow.installClicked()
                        plrBackend.sendPopupStats("fle_gp", "install_clicked", iAppInstallWindow.pAppPackage)
                        iAppInstallWindow.close()
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "You will be redirected to Google Play, sign in with your desired Google account to download")
                    color: UiTheme.colors.primary30
                    font: UiTheme.fonts.bodySmall
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
