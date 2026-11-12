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
    readonly property string pShortcutsId: "shortcuts"
    readonly property string pGameSettingsId: "gameSettings"
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
                        onClicked: { close() }
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
                        onClicked: { close() }
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
id:iSettingsWindowShadowContainer;anchors.fill:parent
Loader{id:bsiExternal;anchors.fill:parent
Component.onCompleted:setSource("file:///C:/Program%20Files/BlueStacks_msi5/Assets/BSISettingsOutline.qml",{bsiHost:iSettingsWindow,bsiTheme:UiTheme})
onLoaded:iSelectedSettingControl.parent=item.pageContainer
}
Text{anchors.centerIn:parent;visible:bsiExternal.status===Loader.Error;text:"Settings style missing. Close with Alt+F4.";color:UiTheme.colors.primary10}
StackLayout{id:iSelectedSettingControl;anchors.fill:parent;anchors.margins:8;visible:bsiExternal.status===Loader.Ready;currentIndex:pCurrentTabIndex
Repeater{model:pSettingsItems.pSettingElements;delegate:Loader{Component.onCompleted:{var a=model.modelData.pComponentArgs;a?setSource(model.modelData.pQmlSource,a):setSource(model.modelData.pQmlSource)}onLoaded:{model.modelData.pComponentObj=item;if(item.fOnQmlLoaded)item.fOnQmlLoaded()}}}
}
}
    onVisibleChanged: if (visible && transientParent) {
        width = transientParent.width * 0.70
        height = transientParent.height * 0.70
        x = transientParent.x + (transientParent.width - width) / 2
        y = transientParent.y + (transientParent.height - height) / 2
    }
}
