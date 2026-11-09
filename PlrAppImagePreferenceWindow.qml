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

import UiDialogWindow 1.0
import UiToolTipControl 1.0
import UiOverlayControl 1.0

UiDialogWindow {
    id: iAppImagePreferenceWindow
    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"
    x: iAppImagePreferenceWindow.transientParent.x + plrBackend.plrWinOffsets[0] + (iAppImagePreferenceWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1] - iAppImagePreferenceWindow.width) / 2
    y: iAppImagePreferenceWindow.transientParent.y + plrBackend.plrWinOffsets[2] + (iAppImagePreferenceWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3] - iAppImagePreferenceWindow.height) / 2
    width: 440 + 2 * shadowContainer.shadowThickness
    height: iAppImagePreferenceLayout.implicitHeight + 2 * shadowContainer.shadowThickness
    UiOverlay.overlayRect: Qt.rect(iAppImagePreferenceWindow.transientParent.x + plrBackend.plrWinOffsets[0],
                                   iAppImagePreferenceWindow.transientParent.y + plrBackend.plrWinOffsets[2],
                                   iAppImagePreferenceWindow.transientParent.width - plrBackend.plrWinOffsets[0] - plrBackend.plrWinOffsets[1],
                                   iAppImagePreferenceWindow.transientParent.height - plrBackend.plrWinOffsets[2] - plrBackend.plrWinOffsets[3])

    pCheckBoxState: iDoNotShowCheckBox.checked

    property bool pIsBsxInstalled: true
    property string pSelectedOption: iBlueStacksXBtn.checked ? "primary" : "secondary"

    signal checkBoxClicked(var checked)

    Component.onCompleted: {
        if (typeof(uiBackend) !== "undefined")
            uiBackend.pIsShortcutsEnabled = false
    }

    onClosed: {
        if (typeof(uiBackend) !== "undefined")
            uiBackend.pIsShortcutsEnabled = true

        if(iAppImagePreferenceWindow.pOwnership === 1) //only for JavaScriptOwnership
            iAppImagePreferenceWindow.destroy()
    }

    onVisibleChanged: {
        if (visible)
        {
            if (iAppImagePreferenceWindow.transientParent != null)
            {
                iAppImagePreferenceWindow.x = Qt.binding(function() {
                    var iAppImagePreferenceWindowX = iAppImagePreferenceWindow.transientParent.x + (iAppImagePreferenceWindow.transientParent.width - iAppImagePreferenceWindow.width) / 2
                    if (iAppImagePreferenceWindowX < iAppImagePreferenceWindow.transientParent.screen.virtualX)
                        iAppImagePreferenceWindowX = iAppImagePreferenceWindow.transientParent.screen.virtualX
                    if(iAppImagePreferenceWindowX + iAppImagePreferenceWindow.width > iAppImagePreferenceWindow.transientParent.screen.virtualX + iAppImagePreferenceWindow.transientParent.screen.width)
                        iAppImagePreferenceWindowX = iAppImagePreferenceWindow.transientParent.screen.virtualX + iAppImagePreferenceWindow.transientParent.screen.width - iAppImagePreferenceWindow.width
                    return iAppImagePreferenceWindowX
                })
                iAppImagePreferenceWindow.y = Qt.binding(function() {
                    var iAppImagePreferenceWindowY = iAppImagePreferenceWindow.transientParent.y + (iAppImagePreferenceWindow.transientParent.height - iAppImagePreferenceWindow.height) / 2
                    if (iAppImagePreferenceWindowY < iAppImagePreferenceWindow.transientParent.screen.virtualY)
                        iAppImagePreferenceWindowY = iAppImagePreferenceWindow.transientParent.screen.virtualY
                    if(iAppImagePreferenceWindowY + iAppImagePreferenceWindow.height > iAppImagePreferenceWindow.transientParent.screen.virtualY + iAppImagePreferenceWindow.transientParent.screen.height)
                        iAppImagePreferenceWindowY = iAppImagePreferenceWindow.transientParent.screen.virtualY + iAppImagePreferenceWindow.transientParent.screen.height - iAppImagePreferenceWindow.height
                    return iAppImagePreferenceWindowY
                })
            }
        }
    }

    ButtonGroup {
        id: iDownloadingOptionsBtnGrp
    }

    UiShadowContainer {
        id: shadowContainer
        UiColumnLayout {
            id: iAppImagePreferenceLayout
            anchors.left: parent != null ? parent.left : undefined
            anchors.right: parent != null ? parent.right : undefined
            color: UiTheme.colors.primary70
            border.color: UiTheme.colors.primary60
            border.width: 1
            padding: 20
            spacing: 12
            UiRowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: iAppImagePreferenceWindow.title
                    color: UiTheme.colors.accentNormal
                    font: UiTheme.fonts.titleSmallest
                    wrapMode: Text.Wrap
                }
                UiImageButton {
                    asset: "CloseIcon"
                    UiToolTip.text: qsTranslate("QObject", "Close")
                    pImageWidth: 16
                    pImageHeight: 16
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        iAppImagePreferenceWindow.close()
                        iAppImagePreferenceWindow.closeClicked()
                    }
                }
            }

            UiColumnLayout {
                Layout.fillWidth: true
                spacing: 20
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        Layout.fillWidth: true
                        text: iAppImagePreferenceWindow.pSubtitle
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.titleLarge
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: iAppImagePreferenceWindow.pDescription
                        color: UiTheme.colors.primary20
                        font: UiTheme.fonts.bodyLarge
                        wrapMode: Text.Wrap
                    }
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24
                    Rectangle {
                        id: iBlueStacksXRowParent
                        implicitWidth: parent.width
                        implicitHeight: iBlueStacksXRow.implicitHeight
                        color: "transparent"
                        MouseArea {
                            id: iBlueStacksXRowParentMouseArea
                            anchors.fill: iBlueStacksXRowParent
                            enabled: true
                            hoverEnabled: true
                        }

                        Item {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            UiToolTip.text: qsTranslate("QObject", "Download %1 for a better experience").arg(uiBackend.bsxProductName)
                            UiToolTip.visible: !pIsBsxInstalled && iBlueStacksXRowParentMouseArea.containsMouse
                        }

                        UiRowLayout {
                            id: iBlueStacksXRow
                            anchors.left: parent != null ? parent.left : undefined
                            anchors.right: parent != null ? parent.right : undefined
                            spacing: 16
                            enabled: pIsBsxInstalled
                            opacity: enabled ? 1 : 0.4
                            pMouseArea {
                                anchors.fill: iBlueStacksXRow
                                enabled: true
                                onClicked: {
                                    iBlueStacksXBtn.checked = true
                                }
                            }
                            UiRowLayout {
                                Layout.alignment: Qt.AlignTop
                                spacing: 12
                                UiRadioButton {
                                    id: iBlueStacksXBtn
                                    checked: iBlueStacksXRow.enabled ? true : false
                                    pSize: UiTheme.radioButtons.sizes.small
                                    ButtonGroup.group: iDownloadingOptionsBtnGrp
                                }
                                UiImage {
                                    asset: "BlueStacksLogo"
                                    pImageWidth: 24
                                    pImageHeight: 24
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: qsTranslate("QObject", "Automatically download using %1").arg(uiBackend.bsxProductName)
                                color: UiTheme.colors.primary10
                                font: UiTheme.fonts.bodyLarge
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                    UiRowLayout {
                        id: iBlueStacksWebsiteRow
                        Layout.fillWidth: true
                        spacing: 16
                        pMouseArea {
                            anchors.fill: iBlueStacksWebsiteRow
                            enabled: true
                            onClicked: {
                                iBlueStacksWebsiteBtn.checked = true
                            }
                        }
                        UiRowLayout {
                            Layout.alignment: Qt.AlignTop
                            spacing: 12
                            UiRadioButton {
                                id: iBlueStacksWebsiteBtn
                                checked: iBlueStacksXRow.enabled ? false : true
                                pSize: UiTheme.radioButtons.sizes.small
                                ButtonGroup.group: iDownloadingOptionsBtnGrp
                            }
                            UiImage {
                                asset: "BlueStacksWebsiteOption"
                                pImageWidth: 24
                                pImageHeight: 24
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "Manually download from our official page")
                            color: UiTheme.colors.primary10
                            font: UiTheme.fonts.bodyLarge
                            wrapMode: Text.Wrap
                        }
                    }
                }

                UiRowLayout{
                    Layout.fillWidth: true
                    spacing: 16

                    UiCheckBox {
                        id: iDoNotShowCheckBox
                        pSize: UiTheme.checkBoxes.sizes.small
                        visible: text !== ""
                        text: iAppImagePreferenceWindow.pCheckBoxText
                        onClicked: {
                            iAppImagePreferenceWindow.checkBoxClicked(checked)
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        model: iAppImagePreferenceWindow.pButtonsList.pButtons
                        spacing: 16
                        orientation: ListView.Horizontal
                        layoutDirection: Qt.RightToLeft
                        interactive: false
                        delegate: UiButton {
                            pSize: UiTheme.buttons.sizes.medium
                            pColor: model.modelData.pColor === null ? UiTheme.buttons.colors.accent : model.modelData.pColor
                            text: model.modelData.pText
                            onClicked: {
                                model.modelData.clicked()
                            }
                        }
                    }
                }
            }
        }
    }
}
