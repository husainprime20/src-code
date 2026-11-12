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
    objectName: "gameSetting"

    property bool pCompLoaded: false
    property bool pEnableSave: false
    property int pSelectedAppsCount
    property var pAppSettingsChanged: []
    property int pDefaultSelectedApps: 0
    property bool pIsAllAppsToggled: false
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
                    spacing: 4
                    UiText {
                        text: qsTranslate("QObject", "Launch in fullscreen")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    UiText {
                        text: qsTranslate("QObject", "Choose apps that you want to launch in fullscreen by default.")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary30
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                    }
                }

                UiRowLayout {
                    visible: !iAllAppsRow.visible
                    border.color: UiTheme.colors.primary50
                    color: UiTheme.colors.primary90
                    Layout.topMargin: 20
                    spacing: 6
                    UiImage {
                        Layout.leftMargin: 12
                        Layout.topMargin: 12
                        Layout.bottomMargin: 12
                        asset: "MenuInfo"
                        pImageHeight: 16
                        pImageWidth: 16
                    }
                    UiText {
                        Layout.rightMargin: 12
                        Layout.topMargin: 12
                        Layout.bottomMargin: 12
                        text: qsTranslate("QObject", "No apps installed")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary20
                        Layout.fillWidth: true
                        elide:Text.ElideRight
                    }
                }

                UiRowLayout {
                    id: iAllAppsRow
                    visible: plrBackend.getInstalledAppsCount()
                    Layout.topMargin: 20
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: qsTranslate("QObject", "All apps")
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        horizontalAlignment: Text.AlignLeft
                        Layout.fillWidth: true
                        elide:Text.ElideRight
                    }
                    UiToggleButton {
                        id: iEnableFullScreenInAppsToggleBtn
                        onToggled: {
                            uiBackend.confSetInstanceBool("enable_fullscreen_all_apps", checked)
                            plrBackend.modifyFullScreenSetting(checked, true, "")
                            if (!checked)
                                pSelectedAppsCount = 0
                            else
                                pSelectedAppsCount = plrGameSettingViewModel.rowCount()

                            pAppSettingsChanged = []
                            pIsAllAppsToggled = pDefaultSelectedApps !== pSelectedAppsCount
                            fMonitorChange()
                        }
                    }
                }

                UiColumnLayout {
                    spacing: 12
                    Layout.fillWidth: true

                    Repeater
                    {
                        id: iGameSettingsRepeaterId
                        model: plrGameSettingViewModel
                        delegate: UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            UiImage {
                                source: model.iconFileName
                                pImageHeight: 24
                                pImageWidth: 24
                            }

                            UiText {
                                text: model.appLabel
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary20
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            UiToggleButton {
                                id: iFullScreenToggleBtn
                                checked: model.isFullScreen
                                onToggled: {
                                    model.isFullScreen = checked
                                    if(checked) {
                                        pSelectedAppsCount++
                                        if(plrGameSettingViewModel.rowCount() === pSelectedAppsCount) {
                                            iEnableFullScreenInAppsToggleBtn.checked = true
                                            uiBackend.confSetInstanceBool("enable_fullscreen_all_apps", true)
                                        }
                                    }
                                    else {
                                        if(pSelectedAppsCount > 0)
                                            pSelectedAppsCount--
                                        iEnableFullScreenInAppsToggleBtn.checked = false
                                        uiBackend.confSetInstanceBool("enable_fullscreen_all_apps", false)
                                    }
                                    pIsAllAppsToggled = pSelectedAppsCount !== pDefaultSelectedApps
                                    if(plrBackend.getFullScreenSettingForApp(model.appPkg) !== model.isFullScreen) {
                                        pAppSettingsChanged.push(model.appPkg)
                                    }
                                    else {
                                        var ind = pAppSettingsChanged.indexOf(model.appPkg)
                                        if (ind > -1) {
                                            pAppSettingsChanged.splice(ind, 1);
                                        }
                                    }
                                    fMonitorChange()
                                }
                            }
                        }
                    }
                }
            }
        }
        UiRowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            UiButton{
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Save changes")
                opacity: pEnableSave ? 1 : 0.4
                enabled: pEnableSave
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    uiBackend.confCommit()
                    plrBackend.setAppLaunchInFullScreen(true)
                    fSendStats()
                    pEnableSave = false
                    pAppSettingsChanged = []
                    pIsAllAppsToggled = false
                    pDefaultSelectedApps = pSelectedAppsCount
                    iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                }
            }
        }
    }

    function fInitUi() {
        plrBackend.populateFullScreenSettingModel()
        pSelectedAppsCount = plrBackend.getFullScreenAppsCount()
        if(plrGameSettingViewModel.rowCount() > 0) {
            iEnableFullScreenInAppsToggleBtn.checked = pSelectedAppsCount === plrGameSettingViewModel.rowCount() ? true : false
            uiBackend.confSetInstanceBool("enable_fullscreen_all_apps", iEnableFullScreenInAppsToggleBtn.checked)
            uiBackend.confCommit()
        }

        pDefaultSelectedApps = pSelectedAppsCount
        pIsAllAppsToggled = false
        pAppSettingsChanged = []
        pEnableSave = false
    }

    function fMonitorChange() {
        var settingChanged = pAppSettingsChanged.length > 0 ? true : false
        if (uiBackend.confIsModified() || settingChanged || pIsAllAppsToggled)
            pEnableSave = true
        else
            pEnableSave = false
    }

    function fSendStats() {
        var packagesList = ""
        for(var i = 0; i< pAppSettingsChanged.length; i++)
            packagesList += pAppSettingsChanged[i] + "+"
        plrBackend.sendGameSettingsStats(packagesList)
    }

    function fSetPreviousState() {
        fInitUi()
    }

    function fShowDiscardChangesPrompt() {
        iDiscardChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fClearChangedSettingsOfApp()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fIsAnyAppSettingsChanged() {
        return (pAppSettingsChanged.length || pIsAllAppsToggled) > 0 ? true : false
    }

    function fClearChangedSettingsOfApp() {
        pAppSettingsChanged = []
        pIsAllAppsToggled = false
    }
}
