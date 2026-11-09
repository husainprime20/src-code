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

ScrollBar {
    id: iControl

    property QtObject pColor: UiTheme.scrollBars.colors.accent

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 0
    visible: policy !== ScrollBar.AlwaysOff
    minimumSize: orientation == Qt.Horizontal ? height / width : width / height

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: 6
        color: iControl.policy === ScrollBar.AlwaysOn || (iControl.policy === ScrollBar.AsNeeded && (iControl.hovered || iControl.active))
               ? (iControl.hovered ? iControl.pColor.backgroundHover : iControl.pColor.background) : "transparent"
    }
}
