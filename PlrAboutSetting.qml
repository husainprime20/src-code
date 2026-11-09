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

Item {
    objectName: "aboutSettings"
    property bool pUpdateAvailable: false
    property string pUpdateVersion: ""
    property string pMoreInfoURL: ""
    property string pDownloadURL: ""
    property bool pIsInCompatibleUpdateVersion : false
    property string pParentWindow: ""
    UiColumnLayout {
        anchors.fill: parent
        spacing: 24
        UiScrollView {
            id: iScrollView
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            clip: true
            contentWidth: iContentLayout.width
            contentHeight: iContentLayout.height + 10

            UiColumnLayout {
                id: iContentLayout
                width: 548
                Layout.alignment: Qt.AlignTop
                spacing: 16
                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    UiImage {
                        asset: "BlueStacks5Beta"
                        pImageWidth: 160
                        pImageHeight: 48
                        Layout.alignment: Qt.AlignTop
                    }
                    Rectangle {
                        Layout.preferredWidth: 1
                        color: UiTheme.colors.primary50
                        Layout.fillHeight: true
                    }
                    UiColumnLayout {
                        spacing: 2
                        UiRowLayout {
                            Text {
                                text: qsTranslate("QObject", "%1").arg(uiBackend.productName)
                                font: UiTheme.fonts.bodyLarge
                                color: UiTheme.colors.primary10
                                visible: uiBackend.oem !== "nxt" ? true : false
                            }
                            Text {
                                text: "App Player"
                                font: UiTheme.fonts.bodyLarge
                                Layout.leftMargin: 3
                                color: UiTheme.colors.primary20
                                visible: uiBackend.oem==="nxt" ? true:false
                            }
                        }


                        Text {
                            id: iAndroidText
                            text: plrBackend.version + " " + qsTranslate("QObject", uiBackend.getImageTrait(plrBackend.getVmName()).shortDisplayName)
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary30
                        }
                    }
                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        UiTextUrl {
                            id: iIncompatibleVersionInfo
                            visible: pIsInCompatibleUpdateVersion
                            text: qsTranslate("QObject", "A new update is available but it is not compatible with your machine.") + " <a href=\"javascript:void(0)\">"+qsTranslate("QObject", "More info.")+"</a>"
                            font:  UiTheme.fonts.bodySmall
                            color: UiTheme.colors.primary30
                            linkColor: UiTheme.colors.accentNormal
                            wrapMode: Text.Wrap
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: parent.width
                            Layout.maximumWidth: 229
                            onLinkActivated: uiBackend.openHelpArticle("incompatible_update_version")
                        }
                        Text {
                            id: iOnLatestVersion
                            Layout.alignment: Qt.AlignRight
                            text: qsTranslate("QObject", "You are on the latest version")
                            font: UiTheme.fonts.bodySmall
                            color: UiTheme.colors.primary20
                            visible: false
                        }
                        UiTextUrl {
                            Layout.alignment: Qt.AlignRight
                            text: pUpdateVersion+" "+ qsTranslate("QObject", "available") + " . <a href=\"javascript:void(0)\">"+qsTranslate("QObject", "More info")+"</a>"
                            font: UiTheme.fonts.bodyExtraSmall
                            color: UiTheme.colors.primary20
                            visible: pUpdateAvailable && !pIsInCompatibleUpdateVersion
                            linkColor: UiTheme.colors.accentNormal
                            onLinkActivated: Qt.openUrlExternally(pMoreInfoURL)
                        }
                        UiButton{
                            Layout.preferredWidth: 124
                            Layout.alignment: Qt.AlignRight
                            pSize: UiTheme.buttons.sizes.small
                            pColor: UiTheme.buttons.colors.accent
                            text: pUpdateAvailable ? qsTranslate("QObject", "Download Update"): qsTranslate("QObject", "Check for updates")
                            visible: !iLoader.visible && !iOnLatestVersion.visible && !iIncompatibleVersionInfo.visible
                            onClicked: {
                                if(pUpdateAvailable)
                                {
                                    Qt.openUrlExternally(pDownloadURL)
                                }
                                else
                                {
                                    iLoader.visible = true;
                                    plrBackend.checkForUpdate();
                                }
                            }
                        }
                        UiRowLayout {
                            spacing: 7
                            Layout.alignment: Qt.AlignRight
                            UiImage {
                                id: iLoader
                                asset: "Loader_bright"
                                pImageWidth: 12
                                pImageHeight: 12
                                visible: false
                                cache: false
                                RotationAnimation on rotation {
                                    loops: Animation.Infinite
                                    duration: 2000
                                    from: 0
                                    to: 360
                                    direction: RotationAnimation.Clockwise
                                    running: iLoader.visible
                                }
                            }
                            Text {
                                text: qsTranslate("QObject", "Checking")
                                font: UiTheme.fonts.bodySmall
                                color: UiTheme.colors.primary20
                                visible: iLoader.visible
                            }
                        }


                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: uiBackend.oem !== "msi5"
                    Text {
                        text: qsTranslate("QObject", "Important links")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        UiTextUrl {
                            id: iSupportEmailText
                            text: qsTranslate("QObject", "Support email") + ((uiBackend.oem === "nxt_cn") ? " - <a href=\"javascript:void(0)\">china-support@bluestacks.com</a>" : " - <a href=\"javascript:void(0)\">support@bluestacks.com</a>")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            linkColor: UiTheme.colors.accentNormal
                            onLinkActivated: (uiBackend.oem === "nxt_cn") ? uiBackend.openEmail("china-support@bluestacks.com") : uiBackend.openEmail("support@bluestacks.com")
                        }

                        UiTextUrl {
                            id: iSupportText
                            text: qsTranslate("QObject", "Support") + ((uiBackend.oem === "nxt_cn") ?  " - <a href=\"javascript:void(0)\">bluestacks.cn/faq.html</a>" : " - <a href=\"javascript:void(0)\">support.bluestacks.com</a>")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            linkColor: UiTheme.colors.accentNormal
                            onLinkActivated: (uiBackend.oem === "nxt_cn") ?  Qt.openUrlExternally("https://www.bluestacks.cn/faq.html") : Qt.openUrlExternally("http://support.bluestacks.com")
                        }

                        UiTextUrl {
                            id: iWebsiteText
                            text: qsTranslate("QObject", "Website") + ((uiBackend.oem === "nxt_cn") ?  " - <a href=\"javascript:void(0)\">www.bluestacks.cn</a>" : " - <a href=\"javascript:void(0)\">www.bluestacks.com</a>")
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                            linkColor: UiTheme.colors.accentNormal
                            onLinkActivated: (uiBackend.oem === "nxt_cn") ?  Qt.openUrlExternally("http://www.bluestacks.cn") : Qt.openUrlExternally("http://www.bluestacks.com")
                        }
                    }
                    UiRowLayout
                    {
                        visible: uiBackend.oem === "nxt_cn"
                        Text {
                            text: "联系我们:"
                            font: UiTheme.fonts.bodyMedium
                            color: UiTheme.colors.primary20
                        }
                        UiRowLayout {
                            Layout.leftMargin: 50
                            UiButton {
                                implicitWidth: 64
                                pSize: UiTheme.buttons.sizes.small
                                pColor: UiTheme.buttons.colors.accent
                                text: "在线客服"
                                onClicked: uiBackend.openQQSupportUrl()
                            }
                            UiButton {
                                implicitWidth: 64
                                Layout.leftMargin: 40
                                pSize: UiTheme.buttons.sizes.small
                                pColor: UiTheme.buttons.colors.accent
                                text: "QQ群"
                                onClicked: Qt.openUrlExternally("https://jq.qq.com/?_wv=1027&k=6x617Pxu")
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 1
                    color: UiTheme.colors.seperator
                    Layout.fillWidth: true
                    visible: uiBackend.oem !== "msi5"
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    visible: uiBackend.oem !== "msi5"
                    Text {
                        text: qsTranslate("QObject", "About and other info")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    UiTextUrl {
                        id: iTermsOfUseText
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "©2011 through 2026 now.gg, Inc. All rights reserved worldwide. By using BlueStacks you agree to our ") + "<a href=\"javascript:void(0)\">" + qsTranslate("QObject", "Terms of use") + "</a>"
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary20
                        linkColor: UiTheme.colors.accentNormal
                        onLinkActivated: uiBackend.openHelpArticle("terms_of_use")
                    }
                }
            }
        }
    }

    function fCheckForUpdateCallback(apiCallStatus,jsonData) {
        if(apiCallStatus == 0) {
            var jsonObj= JSON.parse(jsonData)
            pUpdateAvailable = (jsonObj.update_available.toLowerCase()  == 'true')
            pIsInCompatibleUpdateVersion = false
            iLoader.visible = false
            if (pUpdateAvailable) {
                pUpdateVersion = jsonObj.update_details.client_version;
                pMoreInfoURL = jsonObj.update_details.detailed_changelogs_url;
                pDownloadURL = jsonObj.update_details.download_url;
                pIsInCompatibleUpdateVersion = !(jsonObj.update_details.is_build_compatible.toLowerCase() === 'true')
            }
            else {
                iOnLatestVersion.visible = true;
            }

        } else {
            pUpdateAvailable = false;
            iLoader.visible = false
            pIsInCompatibleUpdateVersion = false
        }
    }

    function fUpdateShortDisplayName(displayName) {
        iAndroidText.text = plrBackend.version + " " + displayName
    }
}

