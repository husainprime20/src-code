/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import SettingElementModel 1.0
import SettingElementModelList 1.0

Window {
    id: iSettingsWindow
    objectName: "settingsWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: qsTranslate("QObject", "Settings")

    screen: transientParent.screen
    readonly property alias pShadowThickness: iSettingsWindowShadowContainer.shadowThickness

    signal showRestartLoader()
    signal gamepadDetectionEnabled()

    property int pCurrentTabIndex: 0
    property int pNewTabIndex: 0
    property string pParentWindow: ""
    readonly property string pShortcutsId:    "shortcuts"
    readonly property string pGameSettingsId:    "gameSettings"
    readonly property string pAdvanceSettingId: "advanceSettings"
    property SettingElementModelList pSettingsItems: SettingElementModelList { }
    property bool pGamepadDetectionEnabled: uiBackend.confGetBool("bst.enable_gamepad_detection")
    Component.onCompleted: {
        if(pParentWindow == "plr") {
            plrBackend.setSettingsWindowObject()
            uiBackend.pIsShortcutsEnabled = false
        }
    }

    property UiToastPopup pUiSettingsToast: null
    Component {
        id: iSettingsToastComponent
        UiToastPopup { }
    }

    function fChangeSelectedSetting(newIndex) {
        pNewTabIndex = newIndex
        if (uiBackend.confIsModified() || fIsGameSettingsChanged() || fIsAnyAdvanceSettingChanged())
            iDiscardChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
        else
            fSwitchSettingPanel()
    }

    function fIsGameSettingsChanged(index) {
        var isChanged = false
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(i===pCurrentTabIndex && pSettingsItems.pSettingElements[i].pButtonId === pGameSettingsId) {
                if(pSettingsItems.pSettingElements[i].pComponentObj.fIsAnyAppSettingsChanged !== undefined)
                    isChanged = pSettingsItems.pSettingElements[i].pComponentObj.fIsAnyAppSettingsChanged()
            }
        }
        return isChanged
    }

    function fIsAnyAdvanceSettingChanged() {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if (pSettingsItems.pSettingElements[i].pButtonId === pAdvanceSettingId) {
                if (pSettingsItems.pSettingElements[i].pComponentObj.fAndroidTouchPointSettingChanged !== undefined) {
                    return pSettingsItems.pSettingElements[i].pComponentObj.fAndroidTouchPointSettingChanged()
                }
                break
            }
        }
        return false
    }

    function fClearGameSettingsData() {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(i===pCurrentTabIndex && pSettingsItems.pSettingElements[i].pButtonId === pGameSettingsId) {
                if(pSettingsItems.pSettingElements[i].pComponentObj.fClearChangedSettingsOfApp !== undefined)
                    pSettingsItems.pSettingElements[i].pComponentObj.fClearChangedSettingsOfApp()
            }
        }
    }

    function fClearAdvanceSettingData() {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if (pSettingsItems.pSettingElements[i].pButtonId === pAdvanceSettingId) {
                if (pSettingsItems.pSettingElements[i].pComponentObj.fResetAndroidTouchPointsSetting !== undefined) {
                    pSettingsItems.pSettingElements[i].pComponentObj.fResetAndroidTouchPointsSetting()
                }
                break
            }
        }
    }

    function fSwitchSettingPanel() {
        if (pCurrentTabIndex !== pNewTabIndex) {
            pCurrentTabIndex = pNewTabIndex

            var isShortcutTab = false
            for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
                if(i===pCurrentTabIndex && pSettingsItems.pSettingElements[i].pButtonId === pShortcutsId)
                    isShortcutTab = true
            }
            fEnableShortcutsEditingMode(isShortcutTab)
        }
    }

    function fPreferenceSettingChangedClbk(status) {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(pSettingsItems.pSettingElements[i].pComponentObj.fPreferenceSettingChangedClbk !== undefined)
                pSettingsItems.pSettingElements[i].pComponentObj.fPreferenceSettingChangedClbk(status)
        }
    }

    function fAdvanceSettingChangedClbk(status) {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(pSettingsItems.pSettingElements[i].pComponentObj.fAdvanceSettingChangedClbk !== undefined)
                pSettingsItems.pSettingElements[i].pComponentObj.fAdvanceSettingChangedClbk(status)
        }
    }

    function fRefreshAudioSettingModels(refreshOutputModel) {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(pSettingsItems.pSettingElements[i].pComponentObj.fRefreshAudioSettingModels !== undefined)
                pSettingsItems.pSettingElements[i].pComponentObj.fRefreshAudioSettingModels(refreshOutputModel)
        }
    }

    function fReloadSettingComboboxes() {
        for(var i=0; i< pSettingsItems.pSettingElements.length; i++) {
            if(pSettingsItems.pSettingElements[i].pComponentObj.fReloadComboboxes !== undefined)
                pSettingsItems.pSettingElements[i].pComponentObj.fReloadComboboxes()
        }
    }

    function fShowToast(message) {
        pUiSettingsToast = iSettingsToastComponent.createObject(iSettingsWindow, { pToastMessage: message })
        pUiSettingsToast.fShowMessage({widthOffset:0})
    }

    function fSaveSettingsForMim(){
        for (var conf in updateConfList) {
            uiBackend.confSetString(conf, updateConfList[conf])
        }

        for (var instConf in updateInstanceConfList) {
            uiBackend.confSetInstanceString(instConf, updateInstanceConfList[instConf])
        }
        uiBackend.confCommit()
        close()
    }

    Component {
        id: iDiscardChangesAndClosePrompt
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
                            uiBackend.confDiscard()
                            fClearGameSettingsData()
                            fClearAdvanceSettingData()
                            close()
                            iSettingsWindow.close()
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
                            if(pSettingsItems.pSettingElements[pCurrentTabIndex].pComponentObj.fDiscardChanges() !== undefined)
                                pSettingsItems.pSettingElements[pCurrentTabIndex].pComponentObj.fDiscardChanges()
                            fSwitchSettingPanel()
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

    onClosing: function(close) {
        if (uiBackend.confIsModified() || fIsGameSettingsChanged() || fIsAnyAdvanceSettingChanged()) {
            close.accepted = false;
            iDiscardChangesAndClosePrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
        } else {
            if (pUiSettingsToast != null)
                pUiSettingsToast.fClosePopup()
            fPlrResetSettingsObjects()
            pSettingsWindow.destroy()
        }
        if(!pGamepadDetectionEnabled && uiBackend.confGetBool("bst.enable_gamepad_detection"))
            gamepadDetectionEnabled()
    }

    function fPlrResetSettingsObjects() {
        fEnableShortcutsEditingMode(false)
        if(pParentWindow == "plr") {
            uiBackend.pIsShortcutsEnabled = true
            plrBackend.clearSettingsWindowObject()
        }
    }

    function fEnableShortcutsEditingMode(enable) {
        if(pParentWindow == "plr")
            plrBackend.shortcutsEditingMode(enable)
    }

    UiShadowContainer {
        id: iSettingsWindowShadowContainer
        Rectangle {
            anchors.fill: parent
            color: UiTheme.colors.primary80
            UiColumnLayout {
                id:iContentLayout
                anchors.centerIn: parent
                spacing: 20

                UiColumnLayout {
                    id: iSettingsWindowsHeader
                    Layout.preferredHeight: 40
                    Layout.fillWidth: true

                    Text {
                        text: qsTranslate("QObject", "Settings")
                        font: UiTheme.fonts.titleExtraLarge
                        color: UiTheme.colors.primary10
                    }
                }

                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 32
                    UiRowLayout{
                        Layout.alignment: Qt.AlignTop
                        spacing: 4
                        UiColumnLayout {
                            Repeater {
                                model: pSettingsItems.pSettingElements
                                delegate: Component {
                                    UiSettingsButton {
                                        id: iSettingBtn
                                        pSettingIdx: model.index;
                                        pSettingBtnText: model.modelData.pButtonText
                                        pSelected: model.index === pCurrentTabIndex;
                                        pShowRedDot: model.modelData.pShowRedDot
                                        visible: model.modelData.pIsVisible
                                        onSettingClicked: {
                                            fChangeSelectedSetting(model.index)
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.fillHeight: true
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(UiTheme.colors.primary60.r, UiTheme.colors.primary60.g, UiTheme.colors.primary60.b, 1) }
                                GradientStop { position: 1.0; color: Qt.rgba(UiTheme.colors.primary60.r, UiTheme.colors.primary60.g, UiTheme.colors.primary60.b, 0) }
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: iSettingsWindow.height * 0.85 - iSettingsWindowsHeader.height - iContentLayout.spacing
                        Layout.minimumHeight: 360
                        Layout.maximumHeight: 570
                        Layout.preferredWidth: 548
                        color: "transparent"
                        StackLayout {
                            id: iSelectedSettingControl
                            anchors.fill: parent
                            currentIndex: pCurrentTabIndex
                            Repeater {
                                model: pSettingsItems.pSettingElements
                                delegate: Loader {
                                    Component.onCompleted: {
                                        if(model.modelData.pComponentArgs !== null)
                                            setSource(model.modelData.pQmlSource, model.modelData.pComponentArgs)
                                        else
                                            setSource(model.modelData.pQmlSource)
                                    }
                                    onLoaded: {
                                        model.modelData.pComponentObj = item
                                        if(item.fOnQmlLoaded)
                                            item.fOnQmlLoaded()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            UiImageButton {
                asset: "CloseIcon"
                pImageWidth: 16
                pImageHeight: 16
                anchors.top: parent.top
                anchors.topMargin: Math.min(iSettingsWindow.height * 0.06, 56)
                anchors.right: parent.right
                anchors.rightMargin: Math.min(iSettingsWindow.height * 0.06, 56)
                onClicked:  iSettingsWindow.close()
            }
        }
    }
}
