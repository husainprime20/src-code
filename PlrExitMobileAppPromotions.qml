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

import UiToolTipControl 1.0
import UiQuickWindow 1.0

UiQuickWindow {
    id: iExitAppPromotionsWindow
    color: "transparent"
    flags: Qt.Dailog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    title: "BlueStacks Exit Window"
    width: 500 + 2 * iShadow.shadowThickness
    height: iMainLayout.implicitHeight + 2 * iShadow.shadowThickness
    property string pTopActivityAppPackage: ""
    property string pTopActivityAppLabel: ""
    property bool pEmailSentToCloud: false

    PlrQRGenerator {
        id: iQrObj
        content: "txtField.text"
        join: true
    }

    onClosed: {
        iExitAppPromotionsWindow.destroy()
    }

    onVisibleChanged: {
        if (visible) {
            if (iExitAppPromotionsWindow.transientParent != null) {
                iExitAppPromotionsWindow.x = Qt.binding(function() {
                    var messageWindowX = iExitAppPromotionsWindow.transientParent.x + (iExitAppPromotionsWindow.transientParent.width - iExitAppPromotionsWindow.width) / 2
                    if (messageWindowX < iExitAppPromotionsWindow.transientParent.screen.virtualX)
                        messageWindowX = iExitAppPromotionsWindow.transientParent.screen.virtualX
                    if(messageWindowX + iExitAppPromotionsWindow.width > iExitAppPromotionsWindow.transientParent.screen.virtualX + iExitAppPromotionsWindow.transientParent.screen.width)
                        messageWindowX = iExitAppPromotionsWindow.transientParent.screen.virtualX + iExitAppPromotionsWindow.transientParent.screen.width - iExitAppPromotionsWindow.width
                    return messageWindowX
                })
                iExitAppPromotionsWindow.y = Qt.binding(function() {
                    var messageWindowY = iExitAppPromotionsWindow.transientParent.y + (iExitAppPromotionsWindow.transientParent.height - iExitAppPromotionsWindow.height) / 2
                    if (messageWindowY < iExitAppPromotionsWindow.transientParent.screen.virtualY)
                        messageWindowY = iExitAppPromotionsWindow.transientParent.screen.virtualY
                    if(messageWindowY + iExitAppPromotionsWindow.height > iExitAppPromotionsWindow.transientParent.screen.virtualY + iExitAppPromotionsWindow.transientParent.screen.height)
                        messageWindowY = iExitAppPromotionsWindow.transientParent.screen.virtualY + iExitAppPromotionsWindow.transientParent.screen.height - iExitAppPromotionsWindow.height
                    return messageWindowY
                })
            }

            iQrObj.content = plrBackend.getQrLink(pTopActivityAppPackage)
        }
    }

    UiShadowContainer {
        id:iShadow
        UiColumnLayout {
            id: iMainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            padding: 24
            color: UiTheme.colors.primary70
            border.width: 1
            border.color: UiTheme.colors.primary40
            spacing: 20

            UiRowLayout {
                Layout.fillWidth: true
                spacing: 12

                UiImage {
                    pImageWidth: 72
                    pImageHeight: 72
                    source: "file:///" + plrBackend.getAppIconPath(pTopActivityAppPackage)
                }

                UiColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignLeft
                        text: pTopActivityAppLabel
                        font: UiTheme.fonts.bodyExtraLarge
                        color: UiTheme.colors.primary10
                        elide: Text.ElideRight
                        opacity: 0.6
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Qt.AlignLeft
                        text: qsTranslate("QObject", "Install on Phone via %1 Mobile App").arg(uiBackend.productName)
                        font: UiTheme.fonts.titleLarger
                        color: UiTheme.colors.primary10
                        wrapMode: Text.Wrap
                    }
                }


                UiImageButton {
                    asset: "CloseIcon"
                    pImageWidth: 16
                    pImageHeight: 16
                    Layout.alignment: Qt.AlignTop | Qt.AlignRight
                    onClicked: {
                        iExitAppPromotionsWindow.close()
                    }
                }
            }



            UiColumnLayout {
                Layout.fillWidth: true
                border.width: 1
                border.color: "#1AFFFFFF"

                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    padding: 20
                    color: "#1AFFFFFF"


                    UiImage {
                        pImageWidth: 96
                        pImageHeight: 96
                        source: (iQrObj.svgString === "")
                                ? ""
                                : ("data:image/svg+xml;utf8," + iQrObj.svgString)
                    }

                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Qt.AlignLeft
                            text: qsTranslate("QObject", "Scan QR with Phone")
                            font: UiTheme.fonts.titleLarge
                            color: UiTheme.colors.primary10
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Qt.AlignLeft
                            text: qsTranslate("QObject", "Use your phone's camera or a QR scanner app to scan the code.")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                            wrapMode: Text.Wrap
                        }
                    }
                }

                Rectangle {
                    Layout.topMargin: -18
                    Layout.bottomMargin: -18
                    Layout.leftMargin: 136
                    Layout.alignment: Qt.AlignLeft
                    radius: 18
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    color : "#2EFFFFFF"
                    border.width: 0.8
                    border.color: UiTheme.colors.overLayTint
                    Text {
                        anchors.fill: parent
                        text: qsTranslate("QObject", "OR")
                        font: UiTheme.fonts.titleSmall
                        color: UiTheme.colors.primary10
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                UiRowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    padding: 20
                    color: "#2EFFFFFF"

                    UiImage {
                        pImageWidth: 96
                        pImageHeight: 96
                        asset: "EmailIcon"
                    }

                    UiColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Qt.AlignLeft
                            text: pEmailSentToCloud ? qsTranslate("QObject", "Link sent to your email") : qsTranslate("QObject", "Get the link over email")
                            font: UiTheme.fonts.titleLarge
                            color: UiTheme.colors.primary10
                            elide: Text.ElideRight
                        }

                        Text {
                            id: iEmailTitle
                            Layout.fillWidth: true
                            horizontalAlignment: Qt.AlignLeft
                            text: pEmailSentToCloud ? qsTranslate("QObject", "Check your inbox on your phone and tap the link to install") : qsTranslate("QObject", "We’ll send the download link to this email")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary20
                            wrapMode: Text.Wrap
                        }

                        UiRowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            UiTextField {
                                id: iEmailText
                                visible: !pEmailSentToCloud
                                Layout.fillWidth: true
                                pSize: UiTheme.textFields.sizes.medium
                                pColor: UiTheme.textFields.colors.secondary
                                horizontalAlignment: Text.AlignLeft
                                placeholderText: "email@example.com"

                                onTextEdited: {
                                    var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                                    if (!regex.test(text)) {
                                        iEmailText.pInputValidationState = UiTextField.InputValidation.Error
                                    }
                                    else {
                                        iEmailText.pInputValidationState = UiTextField.InputValidation.Valid
                                    }
                                }
                            }
                            UiButton {
                                id: iSubmitBtn
                                visible: !pEmailSentToCloud
                                Layout.alignment: Qt.AlignRight
                                pSize: UiTheme.buttons.sizes.medium
                                pColor: UiTheme.buttons.colors.accent
                                text: qsTranslate("QObject", "Submit")
                                enabled: iEmailText.text !== "" && iEmailText.pInputValidationState !== UiTextField.InputValidation.Error
                                opacity: enabled ? 1 : 0.6
                                hoverEnabled: enabled
                                onClicked: {
                                    pEmailSentToCloud = true
                                    plrBackend.sendEmailForMobileApkLink(iEmailText.text, pTopActivityAppPackage, pTopActivityAppLabel)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
