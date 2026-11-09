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
import UiOverlayControl 1.0

UiQuickWindow {
    id: iFullScreenBlurbWindow
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    width: iFullScreenBlurbLayout.width + iFullScreenBlurbIcon.width + 2 * shadowContainer.shadowThickness
    height: iFullScreenBlurbLayout.implicitHeight + 2 * shadowContainer.shadowThickness
    UiOverlay.overlayRect: Qt.rect(iAppwin.x + plrBackend.plrWinOffsets[0] - adsBackend.pExtendedBannerAdWidth,
                                   iAppwin.y + plrBackend.plrWinOffsets[2],
                                   iAppwin.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1] + adsBackend.pExtendedBannerAdWidth,
                                   iAppwin.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3])

    property alias shadowThickness: shadowContainer.shadowThickness

    onClosed: {
        plrBackend.showGameControlsBlurb()
        iFullScreenBlurbWindow.destroy()
    }

    UiShadowContainer {
        id: shadowContainer
        shadowVisibility: false
        UiImage {
            id: iFullScreenBlurbIcon
            anchors.left: iFullScreenBlurbLayout.right
            anchors.top: iFullScreenBlurbLayout.top
            asset: "SidebarFullScreenIntroduction"
            extn: ".png"
            width: 32
            height: 32
        }

        Shape {
            width: 8
            height: 16
            anchors.top: iFullScreenBlurbLayout.top
            anchors.left: iFullScreenBlurbLayout.right
            anchors.topMargin: 8
            anchors.leftMargin: -2
            ShapePath {
                strokeColor: "#867E96"
                fillColor: "#867E96"
                startX: -1
                startY: 0
                PathLine {
                    x: 8
                    y: 8
                }
                PathLine {
                    x: -1
                    y: 16
                }
            }
            ShapePath {
                strokeColor: "#867E96"
                fillColor: "#867E96"
                startX: 0
                startY: 0
                PathLine {
                    x: 8
                    y: 8
                }
                PathLine {
                    x: 0
                    y: 16
                }
            }
        }

        UiColumnLayout {
            id: iFullScreenBlurbLayout
            width: 300
            color: UiTheme.colors.cloudGradientSecondary
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0; color: UiTheme.colors.cloudGradientSecondary }
                GradientStop { position: 1; color: UiTheme.colors.cloudGradientPrimary }
            }
            UiColumnLayout {
                Layout.fillWidth: true
                border.width: 1
                border.color: "#4DFFFFFF"
                padding: 24
                spacing: 16
                color: UiTheme.colors.cloudGradientSecondary
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0; color: UiTheme.colors.cloudGradientSecondary }
                    GradientStop { position: 1; color: UiTheme.colors.cloudGradientPrimary }
                }

                UiImage {
                    Layout.alignment: Qt.AlignHCenter
                    asset: "FullScreenIntroduction"
                    extn: ".png"
                    Layout.preferredWidth: 126
                    Layout.preferredHeight: 90
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        font: UiTheme.fonts.titleSmall
                        color: UiTheme.colors.primary10
                        text: qsTranslate("QObject", "Play in Fullscreen")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: UiTheme.colors.overLayTint
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: UiTheme.colors.transparent }
                            GradientStop { position: 0.5; color: UiTheme.colors.overLayTint }
                            GradientStop { position: 1; color: UiTheme.colors.transparent }
                        }
                    }

                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            UiRowLayout {
                                radius: 2
                                border.width: 1
                                border.color: UiTheme.colors.warning
                                color: UiTheme.colors.overLayTint
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 24
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    font: UiTheme.fonts.titleSmallest
                                    color: UiTheme.colors.primary10
                                    text: "F11"
                                }
                            }
                            Text {
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary20
                                text: qsTranslate("QObject", "Use shortcut")
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            UiRowLayout {
                                radius: 2
                                border.width: 1
                                border.color: UiTheme.colors.overLayTint
                                color: UiTheme.colors.overLayTint
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 24
                                UiImage {
                                    Layout.alignment: Qt.AlignHCenter
                                    asset: "SidebarFullScreenSmall"
                                    extn: ".png"
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                }
                            }
                            Text {
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary20
                                text: qsTranslate("QObject", "Click icon on sidebar")
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: UiTheme.colors.overLayTint
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: UiTheme.colors.transparent }
                            GradientStop { position: 0.5; color: UiTheme.colors.overLayTint }
                            GradientStop { position: 1; color: UiTheme.colors.transparent }
                        }
                    }
                }

                UiButton {
                    Layout.alignment: Qt.AlignHCenter
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.accent
                    text: qsTranslate("QObject", "Continue")
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered:  {
                            cursorShape = Qt.PointingHandCursor
                        }
                        onExited:  {
                            cursorShape = Qt.ArrowCursor
                        }
                        onClicked: {
                            iFullScreenBlurbWindow.close()
                        }
                    }
                }
            }
        }
    }
}
