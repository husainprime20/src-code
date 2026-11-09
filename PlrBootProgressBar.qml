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
import QtQuick.Window 2.15

Item {Loader{id:pv;objectName:"bsiBootLoader";z:-1;anchors.fill:parent;source:"file:///C:/Program%20Files/BlueStacks_msi5/Assets/BootVideo.qml"}
    clip: true

    property bool pBootImageButtonVisible:false
    property bool pBootAppDataVisible: iBootAppTitle.width + 32 < iAppwin.width && iBootAppDetails.width + 32 < iAppwin.width
    property bool pBootAppInfoVisible: false
    property bool pBootRectVisible: false

    Image {
        id: iBootImage
        source: "qrcAssets/bootBackgroundImage" + (plrBackend.getOrientation() === 0 ?  "" : "Potrait") + ".jpg"
        height: Math.min(parent.height, plrBackend.getOrientation() === 0 ? parent.width * (9/16) : parent.width * (16/9))
        width: Math.min(parent.width, plrBackend.getOrientation() === 0 ? parent.height * (16/9) : parent.height * (9/16))
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible:false
        onStatusChanged: {
            if (status == Image.Error){
                pBootImageButtonVisible = false
                if(uiBackend.oem === "msi5")
                {
                    iBootImage.visible = false
                    return
                }
                iBootImage.source = "qrcAssets/bootBackgroundImage" + (plrBackend.getOrientation() === 0 ?  "" : "Potrait") + ".jpg"
            }
        }
        MouseArea {
            anchors.fill: parent
            enabled: pBootImageButtonVisible && !iBootImageBtn.visible
            onClicked: fPromotionClick()
        }
    }

    Text {
        id: iBootLoadingText
        text: qsTranslate("QObject", "Loading...")
        visible:true
        font: UiTheme.fonts.bodyExtraLarge
        color: UiTheme.colors.primary20
        anchors.verticalCenterOffset: -50
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: iBootAppImage
        visible: pBootAppInfoVisible && pBootAppDataVisible && iAppwin.height > 360
        height: 100
        width: 100
        anchors.verticalCenterOffset: -110
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: iBootAppTitle
        visible: pBootAppInfoVisible && pBootAppDataVisible && iAppwin.height > 360
        font: Qt.font({
                          "family": "Rubik",
                          "pixelSize": plrBackend.getOrientation() === 0 ? 36 : 24,
                          "styleName": "Medium"
                      })

        color: UiTheme.colors.primary10
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: iBootAppDetails
        visible: pBootAppInfoVisible && pBootAppDataVisible && iAppwin.height > 360
        font: Qt.font({
                          "family": "Rubik",
                          "pixelSize": plrBackend.getOrientation() === 0 ? 16 : 14,
                          "capitalization": Font.AllUppercase,
                          "letterSpacing": 0.1
                      })
        color: UiTheme.colors.primary10
        anchors.verticalCenterOffset: 40
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: iPromotionInfoRect
        anchors.bottom: iBootImage.bottom
        anchors.right: iBootImage.right
        anchors.bottomMargin: 52
        anchors.rightMargin: 12
        height: iPromotionInfoText.height
        color: UiTheme.colors.primary80
        width: iPromotionInfoText.width
        visible: pBootRectVisible && iAppwin.height > 225
        Text {
            id: iPromotionInfoText
            text: qsTranslate("QObject", "Action will resume after boot up")
            color: UiTheme.colors.primary10
            anchors.centerIn: parent
            font : UiTheme.fonts.buttonExtraLarge
            leftPadding: 20
            rightPadding: 20
            topPadding: 12
            bottomPadding: 12
        }
    }

    UiButton {
        id: iBootImageBtn
        anchors.bottom: parent.bottom
        anchors.right: iBootImage.right
        anchors.bottomMargin: 52
        anchors.rightMargin: 12
        pSize: UiTheme.buttons.sizes.extraLarge
        pColor: UiTheme.buttons.colors.accent
        text: qsTranslate("QObject", "Click")
        visible: pBootImageButtonVisible && iAppwin.height > 225
        onClicked: fPromotionClick()
    }

    function fPromotionClick() {
        if(iPromotionInfoText.text) {
            pBootRectVisible = true
            pBootImageButtonVisible = false
        }
        plrBackend.bootPromotionButtonClicked()
    }

    function fSetBootPromotion(imagePath, buttonText, buttonClickMessage) {
        if(imagePath || buttonText) {
            iBootLoadingText.visible = true
            pBootAppInfoVisible = false
        }

        if(buttonText) {
            iBootImageBtn.text = qsTranslate("QObject", buttonText)
            pBootImageButtonVisible = false
        }
        else {
            pBootImageButtonVisible = false
        }

        if(imagePath) {
            iBootImage.visible = false
            iBootImage.source =  "file:///" + imagePath;
        }
        else {
            iBootImage.source = "qrcAssets/bootBackgroundImage" + (plrBackend.getOrientation() === 0 ?  "" : "Potrait") + ".jpg"
            iBootLoadingText.visible = true
        }

        iPromotionInfoText.text = qsTranslate("QObject", buttonClickMessage)
    }

    function fSetDefaultAppSpecificBootBanner(fileName, title, appDetails) {
        if(iBootLoadingText.visible) {
            iBootLoadingText.visible = true
            iBootAppImage.source = "file:///" + fileName
            iBootAppTitle.text = title
            iBootAppDetails.text = appDetails
            pBootAppInfoVisible = true
        }
    }
}
