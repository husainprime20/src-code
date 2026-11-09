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
import QtQuick.Shapes 1.12

UiWindowedPopup {
    id: iPopup

    enum ArrowPosition {
        TopCenter,
        BottomCenter,
        RightCenter,
        TopRight
    }

    default property alias pChildren: iInnerLayout.pChildren

    property int arrowPosition: UiHelpPopup.ArrowPosition.BottomCenter
    property alias pInnerLayout: iInnerLayout

    readonly property list<QtObject> pPositionValues: [
        QtObject {
            property int width: 16
            property int height: 8
            property var anchorsTop: iInnerLayout.top
            property var anchorsLeft: undefined
            property var anchorsRight: undefined
            property var anchorsHorizontalCenter: iInnerLayout.horizontalCenter
            property var anchorsVerticalCenter: undefined
            property int anchorsRightMargin: 0
            property QtObject shapePath1: QtObject {
                property int startX: 0
                property int startY: 1
                property int x1: 8
                property int y1: -8
                property int x2: 16
                property int y2: 1
            }
            property QtObject shapePath2: QtObject {
                property int startX: 0
                property int startY: 0
                property int x1: 8
                property int y1: -8
                property int x2: 16
                property int y2: 0
            }
        },
        QtObject {
            property int width: 16
            property int height: 8
            property var anchorsTop: iInnerLayout.bottom
            property var anchorsLeft: undefined
            property var anchorsRight: undefined
            property var anchorsHorizontalCenter: iInnerLayout.horizontalCenter
            property var anchorsVerticalCenter: undefined
            property int anchorsRightMargin: 0
            property QtObject shapePath1: QtObject {
                property int startX: 0
                property int startY: -1
                property int x1: 8
                property int y1: 8
                property int x2: 16
                property int y2: -1
            }
            property QtObject shapePath2: QtObject {
                property int startX: 0
                property int startY: 0
                property int x1: 8
                property int y1: 8
                property int x2: 16
                property int y2: 0
            }
        },
        QtObject {
            property int width: 8
            property int height: 16
            property var anchorsTop: undefined
            property var anchorsLeft: iInnerLayout.right
            property var anchorsRight: undefined
            property var anchorsHorizontalCenter: undefined
            property var anchorsVerticalCenter: iInnerLayout.verticalCenter
            property int anchorsRightMargin: 0
            property QtObject shapePath1: QtObject {
                property int startX: -1
                property int startY: 0
                property int x1: 8
                property int y1: 8
                property int x2: -1
                property int y2: 16
            }
            property QtObject shapePath2: QtObject {
                property int startX: 0
                property int startY: 0
                property int x1: 8
                property int y1: 8
                property int x2: 0
                property int y2: 16
            }
        },
        QtObject {
            property int width: 16
            property int height: 8
            property var anchorsTop: iInnerLayout.top
            property var anchorsLeft: undefined
            property var anchorsRight: iInnerLayout.right
            property var anchorsHorizontalCenter: undefined
            property var anchorsVerticalCenter: undefined
            property int anchorsRightMargin: 10
            property QtObject shapePath1: QtObject {
                property int startX: 0
                property int startY: 1
                property int x1: 8
                property int y1: -8
                property int x2: 16
                property int y2: 1
            }
            property QtObject shapePath2: QtObject {
                property int startX: 0
                property int startY: 0
                property int x1: 8
                property int y1: -8
                property int x2: 16
                property int y2: 0
            }
        }
    ]

    contentWidth: 200
    contentHeight: iInnerLayout.implicitHeight

    UiColumnLayout {
        id: iInnerLayout
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Shape {
        width: pPositionValues[iPopup.arrowPosition].width
        anchors.top: pPositionValues[iPopup.arrowPosition].anchorsTop
        anchors.left: pPositionValues[iPopup.arrowPosition].anchorsLeft
        anchors.right: pPositionValues[iPopup.arrowPosition].anchorsRight
        anchors.horizontalCenter: pPositionValues[iPopup.arrowPosition].anchorsHorizontalCenter
        anchors.verticalCenter: pPositionValues[iPopup.arrowPosition].anchorsVerticalCenter
        anchors.rightMargin: pPositionValues[iPopup.arrowPosition].anchorsRightMargin
        height: pPositionValues[iPopup.arrowPosition].height
        ShapePath {
            strokeColor: iInnerLayout.color
            fillColor: iInnerLayout.color
            startX: pPositionValues[iPopup.arrowPosition].shapePath1.startX
            startY: pPositionValues[iPopup.arrowPosition].shapePath1.startY
            PathLine {
                x: pPositionValues[iPopup.arrowPosition].shapePath1.x1
                y: pPositionValues[iPopup.arrowPosition].shapePath1.y1
            }
            PathLine {
                x: pPositionValues[iPopup.arrowPosition].shapePath1.x2
                y: pPositionValues[iPopup.arrowPosition].shapePath1.y2
            }
        }
        ShapePath {
            strokeColor: iInnerLayout.border.color
            fillColor: iInnerLayout.color
            startX: pPositionValues[iPopup.arrowPosition].shapePath2.startX
            startY: pPositionValues[iPopup.arrowPosition].shapePath2.startY
            PathLine {
                x: pPositionValues[iPopup.arrowPosition].shapePath2.x1
                y: pPositionValues[iPopup.arrowPosition].shapePath2.y1
            }
            PathLine {
                x: pPositionValues[iPopup.arrowPosition].shapePath2.x2
                y: pPositionValues[iPopup.arrowPosition].shapePath2.y2
            }
        }
    }
}
