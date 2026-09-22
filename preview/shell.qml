import QtQuick
import Quickshell
import qs.Commons

// Renders the three states of the root preview.png. Driven by the widget's own
// draw path: TagwerkMeter is BarWidget.qml, so what the card shows is what the
// bar shows.
ShellRoot {
  FloatingWindow {
    id: win
    implicitWidth: 1200
    implicitHeight: 600

    // Matches the [spacing] scale render.sh writes into the scratch HOME, so
    // the stub bar is as tall relative to the meter as the real one is. The
    // widget draws at card size in its own coordinates: no transform, so
    // radii and the Style.space(1) cap notch both rasterise where they land.
    readonly property int s: parseInt(Quickshell.env("PREVIEW_SCALE") || "20")

    // present drives the track; total only sets the paid proportion inside it,
    // so a two-kind day is a total above its own presence.
    readonly property var states: [
      { total: 0, paid: 0, present: 0, over: false },
      { total: 600, paid: 310, present: 440, over: false },
      { total: 740, paid: 420, present: 540, over: true }
    ]

    Rectangle {
      id: card
      width: 1200
      height: 600
      color: Color.bar.background

      Repeater {
        model: win.states

        TagwerkMeter {
          required property var modelData
          required property int index

          x: (card.width - implicitWidth) / 2
          y: 150 + index * 150 - implicitHeight / 2

          bar: barStub
          capMinutes: 480
          totalMinutes: modelData.total
          paidMinutes: modelData.paid
          presentMinutes: modelData.present
          overCap: modelData.over
        }
      }
    }

    // Stands in for the bar the widget normally draws into, so the card takes
    // its colours from the theme without a bar being present.
    QtObject {
      id: barStub
      property color barForeground: Color.bar.text
      property color background: Color.bar.background
      property color urgent: Color.bar.active
      property bool vertical: false
      property int barSize: 40 * win.s
      property int sizeHorizontal: 40 * win.s
      property string fontFamily: "monospace"
      property bool foregroundAnimationEnabled: false
      property var moduleWidgets: ({})
      property int x: 0
      function run(cmd) {}
      function showTooltip() {}
      function hideTooltip() {}
      function registerClickTarget() {}
      function unregisterClickTarget() {}
    }

    // Long enough for the theme files to load and the fill animations to
    // settle on their declared widths.
    Timer {
      interval: 1500
      running: true
      onTriggered: card.grabToImage(function (result) {
        result.saveToFile(Quickshell.env("PREVIEW_OUT"))
        Qt.exit(0)
      })
    }
  }
}
