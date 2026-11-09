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

Control {
    id: iControl

    default property alias children: iContentLayout.pChildren

    property string pText
    property bool pTextVisibility: true
    property int pTextImplicitWidth: iContentText.implicitWidth
    property string pTextColor: iControl.pHovered ? UiTheme.colors.primary10 : UiTheme.colors.primary20
    property string pImageAsset: ""
    property string pImageSource: ""
    property int pImageWidth: 16
    property int pImageHeight: 16
    property bool pHovered: hovered
    property color pBackgroundColor: "transparent"
    property color pBorderColor: "transparent"
    property int pBorderWidth: 0
    property bool pShowRedDot: false

    signal clicked

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + leftInset + rightInset,
                             implicitContentHeight + leftPadding + rightPadding)

    spacing: 10
    font: UiTheme.fonts.bodyLarge
    opacity: enabled ? 1 : 0.4

    background: Rectangle {
        color: iControl.pBackgroundColor
        border.width: iControl.pBorderWidth
        border.color: iControl.pBorderColor
    }

    contentItem: UiRowLayout {
        id: iContentLayout
        spacing: iControl.spacing
        Rectangle {
            color: "transparent"
            Layout.preferredWidth: iControl.pImageWidth
            Layout.preferredHeight: iControl.pImageHeight
            UiImage {
                source: iControl.pImageSource != "" ? iControl.pImageSource : (iControl.pImageAsset !== "" ? "qrcAssets/" + (iControl.pImageAsset + (iControl.pHovered ? "_hover" : "")) + ".svg" : "")
                pImageWidth: iControl.pImageWidth
                pImageHeight: iControl.pImageHeight
            }
            Rectangle {
                visible: iControl.pShowRedDot
                width: 4
                height: 4
                radius: 2
                color: UiTheme.colors.dangerNormal
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top
            }
        }
        Text {
            id: iContentText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            verticalAlignment: Text.AlignVCenter
            visible: iControl.pTextVisibility && iControl.pText !== ""
            text: iControl.pText
            font: iControl.font
            color: iControl.pTextColor
            elide: Text.ElideRight
            lineHeightMode: Text.FixedHeight
            lineHeight: 16
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked:{
            iControl.clicked()
        }
    }
}
