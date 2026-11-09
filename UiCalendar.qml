/*
 * Copyright (C) 2020-2021 BlueStack Systems, Inc.
 * All Rights Reserved
 *
 * THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF BLUESTACK SYSTEMS, INC.
 * The copyright notice above does not evidence any actual or intended
 * publication of such source code.
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls

UiColumnLayout {
    id: iCalendar

    property date pSelectedDate: new Date()
    property date pMinimumDate: new Date()
    property int pVisibleMonth: pSelectedDate.getMonth()
    property int pVisibleYear: pSelectedDate.getFullYear()
    property var pLocale: Qt.locale("en_US")

    signal dateSelected()

    color: UiTheme.colors.primary100
    border.color: UiTheme.colors.primary50
    border.width: 1
    padding: 1

    UiRowLayout {
        Layout.fillWidth: true
        color: UiTheme.colors.primary100
        topPadding: 10
        bottomPadding: 10
        leftPadding: 30
        rightPadding: 30
        spacing: 18
        Text {
            Layout.fillWidth: true
            text: getCalendarMonthText(iCalendar.pVisibleMonth) + " " + iCalendar.pVisibleYear
            font : UiTheme.fonts.titleSmallest
            color: UiTheme.colors.primary10
        }
        UiImageButton {
            asset: "RightArrow"
            pImageWidth: 16
            pImageHeight: 16
            rotation: 90
            onClicked: iCalendar.showNextMonth()
        }
        UiImageButton {
            asset: "RightArrow"
            pImageWidth: 16
            pImageHeight: 16
            rotation: 270
            onClicked: iCalendar.showPreviousMonth()
        }
    }

    DayOfWeekRow {
        locale: iCalendar.pLocale
        Layout.fillWidth: true
        delegate: Text {
            text: shortName
            padding: 6
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font : UiTheme.fonts.bodyMedium
            color: UiTheme.colors.primary10
        }
    }

    MonthGrid {
        id: iMonthGrid
        month: iCalendar.pVisibleMonth
        year: iCalendar.pVisibleYear
        locale: iCalendar.pLocale
        Layout.fillWidth: true
        padding: 0
        spacing: 0

        delegate: UiRowLayout {
            id: iMonthGridDelegate

            property bool isCurrentItem: model.date.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat) === iCalendar.pSelectedDate.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat)

            padding: 1
            border.width: 1
            border.color: pMouseArea.containsMouse && enabled ? UiTheme.colors.accentNormal : UiTheme.colors.primary80
            enabled: model.date.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat) === iCalendar.pMinimumDate.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat) || model.date > iCalendar.pMinimumDate
            pMouseArea {
                enabled: true
                anchors.fill: iMonthGridDelegate
                propagateComposedEvents: true
                hoverEnabled: true
                onPressed: function (mouse) {
                    mouse.accepted = false
                }
            }
            UiRowLayout {
                Layout.fillWidth: true
                padding: 6
                opacity: model.month === iMonthGrid.month ? 1 : 0.4
                color: iMonthGridDelegate.isCurrentItem ? UiTheme.colors.accentNormal : UiTheme.colors.primary100
                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: iCalendar.pLocale.toString(model.date, "d")
                    font : UiTheme.fonts.bodyMedium
                    color: iMonthGridDelegate.isCurrentItem ? UiTheme.colors.primary10 : UiTheme.colors.primary20
                }
            }
        }

        onClicked: function (date) {
            if (date.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat) === iCalendar.pMinimumDate.toLocaleDateString(iCalendar.pLocale, Locale.ShortFormat) || date > iCalendar.pMinimumDate) {
                iCalendar.pSelectedDate = date
                iCalendar.dateSelected()
            }
        }
    }

   function getCalendarMonthText(month) {
        if (month === 0)
            return "January"
        else if (month === 1)
            return "February"
        else if (month === 2)
            return "March"
        else if (month === 3)
            return "April"
        else if (month === 4)
            return "May"
        else if (month === 5)
            return "June"
        else if (month === 6)
            return "July"
        else if (month === 7)
            return "August"
        else if (month === 8)
            return "September"
        else if (month === 9)
            return "October"
        else if (month === 10)
            return "November"
        else if (month === 11)
            return "December"
    }

    function showPreviousMonth() {
        if (iCalendar.pVisibleMonth === 0) {
            iCalendar.pVisibleMonth = 11
            --iCalendar.pVisibleYear
        } else {
            --iCalendar.pVisibleMonth
        }
    }

    function showNextMonth() {
        if (iCalendar.pVisibleMonth === 11) {
            iCalendar.pVisibleMonth = 0
            ++iCalendar.pVisibleYear
        } else {
            ++iCalendar.pVisibleMonth
        }
    }
}
