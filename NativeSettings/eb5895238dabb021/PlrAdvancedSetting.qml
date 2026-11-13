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
// VOID NATIVE SETTINGS V4 — layout only; native callbacks retained
id: voidNativeSettingsPage

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
        spacing: 16
        UiScrollView {
            id: iScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            clip: true
            contentWidth: iContentLayout.width
            contentHeight: iContentLayout.height + 10

            UiColumnLayout {
                id: iContentLayout
                width: Math.min(460, Math.max(0, voidNativeSettingsPage.width))
                Layout.alignment: Qt.AlignTop
                spacing: 12
                visible: uiBackend.oem !== "wmx"
                UiColumnLayout{
                    Layout.fillWidth: true
                    spacing: 12
                    UiRowLayout{
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Application Binary Interface (ABI)")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#eeeef2"
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
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#c7c7ce"
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                        elide:Text.ElideRight
                    }

                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: uiBackend.oem !== "wmx"
                    Text {
                        text: qsTranslate("QObject", "Android Debug Bridge (ADB)")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Connect to Android at 127.0.0.1:%1").arg(uiBackend.confGetInstanceI32("status.adb_port"))
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#c7c7ce"
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
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                }
                UiColumnLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    visible: uiBackend.oem !== "wmx"
                    Text {
                        text: qsTranslate("QObject", "Input debugging")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Show visual feedback for taps")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#c7c7ce"
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
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#c7c7ce"
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
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
        UiRowLayout {
            spacing: 4
            Layout.fillWidth: true
            Layout.preferredHeight: 29

            UiImage {
                asset: "MenuInfo"
                pImageWidth: 12
                pImageHeight: 12
            }

            Text {
                text: qsTranslate("QObject", "Some changes will apply on next launch")
                font : Qt.font({family:"Segoe UI",pixelSize:10})
                color: "#c7c7ce"
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
