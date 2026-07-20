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
            height: units.gu(9)
            // width: parent.width Calendar.qml:18: TypeError: Cannot read property 'width' of null

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
                    source: {
                        if (type in trashIconLut) {
                            'img/' + trashIconLut[type] + '.svg'
                        } else {
                            console.log('trashIconLut does not contain an entry for trash type "' + type + '"')
                            'img/residual_waste.svg'
                        }
                    }
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

                text: type

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

                wasteModel.clear()
                for (var y = 0; y < availableYears.length; y++){
                    python.call(root.providers[root.chosenProvider] + '.getCalendar', [root.addressPostalCode, root.addressNumber, root.addressExtension, availableYears[y].toString()], function(returnValue) {
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
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}
