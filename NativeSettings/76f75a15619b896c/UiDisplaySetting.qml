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
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Item {
// VOID NATIVE SETTINGS V4 — layout only; native callbacks retained
id: voidNativeSettingsPage

    property bool pCompLoaded: false
    property bool pEnableSave: false
    property var pRecommendedResolution: ["1920 x 1080", "1080 x 1920", "2560 x 1080"]
    property int pDefaultWidth: 1920
    property int pDefaultHeight: 1080
    property string pParentWindow: ""
    readonly property int pOriginalDpi: uiBackend.confGetInstanceI32("dpi")
    property UiRadioButton pDefaultResBtn: null
    property UiRadioButton pDefaultDpiBtn: iDpi240
    property UiRadioButton pDefaultCursorBtn: null
    property int pDefaultResComboboxIdx: 0

    property string pDefaultInterfaceScaling: uiBackend.confGetString("bst.ui_scale_factor")

    property bool pWidthWarningPopupOpen: false
    property bool pHeightWarningPopupOpen: false
    property int pCustResRowCount: -1
    property bool pCustomGridVisible: false
    property string pResolution: ""
    property UiRadioButton pDefaultCustomResBtn: null
    property bool pDeleteBtnVisible: false

    property list<QtObject> pInterfaceScalingModel: [
        QtObject {
            property string text: qsTranslate("QObject", "100% (Default)")
            property string value: "1.00"
        },
        QtObject {
            property string text: qsTranslate("QObject", "125%")
            property string value: "1.25"
        },
        QtObject {
            property string text: qsTranslate("QObject", "150%")
            property string value: "1.50"
        },
        QtObject {
            property string text: qsTranslate("QObject", "175%")
            property string value: "1.75"
        },
        QtObject {
            property string text: qsTranslate("QObject", "200%")
            property string value: "2.00"
        },
        QtObject {
            property string text: qsTranslate("QObject", "225%")
            property string value: "2.25"
        },
        QtObject {
            property string text: qsTranslate("QObject", "250%")
            property string value: "2.50"
        },
        QtObject {
            property string text: qsTranslate("QObject", "300%")
            property string value: "3.00"
        }
    ]

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
            fInitUi()
        }
        pCompLoaded = true
    }

    ButtonGroup {
        id: iResolutionBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                fUpdateCustomResInConf(checkedButton, false)
            }
        }
    }

    ButtonGroup {
        id: iCustomResolutionBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                if(checkedButton != null) {
                    fUpdateCustomResInConf(checkedButton, false)
                }
            }
        }
    }

    ButtonGroup {
        id: iDpiBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                var dpi = pOriginalDpi
                if (checkedButton != iDpiCustom)
                    dpi = parseInt(checkedButton.text.substr(0, 3))
                else
                    iCustomDpiTextField.text = pOriginalDpi

                uiBackend.confSetInstanceI32("dpi", dpi)
                fMonitorChange()
            }
        }
    }

    ButtonGroup {
        id: iCursorBtnGrp
        onCheckedButtonChanged: {
            if (pCompLoaded) {
                uiBackend.confSetBool("bst.custom_cursor_enabled",!iCustomCursorLoader.item.fIsDefaultCursor())
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
                            iSettingsWindow.hide()
                            iSettingsWindow.showRestartLoader()

                            if (uiBackend.confIsPropModified("bst.ui_scale_factor"))
                                plrBackend.sendInterfaceScalingStat(pDefaultInterfaceScaling)

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
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iCustomCursorComponent
        UiColumnLayout {
            Component.onCompleted: fSetMouseCursorValue()
            function fIsDefaultCursor() { return iDefaultCursor.checked }
            function fSetMouseCursorValue() {
                if(uiBackend.confGetBool("bst.custom_cursor_enabled"))
                    iCustomCursor.checked = true
                else
                    iDefaultCursor.checked = true
                pDefaultCursorBtn = iCursorBtnGrp.checkedButton
            }

            id: iContentLayout
            width: Math.min(460, Math.max(0, voidNativeSettingsPage.width))
            Layout.alignment: Qt.AlignTop
            spacing: 12
            Rectangle {
                Layout.preferredHeight: 1
                color: "#303034"
                Layout.fillWidth: true
            }

            UiColumnLayout {
                id: iMouseCursorStlyle
                Layout.fillWidth: true
                spacing: 12
                Text {
                    text: qsTranslate("QObject", "Mouse cursor style")
                    font :Qt.font({family:"Segoe UI",pixelSize:12})
                    color: "#eeeef2"
                }

                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 40
                    UiRadioButton {
                        id: iDefaultCursor
                        Layout.preferredWidth: (parent.width - parent.spacing) / 2
                        text: qsTranslate("QObject", "System default")
                        indicator.y: iDefaultCursor.topPadding + (iDefaultCursor.availableHeight - iDefaultCursor.indicator.height) / 2
                        contentItem: UiRowLayout {
                            spacing: 8
                            leftPadding: iDefaultCursor.indicator.width + iDefaultCursor.spacing
                            UiImage {
                                asset: "SystemCursor"
                                pImageWidth: 24
                                pImageHeight: 24
                            }
                            Text {
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                text: iDefaultCursor.text
                                font: iDefaultCursor.pSize.textFont
                                color: "#c7c7ce"
                                wrapMode: Text.Wrap
                            }
                        }
                        ButtonGroup.group: iCursorBtnGrp
                    }
                    UiRadioButton {
                        id: iCustomCursor
                        Layout.preferredWidth: (parent.width - parent.spacing) / 2
                        text: qsTranslate("QObject", "%1").arg(uiBackend.productName)
                        indicator.y: iCustomCursor.topPadding + (iCustomCursor.availableHeight - iCustomCursor.indicator.height) / 2
                        contentItem: UiRowLayout {
                            spacing: 8
                            leftPadding: iCustomCursor.indicator.width + iCustomCursor.spacing
                            UiImage {
                                asset: plrBackend.isMobaCursorSupported() ? "MobaCursor" : "BlueStacksCursor"
                                pImageWidth: 24
                                pImageHeight: 24
                            }
                            Text {
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                text: iCustomCursor.text
                                font: iCustomCursor.pSize.textFont
                                color: "#c7c7ce"
                                wrapMode: Text.Wrap
                            }
                        }
                        ButtonGroup.group: iCursorBtnGrp
                    }
                }
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
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        id: iResolutionTxt
                        text: qsTranslate("QObject", "Display resolution")
                        font: Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }
                    UiComboBox {
                        id: iResolutionCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: [
                            qsTranslate("QObject", "Landscape"),
                            qsTranslate("QObject", "Portrait"),
                            qsTranslate("QObject", "Ultrawide"),
                            qsTranslate("QObject", "Custom")]
                        Layout.preferredWidth: 174
                        onActivated: {
                            if (pCompLoaded) {
                                fSetResolutionOptionsVisibility(currentIndex)
                                if (currentIndex !== 3) {
                                    if (pDefaultResComboboxIdx !== currentIndex) {
                                        fSelectResolutionBtn(pRecommendedResolution[currentIndex])
                                    } else {
                                        pDefaultResBtn.checked = true
                                    }
                                } else {
                                    if(pDefaultCustomResBtn != null) {
                                        pDefaultCustomResBtn.checked = true
                                        fUpdateCustomResInConf(pDefaultCustomResBtn)
                                    }
                                    else if(iCustomResolutionBtnGrp.checkedButton != null) {
                                        pDefaultCustomResBtn = iCustomResolutionBtnGrp.checkedButton
                                        pDefaultCustomResBtn.checked = true
                                        fUpdateCustomResInConf(pDefaultCustomResBtn)
                                    }
                                    iCustomWidthTextField.text = pDefaultWidth
                                    iCustomHeightTextField.text = pDefaultHeight
                                    pEnableSave = false
                                }
                            }
                        }
                    }

                    GridLayout {
                        id: iLandscapeGrid
                        columnSpacing: 40
                        rowSpacing: 12
                        rows: 2
                        columns: 3
                        UiRadioButton {
                            id: iRes960x540
                            text: "960 x 540"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes1280x720
                            text: "1280 x 720"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes1600x900
                            text: "1600 x 900"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes1920x1080
                            text: "1920 x 1080"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes2560x1440
                            text: "2560 x 1440"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes3840x2160
                            text: "3840 x 2160"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                    }
                    GridLayout {
                        id: iPortraitGrid
                        columnSpacing: 40
                        rowSpacing: 12
                        rows: 2
                        columns: 3
                        visible: false

                        UiRadioButton {
                            id: iRes540x960
                            text: "540 x 960"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes720x1280
                            text: "720 x 1280"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes900x1600
                            text: "900 x 1600"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes1080x1920
                            text: "1080 x 1920"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes1440x2560
                            text: "1440 x 2560"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes2160x3840
                            text: "2160 x 3840"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                    }
                    GridLayout {
                        id: iUltraWideGrid
                        columnSpacing: 40
                        rowSpacing: 12
                        rows: 2
                        columns: 3
                        visible: false

                        UiRadioButton {
                            id: iRes1680x720
                            text: "1680 x 720"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes2560x1080
                            text: "2560 x 1080"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes3440x1440
                            text: "3440 x 1440"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                        UiRadioButton {
                            id: iRes5120x2160
                            text: "5120 x 2160"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iResolutionBtnGrp
                        }
                    }
                    UiColumnLayout {
                        id: iCustomResolutionRow
                        visible: false
                        Layout.fillWidth: true
                        GridLayout {
                            visible: pCustomGridVisible
                            id: iCustomResolutionGrid
                            columnSpacing: 24
                            rowSpacing: 12
                            rows: pCustResRowCount
                            columns: 3
                            Layout.fillWidth: true
                            Repeater {
                                id: iCustomResRepeaterId
                                model: uiBackend.getCustomResolutionList()
                                delegate: UiRowLayout {
                                    id: iCustResRowLayout
                                    Layout.preferredWidth: 164
                                    pMouseArea {
                                        enabled: true
                                        anchors.fill: iCustResRowLayout
                                        hoverEnabled: true
                                        onEntered: pDeleteBtnVisible = true
                                        onExited: pDeleteBtnVisible = false
                                    }
                                    UiRadioButton {
                                        id: iCustResBtn
                                        text: modelData
                                        ButtonGroup.group: iCustomResolutionBtnGrp
                                        checked: text === pResolution && uiBackend.confGetInstanceBool("custom_resolution_selected") ? true : false
                                        pHovered: iCustResRowLayout.pMouseArea.containsMouse
                                        hoverEnabled: false
                                    }
                                    UiImageButton {
                                        asset: "DeleteSmall"
                                        pImageWidth: 12
                                        pImageHeight: 12
                                        Layout.leftMargin: 10
                                        visible: pMouseArea.containsMouse && modelData != pResolution && fCheckIfResCanBeDeleted(modelData)
                                        onClicked: {
                                            uiBackend.confDiscard()
                                            if(iCustResBtn.checked && pDefaultCustomResBtn != null) {
                                                pDefaultCustomResBtn.checked = true
                                            }
                                            var resVal = pResolution.split("x")
                                            uiBackend.confSetInstanceI32("fb_width", parseInt(resVal[0].trim()))
                                            uiBackend.confSetInstanceI32("fb_height", parseInt(resVal[1].trim()))
                                            uiBackend.updateCustomResolutionList(modelData)
                                            pCustResRowCount = uiBackend.getRowsCount()
                                            pCustomGridVisible = pCustResRowCount == -1 ? false : true
                                            fReloadConf()
                                            iCustomResRepeaterId.model = uiBackend.getCustomResolutionList()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    UiColumnLayout {
                        id: iCustomResolutionAddRow
                        Layout.fillWidth: true
                        spacing: 12
                        Text {
                            text: qsTranslate("QObject", "There are no custom resolution presets")
                            font: Qt.font({family:"Segoe UI",pixelSize:10})
                            color: "#c7c7ce"
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                            visible: !pCustomGridVisible
                        }
                        UiButton {
                            asset: "AddSmall"
                            text: qsTranslate("QObject", "Add resolution")
                            pSize: UiTheme.buttons.sizes.small
                            pColor: UiTheme.buttons.colors.tertiary
                            onClicked: {
                                iCustomResolutionAddRow.visible = false
                                iCustomResolutionDataRow.visible = pCustomGridVisible = true
                            }
                        }
                    }
                    UiColumnLayout {
                        id: iCustomResolutionDataRow
                        spacing: 12
                        visible: false
                        padding: 12
                        color: "#151519"
                        Layout.fillWidth: true
                        border.color: iErrorMessage.visible ? UiTheme.colors.dangerNormal : UiTheme.colors.primary60
                        UiRowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: qsTranslate("QObject", "Add custom resolution")
                                font: Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#eeeef2"
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            UiImageButton {
                                asset: "CloseSmall"
                                pImageWidth: 9
                                pImageHeight: 9
                                Layout.alignment: Qt.AlignRight
                                onClicked: {
                                    iCustomResolutionDataRow.visible = false
                                    iCustomResolutionAddRow.visible = true
                                    pCustomGridVisible = uiBackend.getRowsCount() === -1 ? false : true
                                    iCustomWidthTextField.text = pDefaultWidth
                                    iCustomHeightTextField.text = pDefaultHeight
                                }
                            }
                        }

                        UiRowLayout {
                            spacing: 12
                            Text {
                                text: qsTranslate("QObject", "Width ") + "(px)"
                                font: Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#c7c7ce"
                                Layout.maximumWidth: 140
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                            }
                            UiTextField {
                                id: iCustomWidthTextField
                                pSize: UiTheme.textFields.sizes.medium
                                Layout.preferredWidth: 80
                                text: "1920"
                                validator: IntValidator {bottom: 480; top: 3840}
                                inputMethodHints: Qt.ImhDigitsOnly
                                maximumLength: 4
                                pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                pErrorTemplateContent: qsTranslate("QObject", "Supported resolution range for Width is : %1").arg("480-3840")
                                onTextChanged: iErrorMessage.visible = false
                            }

                            Text {
                                text: qsTranslate("QObject", "Height ") + "(px)"
                                font: Qt.font({family:"Segoe UI",pixelSize:12})
                                color: "#c7c7ce"
                                Layout.maximumWidth: 140
                                horizontalAlignment: Text.AlignLeft
                                elide: Text.ElideRight
                            }

                            UiTextField {
                                id: iCustomHeightTextField
                                pSize: UiTheme.textFields.sizes.medium
                                Layout.preferredWidth: 80
                                text: "1080"
                                validator: IntValidator {bottom: 480; top: 3840}
                                inputMethodHints: Qt.ImhDigitsOnly
                                maximumLength: 4
                                pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                pErrorTemplateContent: qsTranslate("QObject", "Supported resolution range for Height is : %1").arg("480-3840")
                                onTextChanged: iErrorMessage.visible = false
                            }
                            UiImageButton {
                                asset: "SaveSmall"
                                pImageWidth: 14
                                pImageHeight: 14
                                enabled: (iCustomWidthTextField.acceptableInput &&  iCustomHeightTextField.acceptableInput) ? true : false
                                onClicked: {
                                    if(!fCheckIfResIsDuplicate(iCustomWidthTextField.text, iCustomHeightTextField.text)) {
                                        uiBackend.confDiscard()
                                        uiBackend.setCustomResolutionList(iCustomWidthTextField.text + " x " + iCustomHeightTextField.text)
                                        iCustomResolutionAddRow.visible = pCustomGridVisible = true
                                        iCustomResolutionDataRow.visible = false
                                        iCustomResRepeaterId.model = uiBackend.getCustomResolutionList()
                                        pCustResRowCount = uiBackend.getRowsCount()
                                        iCustomWidthTextField.text = pDefaultWidth
                                        iCustomHeightTextField.text = pDefaultHeight
                                        iErrorMessage.visible = false
                                        fReloadConf()
                                    }
                                    else {
                                        iErrorMessage.visible = true
                                    }
                                }
                            }
                        }
                        Text {
                            id: iErrorMessage
                            visible: false
                            text: qsTranslate("QObject", "This custom resolution already exists")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: UiTheme.colors.dangerNormal
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: {
                            qsTranslate("QObject", "Recommended resolution") + ": " +
                                    ((iResolutionCombobox.currentIndex < 3 && iResolutionCombobox.currentIndex >= 0) ?
                                         pRecommendedResolution[iResolutionCombobox.currentIndex] :
                                         "1920 x 1080")
                        }
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: "#bdbdc5"
                        wrapMode: Text.Wrap
                        visible: iResolutionCombobox.currentIndex != 3
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "NOTE: Keyboard controls at these resolutions are supported only for Wild Rift. Controls may not work as expected for other games.")
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                        visible: iResolutionCombobox.currentIndex === 2
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
                    Text {
                        text: qsTranslate("QObject", "Pixel Density")
                        font :Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }

                    UiRowLayout {
                        spacing: 40
                        UiRadioButton {
                            id: iDpi160
                            text: "160 DPI (" + qsTranslate("QObject", "Low") + ")"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iDpiBtnGrp
                        }
                        UiRadioButton {
                            id: iDpi240
                            text: "240 DPI (" + qsTranslate("QObject", "Medium") + ")"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iDpiBtnGrp
                        }
                        UiRadioButton {
                            id: iDpi320
                            text: "320 DPI (" + qsTranslate("QObject", "High") + ")"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iDpiBtnGrp
                        }
                    }
                    UiRowLayout {
                        spacing: 8
                        UiRadioButton {
                            id: iDpiCustom
                            text: qsTranslate("QObject", "Custom")
                            ButtonGroup.group: iDpiBtnGrp
                            Layout.preferredHeight: iCustomDpiTextField.height
                        }
                        UiTextField {
                            id: iCustomDpiTextField
                            pSize: UiTheme.textFields.sizes.small
                            Layout.preferredWidth: 40
                            visible: iDpiCustom.checked
                            text: ""
                            validator: IntValidator {bottom: 10; top: 999}
                            enabled: iDpiCustom.checked
                            pInputValidationState: acceptableInput ? UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                            pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                            pErrorTemplateContent: qsTranslate("QObject", "Supported range for DPI is: 10-999")
                            inputMethodHints: Qt.ImhDigitsOnly
                            onTextChanged: {
                                uiBackend.confSetInstanceI32("dpi", parseInt(text))
                                fMonitorChange()
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "DPI")
                            font: Qt.font({family:"Segoe UI",pixelSize:12})
                            color: "#c7c7ce"
                            visible: iDpiCustom.checked
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "NOTE: Changing the pixel density may affect gameplay experience of some apps.")
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
                    }
                }

                Loader {
                    id: iCustomCursorLoader
                    visible: false
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: "#303034"
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    id: iInterfaceScaling
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "Interface scaling")
                        font :Qt.font({family:"Segoe UI",pixelSize:12})
                        color: "#eeeef2"
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "Only applies to the size of text and icons in App Player and not within apps.")
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: "#bdbdc5"
                    }

                    UiComboBox {
                        id: iInterfaceScalingCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: pInterfaceScalingModel
                        textRole: "text"
                        valueRole: "value"
                        Layout.preferredWidth: 174
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetString("bst.ui_scale_factor", currentValue)
                                fMonitorChange()
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "NOTE: 100% scaling is advised for screens with a resolution of 1920 x 1080 or lower.")
                        font: Qt.font({family:"Segoe UI",pixelSize:10})
                        color: UiTheme.colors.warning
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
                    if(iResolutionCombobox.currentIndex === 3) {
                        if(!uiBackend.checkIfResCanBeSaved(uiBackend.confGetInstanceI32("fb_width"), uiBackend.confGetInstanceI32("fb_height")))
                        { var resVal = pResolution.split("x")
                            uiBackend.confSetInstanceI32("fb_width", parseInt(resVal[0].trim()))
                            uiBackend.confSetInstanceI32("fb_height", parseInt(resVal[1].trim()))
                        }
                    }
                    if (pParentWindow === "plr") {
                        if (uiBackend.confIsInstancePropModified("fb_width") ||
                                uiBackend.confIsInstancePropModified("fb_height") ||
                                uiBackend.confIsInstancePropModified("dpi") ||
                                uiBackend.confIsPropModified("bst.ui_scale_factor")) {
                            iSaveChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                        }
                        else {
                            if (pDefaultCursorBtn != iCursorBtnGrp.checkedButton) {
                                plrBackend.setMouseCursor(iCustomCursorLoader.item.fIsDefaultCursor() ? "default" : plrBackend.isMobaCursorSupported() ? "moba" : "")
                            }
                            uiBackend.confCommit()
                            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                            fInitUi()
                        }
                    } else {
                        if (uiBackend.confIsPropModified("bst.ui_scale_factor"))
                            mimBackend.sendInterfaceScalingStat(pDefaultInterfaceScaling)

                        uiBackend.confCommit()
                        close()
                    }
                }
            }
        }
    }

    function fInitUi() {
        var fbWidth = uiBackend.confGetInstanceI32("fb_width")
        var fbHeight = uiBackend.confGetInstanceI32("fb_height")
        pResolution = fbWidth + " x " + fbHeight

        iCustomWidthTextField.text = fbWidth
        iCustomHeightTextField.text = fbHeight
        pDefaultWidth = fbWidth
        pDefaultHeight = fbHeight
        if(pParentWindow === "plr") {
            iCustomCursorLoader.visible = true
            iCustomCursorLoader.sourceComponent = iCustomCursorComponent
            iCustomCursorLoader.item.fSetMouseCursorValue()
            plrBackend.setMouseCursor(iCustomCursorLoader.item.fIsDefaultCursor() ? "default" : plrBackend.isMobaCursorSupported() ? "moba" : "")

        }

        pCustResRowCount = uiBackend.getRowsCount()
        pCustomGridVisible = pCustResRowCount == -1 ? false : true

        var currIdx = 0

        if (iCustomResolutionBtnGrp.checkedButton != null && uiBackend.confGetInstanceBool("custom_resolution_selected")) {
            currIdx = 3
            iResolutionCombobox.currentIndex = 3
            if(pDefaultCustomResBtn != null)
                iCustomResolutionBtnGrp.checkedButton = pDefaultCustomResBtn
            else
                pDefaultCustomResBtn = iCustomResolutionBtnGrp.checkedButton
        }
        else
        {
            fSelectResolutionBtn(pResolution)
            if (iResolutionBtnGrp.checkedButton != null) {
                pDefaultResBtn = iResolutionBtnGrp.checkedButton

                if (pDefaultResBtn.parent == iPortraitGrid) {
                    currIdx = 1
                    iResolutionCombobox.currentIndex = 1
                }
                else if (pDefaultResBtn.parent == iUltraWideGrid) {
                    currIdx = 2
                    iResolutionCombobox.currentIndex = 2
                }
                else
                    iResolutionCombobox.currentIndex = 0
            }
            else {
                currIdx = 3
                iResolutionCombobox.currentIndex = 3
            }
        }

        fSetResolutionOptionsVisibility(currIdx)
        pDefaultResComboboxIdx = iResolutionCombobox.currentIndex
        iCustomDpiTextField.text = pOriginalDpi
        if (pOriginalDpi === 160) {
            iDpi160.checked = true
            pDefaultDpiBtn = iDpi160
        }
        else if (pOriginalDpi === 240) {
            iDpi240.checked = true
            pDefaultDpiBtn = iDpi240
        }
        else if (pOriginalDpi === 320) {
            iDpi320.checked = true
            pDefaultDpiBtn = iDpi320
        }
        else {
            iDpiCustom.checked = true
            pDefaultDpiBtn = iDpiCustom
        }

        var screenWidth = Screen.desktopAvailableWidth * Screen.devicePixelRatio
        var screenHeight = Screen.desktopAvailableHeight * Screen.devicePixelRatio
        var recommendedWidth
        var recommendedHeight
        if (screenWidth > 1920 && screenHeight > 1080) {
            recommendedWidth = 1920
            recommendedHeight = 1080
        }
        else if (screenWidth > 1600 && screenHeight > 900) {
            recommendedWidth = 1600
            recommendedHeight = 900
        }
        else if (screenWidth > 1280 && screenHeight > 720) {
            recommendedWidth = 1280
            recommendedHeight = 720
        }
        else
        {
            recommendedWidth = 960
            recommendedHeight = 540
        }

        pRecommendedResolution[0] = recommendedWidth + " x " + recommendedHeight
        pRecommendedResolution[1] = recommendedHeight + " x " + recommendedWidth

        fSelectInterfaceScaling()

        pEnableSave = false
    }

    function fSelectInterfaceScaling() {
        if (pDefaultInterfaceScaling === "1.00")
            iInterfaceScalingCombobox.currentIndex = 0
        else if (pDefaultInterfaceScaling === "1.25")
            iInterfaceScalingCombobox.currentIndex = 1
        else if (pDefaultInterfaceScaling === "1.50")
            iInterfaceScalingCombobox.currentIndex = 2
        else if (pDefaultInterfaceScaling === "1.75")
            iInterfaceScalingCombobox.currentIndex = 3
        else if (pDefaultInterfaceScaling === "2.00")
            iInterfaceScalingCombobox.currentIndex = 4
        else if (pDefaultInterfaceScaling === "2.25")
            iInterfaceScalingCombobox.currentIndex = 5
        else if (pDefaultInterfaceScaling === "2.50")
            iInterfaceScalingCombobox.currentIndex = 6
        else if (pDefaultInterfaceScaling === "3.00")
            iInterfaceScalingCombobox.currentIndex = 7
    }

    function fSelectResolutionBtn(res) {
        if (res === "1280 x 720")
            iRes1280x720.checked = true
        else if (res === "960 x 540")
            iRes960x540.checked = true
        else if (res === "1920 x 1080")
            iRes1920x1080.checked = true
        else if (res === "1600 x 900")
            iRes1600x900.checked = true
        else if (res === "2560 x 1440")
            iRes2560x1440.checked = true
        else if (res === "3840 x 2160")
            iRes3840x2160.checked = true
        else if (res === "720 x 1280")
            iRes720x1280.checked = true
        else if (res === "540 x 960")
            iRes540x960.checked = true
        else if (res === "1080 x 1920")
            iRes1080x1920.checked = true
        else if (res === "900 x 1600")
            iRes900x1600.checked = true
        else if (res === "1440 x 2560")
            iRes1440x2560.checked = true
        else if (res === "2160 x 3840")
            iRes2160x3840.checked = true
        else if (res === "1680 x 720")
            iRes1680x720.checked = true
        else if (res === "2560 x 1080")
            iRes2560x1080.checked = true
        else if (res === "3440 x 1440")
            iRes3440x1440.checked = true
        else if (res === "5120 x 2160")
            iRes5120x2160.checked = true
        else {
            pDefaultResBtn = null
            iResolutionBtnGrp.checkedButton = null
        }
    }

    function fReloadComboboxes(){
        iResolutionCombobox.currentIndex = pDefaultResComboboxIdx
    }

    function fSetPreviousState() {
        fInitUi()
    }

    function fSetResolutionOptionsVisibility(currIdx) {
        iPortraitGrid.visible = false
        iLandscapeGrid.visible = false
        iUltraWideGrid.visible = false
        iCustomResolutionRow.visible = false
        iCustomResolutionAddRow.visible = false
        iCustomResolutionDataRow.visible = false

        if (currIdx === 0)
            iLandscapeGrid.visible = true
        else if (currIdx === 1)
            iPortraitGrid.visible = true
        else if (currIdx === 2)
            iUltraWideGrid.visible = true
        else {
            iCustomResolutionRow.visible = true
            iCustomResolutionAddRow.visible = true
        }
    }

    function fMonitorChange() {
        if (uiBackend.confIsModified()
                && !(iDpiCustom.checked && !iCustomDpiTextField.acceptableInput))
        {
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

    function fUpdateCustomResInConf(selectedBtn) {
        var resVal = selectedBtn.text.split("x")
        uiBackend.confSetInstanceI32("fb_width", parseInt(resVal[0].trim()))
        uiBackend.confSetInstanceI32("fb_height", parseInt(resVal[1].trim()))
        if(iResolutionCombobox.currentIndex === 3)
            uiBackend.confSetInstanceBool("custom_resolution_selected", true)
        else
            uiBackend.confSetInstanceBool("custom_resolution_selected", false)
        fMonitorChange()
    }

    function fReloadConf(currentInstance) {
        if(pParentWindow === "plr")
            plrBackend.reloadConfInAllInstances(currentInstance)
        else
            mimBackend.reloadConfInAllInstances(currentInstance)
    }

    function fCheckIfResCanBeDeleted(resolution) {
        fReloadConf(true)
        return uiBackend.checkIfResCanBeDeleted(resolution)
    }

    function fCheckIfResIsDuplicate(width, height) {
        return uiBackend.checkIfResCanBeSaved(parseInt(width.trim()), parseInt(height.trim()))
    }
}
