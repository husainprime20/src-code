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

Window {
    id: iMacroImportWindow
    objectName: "iMacroImportWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Macro Import Window")
    width:  240 + 2 * iShadow.shadowThickness
    height: iMacroImportWindowLayout.implicitHeight + 2 * iShadow.shadowThickness

    property bool pCanImport: true

    onClosing: {
        mnsBackend.clearImportMacroModels()
        iMacroImportWindow.destroy()
    }

    ButtonGroup {
        id: iSelectAllGroup
        exclusive: false
        checkState: iSelectAllCbx.checkState
    }

    UiShadowContainer {
        id: iShadow
        UiColumnLayout {
            id: iMacroImportWindowLayout
            padding: 1
            anchors.left: parent.left
            anchors.right: parent.right
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary60

            UiRowLayout {
                leftPadding: 12
                Layout.fillWidth: true
                color: UiTheme.colors.primary60
                Text {
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "Import Macro")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.titleExtraSmall
                }
                UiImageButton {
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    onClicked: iMacroImportWindow.close()
                }
            }

            UiScrollView {
                Layout.maximumHeight: 242
                Layout.preferredWidth: parent.width
                clip: true
                contentWidth: parent.width
                contentHeight: iContentLayout.height

                UiColumnLayout {
                    id: iContentLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 8
                    bottomPadding: 8

                    ListView {
                        id: iRenameImportMacrosListView
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: mnsBackend.pRenameImportMacroModel
                        delegate: UiColumnLayout {
                            property var pNewName: newName
                            property alias pRenameCheckBoxChecked: iRenameCheckBox.checked
                            property alias pReplaceRadioBtnChecked: iReplaceMacroRadioBtn.checked

                            function fSetTextValidity(errorCode) {
                                if(errorCode === 0) {
                                    if(iRenameErrorText.visible === true) {
                                        iRenameMacroTextfld.pInputValidationState = UiTextField.InputValidation.Valid
                                        iRenameErrorText.visible = false
                                    }
                                }
                                else {
                                    if(iRenameErrorText.visible === false) {
                                        iRenameMacroTextfld.pInputValidationState = UiTextField.InputValidation.Error
                                        iRenameErrorText.visible = true
                                    }
                                    if(errorCode === 1)
                                        iRenameErrorText.text = qsTranslate("QObject", "Name cannot be empty")
                                    else if (errorCode === 4)
                                        iRenameErrorText.text = qsTranslate("QObject", "Macro name cannot contain following characters") + " \\ / | ? * < > : \""
                                    else if(errorCode === 10)
                                        iRenameErrorText.text = qsTranslate("QObject", "This is a reserved file name")
                                    else if (errorCode === 2)
                                        iRenameErrorText.text = qsTranslate("QObject", "A macro with same name already exists")
                                    else if (errorCode === 13)
                                        iRenameErrorText.text = qsTranslate("QObject", "A folder with same name already exists")
                                }
                            }

                            anchors.left: parent.left
                            anchors.right: parent.right
                            topPadding: 4
                            bottomPadding: 4
                            spacing: 4
                            UiCheckBox {
                                id: iRenameCheckBox
                                ButtonGroup.group: iSelectAllGroup
                                Layout.fillWidth: true
                                text: name
                                pSize: UiTheme.checkBoxes.sizes.small
                                checked: true
                                onCheckedChanged: {
                                    isChecked = checked
                                    fValidateNewMacroNames()
                                }
                            }
                            UiColumnLayout {
                                Layout.fillWidth: true
                                leftPadding: 20
                                spacing: 4
                                Text {
                                    Layout.fillWidth: true
                                    text: qsTranslate("QObject", "Macro with the same name exists.")
                                    color: UiTheme.colors.warning
                                    wrapMode: Text.Wrap
                                    font: UiTheme.fonts.bodySmallest
                                }
                                UiRowLayout {
                                    Layout.fillWidth:true
                                    topPadding: 4
                                    spacing: 4
                                    UiRadioButton {
                                        id: iReplaceMacroRadioBtn
                                        text: qsTranslate("QObject", "Replace")
                                        checked: true
                                        ButtonGroup.group: iBtnGrp
                                        pSize: UiTheme.radioButtons.sizes.small
                                        Layout.fillWidth:true
                                        onCheckedChanged: {
                                            if(checked)
                                            {
                                                isRename = false
                                                newName = pNewName
                                            }
                                            fValidateNewMacroNames()
                                        }
                                    }
                                    UiRadioButton{
                                        id: iRenameMacroRadioBtn
                                        text: qsTranslate("QObject", "Rename")
                                        checked: false
                                        ButtonGroup.group: iBtnGrp
                                        pSize: UiTheme.radioButtons.sizes.small
                                        Layout.fillWidth:true
                                        onCheckedChanged: {
                                            if(checked)
                                            {
                                                isRename = true
                                                newName = pNewName
                                            }
                                            fValidateNewMacroNames()
                                        }
                                    }
                                }
                                UiTextField {
                                    id: iRenameMacroTextfld
                                    Layout.fillWidth:true
                                    pSize: UiTheme.textFields.sizes.extraSmall
                                    visible: iRenameMacroRadioBtn.checked ? true : false
                                    text: pNewName
                                    onTextEdited: {
                                        newName = text
                                        fValidateNewMacroNames()
                                    }
                                }
                                Text {
                                    id: iRenameErrorText
                                    visible: false
                                    Layout.fillWidth: true
                                    color: UiTheme.colors.dangerNormal
                                    wrapMode: Text.Wrap
                                    font: UiTheme.fonts.bodySmallest
                                }
                            }
                            ButtonGroup {
                                id: iBtnGrp
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: mnsBackend.pValidImportMacroModel
                        Layout.topMargin: 4
                        delegate: UiRowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            topPadding: 4
                            bottomPadding: 4
                            UiCheckBox {
                                id: iValidCheckBox
                                ButtonGroup.group: iSelectAllGroup
                                Layout.fillWidth: true
                                text: name
                                pSize: UiTheme.checkBoxes.sizes.small
                                checked: true
                                onCheckedChanged: {
                                    isChecked = checked
                                    fValidateNewMacroNames()
                                }
                            }
                        }
                    }

                    UiRowLayout {
                        visible: mnsBackend.pInValidImportMacroModel.rowCount() > 0
                        topPadding: 4
                        bottomPadding: 4
                        spacing: 4
                        Text {
                            text: qsTranslate("QObject", "Incompatible macros");
                            font: UiTheme.fonts.bodySmall
                            color: UiTheme.colors.primary30
                        }
                        UiImageButton {
                            asset: "HelpSmall"
                            pImageWidth: 12
                            pImageHeight: 12
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: uiBackend.openHelpArticle("IncompatibleMacros_help")
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        implicitHeight: contentHeight
                        model: mnsBackend.pInValidImportMacroModel
                        delegate: UiRowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            topPadding: 4
                            bottomPadding: 4
                            spacing: 8
                            UiImage {
                                asset: "ErrorSmall"
                                pImageWidth: 12
                                pImageHeight: 12
                            }
                            Text {
                                Layout.fillWidth: true
                                text: name
                                font: UiTheme.fonts.bodySmall
                                color: UiTheme.colors.primary20
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            Rectangle {
                color : UiTheme.colors.primary50
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }

            UiRowLayout {
                Layout.fillWidth: true
                padding: 12
                UiCheckBox {
                    id: iSelectAllCbx
                    checkState: iSelectAllGroup.checkState
                    pSize: UiTheme.checkBoxes.sizes.small
                    text: qsTranslate("QObject", "Select all")
                    enabled: mnsBackend.pRenameImportMacroModel.rowCount() > 0 || mnsBackend.pValidImportMacroModel.rowCount() > 0
                }
                UiButton {
                    text: qsTranslate("QObject", "Import")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.accent
                    Layout.alignment: Qt.AlignRight
                    enabled: pCanImport && iSelectAllCbx.enabled
                    opacity: enabled ? 1 : 0.4
                    onClicked: {
                        mnsBackend.importMacros()
                        iMacroImportWindow.close()
                    }
                }
            }
        }
    }

    function fValidateNewMacroNames() {
        pCanImport = mnsBackend.selectedImportMacroCount() > 0
        for(var renameMacro in iRenameImportMacrosListView.contentItem.children) {
            var childItem = iRenameImportMacrosListView.contentItem.children[renameMacro]
            var newName = childItem.pNewName
            if(newName !== undefined) {
                if(childItem.pRenameCheckBoxChecked === false || childItem.pReplaceRadioBtnChecked === true)
                    childItem.fSetTextValidity(0)
                else {
                    var result = mnsBackend.validateImportMacroName(newName)
                    childItem.fSetTextValidity(result)
                    if(result !== 0) {
                        pCanImport = false
                    }
                }
            }
        }
    }
}
