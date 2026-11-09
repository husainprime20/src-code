/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.0
import QtQuick.Controls 2.15

SpinBox {
    id: control

    property int spinBoxValue : 1
    property int decimalPlaces: 0
    property real realValue: 0.0
    property real realFrom: 0.0
    property real realTo: 100.0
    property real realStepSize: 1.0
    property real factor: Math.pow(10, decimalPlaces)

    stepSize: realStepSize * factor
    value: Math.round(realValue * factor)
    to : realTo * factor
    from : realFrom * factor
    editable: true

    background: Rectangle {
        color: UiTheme.colors.primary80
        border.color: UiTheme.colors.primary60
        radius: 1
    }
    contentItem: TextInput {
        id: spinboxTextInput
        Component.onCompleted: text = control.textFromValue(control.value, control.locale)
        color: UiTheme.colors.primary10
        font.family: "Segoe UI"
        readOnly: !control.editable
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 20
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        validator: control.validator
        inputMethodHints: control.inputMethodHints
        onTextChanged:  {
            if(focus)
                value = control.valueFromText(text, control.locale)
        }
    }

    up.indicator: Rectangle {
        height: parent.height / 2
        anchors.right: parent.right
        anchors.top: parent.top
        implicitHeight: 40
        implicitWidth: 20
        color: "transparent"
        border.color: UiTheme.colors.primary60
        UiImageButton {
            asset: "UpArrow"
            pImageWidth: 8
            pImageHeight: 10
            anchors.centerIn: parent
            onClicked: {
                increase()
                spinboxTextInput.text= control.textFromValue(control.value, control.locale)
            }
        }
    }

    down.indicator: Rectangle {
        height: parent.height / 2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: 40
        implicitWidth: 20
        color: "transparent"
        border.color: UiTheme.colors.primary60
        UiImageButton {
            asset: "DownArrow"
            pImageWidth: 8
            pImageHeight: 10
            anchors.centerIn: parent
            onClicked: {
                decrease()
                spinboxTextInput.text= control.textFromValue(control.value, control.locale)
            }
        }
    }

    implicitWidth: 60
    implicitHeight: 20

    textFromValue: function(value, locale) {
        return parseFloat(value / factor).toFixed(decimalPlaces);
    }

    valueFromText: function(text, locale) {
        return parseFloat(text) * factor
    }

    onRealValueChanged: {
        spinboxTextInput.text = control.textFromValue(Math.round(realValue * factor), control.locale)
    }
}
