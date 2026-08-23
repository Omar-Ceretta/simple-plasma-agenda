import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: colors

    // styleMode: 0 = translucent, 1 = solid
    // appearance: 0 = dark, 1 = light, 2 = follow Plasma
    property int styleMode: 1
    property int appearance: 2

    readonly property bool useSystem: appearance === 2
    readonly property bool systemIsDark: {
        var bg = Kirigami.Theme.backgroundColor
        var luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
        return luminance < 0.5
    }
    readonly property bool isLight: appearance === 1 || (useSystem && !systemIsDark)
    readonly property bool isTranslucent: styleMode === 0

    readonly property color background: useSystem
        ? Kirigami.Theme.backgroundColor
        : (isLight ? "#f4f4f5" : "#202124")

    readonly property color foreground: useSystem
        ? Kirigami.Theme.textColor
        : (isLight ? "#202124" : "#f5f5f5")

    readonly property color accent: useSystem
        ? Kirigami.Theme.highlightColor
        : "#3daee9"

    readonly property color separator: foreground
    readonly property color cardBackground: foreground
    readonly property real cardBackgroundOpacity: isTranslucent ? 0.075 : 0.055
    readonly property real backgroundOpacity: isTranslucent ? 0.86 : 1.0
}
