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
import UiToolTipControl 1.0
import Qt.labs.platform 1.1
import UiFolderDialog 1.0
import UiOverlayControl 1.0
import UiQuickWindow 1.0

Item {
    objectName: "preferences"
    property bool pCompLoaded: false
    property bool pEnableSave: false
    property int pDefaultLangIdx: 0
    property string pOldLocale: uiBackend.confGetString("bst.locale")
    property bool pDefaultEnableProgrammaticAds: true
    property string pParentWindow: ""
    property int pMobileDeviceCount: 0
    property bool pDevicesRefreshed: false
    property var pLocaleList: [
        "en-US",
        "ar-EG",
        "de-DE",
        "es-ES",
        "fr-FR",
        "id-ID",
        "it-IT",
        "ja-JP",
        "ko-KR",
        "pl-PL",
        "pt-BR",
        "ru-RU",
        "th-TH",
        "tr-TR",
        "vi-VN",
        "zh-CN",
        "zh-TW"]

    ListModel {
        id: iLangModel
        ListElement {name: "English (United States)"}
        ListElement {name: "العربية (مصر)"}
        ListElement {name: "Deutsch (Deutschland)"}
        ListElement {name: "Español (España, alfabetización internacional)"}
        ListElement {name: "Français (France)"}
        ListElement {name: "Indonesian (Indonesia)"}
        ListElement {name: "Italiano (Italia)"}
        ListElement {name: "日本語 (日本)"}
        ListElement {name: "한국어(대한민국)"}
        ListElement {name: "Polski (Polska)"}
        ListElement {name: "Português (Brasil)"}
        ListElement {name: "Pусский (Россия)"}
        ListElement {name: "ไทย (ไทย)"}
        ListElement {name: "Türkçe (Türkiye)"}
        ListElement {name: "Tiếng Việt (Việt Nam)"}
        ListElement {name: "简体中文"}
        ListElement {name: "繁體中文"}
    }

    function fOnQmlLoaded() {
        if (!pCompLoaded) {
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
                            close()
                        }
                    }
                ]
            }
        }
    }

    UiFolderDialog {
        id: iSelectMediaFolderDialog
        visible: false
        onAccepted: {
            iSelectMediaFolderDialog.close()
            var currentPath = currentFolder.toString()
            console.info("folder path.."+currentPath)
            currentPath = currentPath.replace(
                        /^(file:\/{3})|(qrc:\/{2})|(http:\/{2})/, "")
            currentPath = currentPath.replace(/\//g, '\\')
            if (plrBackend.isDirWritable(currentPath) && !plrBackend.isDirInInstallationFolder(currentPath)) {
                uiBackend.confSetString("bst.media_folder", currentPath)
                iMediaFolderPath.text = currentPath
                fMonitorChange()
            } else {
                iSettingsWindow.fShowToast(qsTranslate("QObject", "%1 does not have the required permissions to store in the folder you have selected").arg(uiBackend.productName))
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
        id: iAdsPreferencePrompt
        UiMessageDialog {
            id: iAdsPreference
            UiOverlay.overlayRect: Qt.rect(iSettingsWindow.x + iSettingsWindow.pShadowThickness,
                                           iSettingsWindow.y + iSettingsWindow.pShadowThickness,
                                           iSettingsWindow.width - (2 * iSettingsWindow.pShadowThickness),
                                           iSettingsWindow.height - (2 * iSettingsWindow.pShadowThickness))
            pDialogType: UiDialogWindow.Graphic
            title: qsTranslate("QObject", "Please keep ads enabled")
            pSubtitle: qsTranslate("QObject", "Ads help us keep %1 awesome and free.").arg(uiBackend.productName)
            pDescription: qsTranslate("QObject", "Please support us by not disabling them.")
            pDialogImageSource: "AdsPopupWarningImage"
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Sure")
                        onClicked: {
                            iEnableProgrammaticAdsBtn.checked = true
                            uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "enable_btn_clicked")
                            iAdsPreference.close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.tertiary
                        pText: qsTranslate("QObject", "Disable")
                        onClicked: {
                            uiBackend.confSetBool("bst.enable_programmatic_ads", false)
                            fMonitorChange()
                            uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "disable_btn_clicked")
                            iAdsPreference.close()
                        }
                    }
                ]
            }
            onCloseClicked: {
                iEnableProgrammaticAdsBtn.checked = true
                uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "close_btn_clicked")
            }
        }
    }

    Component {
        id: iAdsPreferenceComponent
        UiQuickWindow {
            id: iAdsPreferenceWindow
            color: "transparent"
            flags: Qt.Window | Qt.FramelessWindowHint
            width: 360 + 2 * shadowContainer.shadowThickness
            height: iMainContentLayout.implicitHeight + 2 * shadowContainer.shadowThickness
            modality: Qt.ApplicationModal

            onClosed: {
                iAdsPreferenceWindow.destroy()
            }

            onWindowCompleted: {
                uiBackend.sendSettingStats("programmatic_ads_preference_popup", "ads_free", "popup_shown")
            }

            UiShadowContainer {
                id: shadowContainer
                Rectangle {
                    clip: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: iMainContentLayout.implicitHeight
                    border.color: UiTheme.colors.primary60
                    border.width: 1
                    color: UiTheme.colors.primary70

                    UiColumnLayout {
                        id: iMainContentLayout
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: iAdsImg.height
                            UiColumnLayout {
                                anchors.centerIn: parent
                                UiImage {
                                    id: iAdsImg
                                    asset: "AdsPopupWarningImage"
                                    pImageWidth: 250
                                    pImageHeight: 140
                                }
                            }
                            UiImageButton {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.rightMargin: 20
                                anchors.topMargin: 20
                                asset: "CloseIcon"
                                pImageWidth: 16
                                pImageHeight: 16
                                onClicked: {
                                    iEnableProgrammaticAdsBtn.checked = true
                                    uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "close_btn_clicked")
                                    iAdsPreferenceWindow.close()
                                }
                            }
                        }

                        UiColumnLayout {
                            Layout.fillWidth: true
                            padding: 24

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: adsPreferencesPopup.popupData.title
                                font: UiTheme.fonts.titleLarge
                                color: UiTheme.dialogs.colors.accent.title
                                wrapMode: Text.Wrap
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 8
                                horizontalAlignment: Text.AlignHCenter
                                text: adsPreferencesPopup.popupData.description
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary20
                                wrapMode: Text.Wrap
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: iGoPrimeLayout.height + 2
                                Layout.topMargin: 16
                                color: adsPreferencesPopup.popupData.prime_section.background_gradient.border_color
                                visible: adsPreferencesPopup.popupData.prime_section.visible

                                Rectangle {
                                    width: parent.width - 2
                                    height: iGoPrimeLayout.height
                                    anchors.centerIn: parent
                                    color: adsPreferencesPopup.popupData.prime_section.background_gradient.border_color
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0; color: adsPreferencesPopup.popupData.prime_section.background_gradient.start }
                                        GradientStop { position: 1; color: adsPreferencesPopup.popupData.prime_section.background_gradient.end }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Qt.rgba(0, 0, 0, 0.7)

                                        UiColumnLayout {
                                            id: iGoPrimeLayout
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            padding: 16

                                            UiRowLayout {
                                                spacing: 8

                                                UiImage {
                                                    asset: "PrimeIcon"
                                                    pImageWidth: 20
                                                    pImageHeight: 20
                                                }

                                                Text {
                                                    text: adsPreferencesPopup.popupData.prime_section.name
                                                    color: UiTheme.colors.secondaryHover
                                                    font: UiTheme.fonts.titleSmall
                                                }
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                Layout.topMargin: 4
                                                text: adsPreferencesPopup.popupData.prime_section.benefits
                                                color: UiTheme.colors.overLayBright
                                                font: UiTheme.fonts.bodyLarge
                                                wrapMode: Text.Wrap
                                            }

                                            UiButton {
                                                pSize: UiTheme.buttons.sizes.medium
                                                pColor: adsPreferencesPopup.popupData.prime_section.button.type === "nowbuxButton" ?
                                                            UiTheme.buttons.colors.nowbuxButton : adsPreferencesPopup.popupData.prime_section.button.type === "accent" ?
                                                                UiTheme.buttons.colors.accent : adsPreferencesPopup.popupData.prime_section.button.type === "secondary" ?
                                                                    UiTheme.buttons.colors.secondary : adsPreferencesPopup.popupData.prime_section.button.type === "tertiary" ?
                                                                        UiTheme.buttons.colors.tertiary : adsPreferencesPopup.popupData.prime_section.button.type === "danger" ?
                                                                            UiTheme.buttons.colors.danger : adsPreferencesPopup.popupData.prime_section.button.type === "transparent" ?
                                                                                UiTheme.buttons.colors.transparent : adsPreferencesPopup.popupData.prime_section.button.type === "outline" ?
                                                                                    UiTheme.buttons.colors.outline : adsPreferencesPopup.popupData.prime_section.button.type === "accentWhiteBorder" ?
                                                                                        UiTheme.buttons.colors.accentWhiteBorder : UiTheme.buttons.colors.accentWhiteBorder
                                                text: adsPreferencesPopup.popupData.prime_section.button.text
                                                Layout.fillWidth: true
                                                Layout.topMargin: 12
                                                onClicked: {
                                                    iEnableProgrammaticAdsBtn.checked = true
                                                    plrBackend.handleAdsFreeBtnClick(adsPreferencesPopup.popupData.prime_section.button.action, adsPreferencesPopup.popupData.prime_section.button.value)
                                                    uiBackend.sendSettingStats("programmatic_ads_preference_popup", "ads_free", "prime_btn_clicked")
                                                    iAdsPreferenceWindow.close()
                                                    iSettingsWindow.close()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            UiButton {
                                pSize: UiTheme.buttons.sizes.medium
                                pColor: adsPreferencesPopup.popupData.buttons[0].type === "accent" ?
                                            UiTheme.buttons.colors.accent : adsPreferencesPopup.popupData.buttons[0].type === "nowbuxButton" ?
                                                UiTheme.buttons.colors.nowbuxButton : adsPreferencesPopup.popupData.buttons[0].type === "secondary" ?
                                                    UiTheme.buttons.colors.secondary : adsPreferencesPopup.popupData.buttons[0].type === "tertiary" ?
                                                        UiTheme.buttons.colors.tertiary : adsPreferencesPopup.popupData.buttons[0].type === "danger" ?
                                                            UiTheme.buttons.colors.danger : adsPreferencesPopup.popupData.buttons[0].type === "transparent" ?
                                                                UiTheme.buttons.colors.transparent : adsPreferencesPopup.popupData.buttons[0].type === "outline" ?
                                                                    UiTheme.buttons.colors.outline : adsPreferencesPopup.popupData.buttons[0].type === "accentWhiteBorder" ?
                                                                        UiTheme.buttons.colors.accentWhiteBorder : UiTheme.buttons.colors.accentWhiteBorder
                                text: adsPreferencesPopup.popupData.buttons[0].text
                                Layout.fillWidth: true
                                Layout.topMargin: 12
                                onClicked: {
                                    iEnableProgrammaticAdsBtn.checked = true
                                    uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "enable_btn_clicked")
                                    iAdsPreferenceWindow.close()
                                }
                            }

                            Text {
                                id: iFooterTextBtn
                                text: adsPreferencesPopup.popupData.footer_links[0].text
                                font: UiTheme.fonts.bodySmall
                                color: UiTheme.colors.overLayBright
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.topMargin: 12

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: iFooterTextBtn.color = UiTheme.colors.accentNormal
                                    onExited: iFooterTextBtn.color = UiTheme.colors.overLayBright
                                    onClicked: {
                                        uiBackend.confSetBool("bst.enable_programmatic_ads", false)
                                        fMonitorChange()
                                        uiBackend.sendSettingStats("programmatic_ads_preference_popup", "allow_ads", "disable_btn_clicked")
                                        iAdsPreferenceWindow.close()
                                    }
                                }
                            }
                        }
                    }
                }
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
            contentHeight: iContentLayout.height + 20

            UiColumnLayout {
                id: iContentLayout
                width: 520
                Layout.alignment: Qt.AlignTop
                spacing: 16
                UiColumnLayout {
                    spacing: 8
                    Text {
                        text: qsTranslate("QObject", "Language")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }

                    UiComboBox {
                        id: iLanguageCombobox
                        pSize: UiTheme.comboBoxes.sizes.medium
                        model: iLangModel
                        Layout.preferredWidth: 260
                        onActivated: {
                            if (pCompLoaded) {
                                uiBackend.confSetString("bst.locale", pLocaleList[currentIndex])
                                fMonitorChange()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "Platform")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                        horizontalAlignment: Text.AlignLeft
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.oem !== "nxt_cn" && uiBackend.oem !== "wmx"
                        Text {
                            text: qsTranslate("QObject", "Allow %1 to connect with Discord").arg(uiBackend.productName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iDiscordToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_discord_integration", checked)
                                fMonitorChange()
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.oem !== "wmx"
                        Text {
                            text: qsTranslate("QObject", "Create desktop shortcuts for apps after installation")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iAppShortcutToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.create_desktop_shortcuts", checked)
                                fMonitorChange()
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.oem !== "wmx"
                        Text {
                            text: qsTranslate("QObject", "Ask for sign in with Google Play on launching a game")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableGoogleSignInBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_sigin_gamelaunch", checked)
                                fMonitorChange()
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        UiRowLayout{
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Enable android sound while tapping")
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary20
                                horizontalAlignment: Text.AlignLeft
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageWidth: 16
                                pImageHeight: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: uiBackend.openHelpArticle("Android_Sound_on_Tap_Help")
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }


                        UiToggleButton {
                            id: iEnableAndroidSoundBtn
                            Layout.alignment: Qt.AlignRight
                            onCheckedChanged: {
                                uiBackend.confSetInstanceBool("android_sound_while_tapping", checked)
                                fMonitorChange()
                            }
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.confGetBool("bst.feature.programmatic_ads") &&
                                 uiBackend.confGetBool("bst.feature.show_programmatic_ads_preference")
                        Text {
                            text: qsTranslate("QObject", "Allow %1 to show Ads during gameplay").arg(uiBackend.productName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableProgrammaticAdsBtn
                            onCheckedChanged: {
                                if (checked == false && checked != pDefaultEnableProgrammaticAds) {
                                    if (adsPreferencesPopup.hasPopupData)
                                        iAdsPreferenceComponent.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                                    else
                                        iAdsPreferencePrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                                }
                                else {
                                    uiBackend.confSetBool("bst.enable_programmatic_ads", checked)
                                    fMonitorChange()
                                }
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.confGetBool("bst.feature.show_boot_banner_preference")
                        Text {
                            text: qsTranslate("QObject", "Show featured banner on start")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableBluestacksBannerBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_boot_banner", checked)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Open Store on start").arg(uiBackend.productName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableBluestacksStoreBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.launch_store_on_boot", checked)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Upload video recordings to the cloud automatically")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableUploadRecBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_auto_upload_recording", checked)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: uiBackend.confGetBool("bst.feature.show_ai_highlights")
                        Text {
                            text: qsTranslate("QObject", "Enable AI Highlights")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEnableAIHighlightsBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_ai_highlights", checked)
                                fMonitorChange()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "ESC key behavior")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                            horizontalAlignment: Text.AlignLeft
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("ESC_Behavior_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Exit fullscreen")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEscFullScreenToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_esc_fullscreen", checked)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Unlock mouse cursor")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iEscMouseCursorToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetBool("bst.enable_esc_mousecursor", checked)
                                fMonitorChange()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    UiRowLayout {
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "In-app Notifications")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                            horizontalAlignment: Text.AlignLeft
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("Notifications_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Desktop notifications")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iNotificationsToggleBtn
                            onCheckedChanged: {
                                uiBackend.confSetInstanceBool("enable_notifications", checked)
                                fMonitorChange()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Auto hide desktop notifications")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iAutoHideNotificationsToggleBtn
                            enabled: iNotificationsToggleBtn.checked
                            onCheckedChanged: {
                                uiBackend.confSetInstanceBool("autohide_notifications", checked)
                                fMonitorChange()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                    visible: uiBackend.confGetBool("bst.feature.enable_mobile_notification")
                }

                UiColumnLayout {
                    visible: uiBackend.confGetBool("bst.feature.enable_mobile_notification")
                    Layout.fillWidth: true
                    spacing: 12

                    UiColumnLayout {
                        id: iMobileNotificationsCol
                        Layout.fillWidth: true
                        spacing: 8
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Mobile Notifications")
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary10
                                horizontalAlignment: Text.AlignLeft
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageWidth: 16
                                pImageHeight: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: uiBackend.openHelpArticle("Mobile_Notifications_Help")
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                            Rectangle {
                                Layout.preferredWidth: 6
                                Layout.preferredHeight: 6
                                radius: 3
                                color: UiTheme.colors.dangerNormal
                                Layout.alignment: Qt.AlignVCenter
                                visible: false
                            }
                            Item { Layout.fillWidth: true }
                            UiImageButton {
                                asset: "MediumToggleOff"
                                pImageWidth: 28
                                pImageHeight: 14
                                onClicked: plrBackend.showNowggSigninDialog()
                                visible: !iMobileNotificationsToggleBtn.visible
                            }
                            UiToggleButton {
                                id: iMobileNotificationsToggleBtn
                                onCheckedChanged: {
                                    uiBackend.confSetInstanceI32("enable_mobile_notifications", checked ? 1 : 0)
                                    fMonitorChange()
                                }
                            }
                        }
                        Text {
                            text: qsTranslate("QObject", "Get BlueStacks App Player games alerts directly on your mobile")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                    }

                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: iMobileNotificationsToggleBtn.checked
                        UiRowLayout {
                            Layout.preferredHeight: 24
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Linked Devices")
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary10
                                horizontalAlignment: Text.AlignLeft
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageWidth: 16
                                pImageHeight: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: uiBackend.openHelpArticle("Linked_Devices_Help")
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                                visible: pMobileDeviceCount <= 0
                            }
                            Item { Layout.fillWidth: true }
                            UiButton {
                                id: iDeviceRefreshBtn
                                pSize: UiTheme.buttons.sizes.small
                                pColor: UiTheme.buttons.colors.accent
                                text: qsTranslate("QObject", "Refresh")
                                onClicked: {
                                    plrBackend.refreshLinkedDevicesList("app_player_settings_refresh")
                                    iDeviceRefreshBtn.visible = false
                                }
                            }
                            UiImage {
                                id: iDeviceRefreshLoader
                                asset: "Loader_bright"
                                pImageWidth: 16
                                pImageHeight: 16
                                cache: false
                                visible: !iDeviceRefreshBtn.visible
                                RotationAnimation on rotation {
                                    loops: Animation.Infinite
                                    duration: 2000
                                    from: 0
                                    to: 360
                                    direction: RotationAnimation.Clockwise
                                    running: iDeviceRefreshLoader.visible
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            visible: pMobileDeviceCount <= 0
                            Text {
                                Layout.maximumWidth: 380
                                Layout.fillHeight: true
                                text: qsTranslate("QObject", "Download & Install the BlueStacks Mobile App to enable game notifications on your phone.")
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary20
                                horizontalAlignment: Text.AlignLeft
                                wrapMode: Text.Wrap
                            }
                            Text {
                                text: qsTranslate("QObject", "No Device Linked")
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.warning
                                horizontalAlignment: Text.AlignRight
                                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                                Layout.maximumWidth: 120
                                Layout.fillHeight: true
                                wrapMode: Text.Wrap
                                visible: pDevicesRefreshed && pMobileDeviceCount <= 0
                            }
                        }
                        UiTextUrl {
                            text: "<a href=\"javascript:void(0)\">"+qsTranslate("QObject", "How to link")+"</a>"
                            font:  UiTheme.fonts.bodySmall
                            color: UiTheme.colors.primary30
                            linkColor: UiTheme.colors.accentNormal
                            wrapMode: Text.Wrap
                            Layout.alignment: Qt.AlignLeft
                            visible: pMobileDeviceCount <= 0
                            onLinkActivated: uiBackend.openHelpArticle("How_To_Link_Devices_Help")
                        }
                    }

                    ListView {
                        id: iLinkedDevicesList
                        Layout.fillWidth: true
                        model: plrBackend.pMobileDeviceViewModel
                        spacing: 4
                        orientation: ListView.Vertical
                        interactive: false
                        implicitHeight: contentHeight
                        visible: iMobileNotificationsToggleBtn.checked && pMobileDeviceCount > 0

                        delegate: UiRowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 44
                            UiImage {
                                asset: "MobileDevice"
                                pImageWidth: 35
                                pImageHeight: 35
                                Layout.alignment: Qt.AlignVCenter
                            }
                            UiColumnLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 35
                                Layout.leftMargin: 6
                                UiRowLayout {
                                    spacing: 6
                                    Rectangle {
                                        color: "#7AC143"
                                        width: 8
                                        height: 8
                                        radius: width / 2
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    Text {
                                        text: model.name
                                        Layout.fillWidth: true
                                        font: UiTheme.fonts.bodyLarge
                                        color: UiTheme.colors.primary20
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignVCenter
                                    }
                                }
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }
                }


                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: plrBackend.pPushNotificationSettingVisible
                    UiRowLayout {
                        Layout.fillWidth: true
                        UiRowLayout {
                            spacing: 8
                            Text {
                                text: qsTranslate("QObject", "Windows Push Notifications")
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary10
                                horizontalAlignment: Text.AlignLeft
                            }
                            UiImageButton {
                                asset: "MenuHelp"
                                pImageWidth: 16
                                pImageHeight: 16
                                UiToolTip.text: qsTranslate("QObject", "Help")
                                onClicked: uiBackend.openHelpArticle("Push_Notifications_Help")
                                pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }
                        }
                        UiRowLayout {
                            id: iPushNotificationButton
                            spacing: 2
                            Layout.alignment: Qt.AlignRight
                            color: UiTheme.colors.accentNormal
                            leftPadding: 8
                            rightPadding: 8
                            topPadding: 5
                            bottomPadding: 5

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: qsTranslate("QObject", "Manage")
                                font: UiTheme.fonts.titleSmallest
                                color: UiTheme.colors.primary10
                                elide: Text.ElideRight
                            }
                            UiImage {
                                asset: "LinkBright"
                                pImageWidth: 12
                                pImageHeight: 12
                            }

                            pMouseArea {
                                anchors.fill: iPushNotificationButton
                                enabled: true
                                hoverEnabled: true

                                onEntered: iPushNotificationButton.color = UiTheme.colors.accentHover
                                onExited: iPushNotificationButton.color = UiTheme.colors.accentNormal
                                onClicked: {
                                    iPushNotificationButton.color = UiTheme.colors.accentClick
                                    if (false == plrBackend.runBlueStacksServicesNotificationManager())
                                        iSettingsWindow.fShowToast(qsTranslate("QObject", "Cannot manage notifications as BlueStacks Services is not installed."))
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                    visible: plrBackend.pPushNotificationSettingVisible
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        text: qsTranslate("QObject", "Media folder")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                        horizontalAlignment: Text.AlignLeft
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            id: iMediaFolderPath
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }

                        UiButton {
                            pSize: UiTheme.buttons.sizes.small
                            pColor: UiTheme.buttons.colors.tertiary
                            text: qsTranslate("QObject", "Change path")
                            onClicked: {
                                var currentPath = plrBackend.getMediaFolder()
                                currentPath = currentPath.replace(/\\/g, "/")
                                currentPath = "file:///"+currentPath
                                iSelectMediaFolderDialog.currentFolder = currentPath
                                iSelectMediaFolderDialog.open()
                            }
                        }
                    }

                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Allow %1 to access Windows Pictures and Documents folders").arg(uiBackend.productName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                        }
                        UiToggleButton {
                            id: iCanAccessWindowFolderCb
                            onCheckedChanged: {
                                plrBackend.setAccessWindowsFolder(checked)
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
            Layout.preferredHeight: 36

            UiButton{
                Layout.alignment: Qt.AlignRight
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Save changes")
                opacity: pEnableSave ? 1 : 0.4
                enabled: pEnableSave
                onClicked: {
                    var aiHighlightEnableChanged = false
                    if (!iEnableProgrammaticAdsBtn.checked) {
                        adsBackend.closeBannerAds()
                    }

                    if(uiBackend.confIsPropModified("bst.shared_folders"))
                    {
                        iSaveChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    }
                    else
                    {
                        if(uiBackend.confIsPropModified("bst.enable_programmatic_ads"))
                        {
                            plrBackend.enableAndroidAds(iEnableProgrammaticAdsBtn.checked)
                            uiBackend.sendSettingStats("preferences", "allow_programmatic_ads", iEnableProgrammaticAdsBtn.checked ? "enabled" : "disabled")
                        }

                        if(uiBackend.confIsPropModified("bst.launch_store_on_boot"))
                        {
                            uiBackend.sendSettingStats("preferences", "launch_store_on_boot", iEnableBluestacksStoreBtn.checked ? "enabled" : "disabled")
                        }

                        if(uiBackend.confIsPropModified("bst.enable_auto_upload_recording"))
                        {
                            uiBackend.sendSettingStats("preferences", "auto_upload_recording", iEnableUploadRecBtn.checked ? "enabled" : "disabled")
                        }

                        if(uiBackend.confIsPropModified("bst.enable_discord_integration"))
                            plrBackend.discordSettingToggle()

                        if(uiBackend.confIsPropModified("bst.enable_sigin_gamelaunch"))
                            plrBackend.toggleSignInOnGameLaunchPopup(iEnableGoogleSignInBtn.checked)

                        if(uiBackend.confIsInstancePropModified("android_sound_while_tapping")){
                            plrBackend.androidSoundWhileTappingToggle(iEnableAndroidSoundBtn.checked)
                        }

                        if (uiBackend.confIsInstancePropModified("enable_mobile_notifications")) {
                            plrBackend.sendMobileNotificationPreference("app_player_settings", iMobileNotificationsToggleBtn.checked)
                        }

                        if (uiBackend.confIsPropModified("bst.enable_ai_highlights")) {
                            aiHighlightEnableChanged = true
                            plrBackend.sendMomentsStats("ai_highlights", iEnableAIHighlightsBtn.checked ? "enabled" : "disabled")
                        }

                        if (uiBackend.confIsPropModified("bst.locale")){
                            plrBackend.setPlayerLocale(pOldLocale, uiBackend.confGetString("bst.locale"))
                            uiBackend.confSetString("bst.locale", pOldLocale)
                            uiBackend.confCommit()
                        }
                        else
                        {
                            uiBackend.confCommit()
                            fInitUi()
                            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
                        }

                        if (aiHighlightEnableChanged)
                            plrBackend.reloadConfInAllInstances()

                    }
                }
            }
        }
    }

    function fInitUi() {
        var lang = uiBackend.confGetString("bst.locale")
        pDefaultLangIdx = pLocaleList.indexOf(lang)
        iLanguageCombobox.currentIndex = pDefaultLangIdx
        iEscFullScreenToggleBtn.checked = uiBackend.confGetBool("bst.enable_esc_fullscreen")
        iEscMouseCursorToggleBtn.checked = uiBackend.confGetBool("bst.enable_esc_mousecursor")
        iNotificationsToggleBtn.checked = uiBackend.confGetInstanceBool("enable_notifications")
        iAutoHideNotificationsToggleBtn.checked = uiBackend.confGetInstanceBool("autohide_notifications")
        iDiscordToggleBtn.checked = uiBackend.confGetBool("bst.enable_discord_integration")
        iAppShortcutToggleBtn.checked = uiBackend.confGetBool("bst.create_desktop_shortcuts")
        iEnableGoogleSignInBtn.checked = uiBackend.confGetBool("bst.enable_sigin_gamelaunch")
        iMediaFolderPath.text =   plrBackend.getMediaFolder()
        iCanAccessWindowFolderCb.checked = plrBackend.canAccessWindowsFolder()
        iEnableAndroidSoundBtn.checked = uiBackend.confGetInstanceBool("android_sound_while_tapping")
        iEnableProgrammaticAdsBtn.checked = uiBackend.confGetBool("bst.enable_programmatic_ads")
        pDefaultEnableProgrammaticAds = uiBackend.confGetBool("bst.enable_programmatic_ads")
        iEnableBluestacksStoreBtn.checked = uiBackend.confGetBool("bst.launch_store_on_boot")
        iEnableBluestacksBannerBtn.checked = uiBackend.confGetBool("bst.enable_boot_banner")
        iEnableUploadRecBtn.checked =  uiBackend.confGetBool("bst.enable_auto_upload_recording")
        iEnableAIHighlightsBtn.checked = uiBackend.confGetBool("bst.enable_ai_highlights")

        if (uiBackend.confGetBool("bst.feature.enable_mobile_notification")) {
            iMobileNotificationsToggleBtn.visible = uiBackend.confGetInstanceBool("nowbux_signin_completed")
            if (uiBackend.confGetInstanceI32("enable_mobile_notifications") > 0 && uiBackend.confGetInstanceBool("nowbux_signin_completed"))
                iMobileNotificationsToggleBtn.checked = true
        }
        pMobileDeviceCount = plrBackend.getLinkedMobileDevicesCount()

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

    function fLoadNewSettings() {
        fInitUi()
    }

    function fPreferenceSettingChangedClbk(status) {
        if (0 === status) {
            pOldLocale = uiBackend.confGetString("bst.locale")
            iSettingsWindow.fShowToast(qsTranslate("QObject", "Changes saved"))
        }
        else {
            iSettingsWindow.fShowToast(qsTranslate("QObject", "Failed to change language"))
        }
        fSetPreviousState()
    }

    function fShowDiscardChangesPrompt() {
        iDiscardChangesPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
    }

    function fDiscardChanges() {
        uiBackend.confDiscard()
        fInitUi()
        iSettingsWindow.fSwitchSettingPanel()
    }

    function fMobileDeviceListUpdated(count) {
        pDevicesRefreshed = true
        pMobileDeviceCount = count
        iDeviceRefreshBtn.visible = true
        iLinkedDevicesList.forceLayout()
    }

    function fToggleMobileNotificationPreference(isVisible, isChecked) {
        iMobileNotificationsToggleBtn.visible = isVisible
        iMobileNotificationsToggleBtn.checked = isChecked
    }
}
