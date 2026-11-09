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
    id: iImapAbortWindow
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
        plrBackend.showFullScreenBlurb()
        iImapAbortWindow.destroy()
    }

    UiShadowContainer {
        id: shadowContainer
        shadowVisibility: false
        UiImage {
            id: iFullScreenBlurbIcon
            anchors.left: iFullScreenBlurbLayout.right
            anchors.top: iFullScreenBlurbLayout.top
            asset: "SidebarImapAbortIntroduction"
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
                strokeColor: "#454954"
                fillColor: "#454954"
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
                strokeColor: "#454954"
                fillColor: "#454954"
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
                border.color: "#FF454954"
                padding: 24
                spacing: 16
                color: UiTheme.colors.cloudGradientSecondary
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0; color: "#FF21242C" }
                    GradientStop { position: 1; color: "#FF21242C" }
                }

                UiImage {
                    id: iIco
                    Layout.alignment: Qt.AlignHCenter
                    asset: "ImapAbortIntroduction"
                    extn: ".png"

                    Component.onCompleted: {
                        Layout.preferredWidth = 130 //implicitWidth*0.3
                        Layout.preferredHeight = 79 //implicitHeight*0.3
                    }
                }

                
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        font: UiTheme.fonts.titleSmall
                        color: "#FFF7FAFF"
                        text: qsTranslate("QObject", "Reset the Controller")
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
                        spacing: 6
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            UiRowLayout {
                                radius: 2
                                border.width: 1
                                border.color: "#66FFFFFF"
                                color: "#33FFFFFF"
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 24
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    font: UiTheme.fonts.titleSmallest
                                    color: UiTheme.colors.primary10
                                    text: "R3"
                                }
                            }
                            Text {
                                font: UiTheme.fonts.bodyMedium
                                color: "#FF8F94A3"
                                text: qsTranslate("QObject", "Press R3 on the controller to reset")
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                        }

                        Row {
                            property int itemSpacing: 6
                            property int itemEdge: 26

                            id: iRow
                            spacing: itemSpacing
                            anchors.centerIn: parent
                            height: iText.height  

                            Rectangle {
                                width: iFullScreenBlurbLayout.width/2-iText.width-iRow.itemSpacing-iRow.itemEdge
                                height: 1
                                color: "transparent"  
                                anchors.verticalCenter: parent.verticalCenter

                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.strokeStyle = "#0FFFFFFF"
                                        ctx.setLineDash([2, 2])
                                        ctx.beginPath()
                                        ctx.moveTo(0, height/2)
                                        ctx.lineTo(width, height/2)
                                        ctx.stroke()
                                    }
                                }
                            }

                            Text {
                                id: iText
                                text: qsTranslate("QObject", "Or").toUpperCase()
                                font: UiTheme.fonts.bodySmallest
                                color: "#FF454954"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: iFullScreenBlurbLayout.width/2-iText.width-iRow.itemSpacing-iRow.itemEdge
                                height: 1
                                color: "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                Canvas {
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.strokeStyle = "#0FFFFFFF"
                                        ctx.setLineDash([2, 2])
                                        ctx.beginPath()
                                        ctx.moveTo(0, height/2)
                                        ctx.lineTo(width, height/2)
                                        ctx.stroke()
                                    }
                                }
                            }
                        }

                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            UiRowLayout {
                                radius: 2
                                border.width: 1
                                border.color: "#66FFFFFF"
                                color: "#33FFFFFF"
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 24
                                UiImage {
                                    Layout.alignment: Qt.AlignHCenter
                                    asset: "SidebarImapAbortSmall"
                                    extn: ".png"
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                }
                            }
                            Text {
                                font: UiTheme.fonts.bodyMedium
                                color: "#FF8F94A3"
                                text: qsTranslate("QObject", "Press the reset button here")
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
                            iImapAbortWindow.close()
                        }
                    }
                }
            }
        }
    }
}
