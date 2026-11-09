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
import QtQuick.Controls.Basic.impl

ProgressBar {
    id: iControl

    property color backgroundColor: UiTheme.colors.overLayTint
    property color progressColor: UiTheme.colors.accentNormal

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: 6

    background: Rectangle {
        anchors.fill: parent
        color: iControl.backgroundColor
    }

    contentItem: ProgressBarImpl {
        implicitHeight: iControl.height
        scale: iControl.mirrored ? -1 : 1
        progress: iControl.position
        indeterminate: iControl.visible && iControl.indeterminate
        color: iControl.progressColor
    }
}
