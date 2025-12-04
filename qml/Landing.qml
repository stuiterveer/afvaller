import QtQuick 2.7
import Lomiri.Components 1.3
import Qt.labs.settings 1.0

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

        Component.onCompleted: {
            pageModel.clear()

            var pages = [
                {
                    'name': i18n.tr('Afvalkalender'),
                    'file': 'Calendar.qml'
                },
                {
                    'name': i18n.tr('Afvalcontainers'),
                    'file': 'Containers.qml'
                },
                {
                    'name': i18n.tr('Instellingen'),
                    'file': 'Settings.qml'
                }
            ]

            for (var i = 0; i < pages.length; i++)
            {
                pageModel.append(pages[i])
            }
        }
    }
}
