import QtQuick 2.7
import Lomiri.Components 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'afvaller.stuiterveer'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property var providers: {
        'Rd4': 'rd4',
        'ROVA': 'rova'
    }

    property string addressPostalCode: ''
    property string addressNumber: ''
    property string addressExtension: ''
    property string chosenProvider: ''

    readonly property var trashLut: {
        'residual_waste': i18n.tr('Restafval'),
        'gft': i18n.tr('GFT'),
        'paper': i18n.tr('Papier'),
        'pruning_waste': i18n.tr('Snoeiafval'),
        'pmd': i18n.tr('PMD'),
        'best_bag': i18n.tr('BEST-tas'),
        'christmas_trees': i18n.tr('Kerstbomen')
    }

    property var containerInfo: {
        'name': '',
        'address': '',
        'city': '',
        'postalCode': '',
        'public': false,
        'wasteTypes': []
    }

    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            pageStack.push(Qt.resolvedUrl('Landing.qml'))
        }
    }

    Settings {
        id: address
        property alias postalCode: root.addressPostalCode
        property alias number: root.addressNumber
        property alias extension: root.addressExtension
        property alias provider: root.chosenProvider
    }
}
