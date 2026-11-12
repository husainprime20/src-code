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
import UiFolderDialog 1.0

Item {
    objectName: "audioSetting"

    property bool pCompLoaded: false
    property bool pEnableSave: false
    property var pSpeakerModel
    property var pMicrophoneModel
    property bool pErrorVisible: false
    property string pParentWindow: ""

    ButtonGroup {
        id: iCameraRotateAngleBtnGrp
        onCheckedButtonChanged: {
                if (pCompLoaded) {
                    fUpdateCameraAngleInConf(checkedButton)
                }
        }
    }

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
            pDescription: qsTranslate("QObject", "Are you sure you want to discard changes and leave this tab?")
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
                    spacing: 8
                    Layout.fillWidth: true

                    Text {
                        text: qsTranslate("QObject", "Choose your preferred devices")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                        Layout.bottomMargin: 8
                    }

                    Text {
                        text: qsTranslate("QObject", "Speakers")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                    }

                    UiComboBox {
                        id: iAvailableSpeakersCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        Layout.preferredWidth: 360
                        model: plrOutputDevicesModel
                        textRole: "audio"
                        currentIndex: plrOutputDevicesModel.selectedIndex
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetString("bst.speaker_device", currentIndex === 0 ? "" : currentText)
                                fMonitorChange()
                            }
                        }
                    }

                    Text {
                        text: qsTranslate("QObject", "Microphone")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                        Layout.topMargin: 8
                    }

                    UiComboBox {
                        id: iAvailableMicrophonesCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        Layout.preferredWidth: 360
                        model: plrInputDevicesModel
                        textRole: "audio"
                        currentIndex: plrInputDevicesModel.selectedIndex
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetString("bst.microphone_device", currentIndex === 0 ? "" : currentText)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Camera")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                            Layout.topMargin: 8
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            Layout.topMargin: 8
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("switch_camera_help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }

                    UiComboBox {
                        id: iAvailableCamerasCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        pErrorState: pErrorVisible
                        Layout.preferredWidth: 360
                        model: plrCameraDevicesModel
                        textRole: "camera"
                        currentIndex: plrCameraDevicesModel.selectedCameraIndex
                        onActivated: {
                            if (pCompLoaded) {
                                pErrorVisible = !plrBackend.isCameraSupported(iAvailableCamerasCombobox.currentIndex, iAvailableCamerasCombobox.currentText)
                                if(!pErrorVisible) {
                                    uiBackend.confSetInstanceString("camera_device", plrBackend.getCameraNameFromIndex(currentIndex))
                                    uiBackend.confSetInstanceString("camera_backend", plrBackend.getCameraBackendFromIndex(currentIndex))
                                    fMonitorChange()
                                }
                                else
                                    pEnableSave = false
                            }
                        }
                    }

                    Text {
                        id: iErrorMessage
                        visible: pErrorVisible
                        text: qsTranslate("QObject", "This device is not supported")
                        font: UiTheme.fonts.titleSmallest
                        color: UiTheme.colors.dangerNormal
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                    }
                    Text {
                        text: qsTranslate("QObject", "Camera rotation angle")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                        Layout.topMargin: 8
                    }
                    GridLayout {
                        columnSpacing: 40
                        rowSpacing: 12
                        rows: 2
                        columns: 3
                        UiRadioButton {
                            id: iAngle0
                            text: "0"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iCameraRotateAngleBtnGrp
                        }
                        UiRadioButton {
                            id: iAngle90
                            text: "90"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iCameraRotateAngleBtnGrp
                        }
                        UiRadioButton {
                            id: iAngle180
                            text: "180"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iCameraRotateAngleBtnGrp
                        }
                        UiRadioButton {
                            id: iAngle270
                            text: "270"
                            Layout.preferredWidth: 142
                            ButtonGroup.group: iCameraRotateAngleBtnGrp
                        }
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
                    fSaveChanges()
                }
            }
        }
    }

    function fInitUi()
    {
        plrBackend.setDeviceModelIndices()
        fAssignCameraRotationAngleIdx()
        pEnableSave = false
        pErrorVisible = false
    }

    function fSaveChanges() {
        if (uiBackend.confIsPropModified("bst.speaker_device"))
            plrBackend.setSpeakerDevice(iAvailableSpeakersCombobox.currentIndex)
        if (uiBackend.confIsPropModified("bst.microphone_device"))
            plrBackend.setMicrophoneDevice(iAvailableMicrophonesCombobox.currentIndex)
        if (uiBackend.confIsInstancePropModified("camera_device") || uiBackend.confIsInstancePropModified("camera_backend"))
            plrBackend.setCameraDevice(iAvailableCamerasCombobox.currentIndex, iAvailableCamerasCombobox.currentText)

        uiBackend.confCommit()
        pEnableSave = false
        iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fMonitorChange() {
        if (uiBackend.confIsModified() && !pErrorVisible) {
            pEnableSave = true
        } else {
            pEnableSave = false
        }
    }

    function fRefreshAudioSettingModels(refreshOutputModel) {
        var refreshModel = false
        if(refreshOutputModel === "camera") {
            iAvailableCamerasCombobox.model = []
            iAvailableCamerasCombobox.model = plrCameraDevicesModel
        }
        else {

            refreshModel = refreshOutputModel === "speaker" ? true : false
            if(refreshModel)
            {
                iAvailableSpeakersCombobox.model = []
                iAvailableSpeakersCombobox.model = plrOutputDevicesModel
            }
            else
            {
                iAvailableMicrophonesCombobox.model = []
                iAvailableMicrophonesCombobox.model = plrInputDevicesModel
            }
        }
        uiBackend.confDiscard()
        pEnableSave = false
    }

    function fAssignCameraRotationAngleIdx() {
        var selectedAngle = uiBackend.confGetInstanceI32("camera_rotation_angle")
        if(selectedAngle === 0)
            iAngle0.checked = true
        else if(selectedAngle === 90)
            iAngle90.checked = true
        else if(selectedAngle === 180)
            iAngle180.checked = true
        else if(selectedAngle === 270)
            iAngle270.checked = true
        else
            iAngle0.checked = true
    }

    function fUpdateCameraAngleInConf(selectedAngleBtn) {
        uiBackend.confSetInstanceI32("camera_rotation_angle", parseInt(selectedAngleBtn.text.trim()))
        fMonitorChange()
    }
}
