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
import QtWebEngine
import QtWebChannel

Window {
    id: iChatWindow
    width: 252
    height: 218
    color: "transparent"
    title: uiBackend.productName + " Ana"
    flags: Qt.Window | Qt.FramelessWindowHint
    x: iChatWindow.transientParent.x + iChatWindow.transientParent.width - plrBackend.plrWinOffsets[1] - iChatWindow.width + 2
    y: iChatWindow.transientParent.y + iChatWindow.transientParent.height - plrBackend.plrWinOffsets[3] - iChatWindow.height - 2

    property string pImageName: "Pie64"

    WebEngineView {
        id: iWebEngineView
        focus: true
        backgroundColor: "transparent"
        anchors.fill: parent
        anchors.left: parent.left
        anchors.topMargin: 4
        anchors.rightMargin: 4

        settings.javascriptEnabled: true
        settings.javascriptCanOpenWindows: true
        settings.javascriptCanAccessClipboard: true
        settings.javascriptCanPaste: true
        settings.dnsPrefetchEnabled: true
        profile.httpAcceptLanguage: uiBackend.getPreferredLocaleWeighted()

        onLoadProgressChanged: {
            if (iWebEngineView.loadProgress > 99)
                plrBackend.initChat()
        }

        onLoadingChanged: function(loadingInfo) {
            if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
                console.error("Ana ::: Failed to load chat, err : " + loadingInfo.errorString)
                iWebEngineView.visible = false
            }
            else if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                iWebEngineView.visible = true
                iWebEngineView.focus = true
            }
        }

        url: uiBackend.confGetString("bst.bluestacks_cloud_url")
             + "/app_player/get_chatbot_html?guid=" + uiBackend.confGetString("bst.guid")
             + "&player_version=" + plrBackend.version
             + "&instance=" + pImageName
             + "&os_version=" + uiBackend.osVersion
             + "&country=" + uiBackend.confGetString("bst.country")

        webChannel: plrBackend.pChatWebChannel
        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            console.debug(iWebEngineView.renderProcessPid + " " + lineNumber + " [WebEngineConsoleLog] " + level + ": " + message)
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.topMargin: 4
        anchors.rightMargin: 4
        radius: 8
        visible: !iWebEngineView.visible
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#7B4CFF" }
            GradientStop { position: 1.0; color: "#0EA4C5" }
        }
        layer.enabled: true
        layer.smooth: true

        UiColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.topMargin: 1
            anchors.bottomMargin: 1
            leftPadding: 12
            rightPadding: 12
            topPadding: 4
            bottomPadding: 4
            spacing: 8
            radius: 8
            color: UiTheme.colors.primary80

            UiRowLayout {
                Layout.preferredHeight: 40
                Layout.fillWidth: true
                spacing: 4

                UiImage {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    pImageHeight: 36
                    pImageWidth: 36
                    pUseSourceSize: false
                    Layout.alignment: Qt.AlignLeft
                    asset: "AnaIcon"
                    extn: ".png"
                }
                Text {
                    text: qsTranslate("QObject", "Ana AI")
                    font : UiTheme.fonts.titleSmall
                    color: UiTheme.colors.white
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: false
                    elide: Text.ElideRight
                }
                UiImage {
                    pImageHeight: 14
                    pImageWidth: 14
                    Layout.alignment: Qt.AlignLeft
                    asset: "Stars"
                }
                Item { Layout.fillWidth: true }
                UiImageButton {
                    pImageWidth: 32
                    pImageHeight: 32
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    asset: "Minimize"
                    onClicked: {
                        plrBackend.showChatWindow()
                    }
                }
            }

            Rectangle {
                color: UiTheme.colors.white
                opacity: 0.1
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            UiColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Item { Layout.fillHeight: true }
                UiImage {
                    asset: "NoInternet"
                    pImageWidth: 72
                    pImageHeight: 72
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: qsTranslate("QObject", "No Internet")
                    font : UiTheme.fonts.titleSmall
                    color: UiTheme.colors.white
                    horizontalAlignment: Text.AlignHCenter
                    Layout.topMargin: 8
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: qsTranslate("QObject", "Please check your internet connection")
                    font : UiTheme.fonts.bodySmall
                    color: UiTheme.colors.primary20
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: Math.min(222, iChatWindow.width - 30)
                }
                UiButton{
                    pColor: UiTheme.buttons.colors.accent
                    Layout.topMargin: 8
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTranslate("QObject", "Try again")
                    opacity: hovered ? 0.8 : 1
                    btnGradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0EA4C5" }
                        GradientStop { position: 1.0; color: "#7B4CFF" }
                    }
                    pSize: QtObject {
                        property real height: 32
                        property real radius: 18
                        property real horizontalPadding: 20
                        property real spacing: 8
                        property font textFont: UiTheme.fonts.bodySmall
                        property font subTextFont: UiTheme.fonts.bodyExtraSmall
                        property real iconWidth: 16
                        property real iconHeight: 16
                    }
                    onClicked: {
                        console.info("Ana ::: try again clicked")
                        iWebEngineView.reload()
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }

    }

    function fSetChatWindowSize(windowWidth, windowHeight) {
        //if(windowHeight > (iChatWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3] - 2))
        if (windowHeight > iChatWindow.height)
            windowHeight = iChatWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3] - 2

        //if (windowHeight < (iChatWindow.transientParent.height - plrBackend.plrWinOffsets[2]- plrBackend.plrWinOffsets[3]) / 2)
        //    windowHeight = (iChatWindow.transientParent.height - plrBackend.plrWinOffsets[2]- plrBackend.plrWinOffsets[3]) / 2

        if (windowWidth > (iChatWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1]))
            windowWidth = iChatWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1]

        iChatWindow.width = windowWidth
        iChatWindow.height = windowHeight
    }

    function fRunJavaScriptMethod(method) {
        iWebEngineView.runJavaScript(method)
    }
}
