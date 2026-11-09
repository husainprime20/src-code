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
import Qt.labs.platform 1.1

import UiToolTipControl 1.0

Window {
    id: iMacroExportWindow
    objectName: "iMacroExportWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Macro Export Window")
    width: 240 + 2* iShadow.shadowThickness
    height: 200 + 2* iShadow.shadowThickness

    property var pSelectedMacros: []
    property var pMacrosListModel

    onClosing: {
        pMacrosListModel.clear()
        iMacroExportWindow.destroy()
    }

    FolderDialog {
        id: iFolderDialog
        title: "Select destination folder"
        visible: false
        onAccepted: {
            iFolderDialog.close()
            mnsBackend.onMacroExport(folder, pSelectedMacros)
            iMacroExportWindow.close()
        }
    }

    UiShadowContainer {
        id:iShadow
        UiColumnLayout {
            anchors.fill: parent
            padding: 1
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary50

            UiRowLayout {
                Layout.fillWidth: true
                leftPadding: 12
                color: UiTheme.colors.primary60
                Text {
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "Export macro")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.titleExtraSmall
                }
                UiImageButton {
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    onClicked: iMacroExportWindow.close()
                }
            }

            UiColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 12
                spacing: 12

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: contentHeight
                    clip: true
                    spacing: 8
                    model: pMacrosListModel

                    ScrollBar.vertical: UiScrollBar {
                        policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    delegate: UiCheckBox {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        checked: model.checked
                        pSize: UiTheme.checkBoxes.sizes.small
                        text: model.name
                        onToggled: {
                            model.checked = !model.checked
                            if (model.checked) {
                                pSelectedMacros.push(model.name)
                                iExportBtn.enabled = true
                            }
                            else {
                                var index = pSelectedMacros.indexOf(model.name);
                                if (index > -1) {
                                    pSelectedMacros.splice(index, 1);
                                }

                                if(pSelectedMacros.length === 0)
                                    iExportBtn.enabled = false
                            }
                            iSelectAllCbx.checked = (pSelectedMacros.length === pMacrosListModel.count)
                        }
                    }
                }

                Rectangle {
                    color : UiTheme.colors.primary50
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                }

                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    UiCheckBox {
                        Layout.fillWidth: true
                        id: iSelectAllCbx
                        checked: false
                        pSize: UiTheme.checkBoxes.sizes.small
                        text: qsTranslate("QObject", "Select all")
                        onToggled: {
                            //emptying the list
                            pSelectedMacros.splice(0, pSelectedMacros.length)

                            for (var i = 0; i < pMacrosListModel.count; ++i) {
                                pMacrosListModel.setProperty(i, "checked", iSelectAllCbx.checked)
                                if (checked)
                                    pSelectedMacros.push(pMacrosListModel.get(i).name)
                            }
                            iExportBtn.enabled = checked
                        }
                    }
                    UiButton{
                        id: iExportBtn
                        text: qsTranslate("QObject", "Export")
                        pSize: UiTheme.buttons.sizes.small
                        pColor: UiTheme.buttons.colors.accent
                        enabled: false
                        opacity: enabled ? 1 : 0.4
                        onClicked: {
                            iFolderDialog.open()
                        }
                    }
                }
            }
        }
    }
}
