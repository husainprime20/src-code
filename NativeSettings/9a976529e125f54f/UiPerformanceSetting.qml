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
import UiAndroidImageTrait 1.0
import UiToolTipControl 1.0

Item {
// VOID NATIVE SETTINGS V4 — layout only; native callbacks retained
id: voidNativeSettingsPage

    property bool   pCompLoaded: false
    property bool   pEnableSave: false
    property string pParentWindow: ""
    property string pVmName: ""

    property int    pMaxRam: 4096
    property int    pMaxCpu: 8

    property int    pDefaultCpu: -1
    property int    pDefaultRam: -1

    property int pCurrentCpu: -11
    property ListModel pCustomCpuModel: ListModel{}

    property list<QtObject> pRamModel: [
        QtObject {
            property string text: qsTranslate("QObject", "Extreme %1").arg("(12 GB)")
            property string value: "12288"
            property bool visible: fShowRamSelectionOption(12)
        },
        QtObject {
            property string text: qsTranslate("QObject", "High %1").arg("(8 GB)")
            property string value: "8192"
            property bool visible: fShowRamSelectionOption(8)
        },
        QtObject {
            property string text: qsTranslate("QObject", "Enhanced %1").arg("(4 GB)")
            property string value: "4096"
            property bool visible: true
        },
        QtObject {
            property string text: qsTranslate("QObject", "Standard %1").arg("(2 GB)")
            property string value: "2048"
            property bool visible: true
        },
        QtObject {
            property string text: qsTranslate("QObject", "Basic %1").arg("(1 GB)")
            property string value: "1024"
            property bool visible: true
        },
        QtObject {
            property string text: qsTranslate("QObject", "Custom %1").arg("(MB)")
            property string value: "*"
            property bool visible: true
        }
    ]

    property list<QtObject> pCpuModel: [
        QtObject {
            property string text: qsTranslate("QObject", "High (%1 Cores)").arg("4")
            property string value: "4"
        },
        QtObject {
            property string text: qsTranslate("QObject", "Medium (%1 Cores)").arg("2")
            property string value: "2"
        },
        QtObject {
            property string text: qsTranslate("QObject", "Low (1 Core)")
            property string value: "1"
        },
        QtObject {
            property string text: qsTranslate("QObject", "Custom")
            property string value: "1"
        }
    ]

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
            fGetMaxRamAndCpu()
            fInitUi()
        }
        pCompLoaded = true
    }

    Component {
        id: iSaveChangesPrompt
        UiMessageDialog {
            title:qsTranslate("QObject", "Restart %1").arg(uiBackend.productName)
            pDescription: qsTranslate("QObject", "Some of the changes need %1 to restart. Do you want to restart now?").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.Simple
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Restart Now")
                        onClicked: {
                            var notify = false
                            if (uiBackend.confIsInstancePropModified("ram") || uiBackend.confIsInstancePropModified("cpus")) {
                                notify = true
                            }
                            iSettingsWindow.hide()
                            iSettingsWindow.showRestartLoader()
                            uiBackend.confCommit()
                            if (notify)
                                plrBackend.instanceConfigChanged()
                            plrBackend.restartPlayer()
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Discard Changes")
                        onClicked: {
                            fDiscardChanges()
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iRestartLaterPrompt
        UiMessageDialog {
            title:qsTranslate("QObject", "Restart needed")
            pDescription: qsTranslate("QObject", "Some of the changes need %1 to restart. Do you want to restart now?").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.Simple
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Restart Now")
                        onClicked: {
                            plrBackend.sendFpsSliderSettingStats("Restart now")
                            iSettingsWindow.hide()
                            iSettingsWindow.showRestartLoader()
                            uiBackend.confCommit()
                            plrBackend.restartPlayer()
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Restart Later")
                        onClicked: {
                            plrBackend.sendFpsSliderSettingStats("Restart later")
                            fHandleConfChange()
                            plrBackend.setMaxFps(parseInt(uiBackend.confGetInstanceI32("max_fps")))
                            fInitUi()
                            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                            close()
                        }
                    }
                ]
            }
            onCloseClicked: {
                plrBackend.sendFpsSliderSettingStats("Close")
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
            contentHeight: iContentLayout.height + 20

            UiColumnLayout {
                id: iContentLayout
                width: Math.min(460, Math.max(0, voidNativeSettingsPage.width))
                Layout.alignment: Qt.AlignTop
                spacing: 12
                UiColumnLayout {
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "CPU allocation")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }
                    UiRowLayout {
                        spacing: 8
                        UiComboBox {
                            id: iCpuCombobox
                            pSize: UiTheme.comboBoxes.sizes.medium
                            model: pCpuModel
                            textRole: "text"
                            valueRole: "value"
                            Layout.preferredWidth: 174
                            onActivated: {
                                if (pCompLoaded) {
                                    if(currentIndex<=2){
                                        uiBackend.confSetInstanceI32("cpus", currentValue)
                                        iCustomCpuCombobx.visible = false
                                        iCustomCpuCombobx.currentIndex = pDefaultCpu - 1
                                    }
                                    else {
                                        uiBackend.confSetInstanceI32("cpus", pDefaultCpu)
                                        iCustomCpuCombobx.visible = true
                                    }

                                    pCurrentCpu = uiBackend.confGetInstanceI32("cpus")
                                    fMonitorChange()
                                }
                            }
                        }
                        UiComboBox {
                            id: iCustomCpuCombobx
                            pSize: UiTheme.comboBoxes.sizes.medium
                            model: pCustomCpuModel
                            Layout.preferredWidth: 174
                            visible: false
                            onActivated: {
                                if (pCompLoaded && iCpuCombobox.currentIndex === 3) {
                                    uiBackend.confSetInstanceI32("cpus", currentIndex + 1)

                                    pCurrentCpu = uiBackend.confGetInstanceI32("cpus")
                                    fMonitorChange()
                                }
                            }
                        }
                    }
                }
                UiTextUrl {
                    id: iRawModewarningText
                    visible: {
                        if (pCurrentCpu === 1)
                            return false
                        else
                            return uiBackend.confGetBoolDefaultWhenEmpty("bst.status.raw_mode", false)
                    }
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "%1 is currently limited to using 1 CPU core. To utilize more CPU cores, please enable hardware-assisted virtualization.").arg(uiBackend.productName) + " " + "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "View solution") + "</a>"
                    onLinkActivated: uiBackend.openRawModeHelp()
                    font: Qt.font({family:"Segoe UI",pixelSize:10})
                    color: UiTheme.colors.warning
                    linkColor: "#eeeef2"
                }
                Text {
                    id: iMaxCpuwarningTxt
                    visible: !iRawModewarningText.visible && (pCurrentCpu === pMaxCpu)
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "Assigning all CPU cores to %1 will cause overall system to lag/slowdown").arg(uiBackend.productName)
                    font: Qt.font({family:"Segoe UI",pixelSize:10})
                    color: UiTheme.colors.warning
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                }
                UiColumnLayout {
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "Memory allocation")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }
                    UiRowLayout {
                        spacing: 8
                        UiComboBox {
                            id: iRamCombobox
                            pSize: UiTheme.comboBoxes.sizes.medium
                            model: pRamModel
                            textRole: "text"
                            valueRole: "value"
                            pVisibilityRole: "visible"
                            Layout.preferredWidth: 174
                            onActivated: {
                                if (pCompLoaded) {
                                    if (currentValue === "*") {
                                        uiBackend.confSetInstanceI32("ram", parseInt(iCustomRamTextField.text))
                                    }
                                    else {
                                        uiBackend.confSetInstanceI32("ram", currentValue)
                                        iCustomRamTextField.text = currentValue
                                    }
                                    fMonitorChange()
                                }
                            }
                        }
                        UiTextField {
                            id: iCustomRamTextField
                            pSize: UiTheme.textFields.sizes.medium
                            Layout.preferredWidth: 174
                            visible: (iRamCombobox.currentIndex === pRamModel.length - 1)
                            text: "4096"
                            validator: IntValidator {bottom: 600; top: pMaxRam}
                            inputMethodHints: Qt.ImhDigitsOnly
                            maximumLength: 5
                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                            pErrorTemplateContent: qsTranslate("QObject", "Supported memory allocation range is: %1").arg("600-" + pMaxRam+" MB")
                            onTextChanged: {
                                if (pCompLoaded) {
                                    if (iCustomRamTextField.acceptableInput) {
                                        uiBackend.confSetInstanceI32("ram", parseInt(text))
                                    } else {
                                        uiBackend.confSetInstanceI32("ram", pDefaultRam)
                                    }
                                    fMonitorChange()
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                }
                UiColumnLayout{
                    Layout.fillWidth: true
                    spacing: 12
                    visible: pParentWindow === "plr" ? true : false
                    UiColumnLayout{
                        spacing: 4
                        UiRowLayout{
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Performance mode")
                                font: Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#eeeef2"
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageHeight: 16
                                pImageWidth: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: {
                                    uiBackend.openHelpArticle("PerformanceMode_Help")
                                }
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                        UiRowLayout{
                            Layout.fillWidth: true
                            visible: pParentWindow === "plr" && plrBackend.getInstancesCount() > 1 ? true : false
                            Text {
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "This setting is applied to all instances.")
                                font : Qt.font({family:"Segoe UI",pixelSize:10})
                                color: "#bdbdc5"
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                    UiComboBox {
                        id: iMemoryModeCombobox
                        enabled: pParentWindow === "plr" ? true : false
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: [
                             qsTranslate("QObject", "Balanced") ,
                             qsTranslate("QObject", "High Performance") ,
                             qsTranslate("QObject", "Low Memory")
                        ]

                        Layout.preferredWidth: 174
                        onActivated: {
                            if (pCompLoaded) {
                                switch(currentIndex)
                                {
                                case 0:
                                    uiBackend.confSetBool("bst.mem_swap_enabled", 0)
                                    uiBackend.confSetI32("bst.mem_pcr_pclimit",80)
                                    uiBackend.confSetBool("bst.mem_pcr_enabled",1)
                                    break;
                                case 1:
                                    uiBackend.confSetBool("bst.mem_swap_enabled", 0)
                                    uiBackend.confSetBool("bst.mem_pcr_enabled",0)
                                    break;
                                case 2:
                                    if (uiBackend.getMachineRAM() > 7 * 1024) {
                                        uiBackend.confSetBool("bst.mem_swap_enabled", 0)
                                    } else {
                                        uiBackend.confSetBool("bst.mem_swap_enabled", 1)
                                    }
                                    uiBackend.confSetI32("bst.mem_pcr_pclimit",48)
                                    uiBackend.confSetBool("bst.mem_pcr_enabled",1)
                                    break;
                                default:
                                    break;
                                }
                                fMonitorChange();
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                    visible: pParentWindow == "plr" ? true : false
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    UiSlider {
                        id: iFrameRateSlider
                        pSize: UiTheme.sliders.sizes.medium
                        enabled: pParentWindow == "plr" ? !pIsEcoModeEnabled : true
                        from: 1
                        to: 60
                        stepSize: 1
                        value: 100
                        Layout.fillWidth: true
                        pSelectedValueText: qsTranslate("QObject", "Frame rate") + " : "+ value
                        pRangeValueVisibility: true
                        onPressedChanged: {
                            if (pCompLoaded && !pressed) {
                                uiBackend.confSetInstanceI32("max_fps", parseInt(value))
                                fMonitorChange()
                            }
                        }
                    }
                    UiColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true
                        Text {
                            text: qsTranslate("QObject", "Recommended FPS")
                            font : Qt.font({family:"Segoe UI",pixelSize:10})
                            color: "#bdbdc5"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "Play at 60 FPS for smooth gameplay. If you’re running multiple instances, we recommend selecting 20 FPS. Some apps may need an App Player restart for changes to take effect.")
                            font : Qt.font({family:"Segoe UI",pixelSize:10})
                            color: "#bdbdc5"
                            wrapMode: Text.Wrap
                        }
                    }
                    UiColumnLayout {
                        Layout.fillWidth: true
                        visible: pParentWindow ==="plr"?true:false
                        spacing: 12
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Enable high frame rate")
                                font : Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#c7c7ce"
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            UiToggleButton {
                                id: iEnableHighFpsToggleBtn
                                onCheckedChanged: {
                                    uiBackend.confSetInstanceBool("enable_high_fps", checked)
                                    fUpdateFpsSliderValueAndText(checked)
                                    if (checked && iEnableVSyncToggleBtn.checked) {
                                        iEnableVSyncToggleBtn.checked = false
                                        uiBackend.confSetInstanceBool("enable_vsync", false)
                                    }
                                    fMonitorChange()
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Enable VSync (To prevent screen tearing)")
                                font : Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#c7c7ce"
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            UiToggleButton {
                                id: iEnableVSyncToggleBtn
                                onCheckedChanged: {
                                    uiBackend.confSetInstanceBool("enable_vsync", checked)
                                    if (checked && iEnableHighFpsToggleBtn.checked) {
                                        iEnableHighFpsToggleBtn.checked = false
                                        uiBackend.confSetInstanceBool("enable_high_fps", false)
                                        fUpdateFpsSliderValueAndText(false)
                                    }

                                    fMonitorChange()
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Display FPS during gameplay")
                                font : Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#c7c7ce"
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            UiToggleButton {
                                id: iEnableFpsDisplayToggleBtn
                                onCheckedChanged: {
                                    uiBackend.confSetInstanceBool("enable_fps_display", checked)
                                    fMonitorChange()
                                }
                            }
                        }
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
                    if(pParentWindow === "plr"){
                        if((uiBackend.confIsPropModified("bst.mem_swap_enabled") || uiBackend.confIsPropModified("bst.mem_pcr_pclimit") ||
                               uiBackend.confIsPropModified("bst.mem_pcr_enabled")) && plrBackend.getInstancesCount() > 1){
                            iSaveChangesPrompt.createObject(iSettingsWindow, {
                                                                "transientParent": iSettingsWindow,
                                                                "pNotice": qsTranslate("QObject","For the changes to reflect in other running instances, please manually restart them.")
                                                            }).show()
                        }
                        else{
                            if (uiBackend.confIsInstancePropModified("ram")
                                    || uiBackend.confIsInstancePropModified("cpus")
                                    || (uiBackend.confIsPropModified("bst.mem_swap_enabled")
                                    || uiBackend.confIsPropModified("bst.mem_pcr_pclimit")
                                    || uiBackend.confIsPropModified("bst.mem_pcr_enabled"))) {
                                iSaveChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                            }
                            else if (uiBackend.confIsInstancePropModified("max_fps")) {
                                iRestartLaterPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                            }
                            else {
                                fHandleConfChange()
                                uiBackend.confCommit()
                                fInitUi()
                                iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                            }
                        }
                    }
                    else{
                        var notify = false
                        if (uiBackend.confIsInstancePropModified("ram") || uiBackend.confIsInstancePropModified("cpus")) {
                            notify = true
                        }
                        uiBackend.confCommit()
                        if (notify) uiBackend.instanceConfigChanged()
                        close()
                    }
                }
            }
        }
    }

    function fGetMaxRamAndCpu() {
        var machineRam = parseFloat(uiBackend.getMachineRAM())
        var maxRam = machineRam * 0.75
        if (uiBackend.getImageTrait(pVmName).is64Bit || maxRam < pMaxRam)
            pMaxRam = maxRam

        var machineCpu = uiBackend.getMachineLogicalCpuCount()
        if (machineCpu < pMaxCpu)
            pMaxCpu = machineCpu

        for (var i = 1; i <= pMaxCpu; i++) {
            pCustomCpuModel.append({ name: i})
        }
    }

    function fInitUi() {
        pDefaultCpu = uiBackend.confGetInstanceI32("cpus")
        pCurrentCpu = pDefaultCpu
        pDefaultRam = uiBackend.confGetInstanceI32("ram")
        var fpsValue = parseInt(uiBackend.confGetInstanceI32("max_fps"))
        iEnableFpsDisplayToggleBtn.checked = uiBackend.confGetInstanceBool("enable_fps_display")
        iEnableVSyncToggleBtn.checked = uiBackend.confGetInstanceBool("enable_vsync")
        iEnableHighFpsToggleBtn.checked = iEnableVSyncToggleBtn.checked? false : uiBackend.confGetInstanceBool("enable_high_fps")

        if(iEnableHighFpsToggleBtn.checked) {
            iFrameRateSlider.to = 240
        }
        else {
            if(fpsValue > 60)
                fpsValue = 60
            iFrameRateSlider.to = 60
        }
        iFrameRateSlider.value = fpsValue

        var memPcrEnabled = uiBackend.confGetBool("bst.mem_pcr_enabled")
        var memPcrPcLimit = uiBackend.confGetI32("bst.mem_pcr_pclimit")
        if (!memPcrEnabled) {
            iMemoryModeCombobox.currentIndex = 1
        }
        else if (memPcrPcLimit < 80) {
            iMemoryModeCombobox.currentIndex = 2
        }
        else {
            iMemoryModeCombobox.currentIndex = 0
        }

        fReloadComboboxes()
    }

    function fReloadComboboxes() {
        iCustomCpuCombobx.visible = false

        if (pDefaultCpu === 4) {
            iCpuCombobox.currentIndex = 0
        }
        else if (pDefaultCpu === 2) {
            iCpuCombobox.currentIndex = 1
        }
        else if (pDefaultCpu === 1) {
            iCpuCombobox.currentIndex = 2
        }
        else {
            iCpuCombobox.currentIndex = 3
            iCustomCpuCombobx.visible = true
        }
        iCustomCpuCombobx.currentIndex = pDefaultCpu - 1

        iRamCombobox.currentIndex = pRamModel.length - 1
        for(var i = 0; i < pRamModel.length; ++i) {
            if (pDefaultRam === parseInt(pRamModel[i].value))
                iRamCombobox.currentIndex = i
        }
        iCustomRamTextField.text = pDefaultRam

        pEnableSave = false
    }

    function fMonitorChange() {
        if (uiBackend.confIsModified()
                && !(iCustomRamTextField.visible && !iCustomRamTextField.acceptableInput))
        {
            pEnableSave = true
        } else {
            pEnableSave = false
        }
    }

    function fUpdateFpsSliderValueAndText(checked) {
        if (checked) {
            iFrameRateSlider.to = 240
        } else {
            if (parseInt(iFrameRateSlider.value) > 60) {
                iFrameRateSlider.value = 60
                uiBackend.confSetInstanceI32("max_fps", 60)
            }
            iFrameRateSlider.to = 60
        }
    }

    function fHandleConfChange() {
        if(pParentWindow === "plr"){
            if (uiBackend.confIsInstancePropModified("enable_fps_display"))
                plrBackend.enableFpsDisplay(uiBackend.confGetInstanceBool("enable_fps_display"))
            if (uiBackend.confIsInstancePropModified("enable_high_fps"))
                plrBackend.enableHighFps(uiBackend.confGetInstanceBool("enable_high_fps"))
            if (uiBackend.confIsInstancePropModified("enable_vsync"))
                plrBackend.enableVsync(uiBackend.confGetInstanceBool("enable_vsync"))
            uiBackend.confCommit();
        }
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fShowRamSelectionOption(memInGb) {
        var maxRam = parseFloat(uiBackend.getMachineRAM()) * 0.75
        if (uiBackend.getImageTrait(pVmName).is64Bit && maxRam >= (memInGb * 1024))
            return true

        return false
    }
}
