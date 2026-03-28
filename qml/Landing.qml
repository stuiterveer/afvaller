import QtQuick 2.7
import Lomiri.Components 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: 'Afvaller'

        trailingActionBar.actions: [
            Action {
                iconName: 'settings'
                text: i18n.tr('Instellingen')

                onTriggered: {
                    var openedPage = pageStack.push(Qt.resolvedUrl('Settings.qml'))
                    openedPage.settingsChanged.connect(loadMenu)
                }
            }
        ]
    }

    Component {
        id: pageDelegate
        ListItem {
            height: units.gu(6)
            width: parent.width
            Icon {
                id: pageIcon
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                height: units.gu(3)
                width: units.gu(3)
                name: icon
                color: theme.palette.normal.baseText
            }
            Label {
                anchors {
                    left: pageIcon.right
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                text: name
            }
            Icon {
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                height: units.gu(2)
                width: units.gu(2)
                name: 'go-next'
                color: theme.palette.normal.baseText
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

            loadMenu();
        }
    }

    function loadMenu() {
        pageModel.clear()

        if (!(root.chosenProvider in root.providers) && root.chosenProvider != '') {
            root.chosenProvider = ''
        }

        if (root.chosenProvider != '') {
            python.importModule(root.providers[root.chosenProvider], function() {
                console.log('module ' + root.providers[root.chosenProvider] + ' imported');
            });

            python.call(root.providers[root.chosenProvider] + '.getCapabilities', [], function(returnValue) {
                if (returnValue.includes('calendar')) {
                    pageModel.append({
                        'name': i18n.tr('Afvalkalender'),
                        'icon': 'calendar',
                        'file': 'Calendar.qml'
                    })
                }
                if (returnValue.includes('containers')) {
                    pageModel.append({
                        'name': i18n.tr('Afvalcontainers'),
                        'icon': 'maps-app-symbolic',
                        'file': 'Containers.qml'
                    })
                }
            })
        }
    }
}