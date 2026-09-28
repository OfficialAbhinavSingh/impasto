// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C O D E X   M O D U L E                                                │
// │   codex usage · the plan's limits, from its own logs                     │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "../../theme"
import "../../services"
import "../../components"

// Each window the plan limits, as Codex last wrote it down; the ring is the
// fullest one still running. A window past its reset shows no share until
// Codex runs again.
Item {
    id: root

    property bool compact: false

    implicitWidth: holder.implicitWidth
    implicitHeight: holder.implicitHeight

    Component.onCompleted: CodexService.subscribe()
    Component.onDestruction: CodexService.release()

    Loader {
        id: holder
        anchors.fill: parent
        sourceComponent: root.compact ? chip : detail
    }

    Component {
        id: chip

        Item {
            RingIndicator {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.capsuleHeight
                height: Theme.capsuleHeight
                thickness: 2.5
                progress: CodexService.gauge
                trackColor: Theme.indicatorDim
                fillColor: CodexService.tint

                Text {
                    anchors.centerIn: parent
                    text: ModuleService.glyphOf("codex")
                    font.family: Theme.fontMono
                    font.pixelSize: Math.round(Theme.capsuleHeight * 0.44)
                    color: Theme.indicator
                }
            }
        }
    }

    Component {
        id: detail

        ModuleCard {
            title: "Codex"
            subtitle: [CodexService.plan, CodexService.age].filter(part => part !== "").join(" · ")

            mark: RingIndicator {
                anchors.fill: parent
                thickness: 3
                progress: CodexService.gauge
                trackColor: Theme.indicatorDim
                fillColor: CodexService.tint

                Text {
                    anchors.centerIn: parent
                    text: ModuleService.glyphOf("codex")
                    font.family: Theme.fontMono
                    font.pixelSize: 20
                    color: Theme.indicator
                }
            }

            Repeater {
                model: CodexService.limits

                CardLimit {
                    required property var modelData

                    readonly property bool running: CodexService.current(modelData)

                    name: modelData.name
                    fraction: modelData.used
                    known: running
                    resets: modelData.resets
                    tint: modelData.used >= 0.85 ? Theme.indicatorBad
                        : modelData.used >= 0.6 ? Theme.indicatorWarn : Theme.indicator
                }
            }
        }
    }
}
