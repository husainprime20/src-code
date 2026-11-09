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
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

ApplicationWindow {
    id: iAppDataDiskCorruptionProgressWin
    height: iMainColumnLayout.implicitHeight
    width: iMainColumnLayout.width
    visible: true
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    color: UiTheme.colors.primary70

    property var pProgressValue: 0
    signal instanceCreationProgressClosed()

    UiColumnLayout{
        id: iMainColumnLayout
        width: 320
        padding: 24
        spacing: 20
        UiImage {
            id: iLoader
            asset: "Loader_bright"
            pImageWidth: 20
            pImageHeight: 20
            cache: false
            Layout.alignment: Qt.AlignCenter
            RotationAnimation on rotation {
                loops: Animation.Infinite
                duration: 2000
                from: 0
                to: 360
                direction: RotationAnimation.Clockwise
                running: iLoader.visible
            }
        }

        UiColumnLayout{
            Layout.fillWidth: true
            spacing: 4
            Text {
                text: qsTranslate("QObject","Minor repair in progress")
                Layout.fillWidth: true
                color:  UiTheme.colors.primary10
                font : UiTheme.fonts.titleMedium
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
            }

            Text {
                text: qsTranslate("QObject","A few more moments, it will be done in no time at all.")
                Layout.fillWidth: true
                color: UiTheme.colors.primary20
                font: UiTheme.fonts.bodyLarge
                wrapMode: Text.Wrap
                Layout.alignment: Qt.AlignCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component {
        id: iSuccessPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Repair successful")
            pDescription: qsTranslate("QObject", "You can now start BlueStacks.")
            pDialogType: UiDialogWindow.Simple
            pDialogImageSource: "SuccessIcon"
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Okay")
                        onClicked: {
                            close()
                            Qt.quit()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iFailurePrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Something went wrong")
            pDescription: qsTranslate("QObject", "Please contact %1 for further assistance.").arg("<a href=\"http:\\support.bluestacks.com\">support@bluestacks.com</a>")
            pDialogType: UiDialogWindow.DescriptiveNarrow
            pDialogImageSource: "WarningIcon"
            onHyperlinkClicked: Qt.openUrlExternally("mailto:?to=support@bluestacks.com")
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Okay")
                        onClicked: {
                            close()
                            Qt.quit()
                        }
                    }
                ]
            }
        }
    }



    function fShowSuccessPrompt()
    {
        iAppDataDiskCorruptionProgressWin.hide()
        iSuccessPrompt.createObject(iAppDataDiskCorruptionProgressWin, { "transientParent": iAppDataDiskCorruptionProgressWin }).show()
    }

    function fShowFailurePrompt()
    {
        iAppDataDiskCorruptionProgressWin.hide()
        iFailurePrompt.createObject(iAppDataDiskCorruptionProgressWin, { "transientParent": iAppDataDiskCorruptionProgressWin }).show()
    }

}


