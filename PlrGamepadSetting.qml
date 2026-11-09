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
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import UiToolTipControl 1.0
import UiFolderDialog 1.0

Item {
    objectName: "gamepadSetting"

    property bool pCompLoaded: false
    property bool pEnableSave: false
    property string pParentWindow: ""

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
            fInitUi()
        }
        pCompLoaded = true
    }

    Component {
        id: iDiscardChangesPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Discard Changes")
            pDescription: qsTranslate("QObject", "Are you sure you want to discard changes and leave this tab?")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject",  "Discard Changes")
                        onClicked: {
                            fDiscardChanges()
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "No")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    UiColumnLayout {
        anchors.fill: parent
        spacing: 24
        UiScrollView {
            id: iScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            clip: true
            contentWidth: iContentLayout.width
            contentHeight: iContentLayout.height + 10

            UiColumnLayout {
                id: iContentLayout
                width: 520
                Layout.alignment: Qt.AlignTop
                spacing: 16

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "Gamepad detection")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                        horizontalAlignment: Text.AlignLeft
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Allow %1 to connect with your gamepad").arg(uiBackend.productName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iGamepadDetectionToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_gamepad_detection", checked)
                                fMonitorChange()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    enabled: iGamepadDetectionToggleBtn.checked
                    opacity: enabled ? 1 : 0.6
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Gamepad input settings")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                            horizontalAlignment: Text.AlignLeft
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("native_gamepad_help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Allow games direct access to your gamepad")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiComboBox {
                            id: iNativeGamepadComboBox
                            pSize: UiTheme.comboBoxes.sizes.medium
                            Layout.preferredWidth: 120
                            model: [qsTranslate("QObject", "Auto"), qsTranslate("QObject", "On"), qsTranslate("QObject", "Off")]
                            onActivated: {
                                if (pCompLoaded) {
                                    uiBackend.confSetI32("bst.enable_native_gamepad", 2 - currentIndex)
                                    fMonitorChange()
                                }
                            }
                        }
                    }

                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    enabled: iGamepadDetectionToggleBtn.checked
                    opacity: enabled ? 1 : 0.6
                    Text {
                        text: qsTranslate("QObject", "Gamepad vibration")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                        horizontalAlignment: Text.AlignLeft
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Enable gamepad vibration")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iGamepadVibrationToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_gamepad_vibration", checked)
                                fMonitorChange()
                            }
                        }
                    }
                }
            }
        }
        UiRowLayout {
            id: iBottomRow
            spacing: 4
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            UiButton{
                Layout.alignment: Qt.AlignRight
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Save changes")
                opacity: pEnableSave ? 1 : 0.4
                enabled: pEnableSave
                onClicked: {
                    fSaveChanges()
                }
            }
        }
    }

    function fInitUi() {
        iGamepadDetectionToggleBtn.checked = uiBackend.confGetBool("bst.enable_gamepad_detection")
        iGamepadVibrationToggleBtn.checked = uiBackend.confGetBool("bst.enable_gamepad_vibration")
        var state = uiBackend.confGetI32("bst.enable_native_gamepad")
        iNativeGamepadComboBox.currentIndex = 2 - state
        pEnableSave = false
    }

    function fSetPreviousState() {
        fInitUi()
    }

    function fMonitorChange() {
        if (uiBackend.confIsModified()) {
            pEnableSave = true
        } else {
            pEnableSave = false
        }
    }

    function fLoadNewSettings() {
        fInitUi()
    }

    function fShowDiscardChangesPrompt() {
        iDiscardChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
    }

    function fSaveChanges() {
        if(uiBackend.confIsPropModified("bst.enable_gamepad_detection"))
            plrBackend.plrGamepadDetectionToggle(iGamepadDetectionToggleBtn.checked)
        if(uiBackend.confIsPropModified("bst.enable_native_gamepad"))
            plrBackend.plrSetNativeGamepadMode(2 - iNativeGamepadComboBox.currentIndex)
        var reloadConf = false
        if(uiBackend.confIsPropModified("bst.enable_gamepad_vibration"))
            reloadConf = true
        uiBackend.confCommit()
        fInitUi()
        iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
        if(reloadConf)
            plrBackend.reloadConfInAllInstances()
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }
}
