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

UiImage {
    id: iControl
    property bool pAllowClickThrough: true
    property alias pControlPressed: iMouseArea.pressed

    signal pressed(var mouse)
    signal positionChanged(var mouse)
    signal released(var mouse)
    MouseArea {
        id: iMouseArea
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function(mouse) {
            if(iControl.pAllowClickThrough) {
                mouse.accepted = uiBackend.isTransparentClickAccepted(iControl.source, iControl.width, iControl.height, mouse.x, mouse.y)
                if(mouse.accepted)
                    iControl.pressed(mouse)
            } else iControl.pressed(mouse)
        }
        onPositionChanged: function(mouse) {
            iControl.positionChanged(mouse)
        }
        onReleased: function(mouse) {
            iControl.released(mouse)
        }
    }
}
