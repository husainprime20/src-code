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

Item {
    objectName: "deviceProfile"

    property bool pCompLoaded: false
    property bool pProfileLoadedFromCloud: false
    property bool pEnableSave: false

    property variant pDeviceProfileMap: ({})
    property variant pNetworkOperatorMap: ({})
    property variant pAllProfilesMap: ({})

    property ListModel pDeviceProfileModel: ListModel {}
    property ListModel pNetworkOperatorModel: ListModel {}

    property int pCallbackExpectedCount: 0
    property int pCallbackCount: 0
    property bool pRootAccess: false
    property string pProfile: ""
    property string pCarrier: ""
    property string pProfileMessage: ""
    property string pRootAccessMessage: ""
    property int pSuccessClbkCount: 0
    property string pDeviceManufacturer: ""
    property string pDeviceBrand: ""
    property string pDeviceModel: ""
    property string pParentWindow: ""

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
            fInitUi()
        }
        pCompLoaded = true
    }

    ButtonGroup {
        id: iDeviceProfileBtnGrp
        onCheckedButtonChanged: {
            fMonitorChange()
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
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: qsTranslate("QObject", "Device profile")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }

                    Text {
                        id: iDeviceProfileWarningTxt
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Changing this will delete Android framework data.")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }


                    UiImage {
                        id: iDeviceProfileLoader
                        asset: "Loader_bright"
                        pImageWidth: 16
                        pImageHeight: 16
                        cache: false
                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            duration: 2000
                            from: 0
                            to: 360
                            direction: RotationAnimation.Clockwise
                            running: iDeviceProfileLoader.visible
                        }
                    }

                    UiRowLayout {
                        id: iNoInternetRow
                        visible: false
                        Layout.fillWidth: true
                        color: UiTheme.colors.primary90
                        spacing: 8
                        padding: 12
                        border {
                            width: 1
                            color: UiTheme.colors.error
                        }
                        UiImage {
                            id: iNoInternetImg
                            asset: "UiError_colored"
                            pImageWidth: 16
                            pImageHeight: 16
                            Layout.alignment: Qt.AlignTop
                        }
                        UiColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "There was an error fetching the profiles. Please make sure your internet connection is working.")
                                font: UiTheme.fonts.bodySmall
                                color: UiTheme.colors.error
                                wrapMode: Text.Wrap
                            }
                            UiButton{
                                pSize: UiTheme.buttons.sizes.small
                                pColor: UiTheme.buttons.colors.accent
                                text: qsTranslate("QObject", "Try again")
                                onClicked: {
                                    fSetNoInternetVisibility(false)
                                    plrBackend.getDeviceProfileList()
                                }
                            }
                        }
                    }

                    UiColumnLayout {
                        id: iDeviceProfileOptions
                        Layout.fillWidth: true
                        spacing:12
                        visible: false
                        UiColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            Layout.topMargin: 8
                            Layout.fillWidth: true
                            spacing: 4
                            UiRadioButton {
                                id: iPredefinedDeviceProfileBtn
                                text: qsTranslate("QObject", "Choose a predefined profile")
                                ButtonGroup.group: iDeviceProfileBtnGrp
                                onCheckedChanged: {
                                    if (checked)
                                    {
                                        var defaultDeviceProfile = plrBackend.getDefaultDeviceProfile();
                                        for (var i = 0; i < pDeviceProfileModel.count; i++) {
                                            if (pDeviceProfileMap[pDeviceProfileModel.get(i).name] === defaultDeviceProfile) {
                                                iDeviceProfileCombobox.displayText = pDeviceProfileModel.get(i).name
                                                iDeviceProfileCombobox.currentIndex = i
                                                break
                                            }
                                        }
                                        if (iDeviceProfileCombobox.currentIndex == -1) {
                                            iDeviceProfileCombobox.displayText = pDeviceProfileModel.get(0) ? pDeviceProfileModel.get(0).name : ""
                                            iDeviceProfileCombobox.currentIndex = 0
                                        }
                                        if (iDeviceProfileCombobox.currentIndex < pDeviceProfileModel.count) {
                                            uiBackend.confSetInstanceString("device_profile_code", pDeviceProfileMap[pDeviceProfileModel.get(iDeviceProfileCombobox.currentIndex).name])
                                            fMonitorChange()
                                        }
                                    }
                                }
                            }
                            UiComboBox {
                                id: iDeviceProfileCombobox
                                pSize: UiTheme.comboBoxes.sizes.medium
                                model: pDeviceProfileModel
                                Layout.preferredWidth: 256
                                visible: iPredefinedDeviceProfileBtn.checked
                                onActivated: {
                                    if (pCompLoaded && pProfileLoadedFromCloud) {
                                        if (currentIndex >= 0 && currentIndex < pDeviceProfileModel.count) {
                                            iDeviceProfileCombobox.displayText = pDeviceProfileModel.get(currentIndex).name
                                            uiBackend.confSetInstanceString("device_profile_code",
                                                                            pDeviceProfileMap[pDeviceProfileModel.get(currentIndex).name])
                                            fMonitorChange()
                                        }
                                    }
                                }
                            }
                        }
                        UiColumnLayout {
                            Layout.fillWidth: true
                            spacing: 17
                            UiRadioButton {
                                id: iCustomDeviceProfileBtn
                                text: qsTranslate("QObject", "Create a custom profile")
                                ButtonGroup.group: iDeviceProfileBtnGrp
                            }
                            UiRowLayout {
                                id: iCustomDeviceProfilefields
                                Layout.fillWidth: true
                                spacing: 4
                                visible: iCustomDeviceProfileBtn.checked
                                UiColumnLayout {
                                    Layout.preferredWidth: 160
                                    spacing: 4
                                    Text {
                                        text: qsTranslate("QObject", "Manufacturer")
                                        font: UiTheme.fonts.bodySmall
                                        color: UiTheme.colors.primary30
                                        Layout.fillWidth: true
                                    }
                                    UiTextField {
                                        id: iDeviceManufacturerTxt
                                        Layout.fillWidth: true
                                        pSize: UiTheme.textFields.sizes.medium
                                        text: ""
                                        pInputValidationState: text !== "" ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "This field is required")
                                        onTextChanged: {
                                            if (pCompLoaded) {
                                                uiBackend.confSetInstanceString("device_custom_manufacturer", text)
                                                fMonitorChange()
                                            }
                                        }
                                    }
                                }
                                UiColumnLayout {
                                    Layout.preferredWidth: 160
                                    spacing: 4
                                    Text {
                                        text: qsTranslate("QObject", "Brand")
                                        Layout.fillWidth: true
                                        font: UiTheme.fonts.bodySmall
                                        color: UiTheme.colors.primary30
                                    }
                                    UiTextField {
                                        id: iDeviceBrandTxt
                                        Layout.fillWidth: true
                                        pSize: UiTheme.textFields.sizes.medium
                                        text: ""
                                        pInputValidationState: text !== "" ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "This field is required")
                                        onTextChanged: {
                                            if (pCompLoaded) {
                                                uiBackend.confSetInstanceString("device_custom_brand", text)
                                                fMonitorChange()
                                            }
                                        }
                                    }
                                }
                                UiColumnLayout {
                                    Layout.preferredWidth: 160
                                    spacing: 4
                                    Text {
                                        text: qsTranslate("QObject", "Model")
                                        font: UiTheme.fonts.bodySmall
                                        color: UiTheme.colors.primary30
                                        Layout.fillWidth: true
                                    }
                                    UiTextField {
                                        id: iDeviceModelTxt
                                        Layout.fillWidth: true
                                        pSize: UiTheme.textFields.sizes.medium
                                        text: ""
                                        pInputValidationState: text !== "" ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                        pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                        pErrorTemplateContent: qsTranslate("QObject", "This field is required")
                                        onTextChanged: {
                                            if (pCompLoaded) {
                                                uiBackend.confSetInstanceString("device_custom_model", text)
                                                fMonitorChange()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
                Rectangle {
                    id: iSeparator1
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    id: iNetworOpColumn
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: qsTranslate("QObject", "Network provider")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }

                    UiImage {
                        id: iNetworkOperatorLoader
                        asset: "Loader_bright"
                        pImageWidth: 16
                        pImageHeight: 16
                        cache: false
                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            duration: 2000
                            from: 0
                            to: 360
                            direction: RotationAnimation.Clockwise
                            running: iNetworkOperatorLoader.visible
                        }
                    }

                    UiComboBox {
                        id: iNetworkOperatorCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: pNetworkOperatorModel
                        Layout.preferredWidth: 256
                        visible: false
                        onActivated: {
                            if (pCompLoaded && pProfileLoadedFromCloud) {
                                if (currentIndex >= 0 && currentIndex < pNetworkOperatorModel.count) {
                                    uiBackend.confSetInstanceString("device_carrier_code",
                                                                    pNetworkOperatorMap[pNetworkOperatorModel.get(currentIndex).name])
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
                    visible: plrBackend.getRootAccessEnabled()
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    visible: plrBackend.getRootAccessEnabled()
                    Text {
                        text: qsTranslate("QObject", "Root Access")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }

                    UiCheckBox {
                        id: iRootAccessCb
                        text: qsTranslate("QObject", "Enable root access")
                        pSize: UiTheme.checkBoxes.sizes.medium
                        onCheckedChanged: {
                            uiBackend.confSetInstanceBool("enable_root_access", checked)
                            fMonitorChange()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Enabling this may cause game compatibility issues, place your data at risk and may also prevent support from assisting you in the future.")
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
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
                    fHandleConfChange()
                }
            }
        }
    }

    function fInitUi()
    {
        iRootAccessCb.checked = uiBackend.confGetInstanceBool("enable_root_access")
        plrBackend.getDeviceProfileList()
        pEnableSave = false
    }

    function fDeviceProfilesReceivedFromCloud(deviceProfileJson) {
        pProfileLoadedFromCloud = false
        var jsonObj = JSON.parse(deviceProfileJson)
        var deviceProfileArr = jsonObj.device_profile_list
        var networkOperatorArr = jsonObj.ca_selector_list
        var allDeviceProfiles = jsonObj.device_profile_mapping

        pDeviceProfileModel.clear()
        pNetworkOperatorModel.clear()

        var currentProfile = uiBackend.confGetInstanceString("device_profile_code")
        var currentOperator = uiBackend.confGetInstanceString("device_carrier_code")
        iDeviceManufacturerTxt.text = uiBackend.confGetInstanceString("device_custom_manufacturer")
        iDeviceBrandTxt.text = uiBackend.confGetInstanceString("device_custom_brand")
        iDeviceModelTxt.text = uiBackend.confGetInstanceString("device_custom_model")

        if (currentProfile === "custom")
            iCustomDeviceProfileBtn.checked = true
        else
            iPredefinedDeviceProfileBtn.checked = true

        for (var i = 0; i < allDeviceProfiles.length; i++) {
            pAllProfilesMap[allDeviceProfiles[i].pcode] = allDeviceProfiles[i].display_name
        }

        if (deviceProfileJson.search(currentOperator) === -1) {
            pNetworkOperatorMap[""] = "none"
            pNetworkOperatorModel.append({ name: "" })
        }

        var deviceProfileFound = false
        for (i = 0; i < deviceProfileArr.length; i++) {
            pDeviceProfileMap[deviceProfileArr[i].display_name] = deviceProfileArr[i].pcode
            pDeviceProfileModel.append({ name: deviceProfileArr[i].display_name })
            if (deviceProfileArr[i].pcode === currentProfile) {
                iDeviceProfileCombobox.currentIndex = i
                iDeviceProfileCombobox.displayText = pDeviceProfileModel.get(i).name
                deviceProfileFound = true
            }
        }

        if (!deviceProfileFound) {
             console.info("device profile " + currentProfile + " not found.")
            if (pAllProfilesMap[currentProfile]) {
                console.info("Setting display text : " + pAllProfilesMap[currentProfile])
                iDeviceProfileCombobox.displayText = pAllProfilesMap[currentProfile]
            }
            else {
                console.error("Device profile not found in all profiles list")
                iDeviceProfileCombobox.currentIndex = -1
            }
        }

        for (i = 0; i < networkOperatorArr.length; i++) {
            pNetworkOperatorMap[networkOperatorArr[i].display_name] = networkOperatorArr[i].ca_selector
            pNetworkOperatorModel.append({ name: networkOperatorArr[i].display_name })
            if (networkOperatorArr[i].ca_selector === currentOperator)
                iNetworkOperatorCombobox.currentIndex = i
        }

        iDeviceProfileLoader.visible = false
        iDeviceProfileOptions.visible = true
        iNetworkOperatorLoader.visible = false
        if(networkOperatorArr.length !== 0)
            iNetworkOperatorCombobox.visible = true
        else{
            iNetworOpColumn.visible = false
            iSeparator1.visible = false
        }

        pProfileLoadedFromCloud = true
    }

    function fSetNoInternetVisibility(visible) {
        iDeviceProfileLoader.visible = !visible
        iDeviceProfileWarningTxt.visible = !visible
        iSeparator1.visible = !visible
        iNetworOpColumn.visible = !visible

        iNoInternetRow.visible = visible
    }

    function fMonitorChange() {
        if (iPredefinedDeviceProfileBtn.checked && (uiBackend.confIsInstancePropModified("device_profile_code")
                                                    || uiBackend.confIsInstancePropModified("device_carrier_code")
                                                    || uiBackend.confIsInstancePropModified("enable_root_access"))){
            pEnableSave = true
        } else if (iCustomDeviceProfileBtn.checked && (iDeviceManufacturerTxt.text.length > 0)
                   && (iDeviceBrandTxt.text.length > 0) && (iDeviceModelTxt.text.length > 0)
                   && (uiBackend.confIsInstancePropModified("device_custom_manufacturer")
                       || uiBackend.confIsInstancePropModified("device_custom_brand")
                       || uiBackend.confIsInstancePropModified("device_custom_model")
                       || uiBackend.confIsInstancePropModified("device_carrier_code")
                       || uiBackend.confIsInstancePropModified("enable_root_access"))) {
            pEnableSave = true
        } else {
            pEnableSave = false
        }
    }

    function fSetPreviousState() {
        var found = false
        var currentDeviceProfile = uiBackend.confGetInstanceString("device_profile_code")
        for (var i = 0; i < pDeviceProfileModel.count; i++) {
            if (pDeviceProfileMap[pDeviceProfileModel.get(i).name] === currentDeviceProfile) {
                iDeviceProfileCombobox.currentIndex = i
                found = true
                break
            }
        }
        if (!found) {
            if (pAllProfilesMap[currentDeviceProfile])
                iDeviceProfileCombobox.displayText = pAllProfilesMap[currentDeviceProfile]
            else
                iDeviceProfileCombobox.currentIndex = -1
        }
       
        if (currentDeviceProfile === "custom")
            iCustomDeviceProfileBtn.checked = true
        else
            iPredefinedDeviceProfileBtn.checked = true

        found = false
        for (i = 0; i < pNetworkOperatorModel.count; i++) {
            if (pNetworkOperatorMap[pNetworkOperatorModel.get(i).name] ===
                    uiBackend.confGetInstanceString("device_carrier_code")) {
                iNetworkOperatorCombobox.currentIndex = i
                found = true
            }
        }
        if (!found)
            iNetworkOperatorCombobox.currentIndex = -1

        iRootAccessCb.checked = uiBackend.confGetInstanceBool("enable_root_access")

        pCallbackExpectedCount= 0
        pCallbackCount= 0
        pSuccessClbkCount = 0
        pRootAccess= false
        pProfile= ""
        pCarrier= ""
        iDeviceManufacturerTxt.text = uiBackend.confGetInstanceString("device_custom_manufacturer")
        iDeviceBrandTxt.text = uiBackend.confGetInstanceString("device_custom_brand")
        iDeviceModelTxt.text = uiBackend.confGetInstanceString("device_custom_model")
        pProfileMessage= ""
        pRootAccessMessage= ""
        fMonitorChange()
    }

    function fSetDeviceProfile(deviceProfileJson) {
        fDeviceProfilesReceivedFromCloud(deviceProfileJson)
        iBottomRow.visible = true
    }

    function fDeviceProfileReceiveFailed() {
        fSetNoInternetVisibility(true)
        iBottomRow.visible = false
    }

    function fSaveChanges(){
        if(pCallbackCount === pCallbackExpectedCount) {
            uiBackend.confCommit()
            var message = ""
            if(pSuccessClbkCount == pCallbackExpectedCount)
                message = qsTranslate("QObject", "Changes saved")
            else if(pProfileMessage != "" && pRootAccessMessage != "")
                message = pProfileMessage + "\n" +pRootAccessMessage
            else if(pProfileMessage != "")
                message = pProfileMessage
            else
                message = pRootAccessMessage
            iSettingsWindow.fShowToast(message)
            fSetPreviousState()
        }
    }

    function fDeviceProfileSettingChangedClbk(status) {
        pCallbackCount++
        if (0 === status) {
            pSuccessClbkCount++
            if (iPredefinedDeviceProfileBtn.checked) {
                uiBackend.confSetInstanceString("device_profile_code", pProfile)
                uiBackend.confSetInstanceString("device_carrier_code", pCarrier)
                uiBackend.confSetInstanceString("device_custom_manufacturer", "")
                uiBackend.confSetInstanceString("device_custom_brand", "")
                uiBackend.confSetInstanceString("device_custom_model", "")
            } else {
                uiBackend.confSetInstanceString("device_custom_manufacturer", pDeviceManufacturer)
                uiBackend.confSetInstanceString("device_custom_brand", pDeviceBrand)
                uiBackend.confSetInstanceString("device_custom_model", pDeviceModel)
                uiBackend.confSetInstanceString("device_profile_code", "custom")
                uiBackend.confSetInstanceString("device_carrier_code", pCarrier)
            }

            pProfileMessage = qsTranslate("QObject", "Device profile changes saved")
        } else {
            pProfileMessage = qsTranslate("QObject", "Failed to switch device profile")
        }
        fSaveChanges()
    }

    function fDeviceRootSettingChangedClbk(status) {
        pCallbackCount++
        if (0 === status) {
            pSuccessClbkCount++
            uiBackend.confSetInstanceBool("enable_root_access", pRootAccess)
            pRootAccessMessage = qsTranslate("QObject", "Root access changes saved")

        } else {
            pRootAccessMessage = qsTranslate("QObject", "Failed to enable root access")
        }
        fSaveChanges()
    }

    function fHandleConfChange() {
        if(iPredefinedDeviceProfileBtn.checked &&
                (uiBackend.confIsInstancePropModified("device_profile_code")
                 || uiBackend.confIsInstancePropModified("device_carrier_code"))) {
            pProfile = uiBackend.confGetInstanceString("device_profile_code")
            pCarrier = uiBackend.confGetInstanceString("device_carrier_code")
            pCallbackExpectedCount++
        }

        if(iCustomDeviceProfileBtn.checked &&
                (uiBackend.confIsInstancePropModified("device_custom_manufacturer")
                 || uiBackend.confIsInstancePropModified("device_custom_brand")
                 || uiBackend.confIsInstancePropModified("device_custom_model")
                 || uiBackend.confIsInstancePropModified("device_carrier_code"))) {
            pDeviceManufacturer = uiBackend.confGetInstanceString("device_custom_manufacturer")
            pDeviceBrand = uiBackend.confGetInstanceString("device_custom_brand")
            pDeviceModel = uiBackend.confGetInstanceString("device_custom_model")
            pCarrier = uiBackend.confGetInstanceString("device_carrier_code")
            pCallbackExpectedCount++

            iDeviceBrandTxt.focus = false
            iDeviceManufacturerTxt.focus = false
            iDeviceModelTxt.focus = false
        }

        var isRootAccessModified = false
        if (plrBackend.getRootAccessEnabled() &&
                uiBackend.confIsInstancePropModified("enable_root_access")) {
            pRootAccess = uiBackend.confGetInstanceBool("enable_root_access")
            isRootAccessModified = true
            pCallbackExpectedCount++
        }
        uiBackend.confDiscard();

        if (iPredefinedDeviceProfileBtn.checked && (pProfile != "" || pCarrier != ""))
            plrBackend.setDeviceProfile(pProfile, pCarrier)

        if (iCustomDeviceProfileBtn.checked && pDeviceManufacturer != "" && pDeviceBrand != "" &&
                                                pDeviceModel != "" && pCarrier != "")
            plrBackend.setCustomDeviceProfile(pDeviceManufacturer, pDeviceBrand, pDeviceModel, pCarrier)

        if (plrBackend.getRootAccessEnabled() && isRootAccessModified)
            plrBackend.setEnableRootAccess(pRootAccess)
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }
}
