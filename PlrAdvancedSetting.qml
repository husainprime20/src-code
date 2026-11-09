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

Item {
    objectName: "advanceSetting"

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
            pDescription: qsTranslate( "QObject", "Are you sure you want to discard changes and leave this tab?")
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

    Component {
        id: iSaveChangesPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Restart %1").arg(uiBackend.productName)
            pDescription: qsTranslate( "QObject","Some of the changes need %1 to restart. Do you want to restart now?").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.Simple
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Restart Now")
                        onClicked: {
                            iSettingsWindow.hide()
                            iSettingsWindow.showRestartLoader()
                            uiBackend.confCommit()
                            plrBackend.restartPlayer()
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Discard Changes")
                        onClicked: {
                            fDiscardChanges()
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
                visible: uiBackend.oem !== "wmx"
                UiColumnLayout{
                    Layout.fillWidth: true
                    spacing: 12
                    UiRowLayout{
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Application Binary Interface (ABI)")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: uiBackend.openHelpArticle("ABI_Help")
                        }
                    }
                    Text {
                        text: qsTranslate("QObject", uiBackend.getAbiList())
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                        elide:Text.ElideRight
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
                    visible: uiBackend.oem !== "wmx"
                    Text {
                        text: qsTranslate("QObject", "Android Debug Bridge (ADB)")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Connect to Android at 127.0.0.1:%1").arg(uiBackend.confGetInstanceI32("status.adb_port"))
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            elide:Text.ElideRight
                        }
                        UiToggleButton {
                            id: iEnableAdbToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_adb_access", checked)
                                fMonitorChange()
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Turn off ADB after debugging. Leaving it on can compromise the security of your system.")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }
                UiColumnLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    visible: uiBackend.oem !== "wmx"
                    Text {
                        text: qsTranslate("QObject", "Input debugging")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Show visual feedback for taps")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        UiToggleButton {
                            id: iShowTouchPointToggleBtn
                            onCheckedChanged: {
                                fMonitorChange()
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Show pointer location for current touch data")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        UiToggleButton {
                            id: iShowPointerLocationToggleBtn
                            onCheckedChanged: {
                                fMonitorChange()
                            }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Enabling this setting can have adverse effects on your gameplay. Turn it off after debugging.")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
        UiRowLayout {
            spacing: 4
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            UiImage {
                asset: "MenuInfo"
                pImageWidth: 12
                pImageHeight: 12
            }

            Text {
                text: qsTranslate("QObject", "Some changes will apply on next launch")
                font : UiTheme.fonts.bodySmall
                color: UiTheme.colors.primary20
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            UiButton{
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Save changes")
                opacity: pEnableSave ? 1 : 0.4
                enabled: pEnableSave
                onClicked: {
                    fHandleConfChange()
                    uiBackend.confCommit()
                }
            }
        }
    }

    function fInitUi() {
        iEnableAdbToggleBtn.checked = uiBackend.confGetBool("bst.enable_adb_access")
        iShowTouchPointToggleBtn.checked = plrBackend.getShowGuestTouchPoints()
        iShowPointerLocationToggleBtn.checked = plrBackend.getShowGuestPointerLocation()
        pEnableSave = false
    }

    function fMonitorChange() {
        if (uiBackend.confIsModified()
                || iShowTouchPointToggleBtn.checked !== plrBackend.getShowGuestTouchPoints()
                || iShowPointerLocationToggleBtn.checked !== plrBackend.getShowGuestPointerLocation()) {
            pEnableSave = true
        } else {
            pEnableSave = false
        }
    }

    function fSetPreviousState() {
        fInitUi()
    }

    function fAdvanceSettingChangedClbk(status) {
        if (0 === status) {
            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
            uiBackend.confCommit()
        } else {
            uiBackend.confDiscard()
        }
        fSetPreviousState()
    }

    function fOnAppDataCleared(status) {
        if (0 === status) {
            iSaveChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
        } else {
            iSettingsWindow.fShowToast(qsTranslate("QObject", "Failed to switch abi"))
            uiBackend.confDiscard()
            fSetPreviousState()
        }
    }

    function fHandleConfChange() {
        if (iShowTouchPointToggleBtn.checked !== plrBackend.getShowGuestTouchPoints() ||
                iShowPointerLocationToggleBtn.checked !== plrBackend.getShowGuestPointerLocation())
            plrBackend.setEnableInputDebugging( iShowTouchPointToggleBtn.checked, iShowPointerLocationToggleBtn.checked)

        if (uiBackend.confIsPropModified("bst.enable_adb_access"))
            plrBackend.enableAdbAccess(uiBackend.confGetBool("bst.enable_adb_access"))
    }

    function fShowDiscardChangesPrompt() {
        iDiscardChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fAndroidTouchPointSettingChanged() {
        return iShowTouchPointToggleBtn.checked !== plrBackend.getShowGuestTouchPoints() || iShowPointerLocationToggleBtn.checked !== plrBackend.getShowGuestPointerLocation()
    }

    function fResetAndroidTouchPointsSetting() {
        iShowTouchPointToggleBtn.checked = plrBackend.getShowGuestTouchPoints()
        iShowPointerLocationToggleBtn.checked = plrBackend.getShowGuestPointerLocation()
    }
}
