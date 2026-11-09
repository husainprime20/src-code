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
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Window {
    id: iMacroSettingsWindow
    objectName: "iMacroSettingsWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Macro Settings Window")
    width: 462 + 2 * iShadow.shadowThickness
    height: iColumnLayout.implicitHeight + 2 * iShadow.shadowThickness

    property int pMacroIndex : -1
    property var pMacroDetails
    property UiWindowedPopup pStopMacroOnHomeMessageBlurbWin: null
    property bool pStopMacroOnHomePrevVal: false

    signal settingsSaved(var macroSettingsObj, var macroIndex)

    ButtonGroup {
        id: iLoopTypeGrp
    }

    onClosing: {
        iMacroSettingsWindow.destroy()
    }

    Timer {
        repeat: false
        interval: 250
        running: true
        onTriggered: {
            pStopMacroOnHomePrevVal = pMacroDetails.stopOnHome
            if (uiBackend.confGetBool("bst.stop_macro_on_home_blurb_shown"))
                return

            if (pStopMacroOnHomeMessageBlurbWin == null) {
                pStopMacroOnHomeMessageBlurbWin = iStopMacroOnHomeMessageBlurb.createObject(iMacroSettingsWindow)
                pStopMacroOnHomeMessageBlurbWin.x = iStopMacroOnHomeRow.mapToGlobal(0, 0).x
                pStopMacroOnHomeMessageBlurbWin.y = iStopMacroOnHomeRow.mapToGlobal(0, 0).y + 16
                pStopMacroOnHomeMessageBlurbWin.show()

            }
        }
    }

    Component {
        id: iSaveChangesPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "%1 macro recorder").arg(uiBackend.productName)
            pDescription: qsTranslate( "QObject","Discard changes and close this window?")
            pDialogType: UiDialogWindow.Simple
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject",  "Discard changes")
                        onClicked: {
                            uiBackend.confDiscard()
                            close()
                            iMacroSettingsWindow.close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "No")
                        onClicked: close()
                    }
                ]
            }
        }
    }

    Component {
        id: iStopMacroOnHomeMessageBlurb

        UiWindowedPopup {
            contentWidth: 224
            contentHeight: iStopMacroOnHomeBlurbLayout.implicitHeight
            closeOnPressOutside: true

            onClosePopup: {
                uiBackend.confSetBool("bst.stop_macro_on_home_blurb_shown", true)
                uiBackend.confCommit()
            }

            Shape {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                width: 12
                height: 6
                ShapePath {
                    strokeColor: UiTheme.colors.accentNormal
                    fillColor: UiTheme.colors.accentNormal
                    startX: 0
                    startY: 0
                    PathLine { x: 6; y: -6 }
                    PathLine { x: 12; y: 0 }
                }
            }
            UiColumnLayout {
                id: iStopMacroOnHomeBlurbLayout
                anchors.centerIn: parent
                width: 224
                color: UiTheme.colors.accentNormal
                leftPadding: 12
                rightPadding: 12
                topPadding: 10
                bottomPadding: 10

                Text {
                    font: UiTheme.fonts.bodyMedium
                    color: UiTheme.colors.primary10
                    text: qsTranslate("QObject", "This will prevent any unwanted actions on the Home screen")
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

            }
        }
    }

    UiShadowContainer {
        id: iShadow
        anchors.fill: parent
        UiColumnLayout {
            id:iColumnLayout
            anchors.left: parent.left
            anchors.right: parent.right
            padding: 1
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary60

            UiRowLayout {
                id: iTopbar
                Layout.fillWidth: true
                color: UiTheme.colors.primary60
                leftPadding: 12
                spacing: 4
                Text {
                    text: (pMacroDetails.name === "" ? "" : (pMacroDetails.name + " - ")) + qsTranslate("QObject", "Settings")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.titleExtraSmall
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    UiToolTip.text: pMacroDetails.name
                    UiToolTip.visible: iMacroTextMouseArea.containsMouse && truncated
                    MouseArea {
                        id: iMacroTextMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
                UiImageButton {
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    onClicked: {
                        if(pMacroIndex !== -1 && !mnsBackend.pMacroViewModel.compareMacroSettings(pMacroDetails, pMacroDetails.name))
                            iSaveChangesPrompt.createObject(iMacroSettingsWindow, { "transientParent": iMacroSettingsWindow }).show()
                        else
                            iMacroSettingsWindow.close()
                    }
                }
            }

            UiColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                padding: 12
                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: qsTranslate("QObject", "Repeat execution")
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 32
                        topPadding: 2
                        Layout.alignment: Text.AlignTop
                        elide: Text.ElideRight
                    }
                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            UiRadioButton {
                                id: iRepeatActionRadioBtn
                                text: qsTranslate("QObject", "Repeat action")
                                pSize: UiTheme.radioButtons.sizes.small
                                checked: pMacroDetails.loopType === 0
                                ButtonGroup.group: iLoopTypeGrp
                                onCheckedChanged: {
                                    pMacroDetails.loopType = 0
                                }
                            }
                            UiTextField {
                                enabled: iRepeatActionRadioBtn.checked
                                opacity: enabled? 1: 0.4
                                Layout.preferredWidth: 32
                                text: pMacroDetails.loopNumber
                                pSize: UiTheme.textFields.sizes.small
                                validator: IntValidator {bottom: 1; top: 99999}
                                inputMethodHints: Qt.ImhDigitsOnly
                                pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer greater than 0")
                                onTextChanged: {
                                    pMacroDetails.loopNumber = parseInt(text)
                                }
                                onPInputValidationStateChanged:{
                                    if(pInputValidationState === UiTextField.InputValidation.Error)
                                        iSaveBtn.enabled = false;
                                    else
                                        iSaveBtn.enabled = true;
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "time(s)")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                        UiRowLayout{
                            Layout.fillWidth: true
                            spacing: 8
                            UiRadioButton {
                                id: iForDurationOfRadioBtn
                                Layout.preferredHeight: iDurationRowLayout.implicitHeight
                                Layout.alignment: Qt.AlignTop
                                contentItem.visible: false
                                spacing: 0
                                pSize: UiTheme.radioButtons.sizes.small
                                checked: pMacroDetails.loopType === 1
                                ButtonGroup.group: iLoopTypeGrp
                                onCheckedChanged: {
                                    pMacroDetails.loopType = 1
                                }
                            }
                            Flow {
                                id: iDurationFlow
                                Layout.fillWidth: true
                                spacing: 4
                                UiRowLayout{
                                    height: iDurationRowLayout.implicitHeight
                                    Text{
                                        text: qsTranslate("QObject", "For a duration of")
                                        font: UiTheme.fonts.bodySmall
                                        color: UiTheme.colors.primary20
                                    }
                                }
                                UiRowLayout{
                                    id: iDurationRowLayout
                                    spacing: 4
                                    UiTextField {
                                        id:iLoopTimeHrs
                                        enabled: iForDurationOfRadioBtn.checked
                                        opacity: enabled? 1: 0.4
                                        Layout.preferredWidth: 32
                                        text: {
                                            var totalSecs = Number(pMacroDetails.loopTime)
                                            var h = Math.floor(totalSecs / 3600)

                                            return h < 10 ? "0" + h : h
                                        }
                                        pSize: UiTheme.textFields.sizes.small
                                        validator: IntValidator {bottom: 0; top: 99999}
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                                        onTextChanged: fUpdateLoopTime()
                                    }
                                    Text {
                                        text: qsTranslate("QObject","HH")
                                        color: UiTheme.colors.primary20
                                        font: UiTheme.fonts.bodySmall
                                    }
                                    UiTextField {
                                        id:iLoopTimeMins
                                        enabled: iForDurationOfRadioBtn.checked
                                        opacity: enabled? 1: 0.4
                                        Layout.preferredWidth: 32
                                        text: {
                                            var totalSecs = Number(pMacroDetails.loopTime)
                                            var m = Math.floor(totalSecs % 3600 / 60)

                                            return m < 10 ? "0" + m : m
                                        }
                                        pSize: UiTheme.textFields.sizes.small
                                        validator: IntValidator {bottom: 0; top: 99999}
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                                        onTextChanged: fUpdateLoopTime()
                                    }
                                    Text {
                                        text: qsTranslate("QObject","MM")
                                        color: UiTheme.colors.primary20
                                        font: UiTheme.fonts.bodySmall
                                    }
                                    UiTextField {
                                        id: iLoopTimeSecs
                                        enabled: iForDurationOfRadioBtn.checked
                                        opacity: enabled? 1: 0.4
                                        Layout.preferredWidth: 32
                                        text: {
                                            var totalSecs = Number(pMacroDetails.loopTime)
                                            var s = Math.floor(totalSecs % 3600 % 60)

                                            return s < 10 ? "0" + s : s
                                        }
                                        pSize: UiTheme.textFields.sizes.small
                                        validator: IntValidator {bottom: 0; top: 99999}
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                                        onTextChanged: fUpdateLoopTime()
                                    }
                                    Text {
                                        text: qsTranslate("QObject","SS")
                                        color: UiTheme.colors.primary20
                                        font: UiTheme.fonts.bodySmall
                                    }
                                }
                            }
                        }
                        UiRowLayout{
                            Layout.preferredHeight: 24
                            Layout.fillWidth: true
                            UiRadioButton {
                                text: qsTranslate("QObject", "Infinitely until stopped")
                                Layout.fillWidth: true
                                pSize: UiTheme.radioButtons.sizes.small
                                checked: pMacroDetails.loopType === 2
                                ButtonGroup.group: iLoopTypeGrp
                                onCheckedChanged: {
                                    pMacroDetails.loopType = 2
                                }

                            }
                        }
                    }
                }
                UiRowLayout{
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: qsTranslate("QObject", "Interval between executions")
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 32
                        topPadding: 2
                        Layout.alignment: Qt.AlignTop
                        elide: Text.ElideRight
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        UiTextField {
                            id: iLoopIntervalMins
                            Layout.preferredWidth: 32
                            text: {
                                var totalSecs = Number(pMacroDetails.loopInterval)
                                var m = Math.floor(totalSecs / 60)

                                return m < 10 ? "0" + m : m
                            }
                            pSize: UiTheme.textFields.sizes.small
                            validator: IntValidator {bottom: 0; top: 99999}
                            inputMethodHints: Qt.ImhDigitsOnly
                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                            pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                            onTextChanged: {
                                pMacroDetails.loopInterval = parseInt(text) * 60 + parseInt(iLoopIntervalSecs.text)
                            }
                        }
                        Text {
                            text: qsTranslate("QObject", "minutes")
                            color: UiTheme.colors.primary20
                            font: UiTheme.fonts.bodySmall
                        }
                        UiTextField {
                            id: iLoopIntervalSecs
                            Layout.preferredWidth: 32
                            text:  {
                                var totalSecs = Number(pMacroDetails.loopInterval)
                                var s = Math.floor(totalSecs % 60)

                                return s < 10 ? "0" + s : s
                            }
                            pSize: UiTheme.textFields.sizes.small
                            validator: IntValidator {bottom: 0; top: 99999}
                            inputMethodHints: Qt.ImhDigitsOnly
                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                            pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer")
                            onTextChanged: {
                                pMacroDetails.loopInterval = parseInt(text) + parseInt(iLoopIntervalMins.text) * 60
                            }
                        }
                        Text {
                            text: qsTranslate("QObject", "seconds")
                            color: UiTheme.colors.primary20
                            font: UiTheme.fonts.bodySmall
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
                UiRowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    spacing: 4
                    Text {
                        text: qsTranslate("QObject", "Playback speed")
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 32
                        topPadding: 2
                        Layout.alignment: Qt.AlignTop
                        elide: Text.ElideRight
                    }
                    UiComboBox {
                        pSize: UiTheme.comboBoxes.sizes.small
                        model: [ "0.5x", "1x", "1.5x", "2x", "2.5x", "3x", "3.5x", "4x", "4.5x", "5x"]
                        currentIndex: ( pMacroDetails.acceleration - 0.5 ) * 2
                        Layout.preferredWidth: 64
                        onActivated: {
                            pMacroDetails.acceleration = currentIndex / 2.0 + 0.5
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }
                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: qsTranslate("QObject", "Other settings")
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodySmall
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 32
                        topPadding: 2
                        Layout.alignment: Text.AlignTop
                        elide: Text.ElideRight
                    }
                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            UiCheckBox {
                                id: iAfterRadioBtn
                                checked: pMacroDetails.isRestartPlayer
                                pSize: UiTheme.checkBoxes.sizes.small
                                text: qsTranslate("QObject", "After")
                                onCheckedChanged: {
                                    pMacroDetails.isRestartPlayer = checked
                                }
                            }
                            UiTextField {
                                enabled: iAfterRadioBtn.checked
                                opacity: enabled? 1: 0.4
                                Layout.preferredWidth: 32
                                text: pMacroDetails.restartPlayerAfterMinutes
                                pSize: UiTheme.textFields.sizes.small
                                validator: IntValidator {bottom: 1; top: 99999}
                                inputMethodHints: Qt.ImhDigitsOnly
                                pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                pErrorTemplateContent: qsTranslate("QObject", "Enter a valid integer greater than 0")
                                onTextChanged: {
                                    pMacroDetails.restartPlayerAfterMinutes = parseInt(text)
                                }
                                onPInputValidationStateChanged:{
                                    if(pInputValidationState === UiTextField.InputValidation.Error)
                                        iSaveBtn.enabled = false;
                                    else
                                        iSaveBtn.enabled = true;
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "minutes, restart %1").arg(uiBackend.productName)
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                        UiRowLayout {
                            id: iStopMacroOnHomeRow
                            Layout.preferredHeight: 24
                            Layout.fillWidth: true
                            UiCheckBox {
                                checked: pMacroDetails.stopOnHome
                                pSize: UiTheme.checkBoxes.sizes.small
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "Stop macro on returning to the Home screen")
                                onCheckedChanged: {
                                    pMacroDetails.stopOnHome = checked
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.preferredHeight: 24
                            Layout.fillWidth: true
                            UiCheckBox {
                                checked: pMacroDetails.isPlayOnStart
                                pSize: UiTheme.checkBoxes.sizes.small
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "Execute macro when player starts")
                                onCheckedChanged: {
                                    pMacroDetails.isPlayOnStart = checked
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.preferredHeight: 24
                            Layout.fillWidth: true
                            UiCheckBox {
                                checked: pMacroDetails.isDoNotShowOnFinish
                                Layout.fillWidth: true
                                pSize: UiTheme.checkBoxes.sizes.small
                                font: UiTheme.fonts.bodySmall
                                text: qsTranslate("QObject", "Don’t show macro window when execution finishes")
                                onCheckedChanged: {
                                    pMacroDetails.isDoNotShowOnFinish = checked
                                }
                            }
                        }
                    }
                }
                UiButton {
                    id: iSaveBtn
                    Layout.alignment: Qt.AlignRight
                    text: qsTranslate("QObject", "Save")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.accent
                    opacity: enabled ? 1 : 0.4
                    onClicked: {
                        if (pStopMacroOnHomePrevVal !== pMacroDetails.stopOnHome)
                            plrBackend.sendMacroStopOnHomeStats(pMacroDetails.name, pMacroDetails.stopOnHome)

                        settingsSaved(pMacroDetails, pMacroIndex)
                        iMacroSettingsWindow.close()
                    }
                }
            }
        }
    }

    function fUpdateLoopTime()
    {
        var hrs = parseInt(iLoopTimeHrs.text)
        if (iLoopTimeHrs.text === "")
            hrs = 0

        var mins = parseInt(iLoopTimeMins.text)
        if (iLoopTimeMins.text === "")
            mins = 0

        var secs = parseInt(iLoopTimeSecs.text)
        if (iLoopTimeSecs.text === "")
            secs = 0

        pMacroDetails.loopTime = hrs * 60 * 60 + mins * 60 + secs
    }
}
