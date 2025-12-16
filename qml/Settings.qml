import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('Instellingen')

        trailingActionBar.actions: [
            Action {
                iconName: 'ok'
                text: i18n.tr('Opslaan')

                onTriggered: {
                    root.addressPostalCode = postalcode.text != '' ? postalcode.text : null
                    root.addressNumber = housenumber.text != '' ? housenumber.text : null
                    root.addressExtension = numberextension.text != '' ? numberextension.text : null

                    pageStack.pop('Settings.qml')
                }
            }
        ]
    }

    Column {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        TextField {
            id: postalcode
            placeholderText: '1234 AB'
            text: root.addressPostalCode

            inputMethodHints: Qt.ImhNoPredictiveText | (postalcode.length >= 4 ? Qt.ImhUppercaseOnly : Qt.ImhDigitsOnly)
            validator: RegExpValidator {
                regExp: /^\d{4} ?[a-zA-Z]{2}$/
            }

            height: units.gu(4)
            width: parent.width / 4
        }

        TextField {
            id: housenumber
            placeholderText: '1'
            text: root.addressNumber

            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhDigitsOnly
            validator: IntValidator {
                bottom: 1
            }

            height: units.gu(4)
            width: parent.width / 8
        }

        TextField {
            id: numberextension
            placeholderText: 'A'
            text: root.addressExtension

            inputMethodHints: Qt.ImhNoPredictiveText
            height: units.gu(4)
            width: parent.width / 8
        }
    }
}
