/*
 * Copyright (C) 2020 BlueStack Systems, Inc.
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
import QtQml.Models 2.15

import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Window {
    id: iCreateMacroScheduleWindow
    title: qsTranslate("QObject", "New macro schedule")
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.FramelessWindowHint
    color: UiTheme.colors.primary80
    width: iCreateMacroScheduleLayout.width
    height: iCreateMacroScheduleLayout.implicitHeight

    property bool pIsUpdateMacroSchedule: false
    property int pScheduleMacroId: -1
    property date pScheduleMacroDate: new Date()
    property var pScheduleMacroRepeatTime: 0

    property string pHours
    property string pMinutes
    property string pSeconds
    property string pAmPm: "AM"
    property UiWindowedPopup pTimeSelectorWin: null

    property string pDate: "mm/dd/yyyy"
    property UiWindowedPopup pCalendarSelectorWin: null
    property bool pEnableUpdate: false

    Component.onCompleted: {
        var curTime = Qt.formatTime(pScheduleMacroDate, "h:mm:ss:AP").split(':')
        pHours = curTime[0]
        pMinutes = curTime[1]
        pSeconds = "0"

        pAmPm = (Qt.formatTime(pScheduleMacroDate, "h:mm").split(':')[0] >= 12) ? "PM" : "AM"

        if (pIsUpdateMacroSchedule)
            pDate = Qt.formatDate(pScheduleMacroDate, "MM/dd/yyyy")
    }

    onClosing: {
        iCreateMacroScheduleWindow.destroy()
    }

    UiColumnLayout {
        id: iCreateMacroScheduleLayout
        width: 450
        color: UiTheme.colors.primary80
        border.color: UiTheme.colors.primary50
        border.width: 1
        padding: 1
        UiRowLayout {
            color: UiTheme.colors.primary60
            Layout.preferredHeight: 32
            Layout.fillWidth: true
            leftPadding: 16
            Text {
                text: pIsUpdateMacroSchedule ? qsTranslate("QObject", "Edit macro schedule") : qsTranslate("QObject", "New macro schedule")
                color: UiTheme.colors.primary10
                font : UiTheme.fonts.titleExtraSmall
            }
            UiImageButton {
                asset: "TitlebarClose"
                UiToolTip.text: qsTranslate("QObject", "Close")
                pImageWidth: 32
                pImageHeight: 32
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    iCreateMacroScheduleWindow.close()
                }
            }
        }

        UiColumnLayout{
            color: UiTheme.colors.primary80
            Layout.fillWidth: true
            padding: 16
            spacing: 16
            UiRowLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: !pIsUpdateMacroSchedule
                Text {
                    Layout.preferredWidth: 100
                    text: qsTranslate("QObject", "Macro name")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    elide: Qt.ElideRight
                }
                UiComboBox {
                    id: iScheduledMacro
                    Layout.fillWidth: true
                    pSize: UiTheme.comboBoxes.sizes.small
                    model: mnsBackend.pMacroViewModel.macrosAvailableForSchedule()
                    currentIndex: -1
                    displayText: currentIndex == -1 ? qsTranslate("QObject","Select a macro") : currentValue
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    Layout.preferredWidth: 100
                    text: qsTranslate("QObject", "Run on")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    elide: Qt.ElideRight
                }
                UiRowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    leftPadding: 8
                    opacity: 0.4
                    color: UiTheme.colors.primary90
                    border.width: 1
                    border.color: UiTheme.colors.primary50
                    Text {
                        Layout.fillWidth: true
                        text: mnsBackend.pSelfInstanceDisplayName
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary20
                        elide: Qt.ElideRight
                    }
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    Layout.preferredWidth: 100
                    text: qsTranslate("QObject", "Start date")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    elide: Qt.ElideRight
                }
                UiRowLayout {
                    id: iSelectCalendar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    color: UiTheme.colors.primary100
                    border.color: pMouseArea.containsMouse ? UiTheme.colors.accentNormal : UiTheme.colors.primary50
                    border.width: 1
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 1
                    bottomPadding: 1
                    spacing: 8
                    pMouseArea {
                        enabled: true
                        anchors.fill: iSelectCalendar
                        hoverEnabled: true
                        onClicked: {
                            fOpenCalendarSelectorPopup()
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: pDate
                        font: UiTheme.fonts.bodySmall
                        color: UiTheme.colors.primary10
                    }
                    UiImage {
                        asset: "Calendar"
                        pImageWidth: 16
                        pImageHeight: 16
                    }
                }
            }

            UiRowLayout {
                spacing: 12
                Text {
                    Layout.preferredWidth: 100
                    text: qsTranslate("QObject", "Start time")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    elide: Qt.ElideRight
                }
                UiRowLayout {
                    spacing: 8
                    UiComboBox {
                        id: iHoursTumbler
                        Layout.preferredWidth: 50
                        pMaxDropDownHeight: 86
                        pSize: UiTheme.comboBoxes.sizes.small
                        model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                        currentIndex: pHours - 1
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /^([1-9]|1[0-2])$/
                        }
                        onActivated: {
                            pHours = iHoursTumbler.currentValue
                            fEnableUpdateBtn()
                        }
                        onAccepted: {
                            if (find(iHoursTumbler.editText) !== -1) {
                                pHours = iHoursTumbler.editText
                            }
                        }
                        onEditTextChanged: {
                            if(pHours!= "" && pHours !== iHoursTumbler.editText) {
                                fEnableUpdateBtn()
                            }
                        }
                    }
                    UiComboBox {
                        id: iMinutesTumbler
                        Layout.preferredWidth: 50
                        pMaxDropDownHeight: 86
                        pSize: UiTheme.comboBoxes.sizes.small
                        model: 60
                        currentIndex: pMinutes
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /^([0-9]|[1-5][0-9])$/
                        }
                        onActivated: {
                            pMinutes = iMinutesTumbler.currentValue
                            fEnableUpdateBtn()
                        }
                        onAccepted: {
                            if (find(iMinutesTumbler.editText) !== -1) {
                                pMinutes = iMinutesTumbler.editText
                            }
                        }
                        onEditTextChanged: {
                            if(pMinutes != "" && pMinutes !== iMinutesTumbler.editText) {
                                fEnableUpdateBtn()
                            }
                        }
                    }
                    UiComboBox {
                        id: iSecondsTumbler
                        Layout.preferredWidth: 50
                        pMaxDropDownHeight: 86
                        pSize: UiTheme.comboBoxes.sizes.small
                        model: 60
                        currentIndex: pSeconds
                        editable: true
                        inputMethodHints: Qt.ImhDigitsOnly
                        validator: RegularExpressionValidator {
                            regularExpression: /^([0-9]|[1-5][0-9])$/
                        }
                        onActivated: {
                            pSeconds = iSecondsTumbler.currentValue
                            fEnableUpdateBtn()
                        }
                        onAccepted: {
                            if (find(iSecondsTumbler.editText) !== -1) {
                                pSeconds = iSecondsTumbler.editText
                            }
                        }
                        onEditTextChanged: {
                            if(pSeconds != "" && pSeconds !== iSecondsTumbler.editText) {
                                fEnableUpdateBtn()
                            }
                        }
                    }
                    UiComboBox {
                        id: iAmPmTumbler
                        Layout.preferredWidth: 50
                        pSize: UiTheme.comboBoxes.sizes.small
                        model: ListModel {
                            ListElement { value: "AM"; text: qsTranslate("QObject", "AM") }
                            ListElement { value: "PM"; text: qsTranslate("QObject", "PM") }
                        }
                        textRole: "text"
                        valueRole: "value"
                        currentIndex: pAmPm === "AM" ? 0 : 1
                        onActivated: {
                            pAmPm = iAmPmTumbler.currentValue
                            fEnableUpdateBtn()
                        }
                    }
                }
            }

            UiRowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    Layout.preferredWidth: 100
                    Layout.alignment: Qt.AlignTop
                    text: qsTranslate("QObject", "Repeat")
                    color: UiTheme.colors.primary10
                    font: UiTheme.fonts.bodySmall
                    elide: Qt.ElideRight
                }
                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    UiRowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: qsTranslate("QObject", "Once")
                            color: UiTheme.colors.primary10
                            font: UiTheme.fonts.bodySmall
                        }
                        UiToggleButton {
                            id: iRepeatToggleButton
                            checked: pScheduleMacroRepeatTime !== 0
                            onCheckedChanged: {
                                iRepeatIntervalLayout.visible = checked
                                if((pScheduleMacroRepeatTime !== 0 && !checked) || (pScheduleMacroRepeatTime === 0 && checked))
                                    fEnableUpdateBtn()
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: qsTranslate("QObject", "Repeat every")
                            color: UiTheme.colors.primary10
                            font: UiTheme.fonts.bodySmall
                        }
                    }
                    UiRowLayout {
                        id: iRepeatIntervalLayout
                        Layout.fillWidth: true
                        visible: false
                        spacing: 8
                        UiRowLayout {
                            spacing: 4
                            UiSpinBox {
                                id: iRepeatDaysSpinBox
                                implicitWidth: 44
                                implicitHeight: 24
                                realFrom: 0
                                realTo: 99
                                realStepSize: 1
                                realValue: parseInt(pScheduleMacroRepeatTime / (1000 * 60 * 60 * 24))
                                decimalPlaces: 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator {
                                    regularExpression: /^([0-9]|[1-9][0-9])$/
                                }
                                onValueChanged: {
                                    if(iRepeatDaysSpinBox.value !== parseInt(pScheduleMacroRepeatTime / (1000 * 60 * 60 * 24)))
                                        fEnableUpdateBtn()
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "DD")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                        }
                        UiRowLayout {
                            spacing: 4
                            UiSpinBox {
                                id: iRepeatHoursSpinBox
                                implicitWidth: 44
                                implicitHeight: 24
                                realFrom: 0
                                realTo: 23
                                realStepSize: 1
                                realValue: parseInt(pScheduleMacroRepeatTime / (1000 * 60 * 60)) % 24
                                decimalPlaces: 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator {
                                    regularExpression: /^([0-9]|1[0-9]|2[0-3])$/
                                }
                                onValueChanged: {
                                    if(iRepeatHoursSpinBox.value !== parseInt(pScheduleMacroRepeatTime / (1000 * 60 * 60)) % 24)
                                        fEnableUpdateBtn()
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "HH")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                        }
                        UiRowLayout {
                            spacing: 4
                            UiSpinBox {
                                id: iRepeatMinutesSpinBox
                                implicitWidth: 44
                                implicitHeight: 24
                                realFrom: 0
                                realTo: 59
                                realStepSize: 1
                                realValue: parseInt(pScheduleMacroRepeatTime / (1000 * 60)) % 60
                                decimalPlaces: 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator {
                                    regularExpression: /^([0-9]|[1-5][0-9])$/
                                }
                                onValueChanged: {
                                    if(iRepeatMinutesSpinBox.value !== parseInt(pScheduleMacroRepeatTime / (1000 * 60)) % 60)
                                        fEnableUpdateBtn()
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "MM")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                        }
                        UiRowLayout {
                            spacing: 4
                            UiSpinBox {
                                id: iRepeatSecondsSpinBox
                                implicitWidth: 44
                                implicitHeight: 24
                                realFrom: 0
                                realTo: 59
                                realStepSize: 1
                                realValue: parseInt(pScheduleMacroRepeatTime / 1000) % 60
                                decimalPlaces: 0
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator {
                                    regularExpression: /^([0-9]|[1-5][0-9])$/
                                }
                                onValueChanged: {
                                    if(iRepeatSecondsSpinBox.value !== parseInt(pScheduleMacroRepeatTime / 1000) % 60)
                                        fEnableUpdateBtn()
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "SS")
                                color: UiTheme.colors.primary20
                                font: UiTheme.fonts.bodySmall
                            }
                        }
                    }
                }
            }

            UiButton {
                Layout.alignment: Qt.AlignRight
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: pIsUpdateMacroSchedule ? qsTranslate("QObject", "Update") : qsTranslate("QObject", "Schedule")
                enabled: pDate !== "mm/dd/yyyy" && ((pIsUpdateMacroSchedule && pEnableUpdate) || iScheduledMacro.currentIndex !== -1)
                opacity: enabled ? 1 : 0.4
                onClicked: {
                    var date = pDate.split('/')
                    var hours = parseInt(pHours)
                    if (pAmPm === "AM")
                        hours = hours % 12
                    else if (pAmPm === "PM")
                        hours = (hours % 12) + 12

                    var mSecsFromEpochUTCStartTime = mnsBackend.getMSecsFromEpochUTC(date[2], date[0], date[1], hours, pMinutes, pSeconds)
                    var mSecsRepeatTime = 0
                    if (iRepeatToggleButton.checked) {
                        mSecsRepeatTime = parseInt(iRepeatDaysSpinBox.value) * 24 * 60 * 60 * 1000
                                + parseInt(iRepeatHoursSpinBox.value) * 60 * 60 * 1000
                                + parseInt(iRepeatMinutesSpinBox.value) * 60 * 1000
                                + parseInt(iRepeatSecondsSpinBox.value) * 1000
                    }

                    if (pIsUpdateMacroSchedule)
                        mnsBackend.pMacroScheduleListModel.updateScheduleMacro(pScheduleMacroId, mSecsFromEpochUTCStartTime, mSecsRepeatTime)
                    else {
                        mnsBackend.initializeScheduleMacro()
                        mnsBackend.pMacroScheduleListModel.createScheduleMacro(iScheduledMacro.currentValue, mSecsFromEpochUTCStartTime, mSecsRepeatTime)
                    }

                    iCreateMacroScheduleWindow.close()
                }
            }
        }
    }

    Component {
        id: iCalendarSelectorComponent
        UiWindowedPopup {
            id: iCalendarSelector
            contentWidth: iSelectCalendar.width
            contentHeight: iCalendarUi.implicitHeight
            x: iSelectCalendar.mapToGlobal(0, 0).x - width + iSelectCalendar.width + shadowThickness
            y: iSelectCalendar.mapToGlobal(0, 0).y + iSelectCalendar.height - shadowThickness
            UiCalendar {
                id: iCalendarUi
                anchors.left: parent != null ? parent.left : undefined
                anchors.right: parent != null ? parent.right : undefined
                pSelectedDate: pScheduleMacroDate
                pMinimumDate: new Date()
                onDateSelected: {
                    pScheduleMacroDate = iCalendarUi.pSelectedDate
                    pDate = fGetFormattedDate(iCalendarUi.pSelectedDate)
                    fEnableUpdateBtn()
                    iCalendarSelector.close()
                }
            }
        }
    }

    function fOpenCalendarSelectorPopup() {
        if (pCalendarSelectorWin != null) {
            if (pCalendarSelectorWin.visible)
                pCalendarSelectorWin.close()
            return
        }

        pCalendarSelectorWin = iCalendarSelectorComponent.createObject(iCreateMacroScheduleWindow)
        pCalendarSelectorWin.show()
    }

    function fEnableUpdateBtn() {
        pEnableUpdate = true
    }

    function fGetFormattedDate(date) {
        var month = pScheduleMacroDate.getMonth() + 1
        var day = pScheduleMacroDate.getDate()
        var formattedDate = (month < 10 ? '0' : '') + month + '/' +
                (day < 10 ? '0' : '') + day + '/' + pScheduleMacroDate.getFullYear()
        return formattedDate
    }
}
