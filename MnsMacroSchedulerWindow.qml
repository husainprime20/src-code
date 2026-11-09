/*
 * Copyright (C) 2020 BlueStack Systems, Inc.
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
import QtQml.Models 2.15

import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Window {
    id: iMacroSchedulerWindow
    color: "transparent"
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTranslate("QObject", "Macro scheduler")
    width: 560 + 2 * iShadow.shadowThickness
    height: 280 + 2 * iShadow.shadowThickness

    property bool pIsAnyRowPresent: iOrganizationListView.count > 0 ? true : false
    property int pDeletingScheduleMacroId: -1

    property UiHelpPopup pRepeatPopup: null
    property UiHelpPopup pNoRepeatPopup: null

    onClosing: {
        iMacroSchedulerWindow.destroy()
    }

    Component.onCompleted: {
        mnsBackend.onMacroSchedulerWindowOpen()
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
                Layout.fillWidth: true
                color: UiTheme.colors.primary70
                leftPadding: 12

                UiRowLayout{
                    spacing: 8
                    UiImage {
                        asset: "MacroScheduler"
                        pImageWidth: 20
                        pImageHeight: 20
                    }
                    Text {
                        text: qsTranslate("QObject", "Macro scheduler")
                        color:  UiTheme.colors.primary10
                        font : UiTheme.fonts.titleExtraSmall
                    }
                }

                UiRowLayout{
                    Layout.alignment: Qt.AlignRight
                    spacing: 4
                    UiImageLabel {
                        Layout.preferredHeight: 32
                        pText : qsTranslate("QObject", "Schedule")
                        pImageAsset: "AddSmall"
                        pImageWidth: 12
                        pImageHeight: 12
                        rightPadding: 8
                        font: UiTheme.fonts.buttonSmall
                        onClicked: {
                            var component = Qt.createComponent("MnsCreateMacroScheduleWindow.qml");
                            if (component.status === Component.Ready) {
                                component.createObject(iMacroSchedulerWindow).show()
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        color: UiTheme.colors.primary60
                    }
                    UiImageButton {
                        asset: "TitlebarClose"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Close")
                        onClicked: {
                            iMacroSchedulerWindow.close()
                        }
                    }
                }
            }

            UiRowLayout {
                visible: pIsAnyRowPresent
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                leftPadding: 12
                rightPadding: 12
                spacing: 12
                Text {
                    Layout.preferredWidth: 120
                    Layout.minimumWidth: 100
                    text: qsTranslate("QObject", "Macro name")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.preferredWidth: 180
                    text: qsTranslate("QObject", "Instance name")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    Layout.preferredWidth: 120
                    text: qsTranslate("QObject", "Next play time")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: qsTranslate("QObject", "Actions")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary40
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }
            }

            Rectangle {
                id: iRootRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                ListView {
                    id: iOrganizationListView
                    visible: pIsAnyRowPresent
                    anchors.fill: parent
                    clip: true
                    cacheBuffer: 2000 // max 50 delegates are cached in either direction

                    ScrollBar.vertical: UiScrollBar {
                        policy: iOrganizationListView.contentHeight > iOrganizationListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    Connections {
                        target: mnsBackend.pMacroScheduleListModel
                        function onScrollToViewEnd() {
                            Qt.callLater(iOrganizationListView.positionViewAtEnd)
                        }
                    }

                    model: DelegateModel {
                        model: mnsBackend.pMacroProxyScheduleListModel
                        delegate: Component {
                            Rectangle {
                                anchors.left: parent != null ? parent.left : undefined
                                anchors.right: parent != null ? parent.right : undefined
                                color: iInstanceMouseArea.containsMouse
                                       ? UiTheme.colors.primary60
                                       : model.index % 2 == 0 ? UiTheme.colors.primary70 : UiTheme.colors.primary90
                                opacity: model.mSecsFromEpochUTCNextPlayTime > Date.now() ? 1 : 0.4
                                height: 36

                                MouseArea {
                                    id:iInstanceMouseArea
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    onEntered: {
                                        model.isNew = false;
                                    }

                                    UiRowLayout {
                                        anchors.fill: parent
                                        leftPadding: 12
                                        rightPadding: 12
                                        spacing: 12
                                        UiRowLayout {
                                            Layout.preferredWidth: 120
                                            spacing: 4
                                            Text {
                                                text: model.macroName
                                                color: UiTheme.colors.primary10
                                                font: UiTheme.textFields.sizes.small.textFont
                                                Layout.maximumWidth: 110 + (model.isNew ? 0 : 10)
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
                                        }

                                        Text {
                                            Layout.preferredWidth: 180
                                            font: UiTheme.fonts.bodySmall
                                            color: UiTheme.colors.primary20
                                            text: mnsBackend.pSelfInstanceDisplayName
                                            elide: Text.ElideRight
                                        }

                                        UiText {
                                            Layout.preferredWidth: 120
                                            font: UiTheme.fonts.bodySmall
                                            color: UiTheme.colors.primary20
                                            text: Qt.formatDateTime(new Date(model.mSecsFromEpochUTCNextPlayTime), "d MMMM, h:mm:ss AP")
                                            elide: Text.ElideRight
                                        }

                                        UiImage {
                                            id: iRepeatDetailsImage
                                            asset: model.mSecsRepeatTime > 0 ? "Repeat" : "NoRepeat"
                                            pImageWidth: 12
                                            pImageHeight: 12
                                            MouseArea {
                                                id: iMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onEntered: {
                                                    var point = iRepeatDetailsImage.mapToGlobal(0, 0)
                                                    if (model.mSecsRepeatTime > 0) {
                                                        if (pRepeatPopup == null)
                                                            pRepeatPopup = iRepeatComponent.createObject(iMacroSchedulerWindow,
                                                                                                         { "mSecsRepeatTime": model.mSecsRepeatTime })

                                                        pRepeatPopup.x = point.x - (pRepeatPopup.width - iRepeatDetailsImage.width) / 2
                                                        pRepeatPopup.y = point.y + iRepeatDetailsImage.height
                                                        pRepeatPopup.show()
                                                    }
                                                    else {
                                                        if (pNoRepeatPopup == null)
                                                            pNoRepeatPopup = iNoRepeatComponent.createObject(iMacroSchedulerWindow)

                                                        pNoRepeatPopup.x = point.x - (pNoRepeatPopup.width - iRepeatDetailsImage.width) / 2
                                                        pNoRepeatPopup.y = point.y + iRepeatDetailsImage.height
                                                        pNoRepeatPopup.show()
                                                    }
                                                }
                                                onExited: {
                                                    if (pRepeatPopup != null)
                                                        pRepeatPopup.close()

                                                    if (pNoRepeatPopup != null)
                                                        pNoRepeatPopup.close()
                                                }
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        UiRowLayout {
                                            Layout.preferredWidth: 60
                                            Layout.alignment: Qt.AlignRight
                                            spacing: 20
                                            UiImageButton {
                                                asset: "EditIcon"
                                                pImageWidth: 12
                                                pImageHeight: 12
                                                UiToolTip.text: qsTranslate("QObject", "Edit")
                                                onClicked: {
                                                    var component = Qt.createComponent("MnsCreateMacroScheduleWindow.qml");
                                                    if (component.status === Component.Ready) {
                                                        component.createObject(iMacroSchedulerWindow, {
                                                                                   "pIsUpdateMacroSchedule": true,
                                                                                   "pScheduleMacroId" : model.scheduleMacroId,
                                                                                   "pScheduleMacroDate" : new Date(model.mSecsFromEpochUTCStartTime),
                                                                                   "pScheduleMacroRepeatTime" : model.mSecsRepeatTime
                                                                               }).show()
                                                    }
                                                }
                                            }
                                            UiImageButton {
                                                asset: "DeleteSmall"
                                                pImageWidth: 12
                                                pImageHeight: 12
                                                UiToolTip.text: qsTranslate("QObject", "Delete")
                                                onClicked: {
                                                    if(uiBackend.confGetBool("bst.show_schedule_macro_delete_warning")) {
                                                        pDeletingScheduleMacroId = model.scheduleMacroId
                                                        iDeleteMacroPrompt.createObject(iMacroSchedulerWindow, { "transientParent": iMacroSchedulerWindow }).show()
                                                    }
                                                    else {
                                                        mnsBackend.pMacroScheduleListModel.removeScheduleMacro(model.scheduleMacroId)
                                                    }
                                                }
                                            }
                                            Item {
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                UiColumnLayout {
                    spacing: 20
                    visible: !pIsAnyRowPresent
                    anchors.verticalCenter: parent != null ? parent.verticalCenter : undefined
                    anchors.horizontalCenter: parent != null ? parent.horizontalCenter : undefined
                    UiImage {
                        Layout.alignment: Qt.AlignHCenter
                        asset: "NoMacros"
                        pImageWidth: 64
                        pImageHeight: 64
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("QObject", "No Macros scheduled")
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.titleMedium
                    }
                    Text {
                        Layout.preferredWidth: iRootRect.width
                        Layout.maximumWidth: 316
                        horizontalAlignment: Text.AlignHCenter
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "There are no macros lined up to run")
                    }
                    UiButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTranslate("QObject", "Schedule")
                        pSize: UiTheme.buttons.sizes.medium
                        pColor: UiTheme.buttons.colors.accent
                        onClicked: {
                            var component = Qt.createComponent("MnsCreateMacroScheduleWindow.qml");
                            if (component.status === Component.Ready) {
                                component.createObject(iMacroSchedulerWindow).show()
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: iRepeatComponent
        UiHelpPopup {
            property var mSecsRepeatTime

            id: iRepeatHelpPopup
            contentWidth: pInnerLayout.implicitWidth
            arrowPosition: UiHelpPopup.ArrowPosition.TopCenter
            closeOnPressOutside: false
            visible: true
            pInnerLayout {
                color: UiTheme.colors.primary70
                border.color: UiTheme.colors.primary50
                border.width: 1
                padding: 12
            }

            UiRowLayout {
                spacing: 8

                Text {
                    text: qsTranslate("QObject", "Repeat every")
                    color: UiTheme.colors.primary20
                    font: UiTheme.fonts.bodySmall
                }

                UiRowLayout {
                    spacing: 4
                    UiTextField {
                        pSize: UiTheme.textFields.sizes.small
                        enabled: false
                        opacity: 0.4
                        readOnly: true
                        text: parseInt(iRepeatHelpPopup.mSecsRepeatTime / (1000 * 60 * 60 * 24))
                    }
                    Text {
                        text: qsTranslate("QObject", "DD")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodySmall
                    }
                }

                UiRowLayout {
                    spacing: 4
                    UiTextField {
                        pSize: UiTheme.textFields.sizes.small
                        enabled: false
                        opacity: 0.4
                        readOnly: true
                        text: parseInt(iRepeatHelpPopup.mSecsRepeatTime / (1000 * 60 * 60)) % 24
                    }
                    Text {
                        text: qsTranslate("QObject", "HH")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodySmall
                    }
                }

                UiRowLayout {
                    spacing: 4
                    UiTextField {
                        pSize: UiTheme.textFields.sizes.small
                        enabled: false
                        opacity: 0.4
                        readOnly: true
                        text: parseInt(iRepeatHelpPopup.mSecsRepeatTime / (1000 * 60)) % 60
                    }
                    Text {
                        text: qsTranslate("QObject", "MM")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodySmall
                    }
                }

                UiRowLayout {
                    spacing: 4
                    UiTextField {
                        pSize: UiTheme.textFields.sizes.small
                        enabled: false
                        opacity: 0.4
                        readOnly: true
                        text: parseInt(iRepeatHelpPopup.mSecsRepeatTime / 1000) % 60
                    }
                    Text {
                        text: qsTranslate("QObject", "SS")
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodySmall
                    }
                }
            }
        }
    }

    Component {
        id: iNoRepeatComponent
        UiHelpPopup {
            id: iNoRepeatHelpPopup
            contentWidth: pInnerLayout.implicitWidth
            arrowPosition: UiHelpPopup.ArrowPosition.TopCenter
            closeOnPressOutside: false
            visible: true
            pInnerLayout {
                color: UiTheme.colors.primary70
                border.color: UiTheme.colors.primary50
                border.width: 1
                padding: 12
            }

            Text {
                text: qsTranslate("QObject", "Does not repeat")
                color: UiTheme.colors.primary20
                font: UiTheme.fonts.bodySmall
            }
        }
    }

    Component {
        id: iDeleteMacroPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Delete Scheduled Macro?")
            pDescription: qsTranslate("QObject", "Would you like to delete the scheduled macro?")
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.danger
                        pText: qsTranslate("QObject", "Delete")
                        onClicked: {
                            mnsBackend.pMacroScheduleListModel.removeScheduleMacro(pDeletingScheduleMacroId)
                            pDeletingScheduleMacroId = -1
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            pDeletingScheduleMacroId = -1
                            close()
                        }
                    }
                ]
            }
            pCheckBoxText: qsTranslate("QObject", "Do not show again")
            onCheckBoxClicked: {
                uiBackend.confSetBool("bst.show_schedule_macro_delete_warning", !checked)
                uiBackend.confCommit()
            }
        }
    }
}
