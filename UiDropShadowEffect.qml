/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15

Item {
    id: rootItem

    property bool cached: false
    property color color: UiTheme.colors.primary100
    property real glowRadius: 0.0
    property real spread: 0.0
    property real cornerRadius: glowRadius

    ShaderEffectSource {
        id: cacheItem
        anchors.fill: shaderItem
        sourceItem: shaderItem
        visible: rootItem.cached
        hideSource: visible
        smooth: true
        live: true
    }

    ShaderEffect {
        id: shaderItem

        x: (parent.width - width) / 2.0
        y: (parent.height - height) / 2.0
        width: parent.width + rootItem.glowRadius * 2 + rootItem.cornerRadius * 2
        height: parent.height + rootItem.glowRadius * 2 + rootItem.cornerRadius * 2

        function clampedCornerRadius() {
            var maxCornerRadius = Math.min(rootItem.width, rootItem.height) / 2 + rootItem.glowRadius;
            return Math.max(0, Math.min(rootItem.cornerRadius, maxCornerRadius))
        }

        property color color: rootItem.color
        property real inverseSpread: 1.0 - rootItem.spread
        property real relativeSizeX: ((inverseSpread * inverseSpread) * rootItem.glowRadius + rootItem.cornerRadius * 2.0) / width
        property real relativeSizeY: relativeSizeX * (width / height)
        property real spread: rootItem.spread / 2.0
        property real cornerRadius: clampedCornerRadius()

        fragmentShader: "qrc:/shaders/rectangularglow.frag"
    }
}
