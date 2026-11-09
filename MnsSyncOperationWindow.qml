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
import UiToolTipControl 1.0

Window {
    id: iSyncOperationWindow
    color: UiTheme.colors.subWindowBg
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTranslate("QObject", "Sync operations")
    width: 320
    height: iSyncControlLayout.implicitHeight

    property var pSelectedInstances: []
    property bool pAnyInstanceSelected: false
    property bool pIsSyncActive: false

    ButtonGroup {
        id: iSelectAllGroup
        exclusive: false
        checkState: iSelectAllCbx.checkState
    }

    UiColumnLayout {
        anchors.fill: parent
        id: iSyncControlLayout
        border.width: 1
        border.color: UiTheme.colors.primary60
        padding: 1

        UiRowLayout {
            id:iTitlebar
            Layout.fillWidth: true
            height: 32

            pMouseArea {
                enabled: true
                anchors.fill: iTitlebar
                property var startingPosition
                property bool isPressed: false

                onPressed: function(mouse) {
                    isPressed = true
                    startingPosition  = Qt.point(mouse.x, mouse.y)
                }
                onReleased: {
                    isPressed = false
                    if ( iSyncOperationWindow.y < Screen.virtualY) {
                        iSyncOperationWindow.y = Screen.virtualY
                    }
                }
                onPositionChanged: function(mouse) {
                    if (isPressed) {
                        var delta = Qt.point(mouse.x - startingPosition.x, mouse.y - startingPosition.y)
                        iSyncOperationWindow.x += delta.x
                        iSyncOperationWindow.y += delta.y
                    }
                }
            }
            color: UiTheme.colors.subWindowHeader

            UiImage {
                asset: "SyncColor"
                Layout.leftMargin: 12
                pImageWidth: 20
                pImageHeight: 20
            }
            Text {
                text: qsTranslate("QObject", "Sync operations")
                color: UiTheme.colors.secondaryHover
                font: UiTheme.fonts.titleExtraSmall
                Layout.leftMargin: 8
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
            }
            UiImageButton {
                asset: "TitlebarHelp"
                pImageWidth: 32
                pImageHeight: 32
                UiToolTip.text: qsTranslate("QObject", "Help")
                onClicked: uiBackend.openHelpArticle("Sync_Help")
            }
            UiImageButton {
                asset: "TitlebarClose"
                pImageWidth: 32
                pImageHeight: 32
                UiToolTip.text: qsTranslate("QObject", "Close")
                onClicked: iSyncOperationWindow.close()
            }
        }

        UiColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: iInstancesListView.count > 0 ? true : false

            ListView{
                id: iInstancesListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 12
                height: 140
                clip: true
                model: mnsSyncViewModel

                ScrollBar.vertical: UiScrollBar {
                    policy: iInstancesListView.contentHeight > iInstancesListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }

                delegate: Rectangle{
                    width: 240
                    height: 28
                    color: UiTheme.colors.subWindowBg
                    property var pSelectedCbxText : model.name
                    property alias pSelectedCbxChecked: iSelectedCbx.checked
                    UiRowLayout{
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        UiCheckBox{
                            id: iSelectedCbx
                            checked: model.isChecked
                            pSize: UiTheme.checkBoxes.sizes.small
                            text: model.displayName
                            Layout.leftMargin: 12
                            Layout.maximumWidth: 280
                            enabled: !pIsSyncActive
                            ButtonGroup.group: iSelectAllGroup
                            onCheckedChanged: {
                                if(checked){
                                    pSelectedInstances.push(model.name)
                                    pAnyInstanceSelected = true
                                }
                                else{
                                    var index = pSelectedInstances.indexOf(model.name);
                                    if (index > -1) {
                                        pSelectedInstances.splice(index, 1);
                                    }

                                    if(pSelectedInstances.length === 0)
                                        pAnyInstanceSelected = false
                                }
                                model.isChecked = checked
                            }
                        }
                    }
                }

                onCountChanged: {
                    for (var i = pSelectedInstances.length-1; i >=0 ; --i) {
                        var found = false
                        for(var instance in iInstancesListView.contentItem.children) {
                            var childItem = iInstancesListView.contentItem.children[instance]
                            var instanceName = childItem.pSelectedCbxText
                            if(instanceName !== undefined) {
                                if(childItem.pSelectedCbxText === pSelectedInstances[i])
                                    found = true
                            }
                        }
                        if(!found)
                            pSelectedInstances.splice(i, 1)
                    }
                    pAnyInstanceSelected = pSelectedInstances.length > 0
                }
            }

            Rectangle {
                height: 1
                color: UiTheme.colors.primary50
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
            }

        }

        UiColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 153
            visible: iInstancesListView.count > 0 ? false : true
            Layout.alignment: Qt.AlignVCenter

            UiRowLayout{
                Layout.margins: 12
                Layout.fillHeight: true
                Layout.fillWidth: true
                UiImage {
                    asset: "WarningIconYellow"
                    pImageWidth: 64
                    pImageHeight: 64
                    Layout.alignment: Qt.AlignVCenter
                }

                UiColumnLayout{
                    Layout.leftMargin: 16
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    UiText {
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary10
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "No syncable instance.")
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4
                    }

                    UiText {
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary20
                        wrapMode: Text.WordWrap
                        text: qsTranslate("QObject", "Launch more instances to start synchronization between the selected instances.")
                        Layout.fillWidth: true
                    }
                    UiTextUrl {
                        text: "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "Open Multi-instance manager") + "</a>"
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary20
                        linkColor: UiTheme.colors.accentNormal
                        Layout.topMargin: 4
                        Layout.fillWidth: true
                        onLinkActivated: plrBackend.launchMultiInstanceManager()
                    }
                }
            }
        }

        UiRowLayout{
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.bottomMargin: 12
            UiCheckBox{
                id: iSelectAllCbx
                checked: false
                pSize: UiTheme.checkBoxes.sizes.small
                font: UiTheme.fonts.bodySmall
                text: qsTranslate("QObject", "Select all")
                Layout.leftMargin: 12
                Layout.alignment: Qt.AlignVCenter
                enabled: !pIsSyncActive && (iInstancesListView.count > 0)
                checkState: iSelectAllGroup.checkState
            }
            Item {
                Layout.fillWidth: true
            }
            UiButton{
                id: iSyncBtn
                text: pIsSyncActive ? qsTranslate("QObject", "Stop syncing") : qsTranslate("QObject", "Start sync")
                pSize: UiTheme.buttons.sizes.small
                pColor: pIsSyncActive ? UiTheme.buttons.colors.danger : UiTheme.buttons.colors.accent
                Layout.rightMargin: 12
                Layout.alignment: Qt.AlignRight
                enabled: pIsSyncActive ? true : iSelectAllCbx.enabled && pAnyInstanceSelected
                opacity: enabled ? 1 : 0.4
                onClicked: {
                    if(!pIsSyncActive){
                        mnsBackend.syncInstances(pSelectedInstances)
                        iSyncOperationWindow.close()
                    }
                    else {
                        fSyncStopped()
                    }
                }
            }
        }

    }

    function fSyncStopped(){
        pIsSyncActive = false
        mnsBackend.onSyncStopped()
    }

    function fSetSyncState(visible){
        pIsSyncActive = visible === true
    }
}
