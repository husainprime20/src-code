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
import QtQuick.Layouts 1.15

Window {
    property string toolTipText: ""
    property var shortcutMap: {[]}

    width: Math.min(250, toolTipRect.implicitWidth + 2 * toolTipShadowContainer.shadowThickness)
    height: toolTipRect.implicitHeight + 2 * toolTipShadowContainer.shadowThickness
    color: "transparent"
    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.NoFocus

    UiShadowContainer {
        id: toolTipShadowContainer
        glowRadius: 2
        cornerRadius: 4
        UiColumnLayout {
            id: toolTipRect
            anchors.fill: parent
            color: UiTheme.colors.primary80
            border.width: 1
            border.color: UiTheme.colors.primary60
            padding: 4
            Text {
                visible: toolTipText !== ""
                Layout.fillWidth: true
                text: toolTipText
                color: UiTheme.colors.primary10
                font: UiTheme.fonts.bodyExtraSmall
                wrapMode: Text.Wrap
            }
            Repeater {
                Layout.fillWidth: true
                model: shortcutMap
                delegate: Component {
                    Text {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: fGetText(modelData)
                        color: UiTheme.colors.primary10
                        font: UiTheme.fonts.bodyExtraSmall
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    function fGetText(modelData) {
        var finalText = ""
        finalText += (modelData.text !== undefined ? modelData.text : "")

        var val = modelData.value !== undefined ? modelData.value : ""
        if (val === "")
            return finalText

        var shortcut = plrBackend.getDisplayComboFromNameCombo(uiBackend.confGetString("bst.shortcut." + val))
        if (shortcut === "")
            return finalText

        var padding = (finalText !== "") ? " " : ""
        finalText += (padding + "(%1)".arg(shortcut))

        return finalText
    }
}
