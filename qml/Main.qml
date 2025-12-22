import QtQuick 2.7
import Lomiri.Components 1.3
import io.thp.pyotherside 1.4

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'rd4.stuiterveer'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: 'Rd4'
        }

        Label {
            anchors {
                top: header.bottom
                bottom: openAppStore.top
                left: parent.left
                right: parent.right
            }
            wrapMode: Text.WordWrap
            id: noMoreApp
            text: i18n.tr('Deze app zal niet meer niet meer onderhouden worden en is End Of Life.\n\nEr is een nieuwe app die meer afvalverwerkers zal ondersteunen en als vervanging van deze app dient.\n\nKlik op de knop om Afvaller te bekijken in de OpenStore en verwijder daarna de Rd4 app van je apparaat.')
        }

        Button {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            color: theme.name === 'Lomiri.Components.Themes.SuruDark' ? 'Light Green' : 'Green'
            id: openAppStore
            text: i18n.tr('Download Afvaller in de OpenStore')
        }
    }
}
