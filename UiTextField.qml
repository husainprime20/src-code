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
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.12

TextField {
    id: iControl

    enum InputValidation {
        Valid,
        Warning,
        Error
    }

    property QtObject pSize
    property QtObject pColor: UiTheme.textFields.colors.accent
    property QtObject pColorState: pInputValidationState === UiTextField.InputValidation.Error ?
                                       pColor.error : pInputValidationState === UiTextField.InputValidation.Warning ?
                                           pColor.warning : activeFocus ?
                                               pColor.active : hovered ?
                                                   pColor.hover : pColor.normal
    property int pInputValidationState: UiTextField.InputValidation.Valid

    property bool pOpenErrorTemplate: false
    property string pErrorTemplateContent: ""
    property UiWindowedPopup pErrorTemplate: null

    implicitHeight: pSize.height

    leftPadding: pSize.horizontalPadding
    rightPadding: pSize.horizontalPadding
    topPadding: 0
    bottomPadding: 0

    font: pSize.textFont
    selectionColor: pColor.selection
    selectedTextColor: pColor.selectionText

    selectByMouse: true

    color: pColorState.textColor
    placeholderTextColor: pColorState.textColor

    background: Rectangle {
        color: iControl.pColorState.background
        border.width: 1
        border.color: iControl.pColorState.border
    }

    onActiveFocusChanged: {
        iControl.ensureVisible(0)
        if(activeFocus) {
            uiBackend.pIsEditingTextfield = true;
        }
    }

    onEditingFinished: {
        uiBackend.pIsEditingTextfield = false;
    }

    onPOpenErrorTemplateChanged: {
        if (iControl.pOpenErrorTemplate) {
            if (iControl.pErrorTemplate == null) {
                iControl.pErrorTemplate = errorComponent.createObject(null, { "screen" : fGetCurrentScreen() })
                iControl.pErrorTemplate.show()
            }
        } else {
            if (iControl.pErrorTemplate != null) {
                iControl.pErrorTemplate.destroy()
            }
        }
    }

    Connections {
        target: uiBackend
        function onFlickableMovingChanged() {
            if (uiBackend.pFlickableMoving && iControl.pErrorTemplate != null)
                iControl.pErrorTemplate.destroy()
        }
    }

    Component {
        id: errorComponent
        UiWindowedPopup {
            property string pErrorContent: iControl.pErrorTemplateContent

            id: iErrorPopup
            x: iControl.mapToGlobal(0, 0).x - width / 2 + iControl.width / 2
            y: iControl.mapToGlobal(0, 0).y - height + shadowThickness - 12
            contentWidth: Math.min(200, iInnerLayout.implicitWidth)
            contentHeight: iInnerLayout.implicitHeight
            closeOnPressOutside: false
            flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowDoesNotAcceptFocus

            UiColumnLayout {
                id: iInnerLayout
                anchors.left: parent.left
                anchors.right: parent.right
                border.width: 1
                border.color: UiTheme.colors.dangerNormal
                color: UiTheme.colors.dangerDark
                topPadding: 4
                bottomPadding: 4
                rightPadding: 8
                leftPadding: 8
                Text {
                    Layout.fillWidth: true
                    text: iErrorPopup.pErrorContent
                    font: UiTheme.fonts.bodyExtraSmall
                    color: UiTheme.colors.primary10
                    wrapMode: Text.Wrap
                }
            }

            Shape {
                width: 16
                anchors.top: iInnerLayout.bottom
                anchors.horizontalCenter: iInnerLayout.horizontalCenter
                height: 8
                ShapePath {
                    strokeColor: UiTheme.colors.dangerNormal
                    fillColor: UiTheme.colors.dangerNormal
                    startX: 0
                    startY: 0
                    PathLine { x: 8; y: 8 }
                    PathLine { x: 16; y: 0 }
                }
            }
        }
    }

    function fGetCurrentScreen()
    {
        for (var i = 0; i < Qt.application.screens.length; i++)
        {
            if (Qt.application.screens[i].name === Screen.name)
            {
                return Qt.application.screens[i]
            }
        }
    }
}
