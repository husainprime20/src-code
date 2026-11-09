/*
 * Copyright (C) 2020-2024 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import Qt.labs.platform 1.0
import QtWebEngine

import UiToolTipControl 1.0

Window {
    id: iPlayerWebBrowser
    color: UiTheme.colors.primary70
    flags: Qt.Tool | Qt.FramelessWindowHint
    title: uiBackend.productName + " Browser"
    screen: transientParent.screen

    property Item pCurrentWebView: iTabBar.currentIndex >= 0 ? iWebStackLayout.children[iTabBar.currentIndex] : null
    property UiWindowedPopup pDownloadListWin: null

    Component.onCompleted: {
        // if (!uiBackend.confGetBool("bst.gaming_browser_onboarding_done")) {
        //     fCreateWelcomeTab()
        //     uiBackend.confSetBool("bst.gaming_browser_onboarding_done", true)
        //     uiBackend.confCommit()
        // } else {
        //     fCreateHomeTab()
        // }
        fCreateHomeTab()
    }

    ListModel {
        id: downloadModel
        property var downloads: []
    }

    function appendDownload(request) {
        downloadModel.append(request)
        downloadModel.downloads.push(request)
    }

    Component {
        id: iDownloadMenuComponent
        UiWindowedPopup {
            id: iDownloadMenu
            shadowVisibility: false
            x: iShowDownlaodsBtn.mapToGlobal(0, 0).x - width + iShowDownlaodsBtn.width + 10
            y: iShowDownlaodsBtn.mapToGlobal(0, 0).y + iShowDownlaodsBtn.height + 8
            contentWidth: 280
            contentHeight: iDownloadMenuLayout.implicitHeight

            UiColumnLayout {
                id: iDownloadMenuLayout
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8
                color: UiTheme.colors.primary70
                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    topPadding: 10
                    bottomPadding: 10
                    leftPadding: 12
                    rightPadding: 12
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Downloads")
                        color:  UiTheme.colors.primary10
                        font : UiTheme.fonts.titleSmall
                        elide: Text.ElideRight
                    }
                    UiImageButton {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        asset: "CloseSmall"
                        pImageWidth: 12
                        pImageHeight: 12
                        UiToolTip.text: qsTranslate("QObject", "Close")
                        onClicked: {
                            iDownloadMenu.close()
                        }
                    }
                }
                ListView {
                    id: iDownloadsList
                    Layout.fillWidth: true
                    implicitHeight: Math.min(contentHeight, 360)
                    visible: downloadModel.count != 0
                    model: downloadModel
                    orientation: ListView.Vertical
                    clip: true
                    spacing: 4

                    ScrollBar.vertical: UiScrollBar {
                        policy: iDownloadsList.contentHeight > iDownloadsList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    }

                    delegate: UiColumnLayout {
                        id: iDownloadRow
                        anchors.left: parent != null ? parent.left : undefined
                        anchors.right: parent != null ? parent.right : undefined
                        color: pMouseArea.containsMouse ? UiTheme.colors.primary50 : "transparent"
                        padding: 12
                        spacing: 8
                        pMouseArea {
                            anchors.fill: iDownloadRow
                            enabled: true
                            hoverEnabled: true
                            cursorShape: iDownloadRow.pMouseArea.containsMouse ?
                                             iDownloadRow.pMouseArea.containsPress ?
                                                 Qt.ClosedHandCursor : Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                plrBackend.openFolderPath(downloadDirectory)
                                iDownloadMenu.close()
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            UiImage {
                                asset: "File"
                                pImageWidth: 12
                                pImageHeight: 12
                                Layout.alignment: Qt.AlignTop
                            }
                            UiColumnLayout {
                                spacing: 2
                                Layout.fillWidth: true
                                Text {
                                    text: downloadFileName
                                    Layout.fillWidth: true
                                    Layout.maximumHeight: 48
                                    font: UiTheme.fonts.titleExtraSmall
                                    color: UiTheme.colors.primary20
                                    elide: Text.ElideRight
                                    wrapMode: Text.WrapAnywhere
                                }
                                UiRowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Text {
                                        text: {
                                            // Convert bytes to MB and round to 2 decimal places
                                            var totalMB = downloadModel.downloads[index] ? (downloadModel.downloads[index].totalBytes / (1024 * 1024)).toFixed(2) : 0
                                            var receivedMB = downloadModel.downloads[index] ? (downloadModel.downloads[index].receivedBytes / (1024 * 1024)).toFixed(2) : 0

                                            if (downloadModel.downloads[index] && downloadModel.downloads[index].isFinished)
                                                return totalMB + " " + qsTranslate("QObject", "MB")
                                            else
                                                return receivedMB + "/" + totalMB + " " + qsTranslate("QObject", "MB")
                                        }

                                        font: UiTheme.fonts.bodySmallest
                                        color: UiTheme.colors.primary20
                                    }
                                    Rectangle {
                                        Layout.preferredHeight: 2
                                        Layout.preferredWidth: 2
                                        color: UiTheme.colors.primary20
                                        radius: 1
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: {
                                            if (downloadModel.downloads[index] && downloadModel.downloads[index].isFinished)
                                                return qsTranslate("QObject", "Done")
                                            else
                                                return qsTranslate("QObject", "Downloading")
                                        }

                                        font: UiTheme.fonts.bodySmallest
                                        color: UiTheme.colors.primary20
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            UiImageButton {
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                asset: "CloseSmall"
                                pImageWidth: 12
                                pImageHeight: 12
                                visible: downloadModel.downloads[index] ? downloadModel.downloads[index].isFinished : false
                                UiToolTip.text: qsTranslate("QObject", "Remove")
                                onClicked: {
                                    var download = downloadModel.downloads[index]
                                    downloadModel.downloads = downloadModel.downloads.filter(function (el) {
                                        return el.id !== download.id
                                    })
                                    downloadModel.remove(index)
                                }
                            }
                        }
                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: downloadModel.downloads[index] ? !downloadModel.downloads[index].isFinished : false
                            UiProgressBar {
                                id: iProgressBar
                                from: 0
                                to: 99
                                Layout.preferredHeight: 4
                                Layout.fillWidth: true
                                value: downloadModel.downloads[index] ? (downloadModel.downloads[index].receivedBytes / downloadModel.downloads[index].totalBytes) * 100 : 0
                            }
                            UiImageButton {
                                Layout.alignment: Qt.AlignRight
                                asset: "CloseSmall"
                                pImageWidth: 12
                                pImageHeight: 12
                                UiToolTip.text: qsTranslate("QObject", "Cancel")
                                onClicked: {
                                    var download = downloadModel.downloads[index]
                                    download.cancel()
                                    downloadModel.downloads = downloadModel.downloads.filter(function (el) {
                                        return el.id !== download.id
                                    })
                                    downloadModel.remove(index)
                                }
                            }
                        }
                    }
                }
                UiColumnLayout {
                    visible: downloadModel.count == 0
                    Layout.fillWidth: true
                    leftPadding: 12
                    rightPadding: 12
                    topPadding: 2
                    bottomPadding: 2
                    UiRowLayout {
                        Layout.fillWidth: true
                        padding: 8
                        border.width: 1
                        border.color: UiTheme.colors.primary40
                        spacing: 8
                        UiImage {
                            asset: "InfoWhite"
                            pImageWidth: 16
                            pImageHeight: 16
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "No recent downloads")
                            color:  UiTheme.colors.primary30
                            font : UiTheme.fonts.bodyLarge
                            elide: Text.ElideRight
                        }
                    }
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: UiTheme.colors.primary50
                    }
                    UiImageLabel {
                        Layout.fillWidth: true
                        padding: 12
                        pText : qsTranslate("QObject", "Open downloads folder")
                        pImageAsset: "Folder"
                        pBackgroundColor: pHovered ? UiTheme.colors.primary50 : "transparent"
                        onClicked: {
                            plrBackend.openFolderPath(StandardPaths.writableLocation(StandardPaths.DownloadLocation))
                            iDownloadMenu.close()
                        }
                    }
                }
            }
        }
    }

    WebEngineProfile {
        id: iWebEngineProfile

        onDownloadRequested: function(request) {
            appendDownload(request)
            request.accept()
        }
    }

    Component {
        id: iWebComponent
        PlrWebEngineView {
            pParentWin: iPlayerWebBrowser

            onFullScreenRequested: function(request) {
                console.info("Browser :: fullscreen requested")
                plrBackend.changeFullScreenState(request.toggleOn)
                request.accept()
            }
        }
    }

    Component {
        id: iTabBtnComp
        TabButton {
            id: iTabBtn
            width: Math.min((iPlayerWebBrowser.width - 36) / iTabBar.count, (iPlayerWebBrowser.width - 36) / 6) + (iCreateNewTab.visible ? iCreateNewTab.width : 0)
            anchors.top: parent != null ? parent.top : undefined
            anchors.bottom: parent != null ? parent.bottom : undefined
            verticalPadding: 0
            horizontalPadding: 0
            spacing: 0

            background: Rectangle {
                color: UiTheme.colors.primary100
            }

            property int index: 0
            property Item tabWebView: null

            contentItem: UiRowLayout {
                color: iTabBtn.index === iTabBar.currentIndex ? UiTheme.colors.primary70 : UiTheme.colors.primary90
                leftPadding: 8
                spacing: 8
                clip: true
                UiImage {
                    source: iTabBtn.tabWebView == null || iTabBtn.tabWebView.pIsLoading
                            ? "qrcAssets/SiteLoader.svg"
                            : iTabBtn.tabWebView.icon && iTabBtn.tabWebView.icon !== ""
                              ? iTabBtn.tabWebView.icon
                              : "qrcAssets/DefaultFavicon.svg"
                    pImageWidth: 16
                    pImageHeight: 16
                    rotation: iTabBtn.tabWebView && iTabBtn.tabWebView.pIsLoading ? 0 : 0
                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        duration: 2000
                        from: 0
                        to: 360
                        direction: RotationAnimation.Clockwise
                        running: iTabBtn.tabWebView && iTabBtn.tabWebView.pIsLoading
                    }
                }
                Text {
                    id: iTitletext
                    Layout.fillWidth: true
                    font : UiTheme.fonts.bodySmall
                    text: iTabBtn.tabWebView
                          ? iTabBtn.tabWebView.url.toString() === "about:blank"
                            ? "about:blank"
                            : iTabBtn.tabWebView.title
                          : "about:blank"
                    elide: Text.ElideRight
                    color: iTabBtn.index === iTabBar.currentIndex ? UiTheme.colors.white : UiTheme.colors.primary20
                }
                UiImageButton {
                    asset: "CloseIcon"
                    pImageWidth: 12
                    pImageHeight: 12
                    onClicked: fRemoveTab(iTabBtn.index)
                    activeFocusOnTab: true
                }
                UiRowLayout {
                    Rectangle {
                        Layout.preferredHeight: 20
                        Layout.preferredWidth: iTabBtn.index === iTabBar.currentIndex ? 0 : 1
                        color: UiTheme.colors.primary60
                    }
                    Rectangle {
                        id: iCreateNewTab
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        color: UiTheme.colors.primary90
                        visible: iTabBtn.index === iTabBar.count - 1
                        activeFocusOnTab: true
                        MouseArea {
                            id: mouseArea
                            enabled: true
                            anchors.fill: iCreateNewTab
                            onClicked: {
                                fCreateTab()
                                pCurrentWebView.url = plrBackend.pBrowserHomeUrl
                            }
                        }
                        UiImage {
                            asset: "AddSmall"
                            pImageWidth: 12
                            pImageHeight: 12
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    UiColumnLayout {
        spacing: 4
        anchors.fill: parent
        anchors.margins: iPlayerWebBrowser.visibility !== ApplicationWindow.FullScreen ? 2 : 0

        TabBar {
            id: iTabBar
            implicitHeight: 32
            Layout.fillWidth: true
            visible: iPlayerWebBrowser.visibility !== ApplicationWindow.FullScreen

            background: Rectangle {
                color: UiTheme.colors.primary90
            }

            onCountChanged: {
                if (count == 0) {
                    plrBackend.setIsAndroidTabSelected(true)
                }
            }
        }

        UiRowLayout {
            Layout.fillWidth: true
            color: UiTheme.colors.primary70
            spacing: 8
            visible: iPlayerWebBrowser.visibility !== ApplicationWindow.FullScreen

            UiRowLayout {
                leftPadding: 8
                rightPadding: 8
                topPadding: 4
                bottomPadding: 4
                spacing: 12
                Layout.fillWidth: true
                UiImageButton {
                    asset: "Backward"
                    pImageWidth: 16
                    pImageHeight: 16
                    onClicked: pCurrentWebView.goBack()
                    enabled: pCurrentWebView && (pCurrentWebView.canGoBack ? pCurrentWebView.canGoBack : false)
                    activeFocusOnTab: true
                }
                UiImageButton {
                    asset: "Forward"
                    pImageWidth: 16
                    pImageHeight: 16
                    onClicked: pCurrentWebView.goForward()
                    enabled: pCurrentWebView && (pCurrentWebView.canGoForward ? pCurrentWebView.canGoForward : false)
                    activeFocusOnTab: true
                }
                UiImageButton {
                    asset: pCurrentWebView && pCurrentWebView.pIsLoading ? "CloseIcon" : "Reload"
                    pImageWidth: 16
                    pImageHeight: 16
                    onClicked: pCurrentWebView && pCurrentWebView.pIsLoading ? pCurrentWebView.stop() : pCurrentWebView.reload()
                    activeFocusOnTab: true
                }
                UiTextField {
                    id: iAddressBar
                    Layout.fillWidth: true
                    pSize: UiTheme.textFields.sizes.small
                    pColor: UiTheme.textFields.colors.dark
                    text: pCurrentWebView && pCurrentWebView.url
                          ? (uiBackend.getUrlWithoutParams(pCurrentWebView.url.toString()) !== uiBackend.getUrlWithoutParams(plrBackend.pBrowserHomeUrl) &&
                             uiBackend.getUrlWithoutParams(pCurrentWebView.url.toString()) !== uiBackend.getUrlWithoutParams(plrBackend.pBrowserWelcomeUrl))
                            ? pCurrentWebView.url.toString()
                            : ""
                          : ""

                    onAccepted: {
                        if (uiBackend.isUrlValid(text))
                            pCurrentWebView.url = uiBackend.fromUserInputInBrowser(text)
                        else
                            pCurrentWebView.url = "https://www.google.com/search?q=" + text
                    }
                    placeholderText: qsTranslate("QObject", "Search Google or type a URL")
                }
                UiImageButton {
                    id: iShowDownlaodsBtn
                    asset: "DownloadList"
                    Layout.alignment: Qt.AlignRight
                    pImageWidth: 16
                    pImageHeight: 16
                    onClicked: {
                        fOpenDownloadListPopup()
                    }
                    activeFocusOnTab: true
                }
            }
        }


        StackLayout {
            id: iWebStackLayout
            focus: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: iTabBar.currentIndex

            Repeater {
                model: ObjectModel {
                    id: iStackContainer
                }
            }
        }
    }

    function fCreateTab(switchTab = true) {
        var webItem = iWebComponent.createObject(iWebStackLayout)
        if (webItem !== null) {
            plrBackend.setWebEngineProfile(iWebEngineProfile)
            webItem.profile = plrBackend.getWebEngineProfile()
            iStackContainer.append(webItem)
            var item = iTabBtnComp.createObject(iTabBar, {"index": iTabBar.count, "tabWebView": webItem})
            if (item !== null) {
                iTabBar.addItem(item)
                if (switchTab)
                    iTabBar.currentIndex = iTabBar.count - 1
            }
        }
        return webItem
    }

    function fRemoveTab(index) {
        var newCurIdx = iTabBar.currentIndex
        if (index < iTabBar.currentIndex)
            newCurIdx = newCurIdx - 1
        else if (index === iTabBar.currentIndex) {
            if (iTabBar.currentIndex == (iTabBar.count-1))
                newCurIdx = iTabBar.count - 2
        }

        var tabBtn = iTabBar.itemAt(index)
        if (tabBtn !== null) {
            var tabPage = iStackContainer.get(index)
            if (tabPage) {
                iStackContainer.remove(index)
                tabPage.destroy()
            }

            iTabBar.removeItem(tabBtn)
            for (var i = 0; i < iTabBar.count; ++i) {
                var btn = iTabBar.itemAt(i)
                btn.index = i
            }

            if (iTabBar.count != 0)
                iTabBar.currentIndex = newCurIdx
        }
    }

    function fRemoveTabFromUrl(url) {
        var indexToRemove =0;
        var tabCount = iTabBar.count
        for (var i = 0; i < tabCount; ++i) {
            var item = iTabBar.itemAt(i)
            if (item !== null) {
                var tabPage = iStackContainer.get(i)
                if (tabPage.url === url) {
                    console.info("remove tab.."+tabPage.url)
                    indexToRemove = i;
                }
            }
        }
        fRemoveTab(indexToRemove)
    }

    function fHandleFullscreen(isFullscreen) {
        if (isFullscreen)
            iPlayerWebBrowser.showFullScreen()
        else {
            pCurrentWebView.fullScreenCancelled()
            iPlayerWebBrowser.showNormal()
        }
    }

    function fCreateHomeTab(forced = false) {
        if (iTabBar.count === 0 || forced) {
            fCreateTab()
            pCurrentWebView.url = plrBackend.pBrowserHomeUrl
        }
    }

    function fCreateWelcomeTab() {
        fCreateTab()
        pCurrentWebView.url = plrBackend.pBrowserWelcomeUrl
    }

    function fCloseAllTabs() {
        var tabCount = iTabBar.count
        for (var i = 0; i < tabCount; ++i) {
            var item = iTabBar.itemAt(0)
            if (item !== null) {
                var tabPage = iStackContainer.get(0)
                if (tabPage) {
                    iStackContainer.remove(0)
                    tabPage.destroy()
                }
                iTabBar.removeItem(item)
            }
        }
    }

    function fGoToNextOpenTab() {
        if (iTabBar.count > 1) {
            var nextTabIdx = (iTabBar.currentIndex + 1) % iTabBar.count
            iTabBar.currentIndex = nextTabIdx
        }
    }

    function fGoToPreviousOpenTab() {
        if (iTabBar.count > 1) {
            var nextTabIdx = (iTabBar.count + iTabBar.currentIndex - 1) % iTabBar.count
            iTabBar.currentIndex = nextTabIdx
        }
    }

    function fGoToTabNumber(tabNum) {
        if ((tabNum - 1) === iTabBar.currentIndex)
            return

        if (tabNum === -1)
            tabNum = iTabBar.count

        if (tabNum <= iTabBar.count)
            iTabBar.currentIndex = tabNum - 1
    }

    function fCloseCurrentTab() {
        fRemoveTab(iTabBar.currentIndex)
    }

    function fFocusAddressBar() {
        iAddressBar.focus = true
        iAddressBar.selectAll()
    }

    function fReloadWebpage() {
        if (pCurrentWebView && !pCurrentWebView.pIsLoading)
            pCurrentWebView.reload()
    }

    function fOpenDownloadListPopup() {
        if (pDownloadListWin != null) {
            if (pDownloadListWin.visible)
                pDownloadListWin.close()
            return
        }

        pDownloadListWin = iDownloadMenuComponent.createObject(iPlayerWebBrowser)
        pDownloadListWin.show()
    }

    function fSetLoacleInHomeTabs() {
        var homeUrl= uiBackend.getUrlWithoutParams(plrBackend.pBrowserHomeUrl)
        var welcomeUrl = uiBackend.getUrlWithoutParams(plrBackend.pBrowserWelcomeUrl)
        var tabCount = iTabBar.count
        for (var i = 0; i < tabCount; ++i) {
            var tabBtn = iTabBar.itemAt(i)
            if (tabBtn !== null) {
                var tabPage = iWebStackLayout.children[i]
                if (tabPage) {
                    if(tabPage.url.toString().indexOf(homeUrl) !== -1){
                        tabPage.url = plrBackend.pBrowserHomeUrl
                    }
                    else if(tabPage.url.toString().indexOf(welcomeUrl) !== -1){
                        tabPage.url = plrBackend.pBrowserWelcomeUrl
                    }
                }
            }
        }
    }

    function fMuteBrowserAudio(isMute) {
        var tabCount = iTabBar.count
        for (var i = 0; i < tabCount; ++i) {
            var tabBtn = iTabBar.itemAt(i)
            if (tabBtn !== null) {
                var tabPage = iWebStackLayout.children[i]
                if(tabPage) {
                    tabPage.audioMuted = isMute
                }
            }
        }
    }
}
