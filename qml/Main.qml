import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'afvaller.stuiterveer'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    property var address: {
        'postalCode': null,
        'number': null,
        'extension': null
    }

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

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));
            importModule('confighandler', function() {
                console.log('module confighandler imported');
            });

            python.call('confighandler.initConfig')

            python.call('confighandler.readConfig', [], function(returnValue) {
                address['postalCode'] = returnValue['postalCode']
                address['number'] = returnValue['houseNumber']
                address['extension'] = returnValue['extension']
            })
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
