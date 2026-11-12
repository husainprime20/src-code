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

CheckBox {
    id: iControl

    property QtObject pSize

    padding: 0
    spacing :pSize.spacing
    opacity: enabled ? 1 : 0.4

    indicator: UiImage {
        x: iControl.text ? iControl.leftPadding : iControl.leftPadding + (iControl.availableWidth - width) / 2
        y: iControl.topPadding + (iControl.availableHeight / iContent.lineCount - height) / 2
        pImageWidth: iControl.pSize.iconWidth
        pImageHeight: iControl.pSize.iconHeight
        asset: iControl.pSize.iconAsset + (iControl.checked ? "On" : "Off") + (iControl.hovered? "_hover" : "")
    }

    contentItem: Text {
        id:iContent
        text: iControl.text
        leftPadding: iControl.indicator.width + iControl.spacing
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font: iControl.pSize.textFont
        color: UiTheme.colors.primary20
        wrapMode: Text.Wrap
    }
}
