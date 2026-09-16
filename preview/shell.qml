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

    // An item transform, not an image resize. Scaling the item means the cap
    // notch — Style.space(1), a single pixel — rasterises at final size
    // instead of being antialiased into a smudge. Style.spacingScale cannot
    // stand in for this: its config binding wins over any assignment here.
    readonly property real s: 20

    readonly property var states: [
      { total: 0, paid: 0, over: false },
      { total: 440, paid: 310, over: false },
      { total: 540, paid: 420, over: true }
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

          transformOrigin: Item.TopLeft
          scale: win.s
          x: (card.width - implicitWidth * win.s) / 2
          y: 150 + index * 150 - (implicitHeight * win.s) / 2

          bar: barStub
          capMinutes: 480
          totalMinutes: modelData.total
          paidMinutes: modelData.paid
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
      property int barSize: 40
      property int sizeHorizontal: 40
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
