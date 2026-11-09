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
import UiToolTipControl 1.0
import DialogButtonModel 1.0
import DialogButtonModelList 1.0
import UiDialogWindow 1.0

Item {
    objectName: "userData"

    property var optimizationSpaceRequiredinMB: plrBackend.computeOptimizationSpaceRequired()
    property var pDrive: plrBackend.getDataDrive()
    property string pParentWindow: ""

    Component {
        id: iDiskCleanupPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Disk cleanup")
            pDescription: qsTranslate("QObject", "%1 will now clean up its disk. Before starting all instance(s) will be closed. This process may take some time depending on your PC's performance.\n\nWould you like to continue?").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.SimpleNarrow
            pDialogImageSource: "Clean"
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Continue")
                        onClicked: {
                            uiBackend.launchDiskCleanup(plrBackend.getVmName(), "")
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Close")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iDiskOptimizationPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Disk format check")
            pDescription: qsTranslate("QObject", "All %1 instances should be closed before the format check starts.").arg(uiBackend.productName) + "\n\n" + qsTranslate("QObject", "Would you like to start?")
            pDialogImageSource: "Optimize"
            pDialogType: UiDialogWindow.SimpleNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Start")
                        onClicked: {
                            plrBackend.launchDiskOptimization(plrBackend.getVmName())
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Later")
                        onClicked: {
                            plrBackend.removeDiskOptimizationOnboarding()
                            close()
                        }
                    }
                ]
            }
            onCloseClicked: {
                plrBackend.removeDiskOptimizationOnboarding()
            }
        }
    }

    Component {
        id: iCannotStartDiskOptimizationPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Low disk space")
            pDescription: qsTranslate("QObject", "Cannot start disk format check. Please free up at least %1 GB in %2 drive and try again.").arg(String(Math.ceil(optimizationSpaceRequiredinMB / 1024))).arg(pDrive)
            pDialogImageSource: "ErrorLarge"
            pDialogHeaderImageSource: "Optimize"
            pDialogType: UiDialogWindow.DescriptiveNarrow
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Okay")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iCreateBackupPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Backup warning")
            pDescription: qsTranslate("QObject", "You will not be able to use %1 while backup is in progress. Would you like to start the backup?").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.SimpleNarrow
            pDialogImageSource: "Clean"
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Start")
                        onClicked: {
                            plrBackend.launchDataManagerBinary("backup")
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    Component {
        id: iRestoreBackupPrompt
        UiMessageDialog {
            title: qsTranslate("QObject", "Restore backup")
            pDescription: qsTranslate("QObject", "Before restoring, take a backup of your current %1 data to avoid loss of files in case a problem occurs while restoring.").arg(uiBackend.productName)
            pDialogType: UiDialogWindow.SimpleNarrow
            pDialogImageSource: "Clean"
            pButtonsList: DialogButtonModelList {
                pButtons: [
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.accent
                        pText: qsTranslate("QObject", "Restore anyway")
                        onClicked: {
                            plrBackend.launchDataManagerBinary("restore")
                            close()
                        }
                    },
                    DialogButtonModel {
                        pColor: UiTheme.buttons.colors.secondary
                        pText: qsTranslate("QObject", "Cancel")
                        onClicked: {
                            close()
                        }
                    }
                ]
            }
        }
    }

    UiColumnLayout {
        id: iContentLayout
        width: 520
        spacing: 40
        Layout.alignment: Qt.AlignTop
        UiColumnLayout {
            Layout.fillWidth: true
            spacing: 32
            UiRowLayout {
                Layout.fillWidth: true
                spacing: 16
                UiImage {
                    asset: "DiskCleanup"
                    pImageWidth: 48
                    pImageHeight: 48
                    Layout.alignment: Qt.AlignTop
                }
                UiColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    Text {
                        text: qsTranslate("QObject", "Disk cleanup")
                        font: UiTheme.fonts.bodyLarge
                        color: UiTheme.colors.primary10
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Free up space unused by %1 so that other Windows apps on your PC may use it.").arg(uiBackend.productName)
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary30
                        wrapMode: Text.Wrap
                    }
                }
            }
            UiButton {
                Layout.alignment: Qt.AlignRight
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Free up space")
                onClicked: {
                    iDiskCleanupPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                }
            }
        }

        UiColumnLayout {
            Layout.fillWidth: true
            spacing: 32
            visible: plrBackend.showDiskOptimizationSetting()
            UiRowLayout {
                Layout.fillWidth: true
                spacing: 16
                UiImage {
                    asset: "Disk_optimize"
                    pImageWidth: 48
                    pImageHeight: 48
                    Layout.alignment: Qt.AlignTop
                }
                UiColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    UiRowLayout {
                        spacing: 4
                        Text {
                            text: qsTranslate("QObject", "Disk format check")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("Disk_Optimization_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                        Rectangle {
                            visible: plrBackend.pDiskOptimizationOnboarding
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: UiTheme.colors.dangerNormal
                            Layout.alignment: Qt.AlignVCenter
                            Layout.leftMargin: 4
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "One-time disk format check to ensure consistency with current %1 version.").arg(uiBackend.productName)
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary30
                        wrapMode: Text.Wrap
                    }
                }
            }
            UiButton {
                Layout.alignment: Qt.AlignRight
                pSize: UiTheme.buttons.sizes.medium
                pColor: UiTheme.buttons.colors.accent
                text: qsTranslate("QObject", "Check format")
                onClicked: {
                    if(plrBackend.isOptimizationSpaceAvailable(optimizationSpaceRequiredinMB))
                        iDiskOptimizationPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    else {
                        iCannotStartDiskOptimizationPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    }
                }
            }
        }

        UiColumnLayout {
            Layout.fillWidth: true
            spacing: 32
            UiRowLayout {
                Layout.fillWidth: true
                spacing: 16
                UiImage {
                    asset: "Backup_restore"
                    pImageWidth: 48
                    pImageHeight: 48
                    Layout.alignment: Qt.AlignTop
                }
                UiColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true
                    UiRowLayout {
                        spacing: 4
                        Text {
                            text: qsTranslate("QObject", "Backup and restore")
                            font: UiTheme.fonts.bodyLarge
                            color: UiTheme.colors.primary10
                        }
                        UiImageButton {
                            asset: "MenuHelp"
                            pImageWidth: 16
                            pImageHeight: 16
                            UiToolTip.text: qsTranslate("QObject", "Help")
                            onClicked: uiBackend.openHelpArticle("Backup_Restore_Help")
                            pMouseCursor: hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTranslate("QObject", "Backup your installed apps, game controls, user data, macros, settings, and all other instances. Restore them anytime.")
                        font: UiTheme.fonts.bodyMedium
                        color: UiTheme.colors.primary30
                        wrapMode: Text.Wrap
                    }
                }
            }
            UiRowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 16
                UiButton {
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.secondary
                    text: qsTranslate("QObject", "Restore backup")
                    onClicked: {
                        iRestoreBackupPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    }
                }
                UiButton {
                    pSize: UiTheme.buttons.sizes.medium
                    pColor: UiTheme.buttons.colors.accent
                    text: qsTranslate("QObject", "Create backup")
                    onClicked: {
                        iCreateBackupPrompt.createObject(iSettingsWindow, { "transientParent": iSettingsWindow }).show()
                    }
                }
            }
        }
    }
}
