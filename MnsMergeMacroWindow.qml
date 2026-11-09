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
import QtQml.Models 2.15

import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import MergeConfigrationListModel 1.0

Window {
    id: iMergeMacroManagerWindow
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "%1 Merge macromanager")
    width: 602 + 2 * iShadow.shadowThickness
    height: 402 + 2 * iShadow.shadowThickness

    property int pCurrentMergeMacroIndex: -1
    property string pCurrentMergeMacroName: ""
    property bool pIsUpdateMergeMacro: false
    property var pMacrosAvailableToMergeListModel: []
    property MergeConfigrationListModel pMergedMacrosListModel: MergeConfigrationListModel { }
    property var pMacroSettings : mnsBackend.pMacroViewModel.getMacroSettings(pCurrentMergeMacroIndex)

    signal closeAllMergeConfigrationSettings

    onClosing: {
        iMergeMacroManagerWindow.destroy()
    }

    Component {
        id: iUnifyConfirmationPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Unify %1").arg(iMacroNameTextField.text)
            pDescription: qsTranslate( "QObject","You will not be able to configure settings for a unified macro")
            pDialogType: UiDialogWindow.Simple
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Unify")
                        onClicked: {
                            mnsBackend.onMacroUnify(iMacroNameTextField.text, false)
                            close()
                            iMergeMacroManagerWindow.close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    UiShadowContainer {
        id:iShadow
        UiColumnLayout {
            anchors.fill: parent
            padding: 1
            border.width: 1
            border.color: UiTheme.colors.primary60
            color: UiTheme.colors.primary80

            UiRowLayout {
                Layout.fillWidth: true
                leftPadding: 12
                color: UiTheme.colors.primary70
                Text {
                    Layout.fillWidth: true
                    text: pIsUpdateMergeMacro ? qsTranslate("QObject", "Edit merged macro") : qsTranslate("QObject", "Merge macros")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.titleExtraSmall
                }
                UiImageButton {
                    asset: "TitlebarHelp"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Help")
                    onClicked: uiBackend.openHelpArticle("MergeMacro_Help")
                }
                UiImageButton {
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    onClicked: fRevertChanges()
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: 12
                spacing: 12

                UiColumnLayout {
                    Layout.preferredWidth: 220
                    Layout.fillHeight: true
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Existing macros")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodyExtraSmall
                        elide: Text.ElideRight
                    }
                    ListView {
                        id: iMacroToAddListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        implicitHeight: contentHeight
                        clip: true
                        model: pMacrosAvailableToMergeListModel

                        ScrollBar.vertical: UiScrollBar {
                            policy: iMacroToAddListView.contentHeight > iMacroToAddListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        }

                        delegate: UiRowLayout {
                            id: iMacroToAdd
                            height: 26
                            anchors.left: parent.left
                            anchors.right: parent.right
                            color: pMouseArea.containsMouse
                                   ? UiTheme.colors.primary60
                                   : index % 2 == 0 ? UiTheme.colors.primary70 : UiTheme.colors.primary90
                            leftPadding: 8
                            rightPadding: 8
                            spacing: 4
                            pMouseArea {
                                enabled: true
                                anchors.fill: iMacroToAdd
                                hoverEnabled: true
                                onClicked: pMergedMacrosListModel.addMergeConfigration(modelData)
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                color: UiTheme.colors.primary10
                                font: UiTheme.fonts.bodySmall
                                elide: Text.ElideRight
                            }
                            UiImage {
                                asset: "AddSmall"
                                pImageWidth: 12
                                pImageHeight: 12
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    color: UiTheme.colors.primary60
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4
                    UiColumnLayout {
                        visible: pMergedMacrosListModel.pCount === 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        UiColumnLayout {
                            Layout.fillWidth: true
                            border.width: 1
                            border.color: UiTheme.colors.primary50
                            color: UiTheme.colors.primary90
                            spacing: 8
                            padding: 8
                            Text {
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "How to merge macros?")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                                wrapMode: Text.Wrap
                            }
                            ListView {
                                Layout.fillWidth: true
                                implicitHeight: contentHeight
                                spacing: 4
                                clip: true
                                model: [
                                    qsTranslate("QObject", "Click + to add macros from the list on the left."),
                                    qsTranslate("QObject", "Reorder macros by dragging them in the desired order."),
                                    qsTranslate("QObject", "Give the merged macro a name and click merge.")
                                ]
                                delegate: Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    text: (index + 1) + ". " + modelData
                                    color: UiTheme.colors.primary30
                                    font: UiTheme.fonts.bodySmall
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                    Text {
                        visible: pMergedMacrosListModel.pCount !== 0
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Macros to merge")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodyExtraSmall
                        elide: Text.ElideRight
                    }
                    ListView {
                        id: iMacroToRunListView
                        visible: pMergedMacrosListModel.pCount !== 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        implicitHeight: contentHeight
                        spacing: -1
                        clip: true
                        boundsMovement: Flickable.StopAtBounds
                        boundsBehavior: Flickable.StopAtBounds

                        ScrollBar.vertical: UiScrollBar {
                            policy: iMacroToRunListView.contentHeight > iMacroToRunListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                        }

                        model: DelegateModel {
                            model: pMergedMacrosListModel
                            delegate: Component {
                                Item {
                                    id: iDragItem

                                    property bool pHeld: false
                                    property int pLastY: 0
                                    property bool pMoveDown: false

                                    anchors.left: parent != null ? parent.left : undefined
                                    anchors.right: parent != null ? parent.right : undefined
                                    height: iContentRect.height

                                    onYChanged: {
                                        pMoveDown = pLastY < y;
                                        pLastY = y;
                                    }

                                    Rectangle {
                                        id: iContentRect
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        height: iContentLayout.implicitHeight
                                        color: "transparent"
                                        border.width: 1
                                        border.color: UiTheme.colors.primary50

                                        Drag.active: iDragItem.pHeld
                                        Drag.source: iDragItem
                                        Drag.hotSpot.x: width / 2
                                        Drag.hotSpot.y: height / 2
                                        states: State {
                                            when: iDragItem.pHeld
                                            ParentChange { target: iContentRect; parent: iMacroToRunListView }
                                            AnchorChanges { target: iContentRect; anchors.left: undefined; anchors.right: undefined }
                                            PropertyChanges { target: iContentRect; color: UiTheme.colors.primary80 }
                                        }

                                        UiColumnLayout {
                                            id: iContentLayout
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            padding: 8
                                            spacing: 8

                                            UiRowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8
                                                UiImage {
                                                    asset: "MoveSmall" + (iMoveIconMouseArea.containsMouse ? "_hover" : "")
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Drag to sort")
                                                    UiToolTip.visible: iDragItem.pHeld ? false
                                                                                       : iMoveIconMouseArea.containsMouse

                                                    MouseArea {
                                                        id: iMoveIconMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        drag.target: iDragItem.pHeld ? iContentRect : undefined
                                                        drag.axis: Drag.YAxis
                                                        onPressed: iDragItem.pHeld = true
                                                        onReleased: iDragItem.pHeld = false
                                                    }
                                                }
                                                ListView {
                                                    id: iMacrosToRunListView
                                                    Layout.fillWidth: true
                                                    implicitHeight: contentHeight
                                                    spacing: 4
                                                    clip: true
                                                    model: macrosToRun
                                                    interactive: false

                                                    delegate: UiColumnLayout {
                                                        anchors.left: parent != null ? parent.left : undefined
                                                        anchors.right: parent != null ? parent.right : undefined
                                                        spacing: 4
                                                        Rectangle {
                                                            Layout.fillWidth: true
                                                            Layout.preferredHeight: 1
                                                            color: UiTheme.colors.primary60
                                                            visible: index != 0
                                                        }
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: display
                                                            color: UiTheme.colors.primary10
                                                            font: UiTheme.fonts.bodySmall
                                                            elide: Text.ElideRight
                                                        }
                                                    }
                                                }
                                                UiImageButton {
                                                    visible: iMacrosToRunListView.count > 1
                                                    asset: "SmallestDeLinkIcon"
                                                    UiToolTip.text: qsTranslate("QObject", "Ungroup")
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    Layout.rightMargin: 12
                                                    onClicked: pMergedMacrosListModel.unbindMergeConfigrations(index)
                                                }
                                                UiImageButton {
                                                    asset: iSettingsLayout.visible ? "CaretUpSmall" : "CaretDownSmall"
                                                    UiToolTip.text: qsTranslate("QObject", "Options")
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    onClicked: {
                                                        if (!iSettingsLayout.visible)
                                                            iMergeMacroManagerWindow.closeAllMergeConfigrationSettings()
                                                        iSettingsLayout.visible = !iSettingsLayout.visible
                                                    }
                                                }
                                                UiImageButton {
                                                    asset: "CloseSmall"
                                                    UiToolTip.text: qsTranslate("QObject", "Remove")
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    onClicked: pMergedMacrosListModel.removeMergeConfigration(index)
                                                }
                                            }

                                            UiColumnLayout {
                                                id: iSettingsLayout
                                                Layout.fillWidth: true
                                                spacing: 4
                                                visible: false

                                                states: State {
                                                    when: iDragItem.pHeld
                                                    PropertyChanges { target: iSettingsLayout; visible: false }
                                                }

                                                Connections {
                                                    target: iMergeMacroManagerWindow
                                                    function onCloseAllMergeConfigrationSettings() {
                                                        iSettingsLayout.visible = false
                                                    }
                                                }

                                                UiRowLayout {
                                                    spacing: 4
                                                    Text {
                                                        text: qsTranslate("QObject", "Loop")
                                                        color: UiTheme.colors.primary10
                                                        font: UiTheme.fonts.bodyExtraSmall
                                                        wrapMode: Text.WrapAnywhere
                                                        elide: Text.ElideRight
                                                        Layout.preferredWidth: 48
                                                        Layout.preferredHeight: 30
                                                        topPadding: 2
                                                        Layout.alignment: Qt.AlignTop
                                                    }
                                                    UiRowLayout {
                                                        Layout.fillWidth: true
                                                        spacing: 4
                                                        UiTextField {
                                                            Layout.preferredWidth: 32
                                                            pSize: UiTheme.textFields.sizes.small
                                                            text: loopIterations
                                                            validator: IntValidator {bottom: 1; top: 99999}
                                                            inputMethodHints: Qt.ImhDigitsOnly
                                                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                                            pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer greater than 0")
                                                            onEditingFinished: {
                                                                if (pInputValidationState === UiTextField.InputValidation.Valid)
                                                                    loopIterations = parseInt(text)
                                                            }
                                                        }
                                                        Text {
                                                            text: qsTranslate("QObject", "Count")
                                                            color: UiTheme.colors.primary20
                                                            font: UiTheme.fonts.bodyExtraSmall
                                                        }
                                                        UiTextField {
                                                            Layout.preferredWidth: 32
                                                            pSize: UiTheme.textFields.sizes.small
                                                            text: loopInterval
                                                            validator: IntValidator {bottom: 0; top: 99999}
                                                            inputMethodHints: Qt.ImhDigitsOnly
                                                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                                            pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                                                            onEditingFinished: {
                                                                if (pInputValidationState === UiTextField.InputValidation.Valid)
                                                                    loopInterval = parseInt(text)
                                                            }
                                                        }
                                                        Text {
                                                            text: qsTranslate("QObject", "Interval(sec)")
                                                            color: UiTheme.colors.primary20
                                                            font: UiTheme.fonts.bodyExtraSmall
                                                        }
                                                    }
                                                }

                                                UiRowLayout {
                                                    spacing: 4
                                                    Text {
                                                        text: qsTranslate("QObject", "Macro")
                                                        color: UiTheme.colors.primary10
                                                        font: UiTheme.fonts.bodyExtraSmall
                                                        Layout.preferredWidth: 48
                                                        Layout.preferredHeight: 30
                                                        wrapMode: Text.WrapAnywhere
                                                        elide: Text.ElideRight
                                                        topPadding: 2
                                                        Layout.alignment: Qt.AlignTop
                                                    }
                                                    Text {
                                                        text: qsTranslate("QObject", "Execution Speed")
                                                        color: UiTheme.colors.primary20
                                                        font: UiTheme.fonts.bodyExtraSmall
                                                    }
                                                    UiComboBox {
                                                        pSize: UiTheme.comboBoxes.sizes.small
                                                        model: [ "0.5x", "1x", "1.5x", "2x", "2.5x", "3x", "3.5x", "4x", "4.5x", "5x"]
                                                        currentIndex: (acceleration - 0.5) * 2
                                                        Layout.preferredWidth: 64
                                                        onActivated: {
                                                            acceleration = (currentIndex / 2) + 0.5
                                                        }
                                                    }
                                                }

                                                UiRowLayout {
                                                    spacing: 4
                                                    visible: index != (pMergedMacrosListModel.pCount - 1)
                                                    Text {
                                                        text: qsTranslate("QObject", "Script")
                                                        color: UiTheme.colors.primary10
                                                        font: UiTheme.fonts.bodyExtraSmall
                                                        wrapMode: Text.WrapAnywhere
                                                        elide: Text.ElideRight
                                                        Layout.preferredWidth: 48
                                                        Layout.preferredHeight: 30
                                                        topPadding: 2
                                                        Layout.alignment: Qt.AlignTop
                                                    }
                                                    Text {
                                                        text: qsTranslate("QObject", "Delay next script by(sec)")
                                                        color: UiTheme.colors.primary20
                                                        font: UiTheme.fonts.bodyExtraSmall
                                                    }
                                                    UiTextField {
                                                        Layout.preferredWidth: 32
                                                        pSize: UiTheme.textFields.sizes.small
                                                        text: delayNextScript
                                                        validator: IntValidator {bottom: 0; top: 99999}
                                                        inputMethodHints: Qt.ImhDigitsOnly
                                                        pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                                        pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                                                        onEditingFinished: {
                                                            if (pInputValidationState === UiTextField.InputValidation.Valid)
                                                                delayNextScript = parseInt(text)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    UiImageButton {
                                        id: iBindMacroConfigrationButton
                                        visible: index !== 0
                                        anchors.right: iDragItem.right
                                        anchors.verticalCenter: iDragItem.top
                                        anchors.rightMargin: 60
                                        asset: "SmallestLinkIcon"
                                        UiToolTip.text: qsTranslate("QObject", "Group")
                                        pImageWidth: 12
                                        pImageHeight: 12
                                        onClicked: pMergedMacrosListModel.bindMergeConfigrations(index)

                                        states: State {
                                            when: iDragItem.pHeld
                                            PropertyChanges { target: iBindMacroConfigrationButton; visible: false }
                                            AnchorChanges { target: iBindMacroConfigrationButton; anchors.right: undefined; anchors.verticalCenter: undefined }
                                        }
                                    }

                                    DropArea {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        onEntered: function(drag) {
                                            pMergedMacrosListModel.moveMergeConfigration(drag.source.DelegateModel.itemsIndex,
                                                                                         iDragItem.DelegateModel.itemsIndex)

                                            if (iDragItem.pMoveDown)
                                                iMacroToRunListView.currentIndex = iDragItem.DelegateModel.itemsIndex + 2
                                            else
                                                iMacroToRunListView.currentIndex = iDragItem.DelegateModel.itemsIndex - 2
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Name of merged macro")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodyExtraSmall
                        elide: Text.ElideRight
                    }
                    UiTextField {
                        id: iMacroNameTextField
                        Layout.fillWidth: true
                        pSize: UiTheme.textFields.sizes.small
                        text: pCurrentMergeMacroName
                        enabled: !pIsUpdateMergeMacro
                        opacity: enabled ? 1 : 0.4
                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                        onTextEdited: {
                            var errorCode = mnsBackend.isMacroNameValid(text.trim(), pCurrentMergeMacroIndex)
                            if(errorCode === 0) {
                                pInputValidationState = UiTextField.InputValidation.Valid
                            }
                            else {
                                if(errorCode === 1)
                                    pErrorTemplateContent = qsTranslate("QObject", "Name cannot be empty")
                                else if (errorCode === 4)
                                    pErrorTemplateContent = qsTranslate("QObject", "Macro name cannot contain following characters") + " \\ / | ? * < > : \""
                                else if(errorCode === 10)
                                    pErrorTemplateContent = qsTranslate("QObject", "This is a reserved file name")
                                else if (errorCode === 2)
                                    pErrorTemplateContent = qsTranslate("QObject", "A macro with same name already exists")
                                else if (errorCode === 13)
                                    pErrorTemplateContent = qsTranslate("QObject", "A folder with the same name already exists")
                                pInputValidationState = UiTextField.InputValidation.Error
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        topPadding: 6
                        spacing: 10
                        UiImageLabel {
                            Layout.preferredHeight: 24
                            font: UiTheme.fonts.buttonSmall
                            spacing: 6
                            pText: qsTranslate("QObject", "Settings")
                            pImageAsset: "SettingsSmall"
                            pImageWidth: 12
                            pImageHeight: 12
                            onClicked:{
                                var component = Qt.createComponent("MnsMacroSettingsWindow.qml");
                                if (component.status === Component.Ready) {
                                    var macroSettingsWindow = component.createObject(
                                                iMergeMacroManagerWindow,
                                                {
                                                    "pMacroIndex" : pCurrentMergeMacroIndex,
                                                    "pMacroDetails" : mnsBackend.pMacroViewModel.copyMacroSettings(pMacroSettings)
                                                })
                                    macroSettingsWindow.settingsSaved.connect(fMacroSettingsSaved);
                                    macroSettingsWindow.show()
                                }
                            }
                        }
                        UiImageLabel {
                            Layout.preferredHeight: 24
                            visible: pIsUpdateMergeMacro
                            font: UiTheme.fonts.buttonSmall
                            spacing: 6
                            pText: qsTranslate("QObject", "Unify")
                            pImageAsset: "UnifySmall"
                            pImageWidth: 12
                            pImageHeight: 12
                            onClicked:{
                                iUnifyConfirmationPrompt.createObject(iMergeMacroManagerWindow, { "transientParent": iMergeMacroManagerWindow }).show()
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        UiButton {
                            enabled: pMergedMacrosListModel.pCount !== 0
                                     && iMacroNameTextField.pInputValidationState === UiTextField.InputValidation.Valid
                            opacity: enabled ? 1 : 0.4
                            Layout.alignment: Qt.AlignRight
                            pSize: UiTheme.buttons.sizes.small
                            pColor: UiTheme.buttons.colors.accent
                            text: pIsUpdateMergeMacro ? qsTranslate("QObject", "Update") : qsTranslate("QObject", "Merge")
                            onClicked: {
                                if (!pIsUpdateMergeMacro)
                                    mnsBackend.createMergeMacro(iMacroNameTextField.text, pMergedMacrosListModel, pMacroSettings)
                                else
                                    mnsBackend.updateMergeConfigrations(pCurrentMergeMacroIndex, pMergedMacrosListModel)
                                iMergeMacroManagerWindow.close()
                            }
                        }
                    }
                }
            }
        }
    }

    function fMacroSettingsSaved(macroSettingsObj, macroIndex) {
        if (macroIndex !== -1)
            mnsBackend.onMacroSettingsSave(macroSettingsObj, macroIndex)
        pMacroSettings = macroSettingsObj
    }

    function fRevertChanges() {
        if (pIsUpdateMergeMacro)
            mnsBackend.resetMergeConfigrations(pCurrentMergeMacroName)
        iMergeMacroManagerWindow.close()
    }
}
