import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4
import Lomiri.Components.Pickers 1.3

Page {
    anchors.fill: parent

    signal settingsChanged(string trashType, string reminderSet)

    property string trashType
    property string reminderSet

    property int reminderOption
    property int hour
    property int minutes

    header: PageHeader {
        id: header
        title: i18n.tr('Herinnering voor ') + (trashType in trashLut ? trashLut[trashType] : i18n.tr(trashType))

        trailingActionBar.actions: [
            Action {
                iconName: 'ok'
                text: i18n.tr('Opslaan')

                onTriggered: {
                    console.log("SetReminderType.qml  New reminder setting saved")
                    hour = hourMinutePicker.date.getHours()
                    minutes = hourMinutePicker.date.getMinutes()
                    reminderSet = encodeReminderType(reminderOption, hour, minutes)
                    settingsChanged(trashType, reminderSet)
                    pop()
                }
            }
        ]
    }

    Component.onCompleted: {
        console.log('SetReminderType.qml complete', trashType)
        reminderSet = reminderSettings.value(trashType,'-')
        decodeReminderType(reminderSet)
        // Initialize DatePicker
    	var d = new Date()
    	d.setHours(hour, minutes)
        hourMinutePicker.date = d
    }

    // Page elements

    CheckBox {
        id: chbxGeenReminder
        anchors {
            top: header.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
        // height: units.gu(6)
        checked: (reminderOption == 0)
        onClicked: {
            reminderOption = 0
            chbxDagEerder.checked = false
            chbxDagZelf.checked = false
        }
    }
    Text {
        text: "Geen herinnering"
        anchors {
            top: header.bottom
            topMargin: units.gu(2)
            left: chbxGeenReminder.right
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
    }
    CheckBox {
        id: chbxDagEerder
        anchors {
            top: chbxGeenReminder.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
        // height: units.gu(6)
        checked: (reminderOption == 1)
        onClicked: {
            reminderOption = 1
            chbxGeenReminder.checked = false
            chbxDagZelf.checked = false
        }
    }
    Text {
        text: "Dag van tevoren"
        anchors {
            top: chbxGeenReminder.bottom
            topMargin: units.gu(2)
            left: chbxGeenReminder.right
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
    }
    CheckBox {
        id: chbxDagZelf
        anchors {
            top: chbxDagEerder.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
        // height: units.gu(6)
        checked: (reminderOption == 2)
        onClicked: {
            reminderOption = 2
            chbxGeenReminder.checked = false
            chbxDagEerder.checked = false
        }
    }
    Text {
        text: "Zelfde dag"
        anchors {
            top: chbxDagEerder.bottom
            topMargin: units.gu(2)
            left: chbxGeenReminder.right
            leftMargin: units.gu(2)
            // verticalCenter: parent.verticalCenter
        }
    }

    Label {
        id: hourMinutesLabel
        anchors {
            top: chbxDagZelf.bottom
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
        }
        height: units.gu(6)
        verticalAlignment: Text.AlignVCenter
        text: "Tijdstip:"
    }

    DatePicker {
        id: hourMinutePicker
        anchors {
            top: hourMinutesLabel.bottom
            left: parent.left
            right: parent.right
            leftMargin: units.gu(-2)
            rightMargin: units.gu(-2)
        }
        mode: "Hours|Minutes"
    }

    function decodeReminderType(reminderType) {
        var parts = reminderType.split(":")
        if (parts[0] == 'D') {
            reminderOption = 2
        } else if (parts[0] == 'D-1') {
            reminderOption = 1
        } else {
            reminderOption = 0
        }
        if (parts.length > 1) {
            console.log('tijd', parts[1], parts[2])
            hour = parseInt(parts[1])
            minutes = parseInt(parts[2])
        } else {
            hour = 12
            minutes = 0
        }
        console.log('decodeReminderType()', reminderType, reminderOption, hour, minutes)
    }

    function encodeReminderType(option, hour, minutes) {
        var enc
        if (option == 2) {
            enc = 'D:' + hour.toString().padStart(2, "0") + ':' + minutes.toString().padStart(2, "0")
        } else if (option == 1) {
            enc = 'D-1:' + hour.toString().padStart(2, "0") + ':' + minutes.toString().padStart(2, "0")
        } else {
            enc = '-'
        }
        console.log('encodeReminderType', option, hour, minutes, enc)
        return enc
    }

}
