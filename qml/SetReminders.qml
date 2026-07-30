import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    signal settingsChanged()

    property int listItemHeight: units.gu(6)

    header: PageHeader {
        id: header
        title: i18n.tr('Set Reminders')

        trailingActionBar.actions: [
            Action {
                iconName: 'ok'
                text: i18n.tr('Opslaan')

                onTriggered: {
                    // console.log("Return reminder settings")
                    pop()
                }
            }
        ]
    }

    ListView {
        id: remindersListView
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: root.foundTrashTypes

        delegate: ListItem {
            id: listItemReminderRepeat
            
            height: reminderRepeatLayout.height + divider.height

            ListItemLayout {
                id: reminderRepeatLayout

                property var trType: remindersListView.model[index]
                property var trTypeT: (trType in trashLut ? trashLut[trType] : i18n.tr(trType))

                title.text: {
                    // var trType = remindersListView.model[index]
                    // "Reminder for " + (trType in trashLut ? trashLut[trType] : i18n.tr(trType))
                    "Reminder for " + trTypeT
                }
                // subtitle.text: displayReminderType(remindersListView.model[index])
                subtitle.text: displayReminderType(trType)
                subtitle.textSize: Label.Medium
            }

            onClicked: {
                var openedPage = pageStack.push(Qt.resolvedUrl('SetReminderType.qml'),
                    {"trashType": remindersListView.model[index]})
                openedPage.settingsChanged.connect(setReminderType)
            }
        }
    }

    function setReminderType(trashType, reminderSet) {
        console.log("Set reminder type for ", trashType, reminderSet)
        reminderSettings.setValue(trashType, reminderSet)
        // Refresh listview
        remindersListView.model = null
        remindersListView.model = root.foundTrashTypes
    }

    function displayReminderType(trashType) {
        var dsp
        var almtp = reminderSettings.value(trashType, 'none')
        var parts = almtp.split(":")
        if (parts[0] == 'D') {
            dsp = 'Zelfde dag, om ' + parts[1] + ':' + parts[2]
        } else if (parts[0] == 'D-1') {
            dsp = 'Dag van te voren, om ' + parts[1] + ':' + parts[2]
        } else {
            dsp = 'Geen herinnering'
        }
        return dsp
    }

}
