import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4
import QtOrganizer 5.0

Page {
    id: calendarPage
    anchors.fill: parent

    // Events with DisplayLabels that end in this string, will be removed when this page opens
    readonly property string afvallerLabel: '[Afvaller herinnering]'

    // State variable for reminder update process
    property var updateState: 'beforeStart'

    header: PageHeader {
        id: header
        title: i18n.tr('Afvalkalender')
        leadingActionBar.actions: [
            Action {
                id: remindersUpdateAction
                iconName: 'back'
                onTriggered: {
                    updatingReminders.running = true
                    startRemindersUpdate()
                }
            }
        ]
        trailingActionBar.actions: [
            Action {
                id: reminderSettingsAction
                iconName: 'clock'
                text: i18n.tr('Instellingen')
                enabled: false // do not trigger before list is complete
                onTriggered: {
                    var openedPage = pageStack.push(Qt.resolvedUrl('SetReminders.qml'))
                }
            }
        ]
    }

    Component {
        id: wasteDelegate

        ListItem {
            height: units.gu(9)
            width: parent.width

            enabled: dateInfo !== 'past'

            LomiriShape {
                id: iconShape

                height: units.gu(7)
                width: units.gu(7)

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                source: Image {
                    source: 'img/' + type + '.svg'
                }
            }

            Label {
                id: dateLabel

                width: parent.width - iconShape.width - units.gu(5)

                anchors {
                    left: iconShape.right
                    leftMargin: units.gu(1)
                    top: parent.top
                    topMargin: units.gu(2)
                }

                text: date + (dateInfo == 'today' ? ' (' + i18n.tr('vandaag') + ')' : '')
                
                elide: Text.ElideRight
                font.bold: true
            }

            Label {
                id: typeLabel

                width: parent.width - iconShape.width - units.gu(5)

                anchors {
                    left: iconShape.right
                    leftMargin: units.gu(1)
                    top: dateLabel.bottom
                    topMargin: units.gu(0.5)
                }

                text: (type in trashLut ? trashLut[type] : i18n.tr('Onbekend (%1)').arg(type))

                elide: Text.ElideRight
            }
        }
    }

    ListView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        id: trashView
        
        model: ListModel {
            id: wasteModel
        }
        delegate: wasteDelegate
    }

    ActivityIndicator {
        id: fetchingData
        anchors.centerIn: parent
        running: true
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/Providers/'));

            importModule(root.providers[root.chosenProvider], function() {
                console.log('module ' + root.providers[root.chosenProvider] + ' imported');
            });

            var d = new Date()
            var currentYear = d.getFullYear()

            python.call(root.providers[root.chosenProvider] + '.getYears', [], function(availableYears) {
                var currentIndex = 0
                var trtreminder = 'none'
                var trtype = ''

                wasteModel.clear()
                for (var y = 0; y < availableYears.length; y++){
                    python.call(root.providers[root.chosenProvider] + '.getCalendar', [root.addressPostalCode, root.addressNumber, root.addressExtension, availableYears[y].toString()], function(returnValue) {

                        // Generate list of trash types in data
                        root.foundTrashTypes = []
                        for (var i = 0; i < returnValue.length; i++) {
                            if ( !root.foundTrashTypes.includes(returnValue[i]['type']) ) {
                                root.foundTrashTypes.push(returnValue[i]['type'])
                            }
                        }

                        // Alarm settings are saved for each trash type separately.
                        // If we encounter a new trash type here, make sure Settings has an entry for it
                        // (with default setting '-').
                        console.log('Number of trashtypes:', root.foundTrashTypes.length)
                        for (var k = 0; k < root.foundTrashTypes.length; k++) {
                            trtype = root.foundTrashTypes[k]
                            console.log("Trash type:", trtype)
                            trtreminder = reminderSettings.value(trtype,'first')
                            if (trtreminder == 'first') {
                                reminderSettings.setValue(trtype,'-')
                                console.log('New trash type', k, trtype)
                            }
                        }

                        // Create the wastemodel
                        for (var i = 0; i < returnValue.length; i++)
                        {
                            wasteModel.append(returnValue[i])

                            if (returnValue[i]['dateInfo'] != 'past' && currentIndex == 0)
                            {
                            currentIndex = i
                            }
                        }

                        trashView.positionViewAtIndex(currentIndex, ListView.Center)

                        fetchingData.visible = false
                    })
                }
            })
            // Enable setting reminder details
            reminderSettingsAction.enabled = true
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }

    ActivityIndicator {
        id: updatingReminders
        anchors.centerIn: parent
        running: false
    }

    OrganizerModel {
        id: organizer
        manager: "eds" // Evolution Data Server

        Component.onCompleted: {
            var d = new Date()
            // 1st day of last month
            d.setDate(1)
            d.setMonth(d.getMonth() - 1)
            startPeriod = new Date(d)
            // A year later
            d.setYear(d.getFullYear() + 1)
            endPeriod = new Date(d)
        }

        onItemsFetched: function (requestId, fetchedItems) {
            updateState = 'oldRemindersFetched'
            console.log('Events collected:', fetchedItems.length)
            removeAfvallerReminders(fetchedItems)
        }

        // modelChanged events track the reminders update process
        onModelChanged: {
            console.log('OrganizerModel: model changed, item count = ', itemCount, 'state = ', updateState)
            if (updateState == 'beforeStart') {
                console.log('Not updating reminders')
            } else if (updateState == 'oldRemindersRemoved') {
                console.log('Old reminders removed, create new reminders')
                createAfvallerReminders()
            } else if (updateState == 'updateComplete') {
                console.log('Reminders update complete, leave page')
                updatingReminders.running = false
                pop()
            } else {
                console.log('Unknown state: ', updateState)
            }
        }
    }

    // Steps in the reminders update process

    // Step 1: fetch calendar items from organizer period (a year)
    function startRemindersUpdate() {
        organizer.fetchItems(new Date(organizer.startPeriod), new Date(organizer.endPeriod))
    }

    // Step 2: remove the afvaller reminders from fetched calendar events
    function removeAfvallerReminders(fetchedItems) {
        if (fetchedItems == null) {
            console.log('No events fetched from calendar, assume there are none.')
            updateState = 'oldRemindersRemoved'
            organizer.modelChanged()
            return
        }
        var nRemoved = 0
        for (let k = 0; k < fetchedItems.length; k++) {
            // console.log('item', k, fetchedItems[k].displayLabel)
            if (fetchedItems[k].displayLabel.endsWith(afvallerLabel)) {
                // console.log('remove', k)
                organizer.removeItem(fetchedItems[k])
                nRemoved++
            }
        }
        console.log('Afvaller events removed:', nRemoved)
        updateState = 'oldRemindersRemoved'
        if (nRemoved == 0) {
            // Need to signal in order to proceed to next step
            organizer.modelChanged()
        }
    }

    // Step 3: create calendar events events with reminders
    function createAfvallerReminders() {    
        console.log('createAfvallerReminders()')
        var trtype
        var almtype
        var almDate
        var nCreated = 0
        for (let k = 0; k < wasteModel.count; k++) {
            trtype = wasteModel.get(k).type
            // console.log('Herinnering', trtype, wasteModel.get(k).date)
            almtype = reminderSettings.value(trtype, 'none')
            if (almtype.startsWith('D-1')) {
                // Trashtype collection with reminder on previous day
                almDate = new Date(wasteModel.get(k).date)
                almDate.setDate(almDate.getDate() - 1) // appears to work across month boundaries
                almDate.setHours(almtype.substring(4,6))
                almDate.setMinutes(almtype.substring(7))
                // console.log('  =>', almDate.toDateString(), almtype.substring(almtype.length-5))
                createAfvallerReminder(almDate, 'Morgen: ' + trtype)
                nCreated++
            } else if (almtype.startsWith('D')) {
                // Trashtype collection with reminder on same day
                almDate = new Date(wasteModel.get(k).date)
                almDate.setHours(almtype.substring(2,4))
                almDate.setMinutes(almtype.substring(5))
                // console.log('  =>', almDate.toDateString(), almtype.substring(almtype.length-5))
                createAfvallerReminder(almDate, 'Vandaag: ' + trtype)
                nCreated++
            } else {
                // Trashtype collection with reminder on previous day
                // console.log('  =>', 'geen herinnering')
            }
        }
        console.log('Afvaller events created:', nCreated)
        updateState = 'updateComplete'
    }

    // Create event with reminder
    function createAfvallerReminder(date, displayLabel) {
        console.log('createAfvallerReminder()', date.toString(), displayLabel)
        var afvEvent = Qt.createQmlObject('import QtOrganizer 5.0; Event {}', calendarPage)
        afvEvent.startDateTime = date
        var d = new Date(date.setMinutes(date.getMinutes() + 15))
        afvEvent.endDateTime = d
        afvEvent.displayLabel = displayLabel + ' ' + afvallerLabel
        // Detail toevoegen: audible reminder
        var afvReminder = Qt.createQmlObject('import QtOrganizer 5.0; AudibleReminder {}', calendarPage)
        afvReminder.setValue('FieldRepetitionCount', 3)
        afvReminder.setValue('FieldRepetitionDelay', 50) // Seconds; does not seem to work?
        afvReminder.setValue('FieldSecondsBeforeStart', 0)
        afvEvent.setDetail(afvReminder)
        organizer.saveItem(afvEvent)
    }

}
