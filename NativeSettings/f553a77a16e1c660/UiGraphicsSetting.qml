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
import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Item {
// VOID NATIVE SETTINGS V4 — layout only; native callbacks retained
id: voidNativeSettingsPage

    property bool pCompLoaded: false
    property bool pEnableSave: false
    property bool pIsVulkanSupported: false
    property bool pIsInstanceNougat: false

    property string pParentWindow: ""
    property string pVmName: ""
    property UiRadioButton pDefautEngineBtn: iPgaBtn
    property UiRadioButton pDefautRendererBtn: iOpenglBtn
    property bool pIsHwAstcSupported: false

    property ListModel pAstcConfigModel : ListModel {}

    property list<QtObject> pQtRendererModel: [
        QtObject {
            property string text: qsTranslate("QObject", "Auto")
            property string value: "Auto"
            property bool visible: true
        },
        QtObject {
            property string text: qsTranslate("QObject", "Software")
            property string value: "Software"
            property bool visible: uiBackend.oem !== "msi5" ? true : false
        },
        QtObject {
            property string text: qsTranslate("QObject", "OpenGL")
            property string value: "OpenGL"
            property bool visible: true
        },
        QtObject {
            property string text: qsTranslate("QObject", "DirectX")
            property string value: "Direct3D11"
            property bool visible: uiBackend.isDirect3D11Supported()
        }
    ]

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
            fInitUi()
        }
        pCompLoaded = true
    }

    ButtonGroup {
        id: iGraphicsEngineBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                uiBackend.confSetInstanceString("graphics_engine", (checkedButton == iAgaBtn) ? "aga" : "pga")
                fMonitorChange()
            }
        }
    }

    ButtonGroup {
        id: iGraphicsRendereBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                uiBackend.confSetInstanceString("graphics_renderer", (checkedButton == iOpenglBtn) ? "gl"
                                                                                                   : (checkedButton == iDirectxBtn) ? "dx" : "vlcn")
                fMonitorChange()
            }
        }
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
                            if (uiBackend.confIsPropModified("bst.prefer_dedicated_gpu")) {
                                if (uiBackend.confGetBool("bst.prefer_dedicated_gpu"))
                                    uiBackend.runForceGpu("1")
                                else
                                    uiBackend.runForceGpu("0")
                            }

                            var notify = false
                            if (uiBackend.confIsInstancePropModified("graphics_engine") ||
                                    uiBackend.confIsInstancePropModified("graphics_renderer")) {
                                notify = true
                            }

                            iSettingsWindow.hide()
                            iSettingsWindow.showRestartLoader()
                            uiBackend.confCommit()
                            if (notify) plrBackend.instanceConfigChanged()
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
                    Layout.fillWidth: true
                    visible: uiBackend.isGraphicsEngineSupported(pVmName, "pga")
                    Text {
                        text: qsTranslate("QObject", "Graphics engine mode")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 40
                        UiColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredWidth: (parent.width - parent.spacing) / 2
                            UiRadioButton {
                                id: iAgaBtn
                                text: qsTranslate("QObject", "Compatibility")
                                ButtonGroup.group: iGraphicsEngineBtnGrp
                                Layout.fillWidth: true
                            }
                        }
                        UiColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredWidth: (parent.width - parent.spacing) / 2
                            UiRadioButton {
                                id: iPgaBtn
                                text: qsTranslate("QObject", "Performance")
                                checked: true
                                Layout.fillWidth: true
                                ButtonGroup.group: iGraphicsEngineBtnGrp
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                    visible: uiBackend.isGraphicsEngineSupported(pVmName, "pga")
                }
                UiColumnLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Graphics renderer")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#eeeef2"
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("GraphicsRenderer_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 40
                        UiColumnLayout {
                            visible: !pIsInstanceNougat
                            enabled: pIsVulkanSupported
                            UiRadioButton {
                                id: iVulkanBtn
                                Layout.preferredWidth: 160
                                Layout.alignment: Qt.AlignTop
                                text: qsTranslate("QObject", "Vulkan & OpenGL")
                                ButtonGroup.group: iGraphicsRendereBtnGrp
                            }
                            Text {
                                id: iRecommendedTxt
                                Layout.leftMargin: 22
                                text: qsTranslate("QObject", "Recommended")
                                font: Qt.font({family:"Segoe UI",pixelSize:10})
                                color: pIsVulkanSupported ? "#bdbdc5" : UiTheme.colors.primary40
                            }
                        }
                        UiRadioButton {
                            id: iOpenglBtn
                            Layout.preferredWidth: 160
                            Layout.alignment: Qt.AlignTop
                            text: qsTranslate("QObject", "OpenGL")
                            checked: true
                            ButtonGroup.group: iGraphicsRendereBtnGrp
                        }
                        UiRadioButton {
                            id: iDirectxBtn
                            visible: pIsInstanceNougat
                            Layout.preferredWidth: 160
                            Layout.alignment: Qt.AlignTop
                            text: qsTranslate("QObject", "DirectX")
                            ButtonGroup.group: iGraphicsRendereBtnGrp
                        }
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
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Interface renderer")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#eeeef2"
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("QtRenderer_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiComboBox {
                        id: iQtRendererCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: pQtRendererModel
                        textRole: "text"
                        valueRole: "value"
                        pVisibilityRole: "visible"
                        Layout.preferredWidth: 174
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetString("bst.qt_renderer", currentValue)
                                fMonitorChange()
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                    visible: pParentWindow === "plr"
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: pParentWindow === "plr"
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "ASTC Textures (Beta)")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#eeeef2"
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("ASTC_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiComboBox {
                        id: iAstcCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: pAstcConfigModel
                        textRole: "display_name"
                        Layout.preferredWidth: 174
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetInstanceString("astc_decoding_mode", pAstcConfigModel.get(currentIndex).name)
                                iHwAstcNotSuppportedWarningTxt.visible = (!pIsHwAstcSupported && currentIndex === 2)
                                fMonitorChange()
                            }
                        }
                    }

                    Text {
                        id: iHwAstcNotSuppportedWarningTxt
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Hardware decoding is not available, instead Software decoding will be used")
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignLeft
                    }
                }
                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                    visible: pParentWindow === "plr"
                }
                UiColumnLayout {
                    spacing: 12
                    Layout.fillWidth: true
                    visible: pParentWindow === "plr"
                    UiColumnLayout {
                        spacing: 4
                        UiRowLayout {
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "GPU in use")
                                font: Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#eeeef2"
                                horizontalAlignment: Text.AlignLeft
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageWidth: 16
                                pImageHeight: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: uiBackend.openHelpArticle("GPU_Setting_Help")
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                        Text {
                            id: iAvailableGpuTxt
                            text: "NVIDIA GeForce RTX 2080Ti"
                            font: Qt.font({family:"Segoe UI",pixelSize:10})
                            color: "#bdbdc5"
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Prefer dedicated GPU")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#c7c7ce"
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        UiToggleButton {
                            id: iToggleDedicatedGraphics
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.prefer_dedicated_gpu", checked)
                                fMonitorChange()
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
                text: qsTranslate("QObject", "Changes will apply on next launch")
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
                        if (uiBackend.confIsInstancePropModified("graphics_engine") ||
                                uiBackend.confIsInstancePropModified("graphics_renderer") ||
                                uiBackend.confIsPropModified("bst.prefer_dedicated_gpu") ||
                                uiBackend.confIsPropModified("bst.qt_renderer")) {
                            iSaveChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                        } else {
                            fHandleConfChange()
                            fInitUi()
                            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                        }
                    }
                    else {
                        var notify = false
                        if (uiBackend.confIsInstancePropModified("graphics_engine") ||
                                uiBackend.confIsInstancePropModified("graphics_renderer")) {
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

    function checkNougatInstance() {
        if (pVmName.indexOf("Nougat",0) !== -1)
            return true;
        return false;
    }

    function fInitUi() {
        var engine = uiBackend.confGetInstanceString("graphics_engine")
        var renderer = uiBackend.confGetInstanceString("graphics_renderer")
        iToggleDedicatedGraphics.checked = uiBackend.confGetBool("bst.prefer_dedicated_gpu")
        pIsInstanceNougat = checkNougatInstance()
        pIsVulkanSupported = pParentWindow  === "plr" ? !pIsInstanceNougat && plrBackend.getIsVulkanSupported() :
                                                        !pIsInstanceNougat && uiBackend.confGetInstanceBool("vulkan_supported")
        if (engine === "pga")
            pDefautEngineBtn = iPgaBtn
        else
            pDefautEngineBtn = iAgaBtn

        if (renderer === "gl")
            pDefautRendererBtn = iOpenglBtn
        else if(renderer === "vlcn")
            pDefautRendererBtn = iVulkanBtn
        else {
            if (pIsInstanceNougat)
                pDefautRendererBtn = iDirectxBtn
            else
                pDefautRendererBtn = pIsVulkanSupported ? iVulkanBtn : iOpenglBtn
        }

        if (!pIsInstanceNougat)
            iOpenglBtn.text = qsTranslate("QObject", "OpenGL Only");

        pDefautEngineBtn.checked = true
        pDefautRendererBtn.checked = true

        iQtRendererCombobox.currentIndex = -1
        var renderer = uiBackend.confGetString("bst.qt_renderer")
        if (uiBackend.oem === "msi5") {
            if (renderer === "Software")
                renderer = "Auto"
        }
        for(var i = 0; i < pQtRendererModel.length; ++i) {
            if (pQtRendererModel[i].value === renderer)
                iQtRendererCombobox.currentIndex = i
        }

        pAstcConfigModel.clear()
        pAstcConfigModel.append({ display_name: qsTranslate("QObject", "Disabled"), name: "disabled" })
        pAstcConfigModel.append({ display_name: qsTranslate("QObject", "Software Decoding"), name: "software"})
        pAstcConfigModel.append({ display_name: qsTranslate("QObject", "Hardware Decoding"), name: "hardware"})

        if(pParentWindow === "plr")
        {
            pIsHwAstcSupported = plrBackend.getPgaIsHwAstcSupported() === 1
            iAvailableGpuTxt.text = plrBackend.getGraphicsRendererName()
            var astcConfig = uiBackend.confGetInstanceString("astc_decoding_mode")
            iAstcCombobox.currentIndex = find(pAstcConfigModel,
                                              function(item) { return item.name === astcConfig });
            iHwAstcNotSuppportedWarningTxt.visible = (!pIsHwAstcSupported && pAstcConfigModel.get(iAstcCombobox.currentIndex).name === "hardware")
        }
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

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fHandleConfChange() {
        if(pParentWindow === "plr"){
            if (uiBackend.confIsInstancePropModified("astc_decoding_mode"))
                plrBackend.setPgaAstcConfig(uiBackend.confGetInstanceString("astc_decoding_mode"))
            uiBackend.confCommit();
        }
    }

    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i)
            if (criteria(model.get(i)))
                return i
        return -1
    }
}
