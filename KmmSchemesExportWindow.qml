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
import QtQuick.Shapes 1.12
import Qt.labs.platform 1.1

Window {
    id: iSchemesExportWindow
    objectName: "iSchemesExportWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Export schemes window")
    width: 240 + 2* iShadow.shadowThickness
    height: 200 + 2* iShadow.shadowThickness

    property var pSelectedSchemes: []
    property var pModel: iSchemesListView.model
    property var pPackage
    ButtonGroup {
        id: iSelectAllGroup
        exclusive: false
        checkState: iSelectAllCbx.checkState
    }
    FileDialog {
        id: iFolderDialog
        title: "Save as"
        nameFilters:  ["Cfg files (*.cfg)|*.cfg"]
        acceptLabel: qsTranslate("QObject", "Save")
        fileMode: FileDialog.SaveFile
        currentFile: "file:///" + pPackage
        visible: false
        onAccepted: {
            iFolderDialog.close()
            kmmBackend.onSchemesExport(file, pSelectedSchemes)
            iSchemesExportWindow.close()
        }
    }
    UiShadowContainer{
        id:iShadow
        Rectangle {
            anchors.fill: parent
            color: UiTheme.colors.primary70
            ColumnLayout {
                spacing: 0
                anchors.fill: parent
                Rectangle {
                    id: iTopbar
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    color: UiTheme.colors.primary60
                    height: 32

                    RowLayout {
                        anchors.fill: parent

                        Text {
                            text: qsTranslate("QObject", "Export schemes")
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
                            onClicked: iSchemesExportWindow.close()
                        }
                    }
                }
                ListView{
                    id: iSchemesListView
                    Layout.fillWidth: true
                    Layout.minimumHeight: 96
                    Layout.topMargin: 12
                    clip: true
                    model: pModel

                    ScrollBar.vertical: UiScrollBar {
                        policy: iSchemesListView.contentHeight > iSchemesListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    delegate: Rectangle{
                        width: 240
                        height: 24
                        color: UiTheme.colors.primary70

                        property var pIsChecked: false

                        UiRowLayout{
                            Layout.fillWidth: true
                            UiCheckBox{
                                id: iSelectedCbx
                                checked: pIsChecked
                                pSize: UiTheme.checkBoxes.sizes.small
                                font: UiTheme.fonts.bodySmall
                                text: modelData
                                Layout.leftMargin: 12
                                ButtonGroup.group: iSelectAllGroup
                                onCheckedChanged: {
                                    if(checked){
                                        pSelectedSchemes.push(modelData)
                                        iExportBtn.enabled = true
                                    }
                                    else{
                                        var index = pSelectedSchemes.indexOf(modelData);
                                        if (index > -1) {
                                            pSelectedSchemes.splice(index, 1);
                                        }
                                        if(pSelectedSchemes.length === 0)
                                            iExportBtn.enabled = false
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    color : UiTheme.colors.primary50
                    Layout.fillWidth: true
                    Layout.minimumHeight: 1
                    Layout.margins: 12
                }

                UiRowLayout{
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    UiCheckBox{
                        id: iSelectAllCbx
                        checked: false
                        pSize: UiTheme.checkBoxes.sizes.small
                        font: UiTheme.fonts.bodySmall
                        text: qsTranslate("QObject", "Select all")
                        Layout.leftMargin: 12
                        checkState: iSelectAllGroup.checkState
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    UiButton{
                        id: iExportBtn
                        text: qsTranslate("QObject", "Export")
                        pSize: UiTheme.buttons.sizes.small
                        pColor: UiTheme.buttons.colors.accent
                        Layout.rightMargin: 12
                        Layout.alignment: Qt.AlignRight
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
