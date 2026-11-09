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
import UiQuickWindow 1.0

import UiToolTipControl 1.0

UiQuickWindow {
    id: iOnboardingWindow
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    title: uiBackend.productName + " Onboarding Window"

    property UiWindowedPopup pOnboardingClosePopup: null
    property bool pShowCloseComponent: false

    onClosed: {
        if (iTimer.running)
            iTimer.stop()
    }

    Image {
        id: iOnboardingImg
        anchors.fill: parent
        antialiasing: true
        cache: false
        mipmap: true
        opacity: enabled ? 1 : 0.5
    }

    UiImageButton {
        id:iCloseBtn
        visible: false
        asset: "CloseOnboard"
        UiToolTip.text: qsTranslate("QObject", "Close")
        pImageWidth: 72
        pImageHeight: 72
        onClicked:{
            if (pShowCloseComponent == false) {
                iOnboardingWindow.close()
                plrBackend.destroyOnboardingPopup()
                return
            }

            if (pOnboardingClosePopup != null)
            {
                if (pOnboardingClosePopup.visible)
                    pOnboardingClosePopup.closePopup()
                return
            }
            pOnboardingClosePopup = iOnboardingCloseComponent.createObject(iOnboardingWindow)
            pOnboardingClosePopup.x = iCloseBtn.mapToGlobal(0, 0).x - pOnboardingClosePopup.width + pOnboardingClosePopup.shadowThickness - 10
            pOnboardingClosePopup.y = iCloseBtn.mapToGlobal(0, 0).y - pOnboardingClosePopup.shadowThickness
            pOnboardingClosePopup.show()

        }
    }

    Component {
        id: iOnboardingCloseComponent
        UiWindowedPopup {
            id: iOnboardingClosePopup
            contentWidth: iContentLayout.implicitWidth
            contentHeight: iContentLayout.implicitHeight
            UiColumnLayout {
                id: iContentLayout
                spacing: 10
                padding: 10
                color: UiTheme.colors.primary70
                border.width: 1
                border.color: UiTheme.colors.primary60
                UiButton{
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.accent
                    Layout.preferredWidth: 140
                    text: qsTranslate("QObject", "Close")
                    onClicked: {
                        iOnboardingWindow.close()
                        plrBackend.destroyOnboardingPopup()
                        iOnboardingClosePopup.close()
                    }
                }

                UiButton{
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.tertiary
                    Layout.preferredWidth: 140
                    text: qsTranslate("QObject", "Do not show again")
                    onClicked: {
                        plrBackend.doNotShowOnboardingAgain()
                        iOnboardingWindow.close()
                        plrBackend.destroyOnboardingPopup()
                        iOnboardingClosePopup.close()
                    }
                }
            }
        }
    }

    Timer {
        id: iTimer
        repeat: false
        running: false
        onTriggered: {
            iCloseBtn.visible = true
        }
    }

    function fSetOnboardingImage(imagePath, fillMode, horizontalAlign, verticalAlign, transparency,
                                 showDoNotShowAgain, closeBtnX, closeBtnY, closeBtnTimerSecs) {
        iOnboardingImg.source =  "file:///" + imagePath;
        if (fillMode === "Stretch")
            iOnboardingImg.fillMode = Image.Stretch
        else if (fillMode === "PreserveAspectFit")
            iOnboardingImg.fillMode = Image.PreserveAspectFit
        else if (fillMode === "PreserveAspectCrop")
            iOnboardingImg.fillMode = Image.PreserveAspectCrop
        else
            iOnboardingImg.fillMode = Image.Pad

        if (horizontalAlign === "left")
            iOnboardingImg.horizontalAlignment = Image.AlignLeft
        else if (horizontalAlign === "right")
            iOnboardingImg.horizontalAlignment = Image.AlignRight
        else
            iOnboardingImg.horizontalAlignment = Image.AlignHCenter

        if (verticalAlign === "top")
            iOnboardingImg.verticalAlignment = Image.AlignTop
        else if (verticalAlign === "bottom")
            iOnboardingImg.verticalAlignment = Image.AlignBottom
        else
            iOnboardingImg.verticalAlignment = Image.AlignVCenter

        iOnboardingWindow.color = transparency
        iOnboardingWindow.pShowCloseComponent = showDoNotShowAgain

        if (closeBtnX > 0 && closeBtnY > 0) {
            iCloseBtn.x = Qt.binding(function() {
                return (closeBtnX * iOnboardingWindow.width) / 100
            })
            iCloseBtn.y = Qt.binding(function() {
                return (closeBtnY * iOnboardingWindow.height) / 100
            })
        }

        if (closeBtnTimerSecs > 0) {
            iTimer.interval = (closeBtnTimerSecs * 1000)
            iTimer.start()
        }
        else {
            iCloseBtn.visible = true
        }
    }
}
