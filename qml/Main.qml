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
        'De Afvalwijzer': 'mijnafvalwijzer',
        'Rd4': 'rd4',
        'ROVA': 'rova'
    }

    property string addressPostalCode: ''
    property string addressNumber: ''
    property string addressExtension: ''
    property string chosenProvider: ''

    // Lookup table for trash icons
    // Include all trash types returned by getCalendar()
    readonly property var trashIconLut: {
         'Restafval': 'residual_waste',
         'MD': 'md',
         'Plastic en kunststof': 'plastic',
         'Plastic': 'plastic',
         'Papier en karton': 'paper',
         'Oud papier': 'paper',
         'Papierafval': 'paper',
         'Oud papier en karton': 'paper',
         'Groente, Fruit en Tuinafval': 'gft',
         'GFT-afval': 'gft',
         'Groente, fruit, tuinafval en etensresten': 'gft',
         'GFT en etensresten': 'gft',
         'Mobiel Scheidingsstation': 'pruning_waste',
         'Takkenroute': 'pruning_waste',
         'Snoeiafval op afspraak': 'pruning_waste',
         'Droge herbruikbare materialen': 'dry_recyclables',
         'Plastic, Metalen en Drankkartons': 'pmd',
         'Plastic, Blik en Drinkpakken': 'pmd',
         'Plastic verpakkingen, blik en drinkpakken': 'pmd',
         'PMD-verpakkingen': 'pmd',
         'Kerstbomen': 'christmas_trees',
         'Grofvuil': 'bulky_waste',
         'Textiel': 'textiles',
         'BEST-tas': 'best_bag'
    }

    property var containerInfo: {
        'name': '',
        'address': '',
        'city': '',
        'postalCode': '',
        'public': false,
        'wasteTypes': []
    }

    property var providerData: {}

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
        property alias providerData: root.providerData
    }
}
