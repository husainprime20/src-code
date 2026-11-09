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
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import QtWebEngine
import QtWebChannel 1.5

Window {
    id: iBrowserWindow

    property Item pCurrentWebView: iTabBar.currentIndex >= 0 ? iWebStackLayout.children[iTabBar.currentIndex] : null
    property int pPreviousWindowState: 2
    property int pWindowStateBeforeMinimized: -1
    property bool loaded: false

    property bool resizeEnabled: true
    property real prevWidth: 1240
    property real prevHeight: 720

    onWidthChanged: function(width) {
        if (resizeEnabled)
            prevWidth = width
    }

    onHeightChanged: function(height) {
        if (resizeEnabled)
            prevHeight = height
    }

    flags: Qt.Window | Qt.FramelessWindowHint
    title: uiBackend.productName + " Browser"
    color: "transparent"
    visible: true

    onScreenChanged: {
        if (loaded) {
            iBrowserWindow.width = prevWidth
            iBrowserWindow.height = prevHeight
        }
    }

    Component.onCompleted: {
        fCreateTab()
        loaded = true
    }

    onClosing: {
        fCloseAllTabs()
        iBrowserWindow.destroy()
    }

    onVisibilityChanged: function(visibility) {
        if (visibility === Window.Hidden)
            return

        //setting variables required to set the correct windowState when restored from minimized windowState
        if (visibility === Window.Minimized)
            pWindowStateBeforeMinimized = pPreviousWindowState
        else
            pPreviousWindowState = visibility

        //handling to set the correct windowState when restored from minimized state
        if (pWindowStateBeforeMinimized === Window.Maximized && visibility === Window.Windowed) {
            pWindowStateBeforeMinimized = -1
            iBrowserWindow.showMaximized()
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        property int edges: 0
        property int edgeOffest: iBrowserWindow.visibility === Window.Maximized ? 0 : 3

        function setEdges(x, y) {
            edges = 0
            if(x < edgeOffest) edges |= Qt.LeftEdge
            if(x > (width - edgeOffest))  edges |= Qt.RightEdge
            if(y < edgeOffest) edges |= Qt.TopEdge
            if(y > (height - edgeOffest)) edges |= Qt.BottomEdge
        }

        cursorShape: {
            return !containsMouse ? Qt.ArrowCursor : edges == 3 || edges == 12
                                    ? Qt.SizeFDiagCursor : edges == 5 || edges == 10
                                      ? Qt.SizeBDiagCursor : edges & 9
                                        ? Qt.SizeVerCursor : edges & 6
                                          ? Qt.SizeHorCursor : Qt.ArrowCursor
        }

        onPositionChanged: setEdges(mouseX, mouseY)
        onPressed: {
            setEdges(mouseX, mouseY)
            if(edges && containsMouse) {
                startSystemResize(edges)
            }
        }
    }

    WebEngineProfile {
        id: iWebEngineProfile
    }

    Component {
        id: iWebComponent
        PlrWebEngineView {
            pParentWin: iBrowserWindow
            onWindowCloseRequested: {
                fRemoveTab(iTabBar.currentIndex)
            }
        }
    }

    Component {
        id: iTabBtnComp
        TabButton {
            id: iTabBtn
            width: Math.min((iBrowserWindow.width - 36) / iTabBar.count, (iBrowserWindow.width - 36) / 4) + (iCreateNewTab.visible ? iCreateNewTab.width : 0)
            height: 32
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
                    source: iTabBtn.tabWebView
                            ? iTabBtn.tabWebView.pIsLoading
                              ? "qrcAssets/SiteLoader.svg"
                              : iTabBtn.tabWebView.url.toString() === "about:blank"
                                ? "qrcAssets/DefaultFavicon.svg"
                                : iTabBtn.tabWebView.icon ? iTabBtn.tabWebView.icon : "qrcAssets/DefaultFavicon.svg"
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
                    text: iTabBtn.tabWebView
                          ? iTabBtn.tabWebView.url.toString() === "about:blank"
                            ? qsTranslate("QObject", "New Tab")
                            : iTabBtn.tabWebView.title ? iTabBtn.tabWebView.title : qsTranslate("QObject", "New Tab")
                          : qsTranslate("QObject", "New Tab")
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
        anchors.fill: parent
        padding: 1
        color: UiTheme.colors.primary60

        UiRowLayout {
            id: iTopBar
            Layout.preferredHeight: 32
            Layout.fillWidth: true
            color: UiTheme.colors.primary90

            pMouseArea {
                enabled: true
                anchors.fill: iTopBar
                property var startingPosition
                property bool isPressed: false

                onPressed: function(mouse) {
                    isPressed = true
                    resizeEnabled = false
                    startingPosition  = Qt.point(mouse.x, mouse.y)
                }
                onReleased: {
                    isPressed = false
                    resizeEnabled = true
                    if (iBrowserWindow.y < Screen.virtualY) {
                        iBrowserWindow.y = Screen.virtualY
                    }
                }

                onPositionChanged: function(mouse) {
                    if (isPressed) {
                        var delta = Qt.point(mouse.x - startingPosition.x, mouse.y - startingPosition.y)
                        iBrowserWindow.x += delta.x
                        iBrowserWindow.y += delta.y
                    }
                }

                onDoubleClicked: {
                    iBrowserWindow.visibility === Window.Windowed ?
                                iBrowserWindow.showMaximized() :
                                iBrowserWindow.showNormal()
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                leftPadding: 10
                spacing: 8
                UiImage {
                    asset: "BlueStacksLogo"
                    pImageWidth: 20
                    pImageHeight: 20
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTranslate("QObject", "%1 Browser").arg(uiBackend.productName)
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                }
            }

            UiImageButton {
                asset: "TitlebarMinimize"
                pImageWidth: 32
                pImageHeight: 32
                onClicked: {
                    iBrowserWindow.showMinimized()
                }
            }

            UiImageButton {
                asset: "TitlebarMaximize"
                pImageWidth: 32
                pImageHeight: 32
                visible: iBrowserWindow.visibility === Window.Windowed
                onClicked: {
                    iBrowserWindow.showMaximized()
                }
            }

            UiImageButton {
                asset: "TitlebarRestore"
                pImageWidth: 32
                pImageHeight: 32
                visible: iBrowserWindow.visibility === Window.Maximized
                onClicked: {
                    iBrowserWindow.showNormal()
                }
            }

            UiImageButton {
                asset: "TitlebarClose"
                pImageWidth: 32
                pImageHeight: 32
                onClicked: {
                    iBrowserWindow.close()
                }
            }
        }

        TabBar {
            id: iTabBar
            Layout.preferredHeight: 32
            Layout.fillWidth: true

            background: Rectangle {
                color: UiTheme.colors.primary90
            }

            onCountChanged: {
                if (count == 0) {
                    iBrowserWindow.close()
                }
            }
        }

        UiRowLayout {
            id: iAddressBar
            color: UiTheme.colors.primary70
            leftPadding: 8
            rightPadding: 8
            topPadding: 4
            bottomPadding: 4
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            spacing: 8
            UiImageButton {
                asset: "Backward"
                pImageWidth: 16
                pImageHeight: 16
                onClicked: {
                    if (pCurrentWebView)
                        pCurrentWebView.goBack()
                }
                enabled: (pCurrentWebView && pCurrentWebView.canGoBack !== undefined) ? pCurrentWebView.canGoBack : false
                activeFocusOnTab: true
            }
            UiImageButton {
                asset: "Forward"
                pImageWidth: 16
                pImageHeight: 16
                onClicked: {
                    if (pCurrentWebView)
                        pCurrentWebView.goForward()
                }
                enabled: (pCurrentWebView && pCurrentWebView.canGoForward !== undefined) ? pCurrentWebView.canGoForward : false
                activeFocusOnTab: true
            }
            UiImageButton {
                asset: (pCurrentWebView && pCurrentWebView.pIsLoading) ? "CloseIcon" : "Reload"
                pImageWidth: 16
                pImageHeight: 16
                onClicked: {
                    if (pCurrentWebView) {
                        if (pCurrentWebView.pIsLoading)
                            pCurrentWebView.stop()
                        else
                            pCurrentWebView.reload()
                    }
                }
                activeFocusOnTab: true
            }
            UiTextField {
                Layout.fillWidth: true
                pSize: UiTheme.textFields.sizes.small
                text: (pCurrentWebView && pCurrentWebView.url !== undefined) ? pCurrentWebView.url : ""
                onAccepted: {
                    if (uiBackend.isUrlValid(text))
                        pCurrentWebView.url = uiBackend.fromUserInputInBrowser(text)
                    else
                        pCurrentWebView.url = "https://www.google.com/search?q=" + text
                }
                placeholderText: qsTranslate("QObject", "Search Google or type a URL")
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
            iStackContainer.append(webItem)
            plrBackend.setWebEngineProfile(iWebEngineProfile)
            webItem.profile = plrBackend.getWebEngineProfile()
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

            if (iTabBar.count != 0) {
                if (index === iTabBar.count)
                    index = iTabBar.count - 1
                iTabBar.currentIndex = index
            }
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
                    indexToRemove = i;
                }
            }
        }
        fRemoveTab(indexToRemove)
    }

    function fCloseAllTabs() {
        var tabCount = iTabBar.count
        for (var i = 0; i < tabCount; ++i) {
            var item = iTabBar.itemAt(0)
            if (item !== null) {
                if (item.tabWebView)
                    item.tabWebView.destroy()
                iTabBar.removeItem(item)
            }
        }
    }
}
