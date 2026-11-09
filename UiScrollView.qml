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
import QtQuick.Templates 2.15 as T

T.ScrollView {
    id: iControl

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    ScrollBar.vertical: UiScrollBar {
        parent: iControl
        x: iControl.width - width
        y: iControl.topPadding
        height: iControl.availableHeight
        active: iControl.ScrollBar.vertical.active
        policy: iControl.contentHeight > iControl.height && iControl.hovered ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        onActiveChanged: uiBackend.pFlickableMoving = active
    }

    ScrollBar.horizontal: UiScrollBar {
        parent: iControl
        x: iControl.leftPadding
        y: iControl.height - height
        width: iControl.availableWidth
        active: iControl.ScrollBar.horizontal.active
        policy: iControl.contentWidth > iControl.width && iControl.hovered ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        onActiveChanged: uiBackend.pFlickableMoving = active
    }
}
