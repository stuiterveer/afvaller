import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

Page {
    anchors.fill: parent

    header: PageHeader {
        id: header
        title: i18n.tr('Afvalkalender')
    }

    Component {
        id: wasteDelegate

        ListItem {
            height: units.gu(4)
            width: parent.width

            divider {
                visible: false
            }

            Label {
                id: txt
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                text: '<b>' + date + (dateInfo == 'today' ? ' (' + i18n.tr('vandaag') + ')' : '') + ':</b> ' + (type in trashLut ? trashLut[type] : i18n.tr('Onbekend (%1)').arg(type))
                Component.onCompleted: {
                    if (dateInfo == 'past')
                    {
                        color = '#888888'
                    }
                }
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

                wasteModel.clear()
                for (var y = 0; y < availableYears.length; y++){
                    python.call(root.providers[root.chosenProvider] + '.getCalendar', [root.addressPostalCode, root.addressNumber, root.addressExtension, availableYears[y].toString()], function(returnValue) {
                        for (var i = 0; i < returnValue.length; i++)
                        {
                            wasteModel.append(returnValue[i])
                        }

                        trashView.positionViewAtIndex(currentIndex, ListView.Center)

                        fetchingData.visible = false
                    })
                }
            })
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
