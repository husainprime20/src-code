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

UiQuickWindow {
    id: iFlyerWindow
    color: "#E6080A1F"
    flags: Qt.Window | Qt.FramelessWindowHint
    title: uiBackend.productName + " Flyer Window"

    property bool pStatusChanged: false

    onClosed: {
        if (iTimer.running)
            iTimer.stop()
        if (iCloseCounterTimer.running)
            iCloseCounterTimer.stop()
    }

    UiImage {
        id: iBackgroundImg
        anchors.centerIn: parent
        pImageWidth: (iFlyerWindow.width * 8) / 10

        onStatusChanged: {
            if (status == Image.Ready && !pStatusChanged) {
                pStatusChanged = true
                if (iBackgroundImg.height > iFlyerWindow.height) {
                    iBackgroundImg.pImageWidth = 0
                    iBackgroundImg.pImageHeight = Qt.binding(function() { return iFlyerWindow.height })
                }
            }
        }

        Rectangle {
            id: iAdLabelRect
            x: iBackgroundImg.paintedWidth + (iBackgroundImg.width - iBackgroundImg.paintedWidth) / 2 - width
            y: 0 + (iBackgroundImg.height - iBackgroundImg.paintedHeight) / 2
            width: 24
            height: 20
            color: UiTheme.colors.warning

            Text {
                anchors.centerIn: parent
                font: UiTheme.fonts.bodySmall
                color: UiTheme.colors.primary100
                text: qsTranslate("QObject", "Ad")
            }
        }

        UiButton{
            id: iAdActionBtn
            x: iBackgroundImg.paintedWidth + (iBackgroundImg.width - iBackgroundImg.paintedWidth) / 2 - width - 36
            y: iBackgroundImg.paintedHeight + (iBackgroundImg.height - iBackgroundImg.paintedHeight) / 2 - height - 36
            pSize: UiTheme.buttons.sizes.extraLarge
            pColor: UiTheme.buttons.colors.accentWhiteBorder
            visible: false
            text: qsTranslate("QObject", "Play Now")
            onClicked: plrBackend.handleAdsClick(false)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: plrBackend.handleAdsClick(false)
        }
    }

    Rectangle {
        id: iCloseCounterRect
        radius: 20
        width: 40
        height: 40
        color: UiTheme.colors.primary60
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 24
        anchors.rightMargin: 24

        Text {
            id: iCloseCounterText
            anchors.centerIn: parent
            font: UiTheme.fonts.bodyExtraLarge
            color: UiTheme.colors.white
        }

        MouseArea {
            anchors.fill: iCloseCounterRect
            hoverEnabled: true
            onClicked: {
                if (iCloseBtn.visible)
                    plrBackend.handleAdsClick(true)
            }
            onEntered: iCloseCounterRect.color = UiTheme.colors.primary40
            onExited: iCloseCounterRect.color = UiTheme.colors.primary60
        }

        Timer {
            id: iCloseCounterTimer
            repeat: true
            interval: 1000
            running: false
            onTriggered: {
                iCloseCounterText.text = parseInt(iCloseCounterText.text) - 1
            }
        }
    }

    UiImage {
        id: iCloseBtn
        visible: false
        asset: "CloseIcon"
        pImageWidth: 16
        pImageHeight: 16
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 36
        anchors.rightMargin: 36
    }

    Timer {
        id: iTimer
        repeat: false
        running: false
        onTriggered: {
            iCloseCounterTimer.stop()
            iCloseCounterText.visible = false
            iCloseBtn.visible = true
        }
    }

    function fSetFlyerImage(imagePath, crossButtonDelayMs, isCpmStarAd, buttonText) {
        iBackgroundImg.source =  "file:///" + imagePath;

        if (buttonText !== "") {
            iAdActionBtn.text = qsTranslate("QObject", buttonText)
            iAdActionBtn.visible = true
        }
        else {
            iAdActionBtn.visible = false
        }

        if (crossButtonDelayMs > 0) {
            iTimer.interval = crossButtonDelayMs
            iCloseCounterText.text = parseInt(crossButtonDelayMs) / 1000
            iCloseCounterTimer.start()
            iTimer.start()
        }
        else {
            if (iCloseCounterTimer.running)
                iCloseCounterTimer.stop()
            iCloseCounterText.visible = false
            iCloseBtn.visible = true
        }
    }
}
