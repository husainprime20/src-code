/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15

Window {
    id: iLoadingWindow
    color: "transparent"
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    title: uiBackend.productName + " Loading"
    screen: transientParent.screen
    width: 192 + 2* iShadow.shadowThickness
    height: 109 + 2* iShadow.shadowThickness

    property var pText: qsTranslate("QObject", "Restarting")
    property bool pImageAnimationRunning: false

    onClosing: {
        pImageAnimationRunning = false
    }

    onVisibleChanged: {
        pImageAnimationRunning = visible
    }

    UiShadowContainer{
        id:iShadow
        UiColumnLayout {
            anchors.fill: parent
            color: UiTheme.colors.primary70
            UiImage {
                id: iLoadinImg
                asset: "Loader_bright"
                pImageWidth: 16
                pImageHeight: 16
                Layout.topMargin: 26
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                cache: false
                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    duration: 2000
                    from: 0
                    to: 360
                    direction: RotationAnimation.Clockwise
                    running: iLoadingWindow.pImageAnimationRunning
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.bottomMargin: 24
                text: pText
                font: UiTheme.fonts.bodyLarge
                color: UiTheme.colors.primary20
            }
        }
    }
}
