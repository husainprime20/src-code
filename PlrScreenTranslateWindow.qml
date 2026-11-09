/*
 * Copyright (C) 2020 BlueStack Systems, Inc.
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
import UiLiveImage 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import UiHelper 1.0
import QtQuick.Shapes 1.12
import Qt.labs.platform 1.1

Window {
    id: iScreenTranslateWindow
    objectName: "iScreenTranslateWindow"
    color: UiTheme.colors.overlayPrimary
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Translated image")
    screen: transientParent.screen
    width: transientParent.width
    height: transientParent.height
    x: transientParent.x
    y: transientParent.y

    property bool pImageVisible: false
    property var pTranslatedImage
    onPImageVisibleChanged: {
        iLoadingWindow.visible = !pImageVisible
    }

    Component.onCompleted: {
        uiBackend.pIsShortcutsEnabled = false
    }

    Component {
        id: iErrorPrompt
        UiMessageDialog {
            id: iErrorPromptDialog
            title: qsTranslate("QObject", "Translation error")
            pDescription: qsTranslate( "QObject", "An unexpected error has occured. Please check your internet connection and try again.")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject",  "Try again")
                        onClicked: {
                            iErrorPromptDialog.close()                            
                            iScreenTranslateWindow.close()
                            fReOpenScreenTranslateWindow()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            iErrorPromptDialog.close()
                            iScreenTranslateWindow.close()
                        }
                    }
                ]
            }
            onCloseClicked: {
                iScreenTranslateWindow.close()
            }
        }
    }

    Item {
        focus: true
        Keys.onEscapePressed: iScreenTranslateWindow.close()
    }

    Rectangle {
        id: iImageWindow
        visible: pImageVisible

        anchors{
            fill: parent
            leftMargin: plrBackend.plrWinOffsets[0]
            rightMargin: plrBackend.plrWinOffsets[1]
            topMargin: plrBackend.plrWinOffsets[2]
            bottomMargin: plrBackend.plrWinOffsets[3]
        }

        color: UiTheme.colors.black
        border.width: 1
        border.color: UiTheme.colors.primary60
        UiColumnLayout {
            id: iColumnLayout
            anchors.margins: 1
            spacing: 0
            anchors.fill: parent
            Rectangle {
                id: iTopbar
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                color: UiTheme.colors.primary60
                height: 32

                UiRowLayout {
                    anchors.fill: parent

                    Text {
                        text: qsTranslate("QObject", "Translated image")
                        color: UiTheme.colors.secondaryHover
                        font: UiTheme.fonts.titleExtraSmall
                        Layout.leftMargin: 12
                        horizontalAlignment: Text.AlignLeft
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    UiImageButton {
                        asset: "TitlebarClose"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Close")
                        onClicked: iScreenTranslateWindow.close()
                    }
                }
            }

            UiLiveImage {
                property var pAspectRatio: plrBackend.getAspectedRatio()
                property real _height: iColumnLayout.height - 32
                property real _width: Math.min(iColumnLayout.width, (iColumnLayout.height - 32) * pAspectRatio)
                id:iTranslatedImg
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                image: LiveImageProvider.image
                pHeight: _height
                pWidth: _width
                Layout.leftMargin: (iColumnLayout.width - _width) / 2
            }
        }
    }

    Rectangle {
        id: iLoadingWindow
        visible: !pImageVisible

        anchors{
            centerIn: parent
            leftMargin: 44
            rightMargin: 44
            topMargin: 16
            bottomMargin: 16
        }
        width: 192
        height: 108
        color: UiTheme.colors.primary70
        border.width: 1
        border.color: UiTheme.colors.primary60

        UiColumnLayout {
            Layout.fillHeight: true
            anchors.fill: parent
            Layout.alignment: Qt.AlignHCenter

            UiImage {
                id: iLoadingImg
                asset: "Loader_bright"
                pImageWidth: 16
                pImageHeight: 16
                Layout.topMargin: 20
                Layout.alignment: Qt.AlignHCenter
                cache: false
                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    duration: 2000
                    from: 0
                    to: 360
                    direction: RotationAnimation.Clockwise
                    running: iLoadingWindow.visible
                }
            }
            UiText {
                text: qsTranslate("QObject", "Loading translation")
                color: UiTheme.colors.primary20
                font: UiTheme.fonts.bodyLarge
                horizontalAlignment: Text.AlignHCenter
                Layout.bottomMargin: 20
                Layout.fillWidth: true
            }
        }
    }

    function fShowErrorMsg()
    {
        iLoadingWindow.visible = false
        iErrorPrompt.createObject(iScreenTranslateWindow, { "transientParent": iScreenTranslateWindow }).show()
    }
}
