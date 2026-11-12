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
import QtQuick.Controls 2.15

ComboBox {
    id: iControl

    property QtObject pSize
    property QtObject pColor: UiTheme.comboBoxes.colors.accent
    property QtObject pColorState: pErrorState ? pColor.error : hovered ? pColor.hover : pColor.normal

    property real pMaxDropDownHeight: iControl.pSize.maxDropDownHeight
    property string pVisibilityRole: ""
    property bool pErrorState: false
    property string pSubText: ""

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: pSize.height

    leftPadding: 0
    rightPadding: pSize.indicatorWidth

    Connections {
        target: uiBackend
        function onFlickableMovingChanged() {
            if (uiBackend.pFlickableMoving && popup.opened)
                popup.close()
        }
    }

    indicator: Rectangle {
        implicitWidth: iControl.pSize.indicatorWidth
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        color: iControl.contentItem.background.color
        UiImage {
            anchors.centerIn: parent
            pImageWidth: iControl.pSize.indicatorImageWidth
            pImageHeight: iControl.pSize.indicatorImageHeight
            asset: iControl.pSize.indicatorAsset + (iControl.hovered ? "_hover" : "")
        }
    }

    contentItem: UiTextField {
        pSize: iControl.pSize.textField
        pColor: iControl.pColor.textField
        pColorState: iControl.hovered ? pColor.hover : pColor.normal
        rightPadding: 0
        text: iControl.editable ? iControl.editText : iControl.displayText
        enabled: iControl.editable
        autoScroll: iControl.editable
        readOnly: iControl.down
        inputMethodHints: iControl.inputMethodHints
        validator: iControl.validator
        selectByMouse: iControl.selectTextByMouse

        background: Rectangle {
            color: "transparent"
        }

        onEditingFinished: {
            iControl.accepted()
        }
    }

    background: Rectangle {
        color: iControl.pColorState.background
        border.width: 1
        border.color: iControl.pColorState.border
    }

    delegate: ItemDelegate {
        visible: true
        width: ListView.view.width
        height: (iControl.pVisibilityRole === "" || (Array.isArray(iControl.model) ? modelData[iControl.pVisibilityRole] : model[iControl.pVisibilityRole])) ? iControl.pSize.height : 0
        leftPadding: iControl.contentItem.leftPadding
        rightPadding: iControl.contentItem.rightPadding
        topPadding: iControl.contentItem.topPadding
        bottomPadding: iControl.contentItem.bottomPadding
        palette.text: iControl.contentItem.pColor.normal.textColor
        palette.highlightedText: iControl.contentItem.pColor.active.textColor
        font: iControl.contentItem.font
        highlighted: iControl.highlightedIndex === index
        hoverEnabled: iControl.hoverEnabled
        background: Rectangle {
            color: highlighted ? iControl.pColor.dropDownHighlight :
                                 iControl.currentIndex === index ? iControl.pColor.dropDownSelection : "transparent"
        }

        Rectangle {
            color: "transparent"
            anchors.fill: parent
            UiText {
                id: iMainText
                leftPadding: 8
                topPadding: 4
                bottomPadding: 4
                verticalAlignment: Text.AlignVCenter
                text: iControl.textRole ? (Array.isArray(iControl.model) ? modelData[iControl.textRole] : model[iControl.textRole]) : modelData
                font: UiTheme.fonts.bodySmall
                color: pMouseArea.containsMouse ? iControl.contentItem.pColor.active.textColor : iControl.contentItem.pColor.normal.textColor
                pMouseArea {
                    anchors.fill: iMainText
                    hoverEnabled: true
                    enabled: true
                    propagateComposedEvents: true
                    onPressed: function (mouse) {
                        mouse.accepted = false
                    }
                }
            }
            UiText {
                id: iSubText
                rightPadding: 8
                leftPadding: 10
                topPadding: 4
                bottomPadding: 4
                anchors.right: parent.right
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font: UiTheme.fonts.bodySmall
                color: pMouseArea.containsMouse ? iControl.contentItem.pColor.active.textColor : iControl.contentItem.pColor.normal.textColor
                text: iControl.pSubText ? (Array.isArray(iControl.model) ? modelData[iControl.pSubText] : model[iControl.pSubText]) : modelData
                pMouseArea {
                    anchors.fill: iSubText
                    hoverEnabled: true
                    enabled: true
                    propagateComposedEvents: true
                    onPressed: function (mouse) {
                        mouse.accepted = false
                    }
                }
            }
        }
    }

    popup: Popup {
        y: iControl.height
        width: iControl.width
        height: Math.min(contentItem.contentHeight, iControl.pMaxDropDownHeight, iControl.Window.height)
        padding: 0

        contentItem: ListView {
            clip: true
            model: iControl.delegateModel
            currentIndex: iControl.highlightedIndex
            highlightMoveDuration: 0
            onModelChanged: {
                if(model)
                    positionViewAtIndex(iControl.currentIndex, ListView.Center)
            }

            Rectangle {
                z: 10
                width: parent.width
                height: parent.height
                color: "transparent"
                border.width: 1
                border.color: iControl.pColor.normal.border
            }

            ScrollBar.vertical: UiScrollBar {
                policy: parent.contentHeight > parent.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
        }

        background: Rectangle {
            color: iControl.pColor.normal.background
        }
    }
}
