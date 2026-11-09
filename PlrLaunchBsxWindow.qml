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
import UiToolTipControl 1.0
import UiQuickWindow 1.0

UiQuickWindow {
    id: iLaunchBsxWindow
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    width: 860 + 2 * shadowContainer.shadowThickness
    height: iMainLayout.implicitHeight + 2 * shadowContainer.shadowThickness

    onClosed: {
        iLaunchBsxWindow.destroy()
    }

    onVisibleChanged: {
        if (visible) {
            if (iLaunchBsxWindow.transientParent !== null) {
                iLaunchBsxWindow.x = Qt.binding(function() {
                    var messageWindowX = iLaunchBsxWindow.transientParent.x + (iLaunchBsxWindow.transientParent.width - iLaunchBsxWindow.width) / 2
                    if (messageWindowX < iLaunchBsxWindow.transientParent.screen.virtualX)
                        messageWindowX = iLaunchBsxWindow.transientParent.screen.virtualX
                    if(messageWindowX + iLaunchBsxWindow.width > iLaunchBsxWindow.transientParent.screen.virtualX + iLaunchBsxWindow.transientParent.screen.width)
                        messageWindowX = iLaunchBsxWindow.transientParent.screen.virtualX + iLaunchBsxWindow.transientParent.screen.width - iLaunchBsxWindow.width
                    return messageWindowX
                })
                iLaunchBsxWindow.y = Qt.binding(function() {
                    var messageWindowY = iLaunchBsxWindow.transientParent.y + (iLaunchBsxWindow.transientParent.height - iLaunchBsxWindow.height) / 2
                    if (messageWindowY < iLaunchBsxWindow.transientParent.screen.virtualY)
                        messageWindowY = iLaunchBsxWindow.transientParent.screen.virtualY
                    if(messageWindowY + iLaunchBsxWindow.height > iLaunchBsxWindow.transientParent.screen.virtualY + iLaunchBsxWindow.transientParent.screen.height)
                        messageWindowY = iLaunchBsxWindow.transientParent.screen.virtualY + iLaunchBsxWindow.transientParent.screen.height - iLaunchBsxWindow.height
                    return messageWindowY
                })
            }
        }
    }

    UiShadowContainer {
        id: shadowContainer
        UiImage {
            asset: "Background"
            pImageWidth: parent.width
            pImageHeight: parent.height
            extn :".jpg"
        }
        UiColumnLayout{
            id : iMainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20
            padding: 20
            UiRowLayout{
                Layout.fillWidth: true
                UiImageButton {
                    Layout.alignment: Qt.AlignRight
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    onClicked: iLaunchBsxWindow.close()
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                id: iLaunchBsxLayout
                spacing: 56
                leftPadding: 56
                rightPadding: 56
                bottomPadding: 40
                UiImage {
                    asset: "ProductLogoX"
                    pImageWidth: 240
                    pImageHeight: 200
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    UiColumnLayout{
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            font: UiTheme.fonts.titleLargest
                            color: UiTheme.colors.primary10
                            text: qsTranslate("QObject", "Play Android games instantly")
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        Text {
                            font: UiTheme.fonts.bodyExtraLarge
                            color: UiTheme.colors.warning
                            text: qsTranslate("QObject", "powered by Cloud")
                        }
                    }
                    ListView {
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        spacing: 12
                        clip: true
                        model: [
                            qsTranslate("QObject", "No download required"),
                            qsTranslate("QObject", "No device limitations"),
                            qsTranslate("QObject", "New games every week")
                        ]
                        delegate: UiRowLayout{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 8
                            UiImage  {
                                asset: "RecordSmall"
                                pImageHeight: 22
                                pImageWidth: 22
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodyLargest
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                    UiButton{
                        pSize: UiTheme.buttons.sizes.extraLarge
                        pColor: UiTheme.buttons.colors.accent
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        text: qsTranslate("QObject", "Try %1 X").arg(uiBackend.productName)
                        onClicked: {
                            plrBackend.launchBlueStacksX()
                            iLaunchBsxWindow.close()
                        }
                    }
                }
            }
        }
    }
}

