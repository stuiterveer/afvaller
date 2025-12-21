import QtQuick 2.7
import Lomiri.Components 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: 'Afvaller'
    }

    Component {
        id: pageDelegate
        ListItem {
            Label {
                anchors.centerIn: parent
                text: name
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl(file))
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

        model: ListModel {
            id: pageModel
        }
        delegate: pageDelegate
    }

    Python {
        id: python

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/Providers/'));

            if (root.chosenProvider != '') {
                importModule(root.providers[root.chosenProvider], function() {
                    console.log('module ' + root.providers[root.chosenProvider] + ' imported');
                });

                pageModel.clear()
                python.call(root.providers[root.chosenProvider] + '.getCapabilities', [], function(returnValue) {
                    if (returnValue.includes('calendar')) {
                        pageModel.append({
                            'name': i18n.tr('Afvalkalender'),
                            'file': 'Calendar.qml'
                        })
                    }
                    if (returnValue.includes('containers')) {
                        pageModel.append({
                            'name': i18n.tr('Afvalcontainers'),
                            'file': 'Containers.qml'
                        })
                    }
                })
            }

            pageModel.append({
                'name': i18n.tr('Instellingen'),
                'file': 'Settings.qml'
            })
        }
    }
}
