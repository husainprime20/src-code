/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */
import QtQuick 2.15
import QtQuick.Shapes 1.12
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import UiHelper 1.0

Item {
    objectName: "shortcutSettings"

    property bool pEnableSave: false
    property string pParentWindow: ""

    property var pAllShortcutFields: []

    property UiWindowedPopup pHelpPopup: null

    PlrSidebarProperties{id:iSidebarProperties}

    component UiShortcutTextField : UiTextField {
        id: iTextField
        property string confPropKey: ""
        property string originalConfPropValue: ""
        property string internalCombo: ""

        implicitWidth: 157
        pSize: UiTheme.textFields.sizes.small

        pErrorTemplateContent: qsTranslate("QObject", "This shortcut is already being used for another action")
        onPInputValidationStateChanged: {
            if (pInputValidationState === UiTextField.InputValidation.Valid) {
                pOpenErrorTemplate = false
                uiBackend.confSetString(confPropKey, internalCombo.trim())
            }
            else {
                if(activeFocus && hovered)
                    pOpenErrorTemplate = true
                uiBackend.confSetString(confPropKey, originalConfPropValue)
            }
        }

        hoverEnabled: true
        onHoveredChanged: {
            if (pInputValidationState === UiTextField.InputValidation.Error) {
                pOpenErrorTemplate = hovered
            }
        }

        onTextChanged: {
            if(iTextField.text === "MouseXButton1")
                iTextField.text = qsTranslate("QObject", "Mouse button1")
            else if(iTextField.text === "MouseXButton2")
                iTextField.text = qsTranslate("QObject", "Mouse button2")
            else if(iTextField.text === "MouseMButton")
                iTextField.text = qsTranslate("QObject", "Middle button")
        }

        // Discard all shortcut events like Ctrl+A, Ctrl+C etc.
        Keys.onShortcutOverride: function(event) {
            event.accepted = true
        }

        // Discard Tab pressed as it'll move to the next field
        Keys.onTabPressed: function(event) {
            event.accepted = true
        }

        // Discard Esc pressed as it could move the focus out of the text field and have unwarranted behaviour
        Keys.onEscapePressed: function(event) {
            event.accepted = true
        }

        // Special handling for all arrow keys as it'll scroll to that direction
        Keys.onUpPressed: function(event) {
            event.accepted = true
            Keys.onPressed(event)
        }
        Keys.onDownPressed: function(event) {
            event.accepted = true
            Keys.onPressed(event)
        }
        Keys.onLeftPressed: function(event) {
            event.accepted = true
            Keys.onPressed(event)
        }
        Keys.onRightPressed: function(event) {
            event.accepted = true
            Keys.onPressed(event)
        }

        Keys.onPressed: function(event) {
            // We will handle all OnPressed changes for this text field
            event.accepted = true

            // We don't want to handle if user long-presses a key
            if (event.isAutoRepeat) {
                return
            }

            // If backspace is pressed, we just want to clear the textfield for a new shortcut
            if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                this.text = ""
                this.internalCombo = ""
                fHandleShortcutChanged(this)
                return
            }

            if (event.key === Qt.Key_Control || event.key === Qt.Key_Alt || event.key === Qt.Key_Shift) {
                return
            }

            var finalShortcutInternal = plrBackend.getShortcutCombo()
            var finalDisplayShortcut = plrBackend.getDisplayComboFromNameCombo(finalShortcutInternal)

            if (finalDisplayShortcut !== "") {
                this.text = finalDisplayShortcut
                this.internalCombo = finalShortcutInternal
                fHandleShortcutChanged(this)
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.XButton1 | Qt.XButton2 | Qt.MiddleButton
            onPressed: function(mouse) {
                mouse.accepted = true
                var finalShortcutInternal = plrBackend.getShortcutCombo()
                var finalDisplayShortcut = plrBackend.getDisplayComboFromNameCombo(finalShortcutInternal)
                if(iTextField.confPropKey === "bst.shortcut.boss_key")
                    return

                if(finalDisplayShortcut === "MouseXButton1")
                    iTextField.text = qsTranslate("QObject", "Mouse button1")
                else if(finalDisplayShortcut === "MouseXButton2")
                    iTextField.text = qsTranslate("QObject", "Mouse button2")
                else if(finalDisplayShortcut === "MouseMButton")
                    iTextField.text = qsTranslate("QObject", "Middle button")

                if (finalDisplayShortcut !== "") {
                    iTextField.internalCombo = finalShortcutInternal
                    fHandleShortcutChanged(iTextField)
                }
            }
        }
    }

    Component {
        id: iHelpComponent
        UiHelpPopup {
            id: iHelpPopup
            contentWidth: 200
            x: iHelpBlock.mapToGlobal(0, 0).x - (width - iHelpBlock.width) / 2
            y: iHelpBlock.mapToGlobal(0, 0).y - height
            closeOnPressOutside: false
            flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

            pInnerLayout {
                border.width: 1
                border.color: UiTheme.colors.primary60
                color: UiTheme.colors.accentNormal
                spacing: 10
                padding: 10
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                text: qsTranslate("QObject", "Type a sequence of keys to assign it as a shortcut for the relevant action")
                font: UiTheme.fonts.bodySmall
                color: UiTheme.colors.primary10
                wrapMode: Text.Wrap
            }
        }
    }

    Component {
        id: iRestoreDefaultsPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Restore defaults")
            pDescription: qsTranslate( "QObject", "Are you sure you want to restore the shortcuts to their default keys?")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject",  "Restore defaults")
                        onClicked: {
                            fRevertShortcuts()
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

    property var pShortcutsModel: [
        {
            categoryName: qsTranslate("QObject", "Window actions"),
            subcategories: [
                { confProp: "bst.shortcut.boss_key", text: qsTranslate("QObject", "Boss key") },
                { confProp: "bst.shortcut.toggle_fullscreen", text: qsTranslate("QObject", "Toggle fullscreen"), featureEnabled: iSidebarProperties.pIsFullScreenEnabled },
                { confProp: "bst.shortcut.open_settings", text: qsTranslate("QObject", "Open settings") }
            ]
        },
        {
            categoryName: qsTranslate("QObject", "System actions"),
            subcategories: [
                { confProp: "bst.shortcut.increase_volume", text: qsTranslate("QObject", "Increase volume"), featureEnabled: iSidebarProperties.pIsVolumeEnabled  },
                { confProp: "bst.shortcut.decrease_volume", text: qsTranslate("QObject", "Decrease volume"), featureEnabled: iSidebarProperties.pIsVolumeEnabled  },
                { confProp: "bst.shortcut.mute_unmute", text: qsTranslate("QObject", "Mute/Unmute"), featureEnabled: iSidebarProperties.pIsVolumeEnabled },
                { confProp: "bst.shortcut.take_screenshot", text: qsTranslate("QObject", "Take screenshot"), featureEnabled: iSidebarProperties.pIsScreenshotEnabled },
                { confProp: "bst.shortcut.record_screen", text: qsTranslate("QObject", "Start/stop recording") },
                { confProp: "bst.shortcut.record_moment", text: qsTranslate("QObject", "Capture Moment"), featureKey:"bst.feature.show_moments" }
            ]
        },
        {
            categoryName: qsTranslate("QObject", "Android actions"),
            subcategories: [
                { confProp: "bst.shortcut.airplane_mode", text: qsTranslate("QObject", "Toggle airplane mode") },
                { confProp: "bst.shortcut.go_home", text: qsTranslate("QObject", "Home") },
                { confProp: "bst.shortcut.go_back", text: qsTranslate("QObject", "Back") },
                { confProp: "bst.shortcut.shake", text: qsTranslate("QObject", "Shake"), featureEnabled: iSidebarProperties.pIsShakeEnabled },
                { confProp: "bst.shortcut.rotate", text: qsTranslate("QObject", "Rotate"), featureEnabled: iSidebarProperties.pIsRotateEnabled },
                { confProp: "bst.shortcut.open_recent_apps", text: qsTranslate("QObject", "Recent apps") }
            ]
        },
        {
            categoryName: qsTranslate("QObject", "Game controls"),
            subcategories: [
                { confProp: "bst.shortcut.enable_disable_game_controls", text: qsTranslate("QObject", "Toggle game controls"), featureEnabled: iSidebarProperties.pIsGameControlEnabled },
                { confProp: "bst.shortcut.open_controls_editor", text: qsTranslate("QObject", "Controls editor"), featureEnabled: iSidebarProperties.pIsGameControlEnabled },
                { confProp: "bst.shortcut.toggle_eco_mode", text: qsTranslate("QObject", "Eco mode"), featureEnabled: iSidebarProperties.pIsEcoModeEnabled },
                { confProp: "bst.shortcut.show_hide_on_screen_controls", text: qsTranslate("QObject", "Show/Hide on-screen controls") },
                { confProp: "bst.shortcut.toggle_mouse_cursor_lock", text: qsTranslate("QObject", "Lock/unlock mouse cursor"), featureEnabled: iSidebarProperties.pIsLockMouseCurosrEnabled },
                { confProp: "bst.shortcut.switch_scheme", text: qsTranslate("QObject", "Switch game controls scheme") }
            ]
        },
        {
            categoryName: qsTranslate("QObject", "Miscellaneous"),
            subcategories: [
                { confProp: "bst.shortcut.open_media_folder", text: qsTranslate("QObject", "Open media gallery"), featureEnabled: iSidebarProperties.pIsOpenMediaFolderEnabled },
                { confProp: "bst.shortcut.open_macro_recorder", text: qsTranslate("QObject", "Open macro manager"), featureKey:"bst.feature.macros", featureEnabled: iSidebarProperties.pIsMacroEnabled },
                { confProp: "bst.shortcut.open_mim", text: qsTranslate("QObject", "Multi-instance manager"), featureEnabled: iSidebarProperties.pIsMimEnabled },
                { confProp: "bst.shortcut.open_sync_operations", text: qsTranslate("QObject", "Sync operations"), featureEnabled: iSidebarProperties.pIsSyncEnabled },
                { confProp: "bst.shortcut.install_apk", text: qsTranslate("QObject", "Install APK"), featureEnabled: iSidebarProperties.pIsInstallApkEnabled },
                { confProp: "bst.shortcut.play_pause_sync_operations", text: qsTranslate("QObject", "Play/pause sync operations"), featureEnabled: iSidebarProperties.pIsSyncEnabled },
                { confProp: "bst.shortcut.pause_play_macros", text: qsTranslate("QObject", "Pause/play macros"), featureEnabled: iSidebarProperties.pIsMacroEnabled },
                { confProp: "bst.shortcut.trim_memory", text: qsTranslate("QObject", "Trim memory"), featureEnabled: iSidebarProperties.pIsSyncEnabled },
                { confProp: "bst.shortcut.open_location_provider", text: qsTranslate("QObject", "Set location"), featureEnabled: iSidebarProperties.pIsSetLocationEnabled },
                { confProp: "bst.shortcut.screen_translate", text: qsTranslate("QObject", "Screen translation") }
            ]
        }
    ]

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

                Repeater {
                    id: iShortcutsRepeater
                    model: pShortcutsModel
                    delegate : Component {
                        UiColumnLayout {
                            spacing: 16
                            Layout.fillWidth: true

                            UiColumnLayout {
                                spacing: 12
                                Layout.fillWidth: true

                                Text {
                                    text: modelData.categoryName
                                    font: UiTheme.fonts.bodyLarge
                                    color: UiTheme.colors.primary10
                                }

                                Repeater {
                                    id: iRepeater
                                    model: modelData.subcategories
                                    delegate : Component {

                                        UiRowLayout {
                                            id: iShortcutRow
                                            visible: (modelData.featureKey === undefined || uiBackend.confGetBool(modelData.featureKey)) && (modelData.featureEnabled === undefined || modelData.featureEnabled)
                                            Layout.fillWidth: true
                                            spacing: 8
                                            Text {
                                                text: modelData.text
                                                font: UiTheme.fonts.bodyMedium
                                                color: UiTheme.colors.primary20
                                                horizontalAlignment: Text.AlignLeft
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                            UiShortcutTextField {
                                                id: iShortcutTextField
                                                confPropKey: modelData.confProp
                                                text: plrBackend.getDisplayComboFromNameCombo(uiBackend.confGetString(modelData.confProp))
                                                internalCombo: uiBackend.confGetString(modelData.confProp)
                                                originalConfPropValue: uiBackend.confGetString(modelData.confProp)
                                                UiHelper.inputMethodEditing: false
                                                Component.onCompleted: {
                                                    if((modelData.featureKey === undefined || uiBackend.confGetBool(modelData.featureKey)) && (modelData.featureEnabled === undefined || modelData.featureEnabled))
                                                        pAllShortcutFields.push(iShortcutTextField)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                visible: index !== (pShortcutsModel.length - 1)
                                Layout.preferredHeight: 1
                                color: UiTheme.colors.seperator
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }

        // Footer
        UiRowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            UiRowLayout {
                id: iHelpBlock
                spacing: 4
                pMouseArea {
                    anchors.fill: iHelpBlock
                    enabled: true
                    hoverEnabled: true
                    onEntered: {
                        fToggleHelpPopup(true)
                    }
                    onExited: {
                        fToggleHelpPopup(false)
                    }
                }
                UiImage {
                    asset: "MenuHelp"
                    pImageWidth: 12
                    pImageHeight: 12
                }
                Text {
                    text: qsTranslate("QObject", "Help")
                    font : UiTheme.fonts.bodySmall
                    color: UiTheme.colors.primary20
                }
            }

            UiRowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 16
                UiButton {
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.secondary
                    text: qsTranslate("QObject", "Restore default")
                    onClicked: {
                        iRestoreDefaultsPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    }
                }
                UiButton {
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.accent
                    text: qsTranslate("QObject", "Save changes")
                    opacity: pEnableSave ? 1 : 0.4
                    enabled: pEnableSave
                    onClicked: {
                        fShortcutsSaved()
                    }
                }
            }
        }
    }

    function fRevertShortcuts() {
        var shortcutConfList = []
        for (var i = 0; i < pShortcutsModel.length; i++) {
            for (var j = 0; j < pShortcutsModel[i].subcategories.length; j++) {
                shortcutConfList.push(pShortcutsModel[i].subcategories[j].confProp)
            }
        }

        plrBackend.revertDefaultShortcuts(shortcutConfList)
        fReInitUi()
    }

    function fHandleShortcutChanged(textBox) {
        uiBackend.confSetString(textBox.confPropKey, textBox.internalCombo.trim())
        if (fIsShortcutInUse()) {
            pEnableSave = false
        }
        else {
            uiBackend.confSetString(textBox.confPropKey, textBox.internalCombo.trim())
            pEnableSave = uiBackend.confIsModified()
        }
    }

    function fIsShortcutInUse() {
        var inUse = false
        for (var i = 0; i < pAllShortcutFields.length; i++) {
            var inLocalUse = false
            for (var j = 0; j < pAllShortcutFields.length; j++) {
                if (j !== i && pAllShortcutFields[i].internalCombo !== "" && pAllShortcutFields[i].internalCombo === pAllShortcutFields[j].internalCombo) {
                    pAllShortcutFields[i].pInputValidationState = UiTextField.InputValidation.Error
                    inUse = true
                    inLocalUse = true
                    break
                }
            }
            if(!inLocalUse)
                pAllShortcutFields[i].pInputValidationState = UiTextField.InputValidation.Valid

        }
        return inUse
    }

    function fReInitUi() {
        pAllShortcutFields = []
        iShortcutsRepeater.model = []
        iShortcutsRepeater.model = pShortcutsModel
        pEnableSave = false
    }

    function fShortcutsSaved() {
        uiBackend.confCommit()
        plrBackend.updateShortcutList()
        fReInitUi()
        iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fReInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fToggleHelpPopup(show) {
        if (show) {
            if (pHelpPopup == null) {
                pHelpPopup = iHelpComponent.createObject(iSettingsWindow)
            }
            pHelpPopup.show()
        }
        else {
            if (pHelpPopup != null) {
                pHelpPopup.close()
            }
        }
    }

    function fReloadShortcutsForTranslations() {
        iShortcutsRepeater.model = []
        iShortcutsRepeater.model = pShortcutsModel
    }
}
