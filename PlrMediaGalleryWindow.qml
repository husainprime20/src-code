/*
 * Copyright (C) 2020-2023 BlueStack Systems, Inc.
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
import QtWebEngine
import QtWebChannel

import RecordModeEnum 1.0

import UiToolTipControl 1.0
import UiHelper 1.0
import UiQuickWindow 1.0

UiQuickWindow {
    id: iMediaGalleryWindow
    objectName: "mediaGalleryWindow"
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint
    title: qsTranslate("QObject", "%1 Media Gallery").arg(uiBackend.productName)
    width: 640 + 2 * iShadow.shadowThickness
    height: 480 + 2 * iShadow.shadowThickness

    property UiWindowedPopup pMediaOptionsWin: null
    property var pToastErrorMessagesList: [
        qsTranslate("QObject", "Video name cannot be empty"),
        qsTranslate("QObject", "Video name cannot contain following characters") + " \\ / | ? * < > : \"",
        qsTranslate("QObject", "Video name cannot be a reserved file name"),
        qsTranslate("QObject", "A video with same name already exists"),
        qsTranslate("QObject", "Failed to rename Video file"),
    ]

    onClosed: {
        iMediaGalleryWindow.destroy()
    }

    onVisibleChanged: {
        if (visible) {
            if (iMediaGalleryWindow.transientParent !== null) {
                iMediaGalleryWindow.x = Qt.binding(function() {
                    var messageWindowX = iMediaGalleryWindow.transientParent.x + (iMediaGalleryWindow.transientParent.width - iMediaGalleryWindow.width) / 2
                    if (messageWindowX < iMediaGalleryWindow.transientParent.screen.virtualX)
                        messageWindowX = iMediaGalleryWindow.transientParent.screen.virtualX
                    if(messageWindowX + iMediaGalleryWindow.width > iMediaGalleryWindow.transientParent.screen.virtualX + iMediaGalleryWindow.transientParent.screen.width)
                        messageWindowX = iMediaGalleryWindow.transientParent.screen.virtualX + iMediaGalleryWindow.transientParent.screen.width - iMediaGalleryWindow.width
                    return messageWindowX
                })
                iMediaGalleryWindow.y = Qt.binding(function() {
                    var messageWindowY = iMediaGalleryWindow.transientParent.y + (iMediaGalleryWindow.transientParent.height - iMediaGalleryWindow.height) / 2
                    if (messageWindowY < iMediaGalleryWindow.transientParent.screen.virtualY)
                        messageWindowY = iMediaGalleryWindow.transientParent.screen.virtualY
                    if(messageWindowY + iMediaGalleryWindow.height > iMediaGalleryWindow.transientParent.screen.virtualY + iMediaGalleryWindow.transientParent.screen.height)
                        messageWindowY = iMediaGalleryWindow.transientParent.screen.virtualY + iMediaGalleryWindow.transientParent.screen.height - iMediaGalleryWindow.height
                    return messageWindowY
                })
            }
        }
    }

    Component.onCompleted: {
        mediaBackend.setSelectedTabIndexOnInit()
        if(mediaBackend.isAnyMediaInPublishingState(true) && mediaBackend.pSelectedTabIndex === 0) {
            fSetStatusText(qsTranslate("QObject","Uploading Moment to your now.gg account"), "", true, false)
        }
    }

    Connections {
        target: mediaBackend
        function onRunJsFuncInWebEngineView(script) {
            console.info("fRunJsFunctionInWebView - script: " + script)
            iWebEngineView.runJavaScript(script)
        }
    }

    Component {
        id: iMediaOptionsPopupComponent
        UiWindowedPopup {
            id: iRoot
            contentWidth: Math.max(204, iContentCol.implicitWidth)
            contentHeight: iContentCol.implicitHeight

            property string videoId: ""
            property bool uploaded: false
            property string filePath: ""
            property bool isMoment: false
            property bool isPublishing: false

            UiColumnLayout {
                id: iContentCol
                anchors.left: parent.left
                anchors.right: parent.right
                topPadding: 2
                bottomPadding: 2
                color: UiTheme.colors.primary80
                border.width: 1
                border.color: UiTheme.colors.primary60

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Play")
                    pImageAsset: "PlaySmall"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    opacity: enabled ? 1 : 0.4
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        if (iRoot.isMoment && uploaded)
                            mediaBackend.playMoments(iRoot.videoId)
                        else {
                            mediaBackend.playVideoFile(iRoot.filePath)
                        }
                        pMediaOptionsWin.close()
                    }
                }

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Rename")
                    pImageAsset: "EditIcon"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    enabled: !iRoot.isPublishing
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        mediaBackend.setVideoNameEditMode(iRoot.filePath, true)
                        pMediaOptionsWin.close()
                    }
                }

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Open on cloud")
                    pImageAsset: "FolderNowgg"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    visible: iRoot.uploaded
                    enabled: mediaBackend.pIsNowggAccountSignIn || iRoot.isMoment || uiBackend.confGetBool("bst.guest_login_completed")
                    opacity: enabled ? 1 : 0.4
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        pMediaOptionsWin.close()
                        mediaBackend.playMoments(iRoot.videoId)
                    }
                }

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Upload to cloud")
                    pImageAsset: "CloudUpload"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    visible: !iRoot.uploaded && uiBackend.confGetBool("bst.feature.show_moments") && uiBackend.confGetBool("bst.feature.nowgg_cloud_upload_enabled") && !uiBackend.isMsiOem
                    enabled: (mediaBackend.pIsNowggAccountSignIn || uiBackend.confGetBool("bst.guest_login_completed")) && !iRoot.isPublishing
                    opacity: enabled ? 1 : 0.4
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        mediaBackend.uploadMoments(iRoot.filePath, iRoot.isMoment)
                        pMediaOptionsWin.close()
                    }
                }

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Open local file")
                    pImageAsset: "Folder"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    onClicked: {
                        plrBackend.openSystemFolder(iRoot.filePath)
                        pMediaOptionsWin.close()
                    }
                }

                UiImageLabel {
                    Layout.preferredHeight: 32
                    Layout.fillWidth: true
                    pText : qsTranslate("QObject", "Delete")
                    pImageAsset: "DeleteSmall"
                    leftPadding: 12
                    rightPadding: 12
                    pImageWidth: 12
                    pImageHeight: 12
                    pBackgroundColor: pHovered ? UiTheme.colors.primary60 : "transparent"
                    enabled: !iRoot.isPublishing
                    onClicked: {
                        // delete file
                        mediaBackend.deleteVideoFile(iRoot.filePath, iRoot.videoId)
                        pMediaOptionsWin.close()
                    }
                }
            }
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
                id: iTitleBar
                Layout.fillWidth: true
                Layout.preferredWidth: 32
                color: UiTheme.colors.primary70
                spacing: 8

                pMouseArea {
                    enabled: true
                    anchors.fill: iTitleBar
                    property var startingPosition
                    property bool isPressed: false

                    onPressed: function(mouse) {
                        iTitleBar.forceActiveFocus()
                        isPressed = true
                        startingPosition  = Qt.point(mouse.x, mouse.y)
                    }
                    onReleased: {
                        isPressed = false
                        if ( iMediaGalleryWindow.y < Screen.virtualY) {
                            iMediaGalleryWindow.y = Screen.virtualY
                        }
                    }
                    onPositionChanged: function(mouse) {
                        if (isPressed) {
                            var delta = Qt.point(mouse.x - startingPosition.x, mouse.y - startingPosition.y)
                            iMediaGalleryWindow.x += delta.x
                            iMediaGalleryWindow.y += delta.y
                        }
                    }
                }

                UiImage {
                    pImageWidth: 20
                    pImageHeight: 20
                    asset: "MediaGallery"
                    horizontalAlignment: Qt.AlignLeft
                    Layout.leftMargin: 12
                }

                Text {
                    elide: Text.ElideRight
                    text: qsTranslate("QObject", "Media Gallery")
                    font: UiTheme.fonts.titleExtraSmall
                    color: UiTheme.colors.primary10
                }

                Item {
                    Layout.fillWidth: true
                }

                UiImageButton {
                    asset: "TitlebarClose"
                    pImageWidth: 32
                    pImageHeight: 32
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        iMediaGalleryWindow.close()
                    }
                }
            }

            UiRowLayout {
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                Layout.fillWidth: true
                spacing: 12

                UiColumnLayout {
                    id: iMomentsTab
                    spacing: 8
                    visible: uiBackend.confGetBool("bst.feature.show_moments")
                    pMouseArea {
                        enabled: true
                        anchors.fill: iMomentsTab
                        onPressed: {
                            mediaBackend.handleTabSwitch(0)
                            iMediaGalleryView.scrollToTop()
                            if(mediaBackend.isAnyMediaInPublishingState(true)) {
                                fSetStatusText(qsTranslate("QObject","Uploading Moment to your now.gg account"), "", true, false)
                            }
                            else
                                fSetStatusText("", "", false, false)
                        }
                    }

                    UiRowLayout {
                        id: iMomentsTabRow
                        spacing: 4
                        Layout.fillWidth: true

                        UiImage {
                            pImageWidth: 16
                            pImageHeight: 16
                            asset: "MomentsIcon"
                            extn: ".png"
                            horizontalAlignment: Qt.AlignLeft
                        }

                        Text {
                            elide: Text.ElideRight
                            text: qsTranslate("QObject", "Moments")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary10
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: iMomentsTabRow.width
                        height: 1
                        color: mediaBackend.pSelectedTabIndex === 0 ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                    }
                }

                UiColumnLayout {
                    id: iRecordingsTab
                    spacing: 8
                    Layout.leftMargin: 12
                    pMouseArea {
                        enabled: true
                        anchors.fill: iRecordingsTab
                        onPressed: {
                            mediaBackend.handleTabSwitch(1)
                            iMediaGalleryView.scrollToTop()
                            if(mediaBackend.isAnyMediaInPublishingState(false))
                                fSetStatusText(qsTranslate("QObject","Uploading Recording to your now.gg account"), "", true, false)
                            else
                                fSetStatusText("", "", false, false)
                        }
                    }

                    UiRowLayout {
                        id: iRecordingsTabRow
                        spacing: 4
                        Layout.fillWidth: true

                        UiImage {
                            pImageWidth: 16
                            pImageHeight: 16
                            asset: "RecordingIconSmall"
                            horizontalAlignment: Qt.AlignLeft
                        }

                        Text {
                            elide: Text.ElideRight
                            text: qsTranslate("QObject", "Recordings")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary10
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: iRecordingsTabRow.width
                        height: 1
                        color: mediaBackend.pSelectedTabIndex === 1 ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                    }
                }

                UiColumnLayout {
                    id: iScreenshotsTab
                    spacing: 8
                    Layout.leftMargin: 12
                    pMouseArea {
                        enabled: true
                        anchors.fill: iScreenshotsTab
                        onPressed: {
                            mediaBackend.handleTabSwitch(2)
                            fSetStatusText("", "", false, false)
                        }
                    }

                    UiRowLayout {
                        id: iScreenshotsTabRow
                        spacing: 4
                        Layout.fillWidth: true

                        UiImage {
                            pImageWidth: 16
                            pImageHeight: 16
                            asset: "ScreenshotIcon"
                            horizontalAlignment: Qt.AlignLeft
                        }

                        Text {
                            elide: Text.ElideRight
                            text: qsTranslate("QObject", "Screenshots")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary10
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: iScreenshotsTabRow.width
                        height: 1
                        color: mediaBackend.pSelectedTabIndex === 2 ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                    }
                }

                UiColumnLayout {
                    id: iHighlightsTab
                    spacing: 8
                    visible: uiBackend.confGetBool("bst.feature.show_ai_highlights")
                    pMouseArea {
                        enabled: true
                        anchors.fill: iHighlightsTab
                        onPressed: {
                            mediaBackend.handleTabSwitch(3)
                        }
                    }

                    UiRowLayout {
                        id: iHighlightsTabRow
                        spacing: 4
                        Layout.fillWidth: true

                        UiImage {
                            pImageWidth: 16
                            pImageHeight: 16
                            asset: "HighlightsIcon"
                            horizontalAlignment: Qt.AlignLeft
                        }

                        Text {
                            elide: Text.ElideRight
                            text: qsTranslate("QObject", "AI Highlights")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary10
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignBottom
                        width: iHighlightsTabRow.width
                        height: 1
                        color: mediaBackend.pSelectedTabIndex === 3 ? UiTheme.colors.accentNormal : UiTheme.colors.primary60
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            UiRowLayout {
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.bottomMargin: 8
                Layout.fillWidth: true
                spacing: 12
                visible: mediaBackend.pSelectedTabIndex === 0 || mediaBackend.pSelectedTabIndex === 1

                Text {
                    text: {
                        if (mediaBackend.pSelectedTabIndex === 0)
                            qsTranslate("QObject", "%1 Moments Captured").arg(mediaBackend.pVisibleItemCount)
                        else if (mediaBackend.pSelectedTabIndex === 1)
                            qsTranslate("QObject", "%1 Recordings").arg(mediaBackend.pVisibleItemCount)
                        else
                            ""
                    }
                    elide: Text.ElideRight
                    font: UiTheme.fonts.bodyMedium
                    color: UiTheme.colors.primary10
                    horizontalAlignment: Text.AlignLeft
                }

                Item {
                    Layout.fillWidth: true
                }

                UiButton {
                    asset: "Link"
                    text: qsTranslate("QObject", "Open cloud folder")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.tertiary
                    pImageAfterText: true
                    enabled: mediaBackend.pCloudFolderBtnVisible
                    opacity: enabled ? 1 : 0.4
                    visible: uiBackend.confGetBool("bst.feature.show_moments")
                    onClicked: {
                        mediaBackend.openNowggChannel()
                    }
                }

                UiButton {
                    asset: "File"
                    text: qsTranslate("QObject", "Open local folder")
                    pSize: UiTheme.buttons.sizes.small
                    pColor: UiTheme.buttons.colors.tertiary
                    visible: mediaBackend.pSelectedTabIndex !== 3
                    onClicked: {
                        plrBackend.openSystemFolder("")
                    }
                }
            }

            Rectangle {
                id: iGridViewRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 12
                color: "transparent"

                UiColumnLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: (mediaBackend.pSelectedTabIndex === 0) && !iMediaGalleryView.visible

                    UiImage {
                        pImageWidth: 72
                        pImageHeight: 72
                        asset: "MomentsIcon"
                        extn: ".png"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        elide: Text.ElideRight
                        text: qsTranslate("QObject", "No Moments saved yet")
                        font: UiTheme.fonts.titleMedium
                        color: UiTheme.colors.primary10
                        Layout.topMargin: 18
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        elide: Text.ElideRight
                        text: qsTranslate("QObject", "Instantly save and relive your last 60 seconds of epic gameplay!")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                        Layout.topMargin: 4
                        Layout.alignment: Qt.AlignHCenter
                    }

                    UiButton {
                        text: qsTranslate("QObject", "Turn Moments ON")
                        pSize: UiTheme.buttons.sizes.medium
                        pColor: UiTheme.buttons.colors.accent
                        Layout.topMargin: 16
                        Layout.alignment: Qt.AlignHCenter
                        visible: !nowggBackend.pIsScreenRecorderOn || nowggBackend.pRecordMode !== RecordMode.MOMENT
                        onClicked: {
                            nowggBackend.handleMomentsToggled(true)
                            iMediaGalleryWindow.close()
                        }
                    }
                }

                UiColumnLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: (mediaBackend.pSelectedTabIndex === 1) && !iMediaGalleryView.visible

                    UiImage {
                        pImageWidth: 72
                        pImageHeight: 72
                        asset: "RecordingIcon"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        elide: Text.ElideRight
                        text: qsTranslate("QObject", "No epic recordings yet")
                        font: UiTheme.fonts.titleMedium
                        color: UiTheme.colors.primary10
                        Layout.topMargin: 18
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        elide: Text.ElideRight
                        text: qsTranslate("QObject", "Record your gameplay and create epic moments to watch later")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                        Layout.topMargin: 4
                        Layout.alignment: Qt.AlignHCenter
                    }

                    UiButton {
                        text: qsTranslate("QObject", "Record")
                        pSize: UiTheme.buttons.sizes.medium
                        pColor: UiTheme.buttons.colors.accent
                        Layout.topMargin: 16
                        Layout.alignment: Qt.AlignHCenter
                        visible: !nowggBackend.pIsScreenRecorderOn || (nowggBackend.pRecordMode === RecordMode.MOMENT)
                        onClicked: {
                            nowggBackend.startRecording(true)
                            iMediaGalleryWindow.close()
                        }
                    }

                    UiButton {
                        text: qsTranslate("QObject", "Stop Recording")
                        pSize: UiTheme.buttons.sizes.medium
                        pColor: UiTheme.buttons.colors.danger
                        Layout.topMargin: 16
                        Layout.alignment: Qt.AlignHCenter
                        visible: nowggBackend.pIsScreenRecorderOn && (nowggBackend.pRecordMode === RecordMode.NORMAL)
                        onClicked: {
                            nowggBackend.startRecording(false)
                            iMediaGalleryWindow.close()
                        }
                    }
                }

                UiRowLayout {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: mediaBackend.pSelectedTabIndex === 2
                    leftPadding: 8
                    rightPadding: 20

                    UiColumnLayout {
                        Layout.preferredWidth: 300
                        Layout.alignment: Qt.AlignVCenter
                        rightPadding: 20
                        leftPadding: 20

                        UiImage {
                            pImageWidth: 100
                            pImageHeight: 100
                            asset: "AndroidGalleryIcon"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: qsTranslate("QObject", "View your screenshots in Android Gallery")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                            Layout.topMargin: 4
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredHeight: 74
                            Layout.maximumWidth: 200
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                        }
                        UiButton {
                            text: qsTranslate("QObject", "Open Gallery")
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: UiTheme.buttons.colors.accent
                            Layout.topMargin: 16
                            Layout.bottomMargin: 8
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: {
                                plrBackend.openMediaManager()
                                iMediaGalleryWindow.close()
                                plrBackend.setIsAndroidTabSelected(true)
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 206
                        Layout.preferredWidth: 1
                        color: UiTheme.colors.primary60
                        Layout.alignment: Qt.AlignVCenter
                    }

                    UiColumnLayout {
                        Layout.preferredWidth: 300
                        Layout.alignment: Qt.AlignVCenter
                        rightPadding: 20
                        leftPadding: 20

                        UiImage {
                            pImageWidth: 100
                            pImageHeight: 100
                            asset: "WindowsLarge"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: qsTranslate("QObject", "View your screenshots in Windows folder")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                            Layout.topMargin: 4
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            Layout.preferredHeight: 74
                            Layout.maximumWidth: 200
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                        }
                        UiButton {
                            text: qsTranslate("QObject", "Open Folder")
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: UiTheme.buttons.colors.accent
                            Layout.topMargin: 16
                            Layout.bottomMargin: 8
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: {
                                plrBackend.openMediaFolder("")
                                iMediaGalleryWindow.close()
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.rightMargin: 8
                    anchors.bottomMargin: 8
                    visible: mediaBackend.pSelectedTabIndex === 3 && uiBackend.confGetBool("bst.feature.show_ai_highlights")
                    color: UiTheme.colors.primary80

                    WebEngineView {
                        id: iWebEngineView
                        focus: true
                        anchors.fill: parent
                        visible: false
                        backgroundColor: UiTheme.colors.primary80

                        url: mediaBackend.pHighlightsUrl
                        webChannel: mediaBackend.pWebChannel
                        settings.javascriptEnabled: true
                        settings.javascriptCanOpenWindows: true
                        settings.javascriptCanAccessClipboard: true
                        settings.javascriptCanPaste: true
                        settings.dnsPrefetchEnabled: true
                        settings.showScrollBars: false
                        profile.httpAcceptLanguage: uiBackend.getPreferredLocaleWeighted()

                        onLoadingChanged: function(loadingInfo) {
                            if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
                                console.error("Failed to load Highlights web view, err : " + loadingInfo.errorString)
                                iWebEngineView.visible = false
                                iLoader.visible = false
                            }
                            else if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                                iWebEngineView.focus = true
                                iLoader.visible = false
                                iWebEngineView.visible = true
                            }
                        }
                    }

                    UiColumnLayout {
                        id: iNoInternetLayout
                        anchors.fill: parent
                        visible: !iWebEngineView.visible
                        color: UiTheme.colors.primary80

                        Item { Layout.fillHeight: true }

                        UiImage {
                            id: iLoader
                            Layout.alignment: Qt.AlignHCenter
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
                                running: iLoader.visible
                            }
                        }
                        UiImage {
                            asset: "NoWifi"
                            pImageWidth: 72
                            pImageHeight: 72
                            Layout.alignment: Qt.AlignHCenter
                            visible: !iLoader.visible
                        }
                        Text {
                            text: qsTranslate("QObject", "You are offline")
                            font : UiTheme.fonts.titleMedium
                            color: UiTheme.colors.white
                            horizontalAlignment: Text.AlignHCenter
                            Layout.topMargin: 24
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: !iLoader.visible
                        }
                        Text {
                            text: qsTranslate("QObject", "Please check your internet connection and try again")
                            font : UiTheme.fonts.bodySmall
                            color: UiTheme.colors.primary20
                            horizontalAlignment: Text.AlignHCenter
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            Layout.topMargin: 12
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            Layout.maximumWidth: 500
                            visible: !iLoader.visible
                        }
                        UiButton{
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: UiTheme.buttons.colors.accent
                            Layout.topMargin: 12
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTranslate("QObject", "Reload")
                            opacity: hovered ? 0.8 : 1
                            visible: !iLoader.visible
                            onClicked: {
                                console.info("AIHighlights ::: reload clicked")
                                iWebEngineView.reload()
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                GridView {
                    id: iMediaGalleryView
                    anchors.fill: iGridViewRect
                    clip: true
                    model: mediaBackend.pMediaGalleryViewModel
                    visible: mediaBackend.pVisibleItemCount > 0
                    cellWidth: 204 * ((typeof(uiBackend) !== "undefined") ? parseFloat(uiBackend.confGetString("bst.ui_scale_factor")) : 1.0)
                    cellHeight: 155 * ((typeof(uiBackend) !== "undefined") ? parseFloat(uiBackend.confGetString("bst.ui_scale_factor")) : 1.0)
                    cacheBuffer: 816 // 4 rows of grid
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: UiScrollBar {
                        policy: iMediaGalleryView.contentHeight > iMediaGalleryView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    footer: UiRowLayout {
                        width: parent.width
                        height: visible ?
                                    (mediaBackend.pLoadMoreBtnVisible ? 60 :
                                        (mediaBackend.pSelectedTabIndex === 0) ? 100 : 0) : 0

                        UiButton {
                            text: qsTranslate("QObject", "Load more")
                            pSize: UiTheme.buttons.sizes.small
                            pColor: UiTheme.buttons.colors.tertiary
                            Layout.alignment: Qt.AlignHCenter
                            visible: mediaBackend.pLoadMoreBtnVisible
                            onClicked: {
                                mediaBackend.updateMaxVisibleItemCount()
                            }
                        }

                        UiColumnLayout {
                            spacing: 8
                            Layout.alignment: Qt.AlignHCenter
                            visible: !mediaBackend.pLoadMoreBtnVisible && mediaBackend.pSelectedTabIndex === 0

                            Text {
                                text: qsTranslate("QObject", "Enjoying Moments, Share Your feedback")
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.white
                            }
                            UiButton {
                                text: qsTranslate("QObject", "Share Feedback")
                                pSize: UiTheme.buttons.sizes.medium
                                pColor: UiTheme.buttons.colors.accent
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    Qt.openUrlExternally("https://www.research.net/r/9DH2YHR")
                                }
                            }
                        }
                    }

                    delegate: UiColumnLayout {
                        id: iGridItemCol
                        spacing: 8
                        width: (model.isVisible ? 204 : 0) * ((typeof(uiBackend) !== "undefined") ? parseFloat(uiBackend.confGetString("bst.ui_scale_factor")) : 1.0)
                        height: (model.isVisible ? 155 : 0) * ((typeof(uiBackend) !== "undefined") ? parseFloat(uiBackend.confGetString("bst.ui_scale_factor")) : 1.0)
                        rightPadding: 12
                        bottomPadding: 12

                        Rectangle {
                            Layout.preferredWidth: 192
                            Layout.preferredHeight: 115
                            color: "transparent"

                            Image {
                                anchors.fill: parent
                                source: model.thumbnail
                                fillMode: Image.PreserveAspectFit
                                antialiasing: true
                                cache: true
                                mipmap: true
                                onStatusChanged: {
                                    if (status == Image.Ready) {
                                        sourceSize.width = Qt.binding(function() { return 192 })
                                        sourceSize.height = Qt.binding(function() { return 115 })
                                    }
                                }
                            }

                            UiImageButton {
                                anchors.centerIn: parent
                                pImageWidth: 32
                                pImageHeight: 32
                                asset: "PlayLarge"

                                onClicked: {
                                    if (model.isMoment && model.synced)
                                        mediaBackend.playMoments(model.videoId)
                                    else {
                                        mediaBackend.playVideoFile(model.filePath)
                                    }
                                }
                            }

                            UiColumnLayout {
                                id: iErrorOverlay
                                anchors.fill: parent
                                visible: !model.synced && !model.isPublishing && model.isMoment && uiBackend.confGetBool("bst.feature.auto_upload_nowgg_moments") && uiBackend.confGetBool("bst.enable_auto_upload_recording") && !uiBackend.isMsiOem
                                color: UiTheme.colors.overLayGray
                                spacing: 12
                                pMouseArea {
                                    enabled: true
                                    hoverEnabled: true
                                    anchors.fill: iErrorOverlay
                                    onEntered: pMouseArea.cursorShape = Qt.PointingHandCursor
                                    onExited: pMouseArea.cursorShape = Qt.ArrowCursor
                                    onReleased: pMouseArea.cursorShape = Qt.PointingHandCursor
                                    onPressed: {
                                        pMouseArea.cursorShape = Qt.ClosedHandCursor
                                        mediaBackend.uploadMoments(model.filePath, model.isMoment)
                                    }
                                }
                                Item {Layout.fillHeight: true}

                                UiImage {
                                    pImageWidth: 20
                                    pImageHeight: 20
                                    asset: "ErrorOutline"
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                UiRowLayout {
                                    Layout.topMargin: 12
                                    leftPadding: 8
                                    rightPadding: 8
                                    topPadding: 6
                                    bottomPadding: 6
                                    spacing: 6
                                    color: "white"
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: 140

                                    Item { Layout.fillWidth: true }
                                    UiImage {
                                        asset: "CloudUpload"
                                        pImageWidth: 12
                                        pImageHeight: 12
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: qsTranslate("QObject", "Retry upload")
                                        font: UiTheme.fonts.buttonSmall
                                        color: UiTheme.colors.primary70
                                        Layout.maximumHeight: 28
                                        Layout.maximumWidth: 106
                                        wrapMode: Text.Wrap
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                    Item { Layout.fillWidth: true }
                                }

                                Item {Layout.fillHeight: true}
                            }
                        }

                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: model.name
                                elide: Text.ElideRight
                                font: UiTheme.fonts.bodyMedium
                                color: UiTheme.colors.primary10
                                visible: !model.editMode
                                Layout.preferredWidth: 140
                            }

                            UiTextImageField {
                                id: iRecordingNameTextfield
                                visible: model.editMode
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 16
                                pAsset: "SaveSmall"
                                pSize: UiTheme.textFields.sizes.small
                                pReadOnly: false
                                pImageTooltip: qsTranslate("QObject", "Save")
                                onEditingFinished: {
                                    if (model.editMode)
                                        iGridItemCol.fRenameVideo()
                                }
                                onClicked: iGridItemCol.fRenameVideo()

                                onVisibleChanged: {
                                    if (visible) {
                                        iRecordingNameTextfield.text = model.name
                                        iRecordingNameTextfield.pReadOnly = false
                                        iRecordingNameTextfield.forceActiveFocus()
                                        iRecordingNameTextfield.cursorPosition = iRecordingNameTextfield.text.length
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            UiImageButton {
                                asset: model.synced ? "CloudSynced" : "CloudUpload"
                                pImageWidth: 16
                                pImageHeight: 16
                                visible: !model.isPublishing && uiBackend.confGetBool("bst.feature.show_moments") && uiBackend.confGetBool("bst.feature.nowgg_cloud_upload_enabled") && !uiBackend.isMsiOem
                                enabled: mediaBackend.pIsNowggAccountSignIn || model.synced || uiBackend.confGetBool("bst.guest_login_completed")
                                opacity: enabled ? 1 : 0.4
                                onClicked: {
                                    if(model.synced === false)
                                        mediaBackend.uploadMoments(model.filePath, model.isMoment)
                                }
                            }

                            Rectangle {
                                id: iCloudSyncLoaderImgRow
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                visible: model.isPublishing && uiBackend.confGetBool("bst.feature.show_moments")
                                color: "transparent"

                                UiImage {
                                    asset: "CloudSyncSubtract"
                                    pImageWidth: 11
                                    pImageHeight: 11
                                }

                                UiImage {
                                    asset: "LoaderYellow"
                                    pImageWidth: 8
                                    pImageHeight: 8
                                    anchors.rightMargin: 3
                                    anchors.bottomMargin: 4
                                    anchors.right: iCloudSyncLoaderImgRow.right
                                    anchors.bottom: iCloudSyncLoaderImgRow.bottom

                                    RotationAnimation on rotation {
                                        loops: Animation.Infinite
                                        duration: 1000
                                        from: 0
                                        to: 360
                                        direction: RotationAnimation.Clockwise
                                        running: iCloudSyncLoaderImgRow.visible
                                    }
                                }
                            }

                            UiImageButton {
                                asset: "KebabVertical"
                                pImageWidth: 16
                                pImageHeight: 16
                                onClicked: {
                                    var point = mapToGlobal(0, 0)
                                    fOpenMediaOptionsPopup(model.videoId, model.synced, model.filePath, model.isMoment, model.isPublishing, point.x, point.y)
                                }
                            }
                        }

                        function fRenameVideo() {
                            mediaBackend.setVideoNameEditMode(model.filePath, false)
                            iRecordingNameTextfield.pReadOnly = true
                            var trimmedNewName = iRecordingNameTextfield.text.trim().replace("\n","")
                            if(trimmedNewName !== "")
                            {
                                var err = mediaBackend.isVideoNameValid(trimmedNewName, model.filePath)
                                if (err === 0) {
                                    if (model.name !== trimmedNewName) {
                                        if (!mediaBackend.onRenameVideo(trimmedNewName, model.filePath))
                                            iErrorToast.fShow(pToastErrorMessagesList[4], 4000)
                                    }
                                }
                                else
                                    iErrorToast.fShow(pToastErrorMessagesList[err - 1], 4000)
                            }
                            else {
                                iErrorToast.fShow(pToastErrorMessagesList[0], 4000)
                            }
                        }
                    }

                    function scrollToTop() {
                        iMediaGalleryView.positionViewAtBeginning()
                    }
                }
            }

            Rectangle {
                visible: mediaBackend.pSelectedTabIndex === 0 || mediaBackend.pSelectedTabIndex === 1
                Layout.fillWidth: true
                height: 1
                color: UiTheme.colors.primary60
            }

            UiRowLayout {
                id: iStatusBar
                Layout.preferredHeight: 28
                leftPadding: 12
                rightPadding: 12
                spacing: 12
                visible: mediaBackend.pSelectedTabIndex === 0 || mediaBackend.pSelectedTabIndex === 1

                Text {
                    elide: Text.ElideRight
                    text: qsTranslate("QObject", "%1 items").arg(iMediaGalleryView.count)
                    font: UiTheme.fonts.bodySmallest
                    color: UiTheme.colors.primary20
                }

                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: UiTheme.colors.primary60
                    Layout.leftMargin: 4
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }

                UiImage {
                    id: iLoaderStatusImage
                    pImageWidth: 12
                    pImageHeight: 12
                    asset: "Loader_bright"
                    visible: false
                    Layout.alignment: Qt.AlignHCenter

                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        duration: 1000
                        from: 0
                        to: 360
                        direction: RotationAnimation.Clockwise
                        running: iLoaderStatusImage.visible
                    }
                }
                UiImage {
                    id: iStatusImage
                    pImageWidth: 12
                    pImageHeight: 12
                    visible: false
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    id: iStatusText
                    Layout.alignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: ""
                    font: UiTheme.fonts.bodySmallest
                    color: UiTheme.colors.primary20
                    Layout.leftMargin: -8
                    visible: text != ""
                }
            }
        }

        UiToast {
            id: iErrorToast
            pMaximumWidth: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            color: UiTheme.colors.dangerTranslucent
            border.color: UiTheme.colors.dangerNormal
        }
    }

    function fOpenMediaOptionsPopup(videoId, uploaded, filePath, isMoment, isPublishing, x, y) {
        if (pMediaOptionsWin != null) {
            pMediaOptionsWin.close()
        }

        pMediaOptionsWin = iMediaOptionsPopupComponent.createObject(iMediaGalleryWindow, {"videoId": videoId, "uploaded": uploaded, "filePath":filePath, "isMoment": isMoment, "isPublishing": isPublishing})
        pMediaOptionsWin.x = x
        pMediaOptionsWin.y = y
        pMediaOptionsWin.show()
    }

    function fSetStatusText(text, statusImgAsset = "", isRotatingImgVisible = false, isImgVisible = false) {
        iStatusText.text = text
        iLoaderStatusImage.visible = isRotatingImgVisible
        iStatusImage.visible = isImgVisible
        if(isImgVisible)
            iStatusImage.asset = statusImgAsset
    }
}
