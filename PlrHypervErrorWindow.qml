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

import UiToolTipControl 1.0

Window {
    id: iHypervDiagnosePopup
    width: 440 + 2 * shadowContainer.shadowThickness
    height: iHypervDiagnoseLayout.implicitHeight + 2 * shadowContainer.shadowThickness
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    visible: true

    property bool diagonosisRequired: true
    property int diagonosisExitCode: -1

    onVisibleChanged: {
        if (visible) {
            if (iHypervDiagnosePopup.transientParent != null) {
                iHypervDiagnosePopup.x = Qt.binding(function() {
                    var messageWindowX = iHypervDiagnosePopup.transientParent.x + (iHypervDiagnosePopup.transientParent.width - iHypervDiagnosePopup.width) / 2
                    if (messageWindowX < iHypervDiagnosePopup.transientParent.screen.virtualX)
                        messageWindowX = iHypervDiagnosePopup.transientParent.screen.virtualX
                    if(messageWindowX + iHypervDiagnosePopup.width > iHypervDiagnosePopup.transientParent.screen.virtualX + iHypervDiagnosePopup.transientParent.screen.width)
                        messageWindowX = iHypervDiagnosePopup.transientParent.screen.virtualX + iHypervDiagnosePopup.transientParent.screen.width - iHypervDiagnosePopup.width
                    return messageWindowX
                })
                iHypervDiagnosePopup.y = Qt.binding(function() {
                    var messageWindowY = iHypervDiagnosePopup.transientParent.y + (iHypervDiagnosePopup.transientParent.height - iHypervDiagnosePopup.height) / 2
                    if (messageWindowY < iHypervDiagnosePopup.transientParent.screen.virtualY)
                        messageWindowY = iHypervDiagnosePopup.transientParent.screen.virtualY
                    if(messageWindowY + iHypervDiagnosePopup.height > iHypervDiagnosePopup.transientParent.screen.virtualY + iHypervDiagnosePopup.transientParent.screen.height)
                        messageWindowY = iHypervDiagnosePopup.transientParent.screen.virtualY + iHypervDiagnosePopup.transientParent.screen.height - iHypervDiagnosePopup.height
                    return messageWindowY
                })
            }
        }
    }

    Connections {
        target: plrBackend
        function onHypervDiagonosisCompleted(exitCode) {
            iHypervDiagnosePopup.diagonosisExitCode = exitCode
            iHypervDiagnosePopup.diagonosisRequired = false
            iRunningDiagnosis.visible = false
            iActionBtn.enabled = true
            iCloseBtn.enabled = true

            if (exitCode === 0) {
                iActionBtn.text = qsTranslate("QObject", "Run as Admin")
                iDiagnosisResult.text = qsTranslate("QObject", "Diagnosis is complete but %1 requires Administrator privileges to launch.").arg(uiBackend.productName)
            }
            else {
                iActionBtn.text = qsTranslate("QObject", "Run tool")
                iDiagnosisResult.text = qsTranslate("QObject", "Some Windows Hyper-V settings are not configured correctly. To resolve this, run our custom tool to enable Hyper-V correctly.")
            }
        }
    }

    UiShadowContainer {
        id: shadowContainer
        UiColumnLayout {
            id: iHypervDiagnoseLayout
            padding: 1
            anchors.left: parent.left
            anchors.right: parent.right
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary60

            UiRowLayout {
                Layout.fillWidth: true
                leftPadding: 16
                rightPadding: 16
                topPadding: 16
                spacing: 8
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Qt.AlignLeft
                    text: qsTranslate("QObject", "Run Hyper-V Diagnostic tool")
                    font: UiTheme.fonts.titleMedium
                    color: UiTheme.colors.primary10
                    wrapMode: Text.Wrap
                }
                UiImageButton {
                    id: iCloseBtn
                    asset: "CloseIcon"
                    pImageWidth: 16
                    pImageHeight: 16
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        iHypervDiagnosePopup.close()
                        Qt.quit()
                    }
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                leftPadding: 16
                rightPadding: 16
                topPadding: 16
                bottomPadding: 20
                spacing: 16
                UiImage {
                    asset: "ErrorLarge"
                    pImageWidth: 64
                    pImageHeight: 64
                    Layout.alignment: Qt.AlignTop
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Unable to launch %1 because of some conflicts with your Hyper-V settings. We recommend running our diagnostic tool to troubleshoot this error.").arg(uiBackend.productName)
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary20
                        wrapMode: Text.Wrap
                    }
                    Text {
                        id: iDiagnosisResult
                        visible: text !== ""
                        Layout.fillWidth: true
                        text: ""
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.warning
                        wrapMode: Text.Wrap
                    }
                    UiRowLayout {
                        id: iRunningDiagnosis
                        Layout.fillWidth: true
                        visible: false
                        spacing: 8
                        UiImage {
                            asset: "Loader_normal"
                            pImageWidth: 16
                            pImageHeight: 16
                            cache: false
                            RotationAnimation on rotation {
                                loops: Animation.Infinite
                                duration: 2000
                                from: 0
                                to: 360
                                direction: RotationAnimation.Clockwise
                                running: iRunningDiagnosis.visible
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "Running diagnostic tool...")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                        }
                    }
                }
            }

            UiRowLayout {
                leftPadding: 16
                rightPadding: 16
                bottomPadding: 16
                spacing: 16
                Layout.alignment: Qt.AlignRight
                UiButton {
                    Layout.maximumWidth: 180
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.secondary
                    text: qsTranslate("QObject", "Learn more")
                    onClicked: {
                        uiBackend.openHelpArticle("enable_hyperv")
                    }
                }
                UiButton {
                    id: iActionBtn
                    Layout.maximumWidth: 180
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.accent
                    text: qsTranslate("QObject", "Run tool")
                    opacity: iActionBtn.enabled ? 1 : 0.4
                    onClicked: {
                        if (iHypervDiagnosePopup.diagonosisRequired) {
                            iRunningDiagnosis.visible = true
                            iActionBtn.enabled = false
                            iCloseBtn.enabled = false
                        }
                        else {
                            if (iHypervDiagnosePopup.diagonosisExitCode === 0) {
                                iHypervDiagnosePopup.close()
                            }
                            else {
                                iHypervDiagnosePopup.close()
                                Qt.quit()
                            }
                        }
                    }
                }
            }
        }
    }
}
