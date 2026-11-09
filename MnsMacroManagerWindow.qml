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
import QtQuick.Shapes 1.12
import Qt.labs.platform 1.1
import QtQml.Models 2.15

import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0
import UiHelper 1.0

Window {
    id: iMacroManagerWindow
    objectName: "iMacroManagerWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTranslate("QObject", "%1 macro manager")
    width: 640 + 2 * iShadow.shadowThickness
    height: 360 + 2 * iShadow.shadowThickness
    minimumHeight: 360 + 2 * iShadow.shadowThickness

    property bool pIsAnyRowPresent: iOrganizationListView.count > 0 ? true : false
    property bool pAnyMacroMatch: true
    property var loadingScreen
    property string pRunningMacroName: ""
    property var pDeletingMacro
    property UiWindowedPopup hamburgerWin: null
    property ListModel pMacroList: ListModel {}
    property var pToastErrorMessagesList: [
        [qsTranslate("QObject", "The macro loop must be run atleast once"), false],
        [qsTranslate("QObject", "No timer set to run macro"), false],
        [qsTranslate("QObject", "A macro with same name already exists"), true],
        [qsTranslate("QObject", "Field cannot be left empty"), true],
        [qsTranslate("QObject", "Macro name cannot contain following characters") + " \\ / | ? * < > : \"", true],
        [qsTranslate("QObject", "No operation was performed"), false],
        [qsTranslate("QObject", "Please stop the currently running macro to launch another one"), false],
        [qsTranslate("QObject", "%1 macros imported successfully."), false],
        [qsTranslate("QObject", "Macros exported successfully."), false],
        [qsTranslate("QObject", "Cannot import macro file"), true],
        [qsTranslate("QObject", "This is a reserved file name"), true],
        [qsTranslate("QObject", "%1 macro imported successfully."), false],
        [qsTranslate("QObject", "Macro unified successfully"), false],
        [qsTranslate("QObject", "A folder with same name already exists"), true],
        [qsTranslate("QObject", "You cannot create more sub-folders"), true],
        [qsTranslate("QObject", "Folder name cannot contain following characters") + " \\ / | ? * < > : \"", true]
    ]

    signal stopMacro()
    signal pauseMacro()
    Component.onCompleted: {
        mnsBackend.onMacroWindowLoaded()
    }

    onClosing: {
        fSaveMacroWindowGeometry()
        iMacroManagerWindow.destroy()
        if (!mnsBackend.isMacroPlayingOrRecording()) {
            plrBackend.resetSplitAdsState()
        }
    }

    function fSaveMacroWindowGeometry(){
        var macroScreen = screen.name
        var macroX = iMacroManagerWindow.x - screen.virtualX
        var macroY = iMacroManagerWindow.y - screen.virtualY
        uiBackend.confSetInstanceI32("macro_win_x", macroX)
        uiBackend.confSetInstanceI32("macro_win_y", macroY)
        uiBackend.confSetInstanceI32("macro_win_height", iMacroManagerWindow.height)
        uiBackend.confSetInstanceString("macro_win_screen", macroScreen);
        uiBackend.confCommit();
    }

    function fAdjustLocation() {
        if(iMacroManagerWindow.x < screen.virtualX)
            iMacroManagerWindow.x = screen.virtualX
        if((screen.virtualX + screen.width) < (iMacroManagerWindow.x + iMacroManagerWindow.width))
            iMacroManagerWindow.x = screen.virtualX + screen.width - iMacroManagerWindow.width

        if(iMacroManagerWindow.y < screen.virtualY)
            iMacroManagerWindow.y = screen.virtualY
        if((screen.virtualY + screen.height) < (iMacroManagerWindow.y + iMacroManagerWindow.height))
            iMacroManagerWindow.y = screen.virtualY + screen.height - iMacroManagerWindow.height
    }

    function fGoToAllMacroTab() {
        mnsBackend.pMacroViewModel.switchTab(0)
    }

    function fOnCloseOperation() {
        mnsBackend.onCloseMacroManagerWindow()
    }

    Component {
        id: iLoadingScreenComponent
        UiLoadingScreen {
            pText:  qsTranslate("QObject", "Processing macros")
        }
    }

    Component {
        id: iDeleteMacroPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Delete Macro")
            pDescription: qsTranslate("QObject", "Would you like to delete selected macro ?")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject", "Delete")
                        onClicked: {
                            mnsBackend.onMacroDeleteClick(pDeletingMacro)
                            pDeletingMacro = undefined
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            pDeletingMacro = undefined
                            close()
                        }
                    }
                ]
            }
            pCheckBoxText: qsTranslate("QObject", "Do not show again")
            onCheckBoxClicked: {
                uiBackend.confSetBool("bst.show_macro_delete_warning", !checked)
                uiBackend.confCommit()
            }
        }
    }

    Component {
        id: iDeleteDependentMacroPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Delete a dependent macro?")
            pDescription: qsTranslate("QObject", "The macro you are trying to delete is currently in use by another macro(s). Continuing to delete %1 will result in other macro(s) losing their configurability.").arg(pDeletingMacro)
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject", "Delete anyway")
                        onClicked: {
                            mnsBackend.onMacroDeleteClick(pDeletingMacro)
                            pDeletingMacro = undefined
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Don’t delete")
                        onClicked: {
                            pDeletingMacro = undefined
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iDeleteMacroFolderPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Delete folder?")
            pDescription: qsTranslate("QObject", "Are you sure you want to delete this folder?")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject", "Delete")
                        onClicked: {
                            mnsBackend.onMacroDeleteClick(pDeletingMacro)
                            pDeletingMacro = undefined
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            pDeletingMacro = undefined
                            close()
                        }
                    }
                ]
            }
            pCheckBoxText: qsTranslate("QObject", "Do not show again")
            onCheckBoxClicked: {
                uiBackend.confSetBool("bst.show_macro_folder_delete_warning", !checked)
                uiBackend.confCommit()
            }
        }
    }

    Component {
        id: iHamburgerMenuComponent
        UiWindowedPopup {
            id: iHamburgerMenu
            contentWidth: iHamburgerMenuLayout.implicitWidth
            contentHeight: iHamburgerMenuLayout.implicitHeight
            visible: false

            UiColumnLayout {
                id: iHamburgerMenuLayout
                anchors.left: parent.left
                anchors.right: parent.right
                topPadding: 2
                bottomPadding: 2
                color: UiTheme.colors.primary80
                border.width: 1
                border.color: UiTheme.colors.primary60

                UiImageLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    pText: qsTranslate("QObject", "Export macro")
                    pImageAsset: "Export"
                    leftPadding: 12
                    rightPadding: 12
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    enabled: !pIsMacroRunning & mnsBackend.pMacroViewModel.isAnyMacroPresent
                    opacity: enabled ? 1 : 0.4
                    onClicked:{
                        fOpenExportWindow()
                    }
                }
                UiImageLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    pText: qsTranslate("QObject", "Import macro")
                    pImageAsset: "Import"
                    leftPadding: 12
                    rightPadding: 12
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    enabled: !pIsMacroRunning
                    opacity: enabled ? 1 : 0.4
                    onClicked:{
                        fGoToAllMacroTab()
                        iHamburgerMenu.close()
                        iFileDialog.open()
                    }
                }
                UiImageLabel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    pText: qsTranslate("QObject", "Macro folder")
                    pImageAsset: "Folder"
                    leftPadding: 12
                    rightPadding: 12
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        iHamburgerMenu.close()
                        mnsBackend.onOpenMacroFolderClick()
                    }
                }
            }
        }
    }

    FileDialog {
        id: iFileDialog
        title: "Select files"
        nameFilters:  ["JSON files (*.json)"]
        fileMode: FileDialog.OpenFiles
        visible: false
        acceptLabel: qsTranslate("QObject", "Import")
        onAccepted: {
            iFileDialog.close()
            loadingScreen = iLoadingScreenComponent.createObject(iMacroManagerWindow)
            loadingScreen.show()
            mnsBackend.setImportMacrosModel(currentFiles);
        }
    }

    UiShadowContainer {
        id: iShadow
        UiColumnLayout {
            padding: 1
            anchors.fill: parent
            color: UiTheme.colors.primary80
            border.width: 1
            border.color: UiTheme.colors.primary60

            UiRowLayout {
                id: iTopbar
                Layout.fillWidth: true
                focus: true
                color: UiTheme.colors.primary70
                leftPadding: 12
                pMouseArea {
                    enabled: true
                    anchors.fill: iTopbar
                    property var startingPosition
                    property bool isPressed: false

                    onPressed: function(mouse) {
                        iTopbar.forceActiveFocus()
                        isPressed = true
                        startingPosition  = Qt.point(mouse.x, mouse.y)
                    }
                    onReleased: {
                        isPressed = false
                        if ( iMacroManagerWindow.y < Screen.virtualY) {
                            iMacroManagerWindow.y = Screen.virtualY
                        }
                    }
                    onPositionChanged: function(mouse) {
                        if (isPressed) {
                            var delta = Qt.point(mouse.x - startingPosition.x, mouse.y - startingPosition.y)
                            iMacroManagerWindow.x += delta.x
                            iMacroManagerWindow.y += delta.y
                        }
                    }
                }

                UiRowLayout{
                    spacing: 8
                    UiImage {
                        asset: "MacroSimple"
                        pImageWidth: 20
                        pImageHeight: 20
                    }
                    Text {
                        text: qsTranslate("QObject", "%1 macro manager").arg(uiBackend.productName)
                        color:  UiTheme.colors.primary10
                        font : UiTheme.fonts.titleExtraSmall
                    }
                }

                UiRowLayout{
                    Layout.alignment: Qt.AlignRight
                    UiImageButton {
                        asset: "TitlebarHelp"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Help")
                        onClicked: uiBackend.openHelpArticle("Macro_Help")
                    }
                    UiImageButton {
                        id: iCfgBtn
                        asset: "TitlebarMenu"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Options")
                        onPressed: fOpenHamburgerPopup()
                    }
                    UiImageButton {
                        asset: "TitlebarClose"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Close")
                        onClicked: {
                            mnsBackend.pMacroViewModel.searchString("")
                            mnsBackend.onCloseMacroManagerWindow()
                            iMacroManagerWindow.close()
                        }
                    }
                }
            }

            UiRowLayout{
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 8
                leftPadding: 12
                rightPadding: 12
                UiButton {
                    text: qsTranslate("QObject", "Record new macro")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.accent
                    asset: "Record"
                    enabled: !pIsMacroRunning
                    opacity: enabled ? 1 : 0.4
                    onClicked: {
                        fGoToAllMacroTab()
                        mnsBackend.onMacroRecordClick()
                        mnsBackend.pMacroViewModel.searchString("")
                        iMacroManagerWindow.close()
                    }
                }
                UiButton {
                    asset: "Schedule"
                    text: qsTranslate("QObject", "Scheduler")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.tertiary
                    enabled: !pIsMacroRunning & mnsBackend.pMacroViewModel.isAnyMacroPresent
                    opacity: enabled ? 1 : 0.4
                    onClicked:
                    {
                        var component = Qt.createComponent("MnsMacroSchedulerWindow.qml");
                        if (component.status === Component.Ready) {
                            component.createObject(iMacroManagerWindow).show()
                        }
                    }
                }
                UiRowLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: 8
                    Layout.fillWidth: true
                    UiImageButton {
                        asset: "Merge"
                        enabled: !pIsMacroRunning & mnsBackend.pMacroViewModel.isAnyMacroPresent
                        pImageWidth: 16
                        pImageHeight: 16
                        UiToolTip.text: qsTranslate("QObject", "Merge macros")
                        onClicked: {
                            fGoToAllMacroTab()
                            var macrosAvailableToMergeList = mnsBackend.pMacroViewModel.allowedMergeConfigrations(-1)
                            var component = Qt.createComponent("MnsMergeMacroWindow.qml");
                            if (component.status === Component.Ready) {
                                component.createObject(iMacroManagerWindow, {
                                                           "pCurrentMergeMacroName": mnsBackend.getNewMacroName(),
                                                           "pMacrosAvailableToMergeListModel" : macrosAvailableToMergeList
                                                       }).show()
                            }
                        }
                    }
                    UiImageButton {
                        asset: "NewFolder"
                        enabled: !pIsMacroRunning & mnsBackend.pMacroViewModel.isAnyMacroPresent
                        pImageWidth: 16
                        pImageHeight: 16
                        UiToolTip.text: qsTranslate("QObject", "Create folder")
                        onClicked:
                        {
                            fGoToAllMacroTab()
                            mnsBackend.addNewFolder()
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    UiTextImageField {
                        Layout.preferredWidth: 160
                        pAsset: "Search"
                        color: UiTheme.colors.primary10
                        pSize: UiTheme.textFields.sizes.small
                        pReadOnly: false
                        placeholderText: qsTranslate("QObject", "Search")
                        placeholderTextColor: UiTheme.colors.primary20
                        onTextChanged: fSearchString()
                        Keys.onReturnPressed: fSearchString()
                        onClicked: {    
                            fSearchString()
                            pReadOnly = false
                        }

                        function fSearchString() {
                            fGoToAllMacroTab()
                            if (!mnsBackend.pMacroViewModel.searchString(text)) {
                                pInputValidationState = UiTextField.InputValidation.Error
                                pAnyMacroMatch = false
                            }
                            else {
                                pInputValidationState = UiTextField.InputValidation.Valid
                                pAnyMacroMatch = true
                            }
                        }
                    }
                }
            }

            UiRowLayout {
                id: iKeyControlSwitchRow
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 13
                Layout.bottomMargin: 5
                spacing: 13

                Rectangle {
                    id: iAllmacrosRect
                    Layout.leftMargin: 4
                    Layout.preferredHeight: 21
                    implicitWidth: iAllMacrosRowLayout.implicitWidth
                    color: UiTheme.colors.primary80
                    focus: true
                    UiColumnLayout {
                        UiRowLayout{
                            id: iAllMacrosRowLayout
                            UiImage{
                                asset: "All_macros"
                                pImageWidth: 16
                                pImageHeight: 16
                            }
                            UiText {
                                Layout.margins: 5
                                Layout.alignment: Qt.AlignCenter
                                font: UiTheme.fonts.titleSmallest
                                text: qsTranslate("QObject", "All macros")
                                color: (mnsBackend.pMacroViewModel.pTabIndex === 0) ? UiTheme.colors.primary20 : UiTheme.colors.primary30
                            }
                        }
                        Rectangle {
                            id: iAllmacrosRectLine
                            Layout.alignment: Qt.AlignBottom
                            width: iAllMacrosRowLayout.width
                            height: 1
                            color: (mnsBackend.pMacroViewModel.pTabIndex === 0) ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                        }
                    }
                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            iAllmacrosRect.forceActiveFocus()
                            mnsBackend.pMacroViewModel.switchTab(0)
                        }
                    }
                }

                Rectangle {
                    id: iRecentmacroRect
                    Layout.leftMargin: 4
                    Layout.preferredHeight: 21
                    color: UiTheme.colors.primary80
                    implicitWidth: iRecentsRowLayout.implicitWidth
                    focus: true
                    UiColumnLayout {
                        UiRowLayout{
                            id: iRecentsRowLayout
                            UiImage{
                                asset: "Recent"
                                pImageWidth: 16
                                pImageHeight: 16
                            }

                            UiText {
                                Layout.margins: 5
                                Layout.alignment: Qt.AlignCenter
                                font: UiTheme.fonts.titleSmallest
                                text: qsTranslate("QObject", "Recent")
                                color: (mnsBackend.pMacroViewModel.pTabIndex === 1) ? UiTheme.colors.primary20 : UiTheme.colors.primary30
                            }
                        }
                        Rectangle {
                            id: iRecentmacroRectLine
                            Layout.alignment: Qt.AlignBottom
                            width: iRecentsRowLayout.width
                            height: 1
                            color: (mnsBackend.pMacroViewModel.pTabIndex === 1) ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                        }
                    }

                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked:{
                            iRecentmacroRect.forceActiveFocus()
                            mnsBackend.pMacroViewModel.switchTab(1)
                        }
                    }
                }

                Rectangle {
                    id: iMacroLogsRect
                    Layout.leftMargin: 4
                    Layout.preferredHeight: 21
                    color: UiTheme.colors.primary80
                    implicitWidth: iLogsRowLayout.implicitWidth
                    focus: true
                    UiColumnLayout {
                        UiRowLayout{
                            id: iLogsRowLayout
                            UiImage{
                                asset: "Log"
                                pImageWidth: 16
                                pImageHeight: 16
                            }

                            UiText {
                                Layout.margins: 5
                                Layout.alignment: Qt.AlignCenter
                                font: UiTheme.fonts.titleSmallest
                                text: qsTranslate("QObject", "Logs")
                                color: (mnsBackend.pMacroViewModel.pTabIndex === 2) ? UiTheme.colors.primary20 : UiTheme.colors.primary30
                            }
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignBottom
                            width: iLogsRowLayout.width
                            height: 1
                            color: (mnsBackend.pMacroViewModel.pTabIndex === 2) ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                        }
                    }

                    MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked:{
                            iMacroLogsRect.forceActiveFocus()
                            mnsBackend.pMacroViewModel.switchTab(2)
                        }
                    }
                }
            }

            Rectangle {
                height: 1
                color: UiTheme.colors.primary60
                Layout.fillWidth: true
                Layout.bottomMargin: 13
            }

            UiRowLayout {
                visible: {
                    pAnyMacroMatch &
                    pIsAnyRowPresent &
                    (mnsBackend.pMacroViewModel.pTabIndex === 0 | mnsBackend.pMacroViewModel.isAnyRecentMacroPresent) &
                    (mnsBackend.pMacroViewModel.pTabIndex !== 2)
                }
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                Layout.minimumWidth: 581
                leftPadding: 12
                rightPadding: 12
                Text {
                    Layout.preferredWidth: 263
                    Layout.minimumWidth: 74
                    text: qsTranslate("QObject", "Macro name")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 79
                    text: qsTranslate("QObject", "Info")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.preferredWidth: 136
                    text: qsTranslate("QObject", "Shortcut")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
                Text {
                    Layout.preferredWidth: 139
                    Layout.alignment: Qt.AlignRight
                    text: qsTranslate("QObject", "Actions")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
            }

            UiRowLayout {
                visible: pAnyMacroMatch & (mnsBackend.pMacroViewModel.pTabIndex === 2)
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                Layout.minimumWidth: 581
                leftPadding: 12
                rightPadding: 12
                spacing: 8
                Text {
                    Layout.preferredWidth: 154
                    text: qsTranslate("QObject", "TIME STAMP")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.preferredWidth: 165
                    text: qsTranslate("QObject", "ACTIVITY")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.preferredWidth: 165
                    text: qsTranslate("QObject", "SOURCE")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "STATUS")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
            }

            Rectangle {
                id: iRectRoot
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ListView {
                    id: iOrganizationListView
                    visible: pIsAnyRowPresent & pAnyMacroMatch & (mnsBackend.pMacroViewModel.pTabIndex !== 2)
                    anchors.fill: parent
                    clip: true
                    cacheBuffer: 2000 // max 50 delegates are cached in either direction
                    boundsMovement: Flickable.StopAtBounds
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: UiScrollBar {
                        policy: iOrganizationListView.contentHeight > iOrganizationListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    Connections {
                        target: mnsBackend.pMacroViewModel
                        function onScrollToViewEnd() {
                            Qt.callLater(iOrganizationListView.positionViewAtEnd)
                        }
                    }

                    model: DelegateModel {
                        model: mnsBackend.pMacroViewModel
                        delegate: Component {

                            Item {
                                id: iDragItem
                                visible: isVisible
                                anchors.left: parent != null ? parent.left : undefined
                                anchors.right: parent != null ? parent.right : undefined
                                height: visible ? iContentRect.height : 0
                                onYChanged: {
                                    pMoveDown = pLastY < y;
                                    pLastY = y;
                                }
                                enabled: !pIsMacroRunning | (pRunningMacroName === model.name)
                                opacity: enabled ? 1 : 0.4

                                property bool pHeld: false
                                property int pLastY: 0
                                property bool pMoveDown: false

                                Rectangle {
                                    id:iContentRect
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    color: iInstanceMouseArea.containsMouse
                                           ? UiTheme.colors.primary60
                                           : model.oddColor ? UiTheme.colors.primary70 : UiTheme.colors.primary90
                                    height: 40

                                    Drag.active: iDragItem.pHeld
                                    Drag.source: iDragItem
                                    Drag.hotSpot.x: width / 2
                                    Drag.hotSpot.y: height / 2
                                    states: State {
                                        when: iDragItem.pHeld
                                        ParentChange { target: iContentRect; parent: iOrganizationListView }
                                        AnchorChanges { target: iContentRect; anchors.left: undefined; anchors.right: undefined }
                                        PropertyChanges { target: iContentRect; color: UiTheme.colors.primary80 }
                                    }

                                    MouseArea {
                                        id:iInstanceMouseArea
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        onClicked: forceActiveFocus()
                                        onEntered: {
                                            model.isNew = false;
                                        }

                                        UiRowLayout {
                                            anchors.fill: parent
                                            leftPadding: 12
                                            rightPadding: 12
                                            UiImageButton {
                                                id: iFolderIcon
                                                asset: model.folderOpen & model.anyChild ? "OpenFolder" : "Folder"
                                                visible: isFolder & model.anyChild
                                                pImageWidth: 12
                                                pImageHeight: 12
                                                Layout.rightMargin: 8
                                                Layout.leftMargin: mnsBackend.pMacroViewModel.isSearchMode ? 0 : (model.nestingLevel * 20)
                                                UiToolTip.text: model.folderOpen & model.anyChild ? qsTranslate("QObject", "Collapse folder") : qsTranslate("QObject", "Open folder")
                                                onClicked: {
                                                    mnsBackend.pMacroViewModel.collapseFolder(index, (asset === "Folder"))
                                                }
                                            }
                                            UiImage {
                                                asset: iFolderIcon.asset
                                                visible: isFolder & !model.anyChild
                                                pImageWidth: 12
                                                pImageHeight: 12
                                                Layout.rightMargin: 8
                                                Layout.leftMargin: mnsBackend.pMacroViewModel.isSearchMode ? 0 : (model.nestingLevel * 20)
                                            }
                                            UiRowLayout {
                                                Layout.preferredWidth: 262 - (mnsBackend.pMacroViewModel.isSearchMode ? 0 : (model.nestingLevel * 20))
                                                Layout.leftMargin: model.isFolder ? 0 : (mnsBackend.pMacroViewModel.isSearchMode ? 0 : (model.nestingLevel * 20))
                                                UiRowLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4
                                                    visible: iMacroNameTextfield.pReadOnly
                                                    Text {
                                                        text: model.isFolder ? uiBackend.translateFolderName(model.name) : model.name
                                                        color: UiTheme.colors.primary10
                                                        font: UiTheme.textFields.sizes.small.textFont
                                                        Layout.maximumWidth: 222 + (model.isNew ? 0 : 10)
                                                        elide: Text.ElideRight
                                                    }
                                                    Rectangle {
                                                        visible: model.isNew
                                                        Layout.preferredHeight: 6
                                                        Layout.preferredWidth: 6
                                                        radius: 3
                                                        color: UiTheme.colors.dangerNormal
                                                    }
                                                    Item {
                                                        Layout.fillWidth: true
                                                    }
                                                    UiImageButton {
                                                        Layout.alignment: Qt.AlignRight
                                                        Layout.rightMargin: 8
                                                        asset: "EditIcon"
                                                        UiToolTip.text: qsTranslate("QObject", "Rename")
                                                        pImageWidth: 12
                                                        pImageHeight: 12
                                                        visible: !pIsMacroRunning && iInstanceMouseArea.containsMouse && iMacroNameTextfield.pReadOnly
                                                        onClicked:  {
                                                            if(asset ==="EditIcon"){
                                                                iMacroNameTextfield.pReadOnly = false
                                                                iMacroNameTextfield.forceActiveFocus()
                                                                iMacroNameTextfield.cursorPosition = iMacroNameTextfield.text.length
                                                            }
                                                        }
                                                    }
                                                }
                                                UiTextImageField {
                                                    visible: !pReadOnly
                                                    id: iMacroNameTextfield
                                                    Layout.fillWidth: true
                                                    Layout.rightMargin: 8
                                                    pAsset: "SaveSmall"
                                                    pSize: UiTheme.textFields.sizes.small
                                                    text: model.isFolder ? uiBackend.translateFolderName(model.name) : model.name
                                                    pReadOnly: true
                                                    pImageTooltip: qsTranslate("QObject", "Save")
                                                    onEditingFinished: {
                                                        iInstanceMouseArea.fRenameMacro()
                                                    }
                                                    onClicked: {
                                                        iInstanceMouseArea.fRenameMacro()
                                                    }
                                                }
                                            }
                                            Item {
                                                visible: isFolder
                                                Layout.fillWidth: true
                                            }

                                            UiRowLayout {
                                                Layout.alignment: Qt.AlignRight
                                                Layout.preferredWidth: 80
                                                spacing: 12
                                                visible: !isFolder
                                                UiImageButton {
                                                    asset: "InfoSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Created on: ") + model.creationTime
                                                }
                                                UiImageButton {
                                                    asset: "AutoStartSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    visible: model.isPlayOnStart
                                                    UiToolTip.text: qsTranslate("QObject", "Macro auto starts on %1 launch").arg(uiBackend.productName)
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                            }

                                            UiRowLayout {
                                                Layout.preferredWidth: 136
                                                visible: !isFolder
                                                Text {
                                                    font: UiTheme.fonts.bodySmall
                                                    color: UiTheme.colors.primary20
                                                }
                                                UiTextField {
                                                    property var finalShortcutInternal: model.shortcut
                                                    enabled: !pIsMacroRunning
                                                    opacity: enabled ? 1 : 0.4
                                                    Layout.preferredWidth: 100
                                                    pSize: UiTheme.textFields.sizes.small
                                                    pOpenErrorTemplate: activeFocus && pInputValidationState === UiTextField.InputValidation.Error
                                                    pErrorTemplateContent: qsTranslate("QObject", "This shortcut is already being used for another macro")
                                                    text: plrBackend.getDisplayComboFromNameCombo(model.shortcut)
                                                    UiHelper.inputMethodEditing: false
                                                    horizontalAlignment: Text.AlignHCenter

                                                    onActiveFocusChanged: {
                                                        if (activeFocus)
                                                            mnsBackend.setEditingShortcutMode(true)
                                                    }

                                                    onFocusChanged: {
                                                        if(focus)
                                                            selectAll()
                                                    }

                                                    onEditingFinished: {
                                                        if (pInputValidationState === UiTextField.InputValidation.Valid) {
                                                            model.shortcut = finalShortcutInternal
                                                            mnsBackend.updateMacroShortcut()
                                                        }
                                                        else {
                                                            pInputValidationState = UiTextField.InputValidation.Valid
                                                            finalShortcutInternal = model.shortcut
                                                        }

                                                        this.text = Qt.binding(function() {return plrBackend.getDisplayComboFromNameCombo(model.shortcut)})
                                                        mnsBackend.setEditingShortcutMode(false)
                                                    }

                                                    // Discard all shortcut events like Ctrl+A, Ctrl+C etc.
                                                    Keys.onShortcutOverride: function(event) { event.accepted = true }

                                                    // Discard Tab pressed as it'll move to the next field
                                                    Keys.onTabPressed: function(event) { event.accepted = true }

                                                    // Discard Esc pressed as it could move the focus out of the text field and have unwarranted behaviour
                                                    Keys.onEscapePressed: function(event) { event.accepted = true }

                                                    // Discard Enter and Space pressed
                                                    Keys.onEnterPressed: function(event) {
                                                        iInstanceMouseArea.forceActiveFocus()
                                                        event.accepted = true
                                                    }
                                                    Keys.onReturnPressed: function(event) {
                                                        iInstanceMouseArea.forceActiveFocus()
                                                        event.accepted = true
                                                    }
                                                    Keys.onSpacePressed: function(event) { event.accepted = true }

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
                                                            this.finalShortcutInternal = ""
                                                            pInputValidationState = UiTextField.InputValidation.Valid
                                                            return
                                                        }

                                                        if (event.key === Qt.Key_Control || event.key === Qt.Key_Alt
                                                                || event.key === Qt.Key_Shift || event.key === Qt.Key_CapsLock
                                                                || event.key === Qt.Key_Meta) {
                                                            return
                                                        }

                                                        var shortcutInternal = mnsBackend.getShortcutKeyPressed()
                                                        var displayShortcut = plrBackend.getDisplayComboFromNameCombo(shortcutInternal)

                                                        if (displayShortcut !== "") {
                                                            this.text = displayShortcut
                                                            this.finalShortcutInternal = shortcutInternal
                                                            if (shortcutInternal !== model.shortcut) {
                                                                pInputValidationState = mnsBackend.validateShortcut(shortcutInternal) ?
                                                                            UiTextField.InputValidation.Valid : UiTextField.InputValidation.Error
                                                            } else {
                                                                pInputValidationState = UiTextField.InputValidation.Valid
                                                            }
                                                        }
                                                    }
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                            }

                                            UiRowLayout {
                                                Layout.alignment: Qt.AlignRight
                                                spacing: 22
                                                visible: !pIsMacroRunning || (pRunningMacroName !== model.name)
                                                UiImageButton {
                                                    asset: "PlaySmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Play")
                                                    visible: !isFolder
                                                    onClicked: {
                                                        if (model.loopType === 0 && model.loopNumber < 1) {
                                                            iToast.pErrorToast = pToastErrorMessagesList[0][1]
                                                            iToast.fShow(pToastErrorMessagesList[0][0], 4000)
                                                        }
                                                        else if (model.loopType === 1 && model.loopTime < 1) {
                                                            iToast.pErrorToast = pToastErrorMessagesList[1][1]
                                                            iToast.fShow(pToastErrorMessagesList[1][0], 4000)
                                                        }
                                                        else {
                                                            mnsBackend.onMacroPlayClick(iMacroNameTextfield.text)
                                                            iMacroManagerWindow.close()
                                                        }
                                                    }
                                                }
                                                UiImageButton {
                                                    visible: !model.isMergeMacro & !isFolder
                                                    asset: "SettingsSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Settings")
                                                    onClicked: {
                                                        var component = Qt.createComponent("MnsMacroSettingsWindow.qml");
                                                        if (component.status === Component.Ready) {
                                                            var macroSettingsWindow = component.createObject(
                                                                        iMacroManagerWindow,
                                                                        {
                                                                            "pMacroIndex" : index,
                                                                            "pMacroDetails" : mnsBackend.pMacroViewModel.getMacroSettings(model.name)
                                                                        })
                                                            macroSettingsWindow.settingsSaved.connect(fMacroSettingsSaved);
                                                            macroSettingsWindow.show()
                                                        }
                                                    }
                                                }
                                                UiImageButton {
                                                    visible: model.isMergeMacro & !isFolder
                                                    asset: "MergeSettingsSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Settings")
                                                    onClicked: {
                                                        var component = Qt.createComponent("MnsMergeMacroWindow.qml");
                                                        if (component.status === Component.Ready) {
                                                            var macrosAvailableToMergeList = mnsBackend.pMacroViewModel.allowedMergeConfigrations(index)
                                                            var mergeConfigrationsListModel = mnsBackend.getMergeConfigrationListModel(index)
                                                            component.createObject(iMacroManagerWindow, {
                                                                                       "pCurrentMergeMacroIndex" : index,
                                                                                       "pCurrentMergeMacroName": model.name,
                                                                                       "pIsUpdateMergeMacro" : true,
                                                                                       "pMacrosAvailableToMergeListModel" : macrosAvailableToMergeList,
                                                                                       "pMergedMacrosListModel" : mergeConfigrationsListModel
                                                                                   }).show()
                                                        }
                                                    }
                                                }
                                                Rectangle {
                                                    width: 1
                                                    height: 18
                                                    color: UiTheme.colors.primary40
                                                }
                                                UiImageButton {
                                                    asset: "DeleteSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Delete")
                                                    onClicked: {
                                                        if (model.isDependentMacro)
                                                        {
                                                            pDeletingMacro = model.name
                                                            iDeleteDependentMacroPrompt.createObject(iMacroManagerWindow, { "transientParent": iMacroManagerWindow }).show()
                                                        }
                                                        else if(model.isFolder & uiBackend.confGetBool("bst.show_macro_folder_delete_warning"))
                                                        {
                                                            pDeletingMacro = model.name
                                                            iDeleteMacroFolderPrompt.createObject(iMacroManagerWindow, { "transientParent": iMacroManagerWindow }).show()
                                                        }
                                                        else if(!model.isFolder & uiBackend.confGetBool("bst.show_macro_delete_warning"))
                                                        {
                                                            pDeletingMacro = model.name
                                                            iDeleteMacroPrompt.createObject(iMacroManagerWindow, { "transientParent": iMacroManagerWindow }).show()
                                                        }
                                                        else
                                                        {
                                                            mnsBackend.onMacroDeleteClick(model.name)
                                                        }
                                                    }
                                                }
                                                UiImage {
                                                    id: iMoveIcon
                                                    asset: "MoveSmall" + (iMoveIconMouseArea.containsMouse ? "_hover" : "")
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Rearrange")
                                                    UiToolTip.visible: iDragItem.pHeld ? false
                                                                                       : iMoveIconMouseArea.containsMouse
                                                    enabled: !mnsBackend.pMacroViewModel.isSearchMode
                                                    opacity: mnsBackend.pMacroViewModel.pTabIndex === 0 ? 1 : 0

                                                    MouseArea {
                                                        id: iMoveIconMouseArea
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        drag.target: iDragItem.pHeld ? iContentRect : undefined
                                                        drag.axis: Drag.YAxis
                                                        property var pIndex
                                                        property var pWasOpen
                                                        property var pMoved
                                                        onPressed: {
                                                            pIndex = index
                                                            pWasOpen = model.folderOpen & model.anyChild
                                                            pMoved = -1
                                                            if (model.isFolder) {
                                                                mnsBackend.pMacroViewModel.collapseFolder(pIndex, false)
                                                            }

                                                            iDragItem.pHeld = true
                                                        }
                                                        onReleased: {
                                                            if (!mnsBackend.pMacroViewModel.dragComplete(pIndex, index, pWasOpen, pMoved > 0))
                                                            {
                                                                fShowMacroMessageToast(14)
                                                            }

                                                            iDragItem.pHeld = false
                                                        }
                                                        onPositionChanged: {
                                                            pMoved += 1
                                                        }
                                                    }
                                                }
                                            }
                                            UiRowLayout {
                                                Layout.preferredWidth: 164
                                                Layout.alignment: Qt.AlignRight
                                                visible: pIsMacroRunning && (pRunningMacroName === model.name)
                                                spacing: 22
                                                UiImageButton {
                                                    asset:  !pIsMacroPause ? "PauseSmall" : "PlaySmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text:  !pIsMacroPause ? qsTranslate("QObject", "Pause") :  qsTranslate("QObject", "Play")
                                                    onClicked: pauseMacro()
                                                }
                                                UiImageButton {
                                                    asset: "StopSmall"
                                                    pImageWidth: 12
                                                    pImageHeight: 12
                                                    UiToolTip.text: qsTranslate("QObject", "Stop")
                                                    onClicked: stopMacro()
                                                }
                                                Text {
                                                    Layout.fillHeight: true
                                                    text: !pIsMacroPause ? qsTranslate("QObject", "Running") : qsTranslate("QObject", "Paused")
                                                    font: UiTheme.fonts.bodyExtraSmall
                                                    color: UiTheme.colors.accentNormal
                                                    elide: Text.ElideRight
                                                }
                                            }
                                        }

                                        function fRenameMacro() {
                                            iMacroNameTextfield.pReadOnly= true;
                                            var trimmedNewName = iMacroNameTextfield.text.trim().replace("\n","")
                                            if(trimmedNewName !== "")
                                            {
                                                var err = mnsBackend.isMacroNameValid(trimmedNewName,index)
                                                if(err === 0) {
                                                    if (model.name !== trimmedNewName) {
                                                        mnsBackend.onRenameMacro(trimmedNewName,index)
                                                        model.name = trimmedNewName
                                                        iMacroNameTextfield.text = Qt.binding( function() { return model.name })
                                                    }
                                                }
                                                else {
                                                    iMacroNameTextfield.text = Qt.binding( function() { return model.name })
                                                    iToast.pErrorToast = pToastErrorMessagesList[err][1]
                                                    iToast.fShow(pToastErrorMessagesList[err][0], 4000)
                                                }
                                            }
                                            else {
                                                iMacroNameTextfield.text = Qt.binding( function() { return model.name })
                                                iToast.pErrorToast = pToastErrorMessagesList[3][1]
                                                iToast.fShow(pToastErrorMessagesList[3][0], 4000)
                                            }
                                        }
                                    }
                                }
                                DropArea {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    onEntered: function(drag) {
                                        mnsBackend.pMacroViewModel.moveRow(drag.source.DelegateModel.itemsIndex,
                                                                           iDragItem.DelegateModel.itemsIndex)

                                        if (iDragItem.pMoveDown)
                                            iOrganizationListView.currentIndex = iDragItem.DelegateModel.itemsIndex + parseInt(mnsBackend.pMacroViewModel.collpasedRows(iDragItem.DelegateModel.itemsIndex)) + 2
                                        else
                                            iOrganizationListView.currentIndex = iDragItem.DelegateModel.itemsIndex - 2 - parseInt(mnsBackend.pMacroViewModel.collpasedRows(iDragItem.DelegateModel.itemsIndex))
                                    }
                                    // onPositionChanged: function(drag) {
                                    //     iMoveIconMouseArea.pMoved += 1
                                    // }
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: iMacroLogsView
                    visible: pAnyMacroMatch & (mnsBackend.pMacroViewModel.pTabIndex === 2)
                    anchors.fill: parent
                    clip: true
                    cacheBuffer: 2000

                    ScrollBar.vertical: UiScrollBar {
                        policy: iMacroLogsView.contentHeight > iMacroLogsView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    model: DelegateModel {
                        model: mnsBackend.pMacroHistoryViewModel
                        delegate: Component {
                            Rectangle {
                                id: iLogsEntryRect
                                anchors.left: parent != null ? parent.left : undefined
                                anchors.right: parent != null ? parent.right : undefined
                                color: iLogsEntryMouseArea.containsMouse
                                       ? UiTheme.colors.primary60
                                       : model.oddColor ? UiTheme.colors.primary70 : UiTheme.colors.primary90
                                height: 40

                                MouseArea {
                                    id:iLogsEntryMouseArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    onClicked: forceActiveFocus()

                                    UiRowLayout {
                                        anchors.fill: parent
                                        leftPadding: 12
                                        rightPadding: 12
                                        spacing: 8
                                        Text {
                                            text: model.timestamp
                                            color: model.success ? UiTheme.colors.primary10 : UiTheme.colors.error
                                            font: UiTheme.textFields.sizes.small.textFont
                                            Layout.preferredWidth: 154
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignLeft
                                        }
                                        Text {
                                            text: model.activity
                                            color: model.success ? UiTheme.colors.primary10 : UiTheme.colors.error
                                            font: UiTheme.textFields.sizes.small.textFont
                                            Layout.preferredWidth: 165
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignLeft
                                        }
                                        Text {
                                            text: model.source
                                            color: model.success ? UiTheme.colors.primary10 : UiTheme.colors.error
                                            font: UiTheme.textFields.sizes.small.textFont
                                            Layout.preferredWidth: 165
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignLeft
                                        }

                                        Text {
                                            text: model.status
                                            color: model.success ? UiTheme.colors.primary10 : UiTheme.colors.error
                                            font: UiTheme.textFields.sizes.small.textFont
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            horizontalAlignment: Text.AlignLeft
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                UiColumnLayout {
                    spacing: 20
                    visible: !pIsAnyRowPresent & pAnyMacroMatch & (mnsBackend.pMacroViewModel.pTabIndex === 0)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    UiImage {
                        Layout.alignment: Qt.AlignHCenter
                        asset: "NoMacros"
                        pImageWidth: 64
                        pImageHeight: 64
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("QObject", "No macros")
                        color:  UiTheme.colors.primary10
                        font: UiTheme.fonts.titleMedium
                    }
                    Text {
                        Layout.preferredWidth: iRectRoot.width
                        Layout.maximumWidth: 316
                        horizontalAlignment: Text.AlignHCenter
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "Record or import macros to automate boring tasks in-game. You can also import macros from %1 4.").arg(uiBackend.productName)
                    }
                    UiRowLayout {
                        spacing: 16
                        Layout.alignment: Qt.AlignHCenter
                        UiButton {
                            text: qsTranslate("QObject", "Record")
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: UiTheme.buttons.colors.accent
                            asset: "Record"
                            onClicked: {
                                mnsBackend.onMacroRecordClick()
                                mnsBackend.pMacroViewModel.searchString("")
                                iMacroManagerWindow.close()
                            }
                        }
                        UiButton {
                            text: qsTranslate("QObject", "Import")
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: UiTheme.buttons.colors.secondary
                            asset: "Import_dark"
                            onClicked: iFileDialog.open()
                        }
                    }
                }

                UiColumnLayout {
                    spacing: 3
                    visible: pAnyMacroMatch & !mnsBackend.pMacroViewModel.isAnyRecentMacroPresent & (mnsBackend.pMacroViewModel.pTabIndex === 1)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("QObject", "No recent macros")
                        color:  UiTheme.colors.primary20
                        font: UiTheme.fonts.titleMedium
                    }
                    Text {
                        Layout.preferredWidth: iRectRoot.width
                        Layout.maximumWidth: 316
                        horizontalAlignment: Text.AlignHCenter
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary30
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "You haven't played any macros recently.")
                    }
                }

                UiColumnLayout {
                    spacing: 20
                    visible: !pAnyMacroMatch
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        Layout.preferredWidth: iRectRoot.width
                        Layout.topMargin: 64
                        Layout.maximumWidth: 316
                        horizontalAlignment: Text.AlignHCenter
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "No items match your search")
                    }
                }
            }
        }

        UiToast {
            id: iToast
            pMaximumWidth: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 32
            color: pErrorToast ? UiTheme.colors.dangerTranslucent : UiTheme.colors.overlayPrimary
            border.color: pErrorToast ? UiTheme.colors.dangerNormal : UiTheme.colors.primary50
            property bool pErrorToast: false
        }
    }

    function fImportMacros() {
        loadingScreen.close()
        loadingScreen.destroy()

        if(mnsBackend.pRenameImportMacroModel.rowCount() > 0 || mnsBackend.pInValidImportMacroModel.rowCount() > 0) {
            var component = Qt.createComponent("MnsMacroImportWindow.qml");
            if (component.status === Component.Ready) {
                component.createObject(iMacroManagerWindow).show();
            }
        } else {
            mnsBackend.importMacros()
            mnsBackend.clearImportMacroModels()
        }
    }

    function fShowMacroMessageToast(code) {
        iToast.pErrorToast = pToastErrorMessagesList[code][1]
        iToast.fShow(pToastErrorMessagesList[code][0], 4000)
    }

    function fShowMacroImportSuccessToast(code,count) {
        iToast.pErrorToast = pToastErrorMessagesList[code][1]
        iToast.fShow(pToastErrorMessagesList[code][0].arg(count), 4000)
    }

    function fMacroSettingsSaved(macroSettingsObj, macroIndex) {
        mnsBackend.onMacroSettingsSave(macroSettingsObj, macroIndex)
    }

    function fOpenHamburgerPopup() {
        if (hamburgerWin != null)
        {
            if (hamburgerWin.visible)
                hamburgerWin.close()
            return
        }

        hamburgerWin = iHamburgerMenuComponent.createObject(iMacroManagerWindow)
        var point = iCfgBtn.mapToGlobal(0, 0)
        hamburgerWin.x = point.x - hamburgerWin.width + iCfgBtn.width + hamburgerWin.shadowThickness
        hamburgerWin.y = point.y + iCfgBtn.height - hamburgerWin.shadowThickness
        hamburgerWin.show()
    }

    function fOpenExportWindow() {
        hamburgerWin.close()
        var macroList = mnsBackend.getMacrosListModel()
        for (var idx in macroList)
            pMacroList.append({"name": macroList[idx], "checked": false})
        var component = Qt.createComponent("MnsMacroExportWindow.qml");
        if (component.status === Component.Ready) {
            component.createObject(iMacroManagerWindow, { "pMacrosListModel": pMacroList}).show()
        }
    }
}
