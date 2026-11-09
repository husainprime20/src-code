/*
 * Copyright (C) 2020 BlueStack Systems, Inc.
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

Window {
    id: iScriptEditorWin
    objectName: "scriptEditor"
    color: "#00000000"
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: uiBackend.productName + " Script Editor"
    screen: transientParent.screen

    property QtObject pKmmControl: null
    property int pSidePanelWidth: 260

    component CustomMenuButton: UiButton {
        id: iButton
        pSize: UiTheme.buttons.sizes.medium
        pColor: UiTheme.buttons.colors.transparent
        Layout.fillWidth: true
        horizontalPadding: 10
        property string pButtonShortcut: ""
        contentItem: UiRowLayout {
            spacing: iButton.spacing
            Text {
                Layout.fillWidth: true
                text: iButton.text
                font: iButton.font
                color: enabled ? iButton.pColorState.textColor : UiTheme.colors.primary50
            }
            Text {
                horizontalAlignment: Text.AlignRight
                text: iButton.pButtonShortcut
                font: UiTheme.fonts.bodyExtraSmall
                color: enabled ? iButton.pColorState.textColor : UiTheme.colors.primary50
            }
        }
    }

    UiRowLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(8.0 / 255, 10.0 / 255, 31.0 / 255, 0.6)
        }

        Rectangle {
            Layout.preferredWidth: pSidePanelWidth
            Layout.fillHeight: true
            color: UiTheme.colors.primary80

            UiColumnLayout {
                spacing: 6
                anchors.fill: parent

                UiRowLayout {
                    leftPadding: 8
                    color: UiTheme.colors.primary80
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        font: UiTheme.fonts.titleExtraSmall
                        color: UiTheme.colors.primary10
                        text: qsTranslate("QObject", "Script editor")
                        elide: Text.ElideRight
                    }
                    UiImageButton {
                        asset: "TitlebarClose"
                        pImageWidth: 32
                        pImageHeight: 32
                        UiToolTip.text: qsTranslate("QObject", "Close")
                        onClicked: {
                            iScriptEditorWin.close()
                        }
                    }
                }

                Text {
                    font: UiTheme.fonts.bodySmall
                    color: UiTheme.colors.primary30
                    text: qsTranslate("QObject", "Create your customized script that performs a set of actions at the click of a button")
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    id: iSciptCommandRect
                    color: UiTheme.colors.primary80
                    border.width: 1
                    border.color: UiTheme.colors.primary50
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8

                    UiScrollView {
                        anchors.fill: parent

                        TextArea {
                            id: iScriptCommandArea
                            color: UiTheme.colors.primary20
                            font: UiTheme.fonts.bodyMedium
                            selectByKeyboard: true
                            selectByMouse: true
                            persistentSelection: true
                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    iSciptCommandRect.color = UiTheme.colors.primary90
                                    kmmBackend.kmmEditorHideScriptTooltip()
                                }
                                else
                                    iSciptCommandRect.color = UiTheme.colors.primary80
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onClicked: {
                                    if (mouse.button === Qt.RightButton)
                                    {
                                        var selectedText = iScriptCommandArea.selectedText
                                        var helpWin = iEditMenuComponent.createObject(iScriptEditorWin)
                                        var point = iScriptCommandArea.mapToGlobal(0, 0)
                                        helpWin.x = point.x + mouseX
                                        helpWin.y = point.y + mouseY
                                        if ((helpWin.x + helpWin.width) >
                                                (iScriptEditorWin.screen.virtualX + iScriptEditorWin.screen.width))
                                            helpWin.x = iScriptEditorWin.screen.width - helpWin.width
                                        helpWin.pEnableCut = iScriptCommandArea.selectedText !== ""
                                        helpWin.pEnableCopy = iScriptCommandArea.selectedText !== ""
                                        helpWin.pEnablePaste = kmmBackend.clipboardText !== ""
                                        helpWin.show()
                                    }
                                }
                            }
                        }
                    }
                }

                UiRowLayout {
                    leftPadding: 8
                    rightPadding: 8
                    bottomPadding: 8
                    Layout.fillWidth: true

                    UiTextUrl {
                        text: "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "Script guide") + "</a>"
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        Layout.fillWidth: true
                        linkColor: UiTheme.colors.accentNormal
                        onLinkActivated: uiBackend.openHelpArticle("keymapping_script_faq")
                    }

                    UiButton {
                        pSize: UiTheme.buttons.sizes.small
                        pColor: UiTheme.buttons.colors.accent
                        Layout.alignment: Qt.AlignRight
                        text: qsTranslate("QObject", "Done")
                        onClicked: {
                            kmmBackend.kmmEditorValidateScriptCommands(iScriptCommandArea.text)
                        }
                    }
                }
            }

            UiToast {
                id: iToast
                anchors.horizontalCenter: parent.horizontalCenter
                pMaximumWidth: pSidePanelWidth - 16
                pShowCross: false
            }
        }
    }

    Component {
        id: iEditMenuComponent
        UiWindowedPopup {
            id: iEditMenu
            contentWidth: iEditMenuLayout.implicitWidth
            contentHeight: iEditMenuLayout.implicitHeight
            visible: false
            shadowVisibility: false

            property bool pEnableCut: false
            property bool pEnableCopy: false
            property bool pEnablePaste: false

            UiColumnLayout {
                id: iEditMenuLayout
                color: UiTheme.colors.primary90
                border.width: 1
                border.color: UiTheme.colors.primary60
                topPadding: 6
                bottomPadding: 6
                CustomMenuButton {
                    text: qsTranslate("QObject", "Cut")
                    pButtonShortcut: "Ctrl + X"
                    enabled: iEditMenu.pEnableCut
                    onClicked: {
                        iEditMenu.close()
                        iScriptCommandArea.cut()
                    }
                }
                CustomMenuButton {
                    text: qsTranslate("QObject", "Copy")
                    pButtonShortcut: "Ctrl + C"
                    enabled: iEditMenu.pEnableCopy
                    onClicked: {
                        iEditMenu.close()
                        iScriptCommandArea.copy()
                    }
                }
                CustomMenuButton {
                    text: qsTranslate("QObject", "Paste")
                    pButtonShortcut: "Ctrl + V"
                    enabled: iEditMenu.pEnablePaste
                    onClicked: {
                        iEditMenu.close()
                        iScriptCommandArea.paste()
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        iScriptCommandArea.text = pKmmControl.commands.join('\n')
        iScriptCommandArea.cursorPosition = iScriptCommandArea.text.length
        kmmBackend.kmmEditorSetVisibility(false)
    }

    onClosing: {
        iScriptEditorWin.destroy()
        kmmBackend.kmmEditorSetVisibility(true)
    }

    function fCopyPointerLocation(mouseLocation) {
        iScriptCommandArea.insert(iScriptCommandArea.cursorPosition, " " + mouseLocation)
    }

    function fDeactiveScripCommandArea() {
        iScriptCommandArea.focus = false
    }

    function fScriptValidated(isValid) {
        if (isValid)
        {
            pKmmControl.commands = iScriptCommandArea.text.split('\n')
            iScriptEditorWin.close()
        }
        else
        {
            iToast.y = iScriptEditorWin.height - iToast.height - 40
            iToast.fShow(qsTranslate("QObject", "Invalid list of Script commands."), 3000)
        }
    }
}
