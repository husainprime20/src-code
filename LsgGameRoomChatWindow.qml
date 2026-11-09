/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Window {
    id: iGameRoomChatWindow
    title: "GameRoom Chat Window"
    flags: Qt.Tool | Qt.FramelessWindowHint
    screen: transientParent.screen
    x: iGameRoomChatWindow.transientParent.x + plrBackend.plrWinOffsets[0] + (iGameRoomChatWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1] - iGameRoomChatWindow.width) / 2
    y: iGameRoomChatWindow.transientParent.y + plrBackend.plrWinOffsets[2] + (iGameRoomChatWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3] - iGameRoomChatWindow.height) / 2
    width: iContentLayout.implicitWidth
    height: 388
    onClosing: {
        iGameRoomChatWindow.destroy()
    }
    property string pStreamUrl: ""
    property ListModel pViewersModel : ListModel {}
    property UiWindowedPopup pViewersWindow: null
    signal showGameRoomExitWarning()

    UiColumnLayout {
        id: iContentLayout
        anchors.fill: parent
        color: UiTheme.colors.primary70
        border.color: UiTheme.colors.primary50
        border.width: 1
        padding: 1
        Layout.minimumWidth: 288
        UiRowLayout {
            id: iTopbar
            Layout.fillWidth: true
            color: UiTheme.colors.primary60
            Layout.preferredHeight: 36
            padding: 8
            UiText {
                text: qsTranslate("QObject", "Gameroom")
                font: UiTheme.fonts.titleSmall
                color: UiTheme.colors.primary10
                wrapMode: Text.NoWrap
                verticalAlignment: Text.AlignVCenter
            }
            UiRowLayout {
                border.color: UiTheme.colors.dangerNormal
                border.width: 1
                radius: 4
                spacing: 4
                leftPadding: 7
                rightPadding: 7
                topPadding: 3
                bottomPadding: 3
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: 6
                Layout.rightMargin: 8
                Layout.preferredHeight: 20
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: UiTheme.colors.dangerNormal
                }
                UiText {
                    text: qsTranslate("QObject", "Live")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary10
                    wrapMode: Text.NoWrap
                }
            }
            Item {
                Layout.fillWidth: true
            }
            UiTextUrl {
                text: "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "Feedback") + "</a>"
                font: UiTheme.fonts.bodySmall
                color: UiTheme.colors.primary20
                linkColor: UiTheme.colors.primary20
                onLinkActivated: lsgBackend.openLiveStreamSurveyUrl()
                Layout.alignment: Qt.AlignRight
            }
            UiImageButton {
                asset: "GameRoomCollapse"
                pImageWidth: 16
                pImageHeight: 16
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.leftMargin: 8
                UiToolTip.text: qsTranslate("QObject", "Hide window")
                onClicked: {
                    iGameRoomChatWindow.hide()
                }
            }
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
                    if ( iGameRoomChatWindow.y < Screen.virtualY) {
                        iGameRoomChatWindow.y = Screen.virtualY
                    }
                }
                onPositionChanged: function(mouse) {
                    if (isPressed) {
                        var delta = Qt.point(mouse.x - startingPosition.x, mouse.y - startingPosition.y)
                        iGameRoomChatWindow.x += delta.x
                        iGameRoomChatWindow.y += delta.y
                    }
                }
            }
        }
        Rectangle {
            height: 1
            Layout.fillWidth: true
            color: UiTheme.colors.primary50
        }
        UiRowLayout {
            leftPadding: 8
            rightPadding: 10
            topPadding: 8
            bottomPadding: 8
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 8
            UiImageButton {
                id: iAudioBtn
                asset: lsgBackend.pIsStreamAudioMuted ? "GameRoomAudioMuted" : "GameRoomAudioUnmuted"
                pImageWidth: 28
                pImageHeight: 28
                UiToolTip.text: lsgBackend.pIsStreamAudioMuted ? qsTranslate("QObject", "Unmute") : qsTranslate("QObject", "Mute")
                onClicked: {
                    lsgBackend.muteUnmuteStreamAudio()
                }
            }
            UiImageButton {
                id: iCopyBtn
                asset: "GameRoomShareUrl"
                pImageWidth: 28
                pImageHeight: 28
                UiToolTip.text:qsTranslate("QObject", "Copy stream link")
                onClicked: {
                    fShowUrlCopiedPopup()
                    lsgBackend.copyStreamingUrl(pStreamUrl)
                    var jsonString = '{ "location" : "chatWindow" }'
                    lsgBackend.sendLiveStreamStats("copy_url_clicked", jsonString)
                }
            }
            UiRowLayout {
                id: iActiveUsersLayout
                Layout.preferredHeight: 28
                color: UiTheme.colors.primary90
                border.width: 1
                border.color: UiTheme.colors.primary50
                spacing: 4
                topPadding: 6
                bottomPadding: 6
                leftPadding: 8
                rightPadding: 8
                radius: 14
                UiToolTip.text: qsTranslate("QObject", "Viewers")
                pMouseArea {
                    enabled: true
                    hoverEnabled: true
                    anchors.fill: iActiveUsersLayout
                    onEntered: {
                        iActiveUsersLayout.border.color = UiTheme.colors.primary30
                        iUserCountText.color = UiTheme.colors.primary10
                    }
                    onExited: {
                        iActiveUsersLayout.border.color = UiTheme.colors.primary50
                        iUserCountText.color = UiTheme.colors.primary20
                    }
                    onClicked: {
                        if(pViewersModel.count > 0)
                            fOpenViewersPopup()
                    }
                }
                UiImageButton {
                    id: iActiveUsersImg
                    asset: "GameRoomOnline"
                    pImageHeight: 12
                    pImageWidth: 12
                    UiToolTip.text: qsTranslate("QObject", "Viewers")
                    MouseArea {
                        anchors.fill: iActiveUsersImg
                        propagateComposedEvents: true
                    }
                }
                UiText {
                    id: iUserCountText
                    text: pViewersModel.count
                    font: UiTheme.fonts.bodySmallest
                    color: UiTheme.colors.primary20
                    wrapMode: Text.NoWrap
                    UiToolTip.text: qsTranslate("QObject", "Viewers")
                    pMouseArea {
                        anchors.fill: iUserCountText
                        propagateComposedEvents: true
                    }
                }
            }
            Item {
                Layout.fillWidth: true
            }

            UiImageButton {
                asset: "GameRoomExitStream"
                Layout.alignment: Qt.AlignRight
                pImageWidth: 28
                pImageHeight: 28
                UiToolTip.text: qsTranslate("QObject", "End stream")
                onClicked: {
                    iGameRoomChatWindow.hide()
                    showGameRoomExitWarning()
                }
            }

            pMouseArea {
                enabled: true
                hoverEnabled: true
            }
        }
        ListView {
            id: iGameRoomChatListView
            Layout.preferredHeight: 240
            Layout.fillWidth: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            spacing: 8
            clip: true
            ScrollBar.vertical: UiScrollBar {
                policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
            model: ListModel { }
            Rectangle{
                id: iRect
                color: UiTheme.colors.primary70
                anchors.fill: iGameRoomChatListView
                visible: iGameRoomChatListView.contentHeight > iGameRoomChatListView.height
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0; color: "#F22B2E4C"}
                    GradientStop { position: 0.15; color: "#CC2B2E4C"}
                    GradientStop { position: 0.3; color: "transparent"}
                    GradientStop { position: 1; color: "transparent" }
                }
            }

            delegate: UiRowLayout {
                width: iGameRoomChatListView.width
                leftPadding: 8
                rightPadding: 8
                spacing: 4
                Text {
                    Layout.maximumWidth: 120
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    text: model.sender
                    color: pickRandomSenderColor()
                    font: UiTheme.fonts.titleSmallest
                    wrapMode: Text.WrapAnywhere
                }
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    text: model.message
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    wrapMode: Text.WrapAnywhere
                }
            }
        }

        UiRowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.bottomMargin: 8
            spacing: 8
            Layout.preferredHeight: 32
            UiTextField {
                id: iMsgTextField
                Layout.preferredWidth: iTopbar.implicitWidth - iSendBtn.width - 24
                pSize: UiTheme.textFields.sizes.medium
                placeholderText: qsTranslate("QObject", "Message")
                placeholderTextColor: UiTheme.colors.primary30
                Layout.minimumWidth: 232
                Layout.alignment: Qt.AlignLeft
                onAccepted: {
                    if(iMsgTextField.text != "")
                        lsgBackend.sendLsgChat(iMsgTextField.text)
                    iMsgTextField.text = ""
                }
            }
            UiImageButton {
                id: iSendBtn
                pImageHeight: 32
                pImageWidth: 32
                asset: "GameRoomChatSendIcon"
                UiToolTip.text: qsTranslate("QObject", "Send")
                onClicked: {
                    if(iMsgTextField.text != "")
                        lsgBackend.sendLsgChat(iMsgTextField.text)
                    iMsgTextField.text = ""
                }
            }
        }
    }

    Component {
        id: iViewersPopupComponent
        UiWindowedPopup {
            id: iViewersPopup
            contentWidth: iViewersContentLayout.implicitWidth
            contentHeight: iViewersContentLayout.implicitHeight
            shadowVisibility: false
            visible: false
            flags: Qt.Tool | Qt.FramelessWindowHint
            closeOnPressOutside: true
            property bool pStartTimer: false
            onClosePopup: {
                pViewersWindow.destroy()
            }

            UiColumnLayout {
                id: iViewersContentLayout
                anchors.left: parent.left
                anchors.right: parent.right
                leftPadding: 10
                rightPadding: 10
                topPadding: 12
                bottomPadding: 12
                border.width: 1
                border.color: UiTheme.colors.primary50
                color: UiTheme.colors.primary70
                spacing: 4
                UiText {
                    text: qsTranslate("QObject", "Viewers")
                    font: UiTheme.fonts.overline
                    color: UiTheme.colors.primary20
                    horizontalAlignment:Text.AlignLeft
                    Layout.minimumWidth: 124
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
                ListView {
                    id: iViewersListView
                    Layout.minimumWidth: 124
                    implicitHeight: contentHeight
                    Layout.fillWidth: true
                    spacing: 4
                    model: pViewersModel
                    delegate: UiRowLayout {
                        width: iViewersListView.width
                        UiText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            text: model.name
                            color: UiTheme.colors.primary10
                            font: UiTheme.fonts.bodySmall
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            Timer {
                id:iPopupTimer
                repeat: false
                interval: 2000
                running: pStartTimer
                onTriggered: {
                    pStartTimer = false
                    iPopupTimer.stop()
                    pViewersWindow.close()
                }
            }
        }

    }

    Component {
        id: iUrlCopiedPopupComponent
        UiHelpPopup {
            id: iCopyUrlPopup
            contentWidth: 138
            visible: false
            flags: Qt.Tool | Qt.FramelessWindowHint
            property bool pStartTimer: false
            pInnerLayout {
                border.width: 1
                border.color: UiTheme.colors.primary40
                color: UiTheme.colors.primary90
                padding: 8
            }

            Text {
                text: qsTranslate("QObject", "Link copied to clipboard")
                font: UiTheme.fonts.bodyExtraSmall
                color: UiTheme.colors.primary10
                verticalAlignment: Text.AlignVCenter
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
            Timer {
                id:iPopupTimer
                repeat: false
                interval: 2000
                running: pStartTimer
                onTriggered: {
                    pStartTimer = false
                    iPopupTimer.stop()
                    iCopyUrlPopup.close()
                }
            }
        }
    }

    function pickRandomSenderColor() {
        var stringList = ["#FF5B5B", "#FFDD6F", "#5C6CFF", "#E29BCA", "#EABB83", "#41D034", "#C29BF4", "#84BFEB"]
        var randomIndex = Math.floor(Math.random() * stringList.length);
        return stringList[randomIndex];
    }

    function fPublishChat(sender, eventValue) {
        iGameRoomChatListView.model.append({ sender: sender, message: eventValue })
        iGameRoomChatListView.positionViewAtEnd();
    }

    function fOpenViewersPopup() {
        if(pViewersWindow != null)
            return
        pViewersWindow = iViewersPopupComponent.createObject(iGameRoomChatWindow, {"pStartTimer" : true})
        pViewersWindow.x = iActiveUsersLayout.mapToGlobal(0,0).x - pViewersWindow.width - 8
        pViewersWindow.y = iActiveUsersLayout.mapToGlobal(0,0).y
        pViewersWindow.show()
    }

    function fUpdateViewersModel(type, name) {
        if(type === "removed") {
            for (var i = 0; i < pViewersModel.count; ++i) {
                if (pViewersModel.get(i).name === name) {
                    pViewersModel.remove(i);
                    break;
                }
            }
        }
        else if(type === "added") {
            pViewersModel.append({name: name})
        }
    }

    function fShowUrlCopiedPopup() {
        var popupWin = iUrlCopiedPopupComponent.createObject(iGameRoomChatWindow, {"pStartTimer" : true})
        popupWin.x = iCopyBtn.mapToGlobal(0,0).x - popupWin.width/2 + iCopyBtn.width/2
        popupWin.y = iCopyBtn.mapToGlobal(0,0).y - iCopyBtn.height - popupWin.height/2
        popupWin.show()
    }
}
