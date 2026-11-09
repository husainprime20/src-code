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
import UiQuickWindow 1.0

UiQuickWindow {
    id: iExitPromotionsWindow
    color: "transparent"
    flags: Qt.Dailog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: "BlueStacks Exit Window"
    width: 360 + 2 * iShadow.shadowThickness
    height: iMainLayout.implicitHeight + 2 * iShadow.shadowThickness

    onClosed: {
        iExitPromotionsWindow.destroy()
    }

    onVisibleChanged: {
        if (visible) {
            if (iExitPromotionsWindow.transientParent != null) {
                iExitPromotionsWindow.x = Qt.binding(function() {
                    var messageWindowX = iExitPromotionsWindow.transientParent.x + (iExitPromotionsWindow.transientParent.width - iExitPromotionsWindow.width) / 2
                    if (messageWindowX < iExitPromotionsWindow.transientParent.screen.virtualX)
                        messageWindowX = iExitPromotionsWindow.transientParent.screen.virtualX
                    if(messageWindowX + iExitPromotionsWindow.width > iExitPromotionsWindow.transientParent.screen.virtualX + iExitPromotionsWindow.transientParent.screen.width)
                        messageWindowX = iExitPromotionsWindow.transientParent.screen.virtualX + iExitPromotionsWindow.transientParent.screen.width - iExitPromotionsWindow.width
                    return messageWindowX
                })
                iExitPromotionsWindow.y = Qt.binding(function() {
                    var messageWindowY = iExitPromotionsWindow.transientParent.y + (iExitPromotionsWindow.transientParent.height - iExitPromotionsWindow.height) / 2
                    if (messageWindowY < iExitPromotionsWindow.transientParent.screen.virtualY)
                        messageWindowY = iExitPromotionsWindow.transientParent.screen.virtualY
                    if(messageWindowY + iExitPromotionsWindow.height > iExitPromotionsWindow.transientParent.screen.virtualY + iExitPromotionsWindow.transientParent.screen.height)
                        messageWindowY = iExitPromotionsWindow.transientParent.screen.virtualY + iExitPromotionsWindow.transientParent.screen.height - iExitPromotionsWindow.height
                    return messageWindowY
                })
            }
        }
    }

    UiShadowContainer {
        id:iShadow
        UiColumnLayout {
            id: iMainLayout
            anchors.fill: parent
            leftPadding: 24
            rightPadding: 24
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary40

            UiRowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                spacing: 8
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignLeft
                    text: qsTranslate("QObject", "Close %1").arg(uiBackend.confGetInstanceString("display_name"))
                    font: UiTheme.fonts.titleMedium
                    color: UiTheme.colors.primary10
                    elide: Text.ElideRight
                }
                UiImageButton {
                    asset: "CloseIcon"
                    pImageWidth: 16
                    pImageHeight: 16
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        iExitPromotionsWindow.close()
                    }
                }
            }

            UiColumnLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 16
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                spacing: 8

                Text {
                    text: plrBackend.pExitPromotionViewModel.pTitleString !== "" ? plrBackend.pExitPromotionViewModel.pTitleString : qsTranslate("QObject", "Would you like to try these popular games before you go?")
                    Layout.fillWidth: true
                    font: UiTheme.fonts.bodyLarge
                    color: UiTheme.colors.primary20
                    wrapMode: Text.Wrap
                }

                ListView {
                    id: pExitPromotionsList
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.leftMargin: 12
                    model: plrBackend.pExitPromotionViewModel
                    spacing: 0
                    orientation: ListView.Vertical
                    interactive: false
                    implicitHeight: contentHeight

                    delegate: UiRowLayout {
                        id: iPromotionRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 56
                        UiImage {
                            source: model.image
                            pImageWidth: 40
                            pImageHeight: 40
                            Layout.alignment: Qt.AlignVCenter
                        }
                        UiColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Text {
                                text: model.name
                                Layout.fillWidth: true
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary20
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignVCenter
                            }
                            Text {
                                text: model.description
                                Layout.topMargin: 4
                                Layout.fillWidth: true
                                font: UiTheme.fonts.bodyExtraSmall
                                color: UiTheme.colors.primary30
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                horizontalAlignment: Text.AlignVCenter
                            }
                        }
                        UiImage {
                            asset: model.action === "UserBrowser" ? "LinkArrow" : "RightArrow"
                            pImageWidth: 16
                            pImageHeight: 16
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 20
                        }

                        pMouseArea {
                            anchors.fill: iPromotionRow
                            enabled: true
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            cursorShape: iPromotionRow.pMouseArea.containsMouse ?
                                             iPromotionRow.pMouseArea.containsPress ?
                                                 Qt.ClosedHandCursor : Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                plrBackend.pExitPromotionViewModel.perfomClickAction(index)
                                iExitPromotionsWindow.close()
                            }
                        }
                    }
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.bottomMargin: 16
                spacing: 16

                UiButton {
                    Layout.preferredWidth: 136
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.secondary
                    text: qsTranslate("QObject", "Cancel")
                    onClicked: {
                        iExitPromotionsWindow.close()
                    }
                }

                UiButton {
                    Layout.preferredWidth: 136
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.danger
                    text: qsTranslate("QObject", "Close")
                    onClicked: {
                        iExitPromotionsWindow.close()
                        plrBackend.onCloseCalled()
                    }
                }
            }
        }
    }
}
