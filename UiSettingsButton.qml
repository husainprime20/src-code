/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: iRoot
    color: "transparent"
    visible: true
    property alias pSettingBtnText: iSettingsText.text
    property alias pSettingBtnColor: iSettingsText.color
    property bool pSelected: false
    property int pSettingIdx: 0
    property bool pShowRedDot: false

    signal settingClicked()

    focus: true
    Layout.preferredWidth: 180
    Layout.preferredHeight: iSettingsBtnLayout.implicitHeight

    UiColumnLayout {
        id: iSettingsBtnLayout
        topPadding: 6
        bottomPadding: 6
        UiRowLayout {
            Text {
                id: iSettingsText
                text: "Display"
                color: pSelected ? UiTheme.colors.subWindowHeaderClick : UiTheme.colors.primary20
                font: UiTheme.fonts.bodyLarge
                Layout.maximumWidth: iRoot.width
                Layout.alignment: Qt.AlignLeft
                elide: Text.ElideRight
            }
            Rectangle {
                visible: pShowRedDot
                Layout.preferredWidth: 6
                Layout.preferredHeight: 6
                radius: 3
                color: UiTheme.colors.dangerNormal
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 10
            }
        }

        Rectangle {
            id: iHighlighter
            Layout.preferredWidth: iSettingsText.width
            Layout.preferredHeight: 1.5
            color: UiTheme.colors.accentNormal
            opacity: pSelected ? 1 : 0
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            settingClicked()
            iRoot.forceActiveFocus()
        }
    }
}
