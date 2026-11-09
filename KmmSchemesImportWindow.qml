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
    id: iSchemesImportWindow
    objectName: "iSchemesImportWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Schemes Import Window")
    width: 320 + 2* iShadow.shadowThickness
    height: 296 + 2* iShadow.shadowThickness

    property var pSelectedSchemes: []
    property var pSchemesList: []

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

                    UiRowLayout {
                        anchors.fill: parent

                        Text {
                            text: qsTranslate("QObject", "Import Schemes")
                            color: UiTheme.colors.secondaryHover
                            font: UiTheme.fonts.titleExtraSmall
                            Layout.leftMargin: 12
                            horizontalAlignment: Text.AlignLeft
                        }
                        UiImageButton {
                            asset: "TitlebarClose"
                            pImageWidth: 32
                            pImageHeight: 32
                            UiToolTip.text: qsTranslate("QObject", "Close")
                            Layout.alignment: Qt.AlignRight
                            onClicked: iSchemesImportWindow.close()
                        }
                    }
                }
                ListView{
                    id: iSchemesListView
                    Layout.fillWidth: true
                    Layout.minimumHeight: 192
                    Layout.topMargin: 12
                    clip: true
                    model: kmmImportSchemesModel

                    ScrollBar.vertical: UiScrollBar {
                        policy: iSchemesListView.contentHeight > iSchemesListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    delegate: Rectangle{
                        id: iDelegateRect
                        width: 320
                        height: model.isRenameRequired ? (model.isUpdatedNameValid ? 72 : 92) : 28
                        color: UiTheme.colors.primary70

                        property var pIsChecked: false

                        UiColumnLayout{
                            anchors.fill: parent
                            leftPadding: 12
                            UiCheckBox{
                                id: iCbx
                                checked: pIsChecked
                                pSize: UiTheme.checkBoxes.sizes.small
                                font: UiTheme.fonts.bodySmall
                                text: model.displayName
                                onCheckedChanged: {
                                    pIsChecked = checked
                                    if(checked){
                                        pSelectedSchemes.push(index)
                                        iImportBtn.enabled = true
                                        if(kmmImportSchemesModel.rowCount() === pSelectedSchemes.length)
                                            iSelectAllCbx.checked = true
                                    }
                                    else{
                                        var i = pSelectedSchemes.indexOf(index);
                                        if (i > -1) {
                                            pSelectedSchemes.splice(i, 1);
                                        }
                                        iSelectAllCbx.checked = false

                                        if(pSelectedSchemes.length === 0)
                                            iImportBtn.enabled = false
                                    }
                                }
                            }
                            Text{
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "Scheme will be imported as")
                                color: UiTheme.colors.warning
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                Layout.leftMargin: 20
                                Layout.maximumWidth: 292
                                visible: model.isRenameRequired
                            }

                            UiTextField{
                                id: iNewSchemeNameField
                                text: model.updatedName
                                pSize: UiTheme.textFields.sizes.small
                                visible: model.isRenameRequired
                                Layout.leftMargin: 20
                                Layout.maximumHeight: 24
                                Layout.minimumWidth: 118
                                Layout.alignment: Qt.AlignVCenter
                                pInputValidationState: model.isUpdatedNameValid ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                onPInputValidationStateChanged: {
                                    if(text === "" || /^[^</*?"\\>:|]+$/.test(text) == false)
                                        iErrorText.text = qsTranslate("QObject", "Error: Invalid scheme name")
                                    else
                                        iErrorText.text = qsTranslate("QObject", "Scheme exists, enter a new name")
                                }
                                onTextChanged: {
                                    model.updatedName = text
                                    if(text === "" || /^[^</*?"\\>:|]+$/.test(text) == false) {
                                        model.isUpdatedNameValid = false
                                    }
                                    else if(pInputValidationState === UiTextField.InputValidation.Error) {
                                        model.isUpdatedNameValid = true
                                    }
                                }
                            }

                            Text{
                                id: iErrorText
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "Error: Invalid scheme name")
                                color: UiTheme.colors.dangerNormal
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                Layout.leftMargin: 20
                                Layout.maximumWidth: 292
                                visible: !model.isUpdatedNameValid
                            }
                        }
                        ButtonGroup {
                            id: iBtnGrp
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
                        onClicked: {
                            if(checked){
                                for(var child in iSchemesListView.contentItem.children) {
                                    iSchemesListView.contentItem.children[child].pIsChecked = true
                                }

                                iImportBtn.enabled = true
                            }
                            else{
                                pSelectedSchemes = []
                                for(var child in iSchemesListView.contentItem.children) {
                                    iSchemesListView.contentItem.children[child].pIsChecked = false
                                }
                                iImportBtn.enabled = false
                            }
                        }
                    }
                    UiButton{
                        id: iImportBtn
                        text: qsTranslate("QObject", "Import")
                        pSize: UiTheme.buttons.sizes.small
                        pColor: UiTheme.buttons.colors.accent
                        Layout.rightMargin: 12
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: 120
                        enabled: false
                        opacity: enabled ? 1 : 0.4
                        onClicked: {
                            var success = kmmBackend.onImportClick(pSelectedSchemes)
                            if(success)
                                iSchemesImportWindow.close()
                        }
                    }
                }
            }
        }
    }
}
