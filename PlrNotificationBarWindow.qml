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
import QtMultimedia

import UiToolTipControl 1.0

Window {
    id: iNotificationBar
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus
    title: qsTranslate("QObject", "Notification bar")
    screen: transientParent.screen
    height: iNotificationBarLayout.implicitHeight

    property string pNotificationJson: ""
    property string pContentTitle: ""
    property string pContentText: ""
    property string pButtonText: ""
    property bool pIsPortraitMode: transientParent.width < transientParent.height || width < 500

    property bool pButtonVisible: true
    property bool pSendStats: true
    property bool pEnableSound: true
    property bool pShowProductIcon: true
    property bool pWhiteButton: false

    property string pAnimateDirection: "out"

    signal buttonClicked(var notificationJson)

    onClosing: {
        if(iNotificationBar.pNotificationJson != "")
            iAppwin.pIsQuestNotificationOpen = false

        iNotificationBar.destroy()
    }

    Component.onCompleted: {
        iNotificationAnimation.start()
        if (pEnableSound)
            iNotificationSound.play()
    }

    NumberAnimation {
        id: iNotificationAnimation
        target: iNotificationBarLayout
        property: "y"
        easing.type: Easing.Linear
        duration: 500
        from: pAnimateDirection == "out" ? -iNotificationBarLayout.implicitHeight : 0
        to: pAnimateDirection == "out" ? 0 : -iNotificationBarLayout.implicitHeight

        onFinished: {
            if (pAnimateDirection == "in")
                iNotificationBar.close()
        }
    }

    SoundEffect {
        id: iNotificationSound
        source: "moneyPrize.wav"
    }

    UiColumnLayout {
        id: iNotificationBarLayout
        anchors.left: parent != null ? parent.left : undefined
        anchors.right: parent != null ? parent.right : undefined
        color: UiTheme.colors.notificationGradientSecondary
        spacing: 4
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: UiTheme.colors.notificationGradientPrimary }
            GradientStop { position: 1; color: UiTheme.colors.notificationGradientSecondary }
        }
        topPadding: 12
        bottomPadding: 12
        leftPadding: 24
        rightPadding: 24

        UiRowLayout {
            Layout.fillWidth: true
            spacing: 12
            visible: !pIsPortraitMode || pShowProductIcon
            UiRowLayout {
                spacing: 8
                visible: pShowProductIcon
                UiImage {
                    asset: "BlueStacks5Beta"
                    pImageWidth: 20
                    pImageHeight: 20
                }
                Text {
                    text: uiBackend.productName
                    color: UiTheme.colors.white
                    opacity: 0.8
                    font: UiTheme.fonts.bodySmall
                }
            }

            Item {
                Layout.fillWidth: true
                visible: pIsPortraitMode
            }

            UiRowLayout {
                id: iLandscapeContentLayout
                Layout.fillWidth: true
                visible: !pIsPortraitMode
                UiRowLayout {
                    Layout.maximumWidth: iLandscapeContentLayout.width
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 20
                    Flow {
                        id: iContentFlow
                        Layout.preferredWidth: iTitleText.width + iContentText.width + 4
                        Layout.maximumWidth: iLandscapeContentLayout.width - iClaimBtn.width - 20
                        spacing: 4
                        Text {
                            id: iTitleText
                            Connections {
                                target: iContentFlow
                                function onWidthChanged() {
                                    iTitleText.width = iContentFlow.width < iTitleText.implicitWidth
                                            ? iContentFlow.width
                                            : iTitleText.implicitWidth
                                }
                            }
                            text: pContentTitle
                            color: UiTheme.colors.white
                            font: UiTheme.fonts.titleExtraSmall
                            wrapMode: Text.Wrap
                        }
                        Text {
                            id: iContentText
                            Connections {
                                target: iContentFlow
                                function onWidthChanged() {
                                    iContentText.width = iContentFlow.width < iContentText.implicitWidth
                                            ? iContentFlow.width
                                            : iContentText.implicitWidth
                                }
                            }
                            text: pContentText
                            color: UiTheme.colors.white
                            opacity: 0.9
                            font: UiTheme.fonts.bodyMedium
                            wrapMode: Text.Wrap
                        }
                    }
                    UiButton {
                        id: iClaimBtn
                        pSize: UiTheme.buttons.sizes.small
                        pColor: pWhiteButton ? UiTheme.buttons.colors.secondary : UiTheme.buttons.colors.accent
                        text: pButtonText
                        visible: pButtonVisible
                        onClicked: {
                            iNotificationBar.buttonClicked(iNotificationBar.pNotificationJson)
                            iNotificationBar.close()
                        }
                    }
                }
            }

            UiImageButton {
                asset: "CloseWhiteIcon"
                pImageWidth: 12
                pImageHeight: 12
                UiToolTip.text: qsTranslate("QObject", "Close")
                onClicked: {
                    if (pSendStats)
                        plrBackend.sendNotificationBarStats("notification_bar_cross_clicked", iNotificationBar.pNotificationJson)
                    iNotificationBar.close()
                }
            }
        }

        UiRowLayout {
            id: iPortraitContentLayout
            visible: pIsPortraitMode
            Layout.fillWidth: true
            spacing: 20
            UiColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    Layout.fillWidth: true
                    Layout.maximumHeight: 14
                    text: pContentTitle
                    color: UiTheme.colors.white
                    font: UiTheme.fonts.titleExtraSmall
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    visible: pContentTitle != ""
                }
                Text {
                    Layout.fillWidth: true
                    Layout.maximumHeight: 36
                    text: pContentText
                    color: UiTheme.colors.white
                    opacity: 0.9
                    font: UiTheme.fonts.bodyMedium
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                }
            }
            UiButton {
                pSize: UiTheme.buttons.sizes.small
                pColor: UiTheme.buttons.colors.accent
                text: pButtonText
                visible: pButtonVisible
                onClicked: {
                    iNotificationBar.buttonClicked(iNotificationBar.pNotificationJson)
                    iNotificationBar.close()
                }
            }
            UiImageButton {
                asset: "CloseWhiteIcon"
                pImageWidth: 12
                pImageHeight: 12
                UiToolTip.text: qsTranslate("QObject", "Close")
                visible: pIsPortraitMode && !pShowProductIcon
                onClicked: {
                    if (pSendStats)
                        plrBackend.sendNotificationBarStats("notification_bar_cross_clicked", iNotificationBar.pNotificationJson)
                    iNotificationBar.close()
                }
            }
        }
    }

    function fAnimateAndClose() {
        pAnimateDirection = "in"
        iNotificationAnimation.start()
    }
}
