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

import QtQuick.Dialogs

WebEngineView {
    id: iWebEngineView
    focus: true
    url: "about:blank"

    settings.javascriptEnabled: true
    settings.javascriptCanOpenWindows: true
    settings.javascriptCanAccessClipboard: true
    settings.javascriptCanPaste: true
    settings.fullScreenSupportEnabled: true
    settings.dnsPrefetchEnabled: true
    profile.httpAcceptLanguage: uiBackend.getPreferredLocaleWeighted()

    property bool pIsLoading: false
    property Window pParentWin: null

    Component {
        id: iFileDialogComponent
        FileDialog {
            id: iFileDialog

            property FileDialogRequest request

            fileMode: request.mode === FileDialogRequest.FileModeOpenMultiple
                      ? FileDialog.OpenFiles : request.mode === FileDialogRequest.FileModeSave
                        ? FileDialog.SaveFile : FileDialog.OpenFile

            onAccepted: {
                request.dialogAccept(selectedFiles)
            }
            onRejected: {
                request.dialogReject()
            }
        }
    }

    Component {
        id: iFolderDialogComponent
        FolderDialog {
            id: iFolderDialog

            property FileDialogRequest request

            onAccepted: {
                request.dialogAccept([selectedFolder])
            }
            onRejected: {
                request.dialogReject()
            }
        }
    }


    onLoadProgressChanged: {
        if (iWebEngineView.loadProgress > 0 && iWebEngineView.loadProgress <= 99)
            iWebEngineView.pIsLoading = true
        else {
            iWebEngineView.pIsLoading = false

            // TODO :: update this default granting of audio video permissions to all websites
            iWebEngineView.grantFeaturePermission(iWebEngineView.url, WebEngineView.MediaAudioCapture, true);
            iWebEngineView.grantFeaturePermission(iWebEngineView.url, WebEngineView.MediaVideoCapture, true);
            iWebEngineView.grantFeaturePermission(iWebEngineView.url, WebEngineView.MediaAudioVideoCapture, true);
        }
    }

    onFeaturePermissionRequested: {
        // TODO :: grant requested permissions via a allow/deny popup
        console.info("Browser :: feature permission requested - " + feature + " .. " + securityOrigin)
        iWebEngineView.grantFeaturePermission(securityOrigin, feature, true);
    }

    onFileDialogRequested: function(request) {
        console.info("Browser :: file dialog requested, mode: " + request.mode)
        request.accepted = true
        if (request.mode === FileDialogRequest.FileModeUploadFolder) {
            iFolderDialogComponent.createObject(null, { "request" : request }).open()
        }
        else {
            iFileDialogComponent.createObject(null, { "request" : request }).open()
        }
    }

    onNewWindowRequested: function(request) {
        console.info("Browser :: onNewWindowRequested clicked url = " + request.requestedUrl.toString())
        if (!request.userInitiated) {
            console.info("Warning: Blocked a popup window.")
        }
        else if (request.destination === WebEngineView.NewViewInBackgroundTab) {
            var backgroundTab = fCreateTab(false)
            request.openIn(backgroundTab)
        }
        else {
            fCreateTab()
            request.openIn(pCurrentWebView)
            plrBackend.setIsAndroidTabSelected(false)
        }
//        else {
//            var iBrowserComponent = Qt.createComponent("UiBrowserWindow.qml")
//            if (iBrowserComponent.status === Component.Ready) {
//                var win = iBrowserComponent.createObject(null, {
//                                                             "x": 300,
//                                                             "y": 50,
//                                                             "width": 1000,
//                                                             "height": 800
//                                                         })
//                win.pCurrentWebView.url = request.requestedUrl.toString()
//                request.openIn(win.pCurrentWebView)
//            }
//        }
    }

    onNavigationRequested: function(request) {
        if (request.navigationType === WebEngineNavigationRequest.LinkClickedNavigation) {
            console.info("Browser :: onNavigationRequested clicked url = " + request.url.toString())
            request.accept()
        }
    }

    onRenderProcessTerminated: function(terminationStatus, exitCode) {
        var status = "";
        switch (terminationStatus) {
        case WebEngineView.NormalTerminationStatus:
            status = "(normal exit)"
            break
        case WebEngineView.AbnormalTerminationStatus:
            status = "(abnormal exit)"
            break
        case WebEngineView.CrashedTerminationStatus:
            status = "(crashed)"
            break
        case WebEngineView.KilledTerminationStatus:
            status = "(killed)"
            break
        }

        console.info("Browser :: Render process exited with code " + exitCode + " " + status)
        iWebEngineView.reload()
    }

    onWindowCloseRequested: function() {
        //console.info("Browser :: windowCloseRequested type = "+url)
        fRemoveTabFromUrl(url)
    }

    onJavaScriptConsoleMessage: function(level, message, lineNumber, sourceID) {
        console.info(iWebEngineView.renderProcessPid + " " + lineNumber + " [WebEngineConsoleLog] " + level + ": " + message)
    }
}
