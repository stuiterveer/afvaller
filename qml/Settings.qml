import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    signal settingsChanged()

    property int listItemHeight: units.gu(6)

    header: PageHeader {
        id: header
        title: i18n.tr('Instellingen')

        trailingActionBar.actions: [
            Action {
                iconName: 'ok'
                text: i18n.tr('Opslaan')

                onTriggered: {
                    enabled = false
                    providerList.enabled = false
                    postalcode.enabled = false
                    housenumber.enabled = false
                    numberextension.enabled = false

                    python.call(root.providers[providerList.text] + '.validateAddress', [postalcode.text, housenumber.text, (numberextension.text != '' ? numberextension.text : null)], function(addressValid) {
                        if (addressValid) {
                            root.addressPostalCode = postalcode.text != '' ? postalcode.text : null
                            root.addressNumber = housenumber.text != '' ? housenumber.text : null
                            root.addressExtension = numberextension.text != '' ? numberextension.text : null
                            root.chosenProvider = providerList.text != '' ? providerList.text : null

                            settingsChanged()
                            pageStack.pop('Settings.qml')
                        } else {
                            enabled = true
                            providerList.enabled = true
                            postalcode.enabled = true
                            housenumber.enabled = true
                            numberextension.enabled = true

                            addressInvalidError.visible = true
                        }
                    })
                }
            }
        ]
    }

    Component {
        id: providerDelegate

        ListItem {
            height: listItemHeight
            width: parent.width

            divider {
                visible: true
            }

            Label {
                id: txt
                anchors.verticalCenter: parent.verticalCenter
                text: name
            }

            onClicked: {
                python.importModule(root.providers[txt.text], function() {
                    console.log('module ' + root.providers[txt.text] + ' imported');
                });

                addressInvalidError.visible = false
                providerList.text = txt.text
                providerList.expanded = false
            }
        }
    }

    Column {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        ComboButton {
            id: providerList
            expandedHeight: collapsedHeight + (listItemHeight * providerModel.count)
            text: root.chosenProvider

            ListView {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                id: providerView
                
                model: ListModel {
                    id: providerModel
                }
                delegate: providerDelegate
            }
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

            onTextChanged: addressInvalidError.visible = false
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

            onTextChanged: addressInvalidError.visible = false
        }

        TextField {
            id: numberextension
            placeholderText: 'A'
            text: root.addressExtension

            inputMethodHints: Qt.ImhNoPredictiveText
            height: units.gu(4)
            width: parent.width / 8

            onTextChanged: addressInvalidError.visible = false
        }

        Label {
            anchors {
                left: parent.left
                right: parent.right
            }
            id: addressInvalidError
            wrapMode: Text.WordWrap
            visible: false
            color: theme.name === 'Lomiri.Components.Themes.SuruDark' ? '#ED3146' : '#C7162B'
            text: i18n.tr('Adres wordt niet herkend door %1.\nControleer of het adres en de gekozen afvalverwerker juist zijn.').arg(providerList.text)
        }
    }

    Component.onCompleted: {
        providerModel.clear()
        var providerList = Object.entries(root.providers)
        for (var i = 0; i < providerList.length; i++) {
            providerModel.append({'name': providerList[i][0]})
        }
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/Providers/'));

            importModule(root.providers[root.chosenProvider], function() {
                console.log('module ' + root.providers[root.chosenProvider] + ' imported');
            });
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
