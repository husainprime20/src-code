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

Window {
    color: UiTheme.colors.overlayPrimary
    flags: Qt.Window | Qt.FramelessWindowHint
    screen: transientParent ? transientParent.screen : null
}
