import QtQuick 2.9

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#0a0e27"

    // Current screen state
    property string currentScreen: "gpio"

    // Listen for screen change signals from Python
    Connections {
        target: appController
        onScreenChanged: {
            console.log("Screen changed to:", arguments[0])
            currentScreen = arguments[0]
        }
    }

    // Header
    Rectangle {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80
        color: "#1a1f3a"
        border.color: "#00f3ff"
        border.width: 2

        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Title
            Text {
                text: currentScreen === "gpio" ? "reTerminal GPIO" : "reTerminal SENSORS"
                font.pixelSize: 32
                font.bold: true
                color: "#00f3ff"
                width: parent.width - 300
                anchors.verticalCenter: parent.verticalCenter
            }

            // Screen indicator buttons
            Row {
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 120
                    height: 40
                    color: currentScreen === "gpio" ? "#00f3ff" : "transparent"
                    border.color: "#00f3ff"
                    border.width: 2
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "GPIO (F1)"
                        font.pixelSize: 14
                        font.bold: true
                        color: currentScreen === "gpio" ? "#000" : "#00f3ff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentScreen = "gpio"
                            appController.handleButtonEvent("F1", "pressed")
                        }
                    }
                }

                Rectangle {
                    width: 140
                    height: 40
                    color: currentScreen === "sensors" ? "#00f3ff" : "transparent"
                    border.color: "#00f3ff"
                    border.width: 2
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "SENSORS (F2)"
                        font.pixelSize: 14
                        font.bold: true
                        color: currentScreen === "sensors" ? "#000" : "#00f3ff"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentScreen = "sensors"
                            appController.handleButtonEvent("F2", "pressed")
                        }
                    }
                }
            }
        }
    }

    // Main content area with screen switching
    Item {
        id: mainContent
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.topMargin: 10

        // GPIO Configuration Screen
        GPIOScreen {
            id: gpioScreen
            anchors.fill: parent
            visible: currentScreen === "gpio"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }

        // Sensor Graphing Screen
        SensorScreen {
            id: sensorScreen
            anchors.fill: parent
            visible: currentScreen === "sensors"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // Footer
    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#1a1f3a"
        border.color: "#00f3ff"
        border.width: 2

        Text {
            anchors.centerIn: parent
            text: "Press F1 for GPIO | Press F2 for Sensors | reTerminal GPIO Control v1.0"
            font.pixelSize: 12
            color: "#666"
        }
    }
}
