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
            height: txt.implicitHeight
            width: txt.implicitWidth

            divider {
                visible: false
            }

            Label {
                id: txt
                text: '<b>' + date + (dateInfo == 'today' ? ' (' + i18n.tr('vandaag') + ')' : '') + ':</b> ' + typesString
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

    Label {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        id: fetchingData

        text: i18n.tr('Bezig met ophalen van data...')
        textSize: Label.XLarge
        wrapMode: Text.WordWrap

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
                            var typesTrans = []
                            for (var j = 0; j < returnValue[i]['types'].length; j++)
                            {
                                if (returnValue[i]['types'][j] in trashLut){
                                    typesTrans.push(trashLut[returnValue[i]['types'][j]])
                                } else {
                                    // Should not happen, but show unknown values to user for debugging and so it can still be added
                                    typesTrans.push(i18n.tr('Onbekend (%1)').arg(returnValue[i]['types'][j]))
                                }
                                if (returnValue[i]['dateInfo'] != 'past' && currentIndex == 0)
                                {
                                    currentIndex = i
                                }
                            }
                            returnValue[i]['typesString'] = typesTrans.join(', ')
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
