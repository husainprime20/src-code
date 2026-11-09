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
    id: iGamePopupWindow
    width: Math.min((height * 7.0) / 16, 242)
    height: iGamePopupWindow.transientParent.height
    color: "transparent"
    title: uiBackend.productName + " Game Pulse"
    flags: Qt.Window | Qt.FramelessWindowHint
    x: iGamePopupWindow.transientParent.x + iGamePopupWindow.transientParent.width
    y: iGamePopupWindow.transientParent.y

    onClosing: {
        iGamePopupWindow.destroy()
    }

    UiColumnLayout {
        spacing: 4
        anchors.fill: parent
        color: UiTheme.colors.primary80
        border.width: 1
        border.color: UiTheme.colors.primary60

        UiColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: rightPanelBackend.pBannerAvailable

            UiColumnLayout {
                id: iWebEngineLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: false

                WebEngineView {
                    id: iWebEngineView
                    focus: true
                    backgroundColor: "transparent"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    webChannel: rightPanelBackend.pData.pWebChannel

                    settings.javascriptEnabled: true
                    settings.javascriptCanOpenWindows: true
                    settings.javascriptCanAccessClipboard: true
                    settings.javascriptCanPaste: true
                    settings.dnsPrefetchEnabled: true
                    settings.showScrollBars: false
                    profile.httpAcceptLanguage: uiBackend.getPreferredLocaleWeighted()

                    onLoadingChanged: function(loadingInfo) {
                        if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
                            console.error("Failed to load right side panel, err : " + loadingInfo.errorString)
                            iWebEngineLayout.visible = false
                            iLoader.visible = false
                        }
                        else if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                            iWebEngineLayout.focus = true
                            iLoader.visible = false
                            iWebEngineLayout.visible = true
                        }
                    }

                    url: rightPanelBackend.pData.pWebEngineViewUrl

                    onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
                        console.debug(iWebEngineView.renderProcessPid + " " + lineNumber + " [WebEngineConsoleLog] " + level + ": " + message)
                    }
                }

                UiRowLayout {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    visible: rightPanelBackend.pData.pDisableDays > 0

                    UiCheckBox {
                        id: iDisableCheckbox
                        checked: false
                        pSize: UiTheme.checkBoxes.sizes.small
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("QObject", "Hide this message for %1 days").arg(rightPanelBackend.pData.pDisableDays)
                        onCheckedChanged: {
                            rightPanelBackend.pData.disableBannerClicked(checked)
                        }
                    }
                }
            }

            UiColumnLayout {
                id: iNoInternetLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignVCenter
                visible: !iWebEngineLayout.visible

                UiImageButton {
                    asset: "CloseIcon"
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    Layout.rightMargin: 8
                    Layout.topMargin: 8
                    pImageWidth: 16
                    pImageHeight: 16
                    onClicked: rightPanelBackend.hideRightSidePanel()
                }

                Item { Layout.fillHeight: true }

                UiImage {
                    id: iLoader
                    Layout.alignment: Qt.AlignHCenter
                    asset: "Loader_bright"
                    pImageWidth: 16
                    pImageHeight: 16
                    cache: false
                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        duration: 2000
                        from: 0
                        to: 360
                        direction: RotationAnimation.Clockwise
                        running: iLoader.visible
                    }
                }
                UiImage {
                    asset: "NoWifi"
                    pImageWidth: 72
                    pImageHeight: 72
                    Layout.alignment: Qt.AlignHCenter
                    visible: !iLoader.visible
                }
                Text {
                    text: qsTranslate("QObject", "You are offline")
                    font : UiTheme.fonts.titleMedium
                    color: UiTheme.colors.white
                    horizontalAlignment: Text.AlignHCenter
                    Layout.topMargin: 24
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: !iLoader.visible
                }
                Text {
                    text: qsTranslate("QObject", "Please check your internet connection and try again")
                    font : UiTheme.fonts.bodySmall
                    color: UiTheme.colors.primary20
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: 200
                    visible: !iLoader.visible
                }
                UiButton{
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.accent
                    Layout.topMargin: 8
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTranslate("QObject", "Reload")
                    opacity: hovered ? 0.8 : 1
                    visible: !iLoader.visible
                    onClicked: {
                        console.info("RightPanel ::: reload clicked")
                        iWebEngineView.reload()
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        UiColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !rightPanelBackend.pBannerAvailable
            Layout.alignment: Qt.AlignVCenter

            UiImageButton {
                asset: "CloseIcon"
                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                Layout.rightMargin: 8
                Layout.topMargin: 8
                pImageWidth: 16
                pImageHeight: 16
                onClicked: rightPanelBackend.hideRightSidePanel()
            }


            Item { Layout.fillHeight: true }
            UiImage {
                asset: "InfoBlue"
                pImageWidth: 72
                pImageHeight: 72
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: qsTranslate("QObject", "Nothing to see here")
                font : UiTheme.fonts.titleMedium
                color: UiTheme.colors.white
                horizontalAlignment: Text.AlignHCenter
                Layout.topMargin: 24
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            Text {
                text: qsTranslate("QObject", "Check back later")
                font : UiTheme.fonts.bodySmall
                color: UiTheme.colors.primary20
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.topMargin: 8
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                Layout.maximumWidth: 200
            }
            Item { Layout.fillHeight: true }
        }

    }

    function fRunJavaScriptMethod(method) {
        iWebEngineView.runJavaScript(method)
    }
}
