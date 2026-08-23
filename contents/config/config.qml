import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    readonly property string trDomain: "plasma_applet_com.simple.plasma.agenda"

    ConfigCategory {
        name: i18nd(trDomain, "Appearance")
        icon: "preferences-desktop-theme"
        source: "config/ConfigAppearance.qml"
    }

    ConfigCategory {
        name: i18nd(trDomain, "Agenda")
        icon: "view-calendar-agenda"
        source: "config/ConfigGeneral.qml"
    }
}
