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

import UiDialogWindow 1.0
import UiToolTipControl 1.0
import UiOverlayControl 1.0

UiDialogWindow {
    id: iExploreWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    x: iExploreWindow.transientParent.x + plrBackend.plrWinOffsets[0] + (iExploreWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1] - iExploreWindow.width) / 2
    y: iExploreWindow.transientParent.y + plrBackend.plrWinOffsets[2] + (iExploreWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3] - iExploreWindow.height) / 2
    width: 642
    height: iExploreStreamLayout.implicitHeight
    UiOverlay.overlayRect: Qt.rect(iExploreWindow.transientParent.x + plrBackend.plrWinOffsets[0],
                                   iExploreWindow.transientParent.y + plrBackend.plrWinOffsets[2],
                                   iExploreWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1],
                                   iExploreWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3])

    onClosed: iExploreWindow.destroy()

    UiColumnLayout {
        id: iExploreStreamLayout
        anchors.fill: parent
        color: UiTheme.colors.primary70
        border.color: UiTheme.colors.primary50
        border.width: 1
        padding: 16
        spacing: 8
        UiImageButton {
            asset: "CloseIcon"
            UiToolTip.text: qsTranslate("QObject", "Close")
            pImageWidth: 16
            pImageHeight: 16
            Layout.alignment: Qt.AlignRight
            onClicked: {
                iExploreWindow.close()
            }
        }
        UiImage {
            pImageHeight: 72
            pImageWidth: 72
            asset: "StreamOnboarding"
            Layout.alignment: Qt.AlignCenter
        }
        UiText {
            Layout.maximumWidth: 402
            text: qsTranslate("QObject", "Play together")
            font: UiTheme.fonts.titleExtraLarge
            color: UiTheme.colors.primary10
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
        }
        UiTextUrl {
            Layout.maximumWidth: 402
            Layout.fillWidth: true
            text: qsTranslate("QObject", "Invite your friends to your live stream—play, chat, and let them control your game. ") + "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "Learn more") + "</a>"
            font: UiTheme.fonts.bodyLarge
            color: UiTheme.colors.primary20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignCenter
            linkColor: UiTheme.colors.accentNormal
            onLinkActivated: uiBackend.openHelpArticle("live_stream_help")
        }
        UiImage {
            Layout.topMargin: 16
            pImageHeight: 130
            pImageWidth: 490
            asset: "GameRoomExplore"
            extn: ".png"
            Layout.alignment: Qt.AlignCenter
        }
        UiButton {
            Layout.topMargin: -16
            Layout.alignment: Qt.AlignCenter
            pImageAfterText: true
            asset: "Continue"
            pSize: UiTheme.buttons.sizes.medium
            pColor: UiTheme.buttons.colors.accent
            text: qsTranslate("QObject", "View supported games")
            onClicked: {
                plrBackend.openPlayTogetherStore()
                iExploreWindow.close()
                lsgBackend.sendLiveStreamStats("supported_games_button_clicked", "")
            }
        }
    }
}
