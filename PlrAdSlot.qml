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
import QtWebEngine
import QtWebChannel 1.5
import QtQuick.Shapes 1.12

import PlrGmApi 1.0
import UiToolTipControl 1.0

Rectangle {
    color: UiTheme.colors.primary60
    border.color: UiTheme.colors.primary100
    border.width: 4

    property alias pWebEngineView: iWebEngineView
    property string pAdSlotBrowserPreference: "default"
    property bool pWebViewClicked: false

    signal adSlotClicked(var clickUrl)

    WebEngineView {
        id: iWebEngineView
        focus: true
        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: 4

        settings.javascriptEnabled: true
        settings.showScrollBars: false

        onNewWindowRequested: function(request) {
            console.info("WebView :: onNewWindowRequested clicked url = " + request.requestedUrl.toString() + " isClicked..." + pWebViewClicked)
            if(!pWebViewClicked)
                return
            if (pAdSlotBrowserPreference === "bst") {
                if (iAppwin.pBrowserWindow == null) {
                    var comp = Qt.createComponent("UiBrowserWindow.qml")
                    if (comp.status === Component.Ready) {
                        iAppwin.pBrowserWindow = comp.createObject(null, {
                                                                       "x": 300,
                                                                       "y": 50,
                                                                       "width": 1000,
                                                                       "height": 800
                                                                   })
                        iAppwin.pBrowserWindow.pCurrentWebView.url = request.requestedUrl.toString()
                        request.openIn(iAppwin.pBrowserWindow.pCurrentWebView)
                    }
                }
                else {
                    var webView = iAppwin.pBrowserWindow.fCreateTab(true)
                    if (webView !== null) {
                        webView.url = request.requestedUrl.toString()
                    }
                }

                if (iAppwin.pBrowserWindow.visibility === Window.Maximized ||
                        (iAppwin.pBrowserWindow.visibility === Window.Minimized &&
                         iAppwin.pBrowserWindow.pWindowStateBeforeMinimized === Window.Maximized))
                    iAppwin.pBrowserWindow.showMaximized()
                else
                    iAppwin.pBrowserWindow.showNormal()

                iAppwin.pBrowserWindow.raise()
                iAppwin.pBrowserWindow.requestActivate()
            }
            adSlotClicked(request.requestedUrl)
            pWebViewClicked = false
        }

        onNavigationRequested: function(request) {
            if (pWebViewClicked && request.navigationType === WebEngineNavigationRequest.LinkClickedNavigation) {
                console.info("WebView :: onNavigationRequested clicked url = " + request.url.toString() + " isClicked..." + pWebViewClicked)

                if (pAdSlotBrowserPreference === "bst") {
                    if (iAppwin.pBrowserWindow == null) {
                        var comp = Qt.createComponent("UiBrowserWindow.qml")
                        if (comp.status === Component.Ready) {
                            iAppwin.pBrowserWindow = comp.createObject(null, {
                                                                           "x": 300,
                                                                           "y": 50,
                                                                           "width": 1000,
                                                                           "height": 800
                                                                       })
                            iAppwin.pBrowserWindow.pCurrentWebView.url = request.url.toString()
                        }
                    }
                    else {
                        var webView = iAppwin.pBrowserWindow.fCreateTab(true)
                        if (webView !== null) {
                            webView.url = request.url.toString()
                        }
                    }

                    if (iAppwin.pBrowserWindow.visibility == Window.Maximized)
                        iAppwin.pBrowserWindow.showMaximized()
                    else
                        iAppwin.pBrowserWindow.showNormal()

                    iAppwin.pBrowserWindow.raise()
                    iAppwin.pBrowserWindow.requestActivate()
                }
                adSlotClicked(request.url.toString())
                pWebViewClicked = false
                request.action = WebEngineNavigationRequest.IgnoreRequest
            }
        }

        onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
            console.info(iWebEngineView.renderProcessPid + " " + lineNumber + " [WebEngineConsoleLog] " + level + ": " + message)
        }

        function runJavaScriptMethod(method) {
            iWebEngineView.runJavaScript(method)
        }
    }

    MouseArea {
        id: iMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPressed: function(mouse){
            pWebViewClicked = true
            mouse.accepted = false
        }
        onEntered: cursorShape =  Qt.PointingHandCursor
        onExited: cursorShape =  Qt.ArrowCursor
    }

}
