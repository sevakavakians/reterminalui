import QtQuick 2.9

Item {
    id: gpioScreen

    // Data model for configured pins
    property var configuredPins: []
    property int selectedPin: -1
    property var selectedPinInfo: null
    property var hardwarePWMPins: []

    // Update configured pins when GPIO controller emits signal
    Connections {
        target: gpioController
        onPinsChanged: {
            updateConfiguredPins()
        }
        onPinValueChanged: {
            // Update when pin values change (e.g., writePin called)
            updateConfiguredPins()
        }
    }

    Component.onCompleted: {
        updateConfiguredPins()
        // Get hardware PWM pins
        var hwPwmJson = gpioController.getHardwarePWMPins()
        hardwarePWMPins = JSON.parse(hwPwmJson)
    }

    function updateConfiguredPins() {
        var pinsJson = gpioController.getConfiguredPins()
        configuredPins = JSON.parse(pinsJson)

        // Update selected pin info if it's still configured
        if (selectedPin !== -1) {
            var found = false
            for (var i = 0; i < configuredPins.length; i++) {
                if (configuredPins[i].pin === selectedPin) {
                    selectedPinInfo = configuredPins[i]
                    found = true
                    break
                }
            }
            if (!found) {
                selectedPin = -1
                selectedPinInfo = null
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: 0

        // Left panel: Available and configured pins
        Rectangle {
            width: parent.width * 0.45
            height: parent.height
            color: "#1a1f3a"
            border.color: "#00f3ff"
            border.width: 2
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                // Header
                Text {
                    text: "GPIO PINS"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#00f3ff"
                }

                // All pins section
                Rectangle {
                    width: parent.width
                    height: parent.height - 60
                    color: "#0f1428"
                    border.color: "#666"
                    border.width: 2
                    radius: 4

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "ALL GPIO PINS"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#888"
                        }

                        Rectangle {
                            width: parent.width
                            height: parent.height - 30
                            color: "transparent"

                            Flickable {
                                anchors.fill: parent
                                contentHeight: availablePinsFlow.height
                                clip: true

                                Flow {
                                    id: availablePinsFlow
                                    width: parent.width
                                    spacing: 10

                                    Repeater {
                                        model: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]

                                        Rectangle {
                                            property var reservedPins: [2, 3, 6, 13]
                                            property bool isReserved: reservedPins.indexOf(modelData) !== -1
                                            property bool isHardwarePWM: hardwarePWMPins.indexOf(modelData) !== -1
                                            property bool isConfigured: {
                                                for (var i = 0; i < configuredPins.length; i++) {
                                                    if (configuredPins[i].pin === modelData) return true
                                                }
                                                return false
                                            }
                                            property var pinInfo: {
                                                for (var i = 0; i < configuredPins.length; i++) {
                                                    if (configuredPins[i].pin === modelData) return configuredPins[i]
                                                }
                                                return null
                                            }

                                            width: 70
                                            height: 70
                                            color: isReserved ? "#1a0a0a" : (isConfigured ? "#0a2e0a" : "#1a1f3a")
                                            border.color: isReserved ? "#ff006e" : (isConfigured ? "#00ff41" : (isHardwarePWM ? "#ffa500" : "#00f3ff"))
                                            border.width: isConfigured ? 3 : (isHardwarePWM ? 3 : 2)
                                            radius: 6
                                            opacity: isReserved ? 0.4 : 1.0

                                            Column {
                                                anchors.centerIn: parent
                                                spacing: 3

                                                Text {
                                                    text: "GPIO"
                                                    font.pixelSize: 10
                                                    color: isReserved ? "#ff006e" : (isConfigured ? "#00ff41" : (isHardwarePWM ? "#ffa500" : "#00f3ff"))
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }

                                                Text {
                                                    text: modelData
                                                    font.pixelSize: 20
                                                    font.bold: true
                                                    font.family: "monospace"
                                                    color: isReserved ? "#ff006e" : (isConfigured ? "#00ff41" : (isHardwarePWM ? "#ffa500" : "#00f3ff"))
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }

                                                Text {
                                                    visible: isReserved
                                                    text: "RSVD"
                                                    font.pixelSize: 8
                                                    font.bold: true
                                                    color: "#ff006e"
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }

                                                Text {
                                                    visible: isHardwarePWM && !isConfigured && !isReserved
                                                    text: "HW PWM"
                                                    font.pixelSize: 7
                                                    font.bold: true
                                                    color: "#ffa500"
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }

                                                Text {
                                                    visible: isConfigured && pinInfo
                                                    text: {
                                                        if (!pinInfo) return ""
                                                        if (pinInfo.mode === "pwm") {
                                                            return "PWM:" + pinInfo.pwm_duty_cycle.toFixed(0) + "%"
                                                        } else if (pinInfo.mode === "output") {
                                                            return "OUT:" + pinInfo.value
                                                        } else {
                                                            return "IN:" + pinInfo.value
                                                        }
                                                    }
                                                    font.pixelSize: 8
                                                    font.bold: true
                                                    font.family: "monospace"
                                                    color: "#00ff41"
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                enabled: !parent.isReserved
                                                onClicked: {
                                                    if (isConfigured) {
                                                        // Select configured pin for control
                                                        selectedPin = modelData
                                                        selectedPinInfo = pinInfo
                                                    } else {
                                                        // Show configuration dialog for unconfigured pin
                                                        pinConfigDialog.pinNumber = modelData
                                                        pinConfigDialog.visible = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right panel: Pin control panel or config dialog
        Rectangle {
            width: parent.width * 0.55
            height: parent.height
            color: "transparent"

            // Pin control panel (when pin is selected)
            PinControlPanel {
                id: controlPanel
                anchors.fill: parent
                anchors.margins: 0
                visible: selectedPin !== -1
                pinNumber: selectedPin
                pinInfo: selectedPinInfo

                onClosed: {
                    selectedPin = -1
                    selectedPinInfo = null
                }
            }

            // Pin configuration dialog (when adding new pin)
            Rectangle {
                id: pinConfigDialog
                anchors.fill: parent
                anchors.margins: 0
                color: "#1a1f3a"
                border.color: "#00f3ff"
                border.width: 2
                radius: 8
                visible: false

                property int pinNumber: -1

                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // Header
                    Row {
                        width: parent.width

                        Text {
                            text: "CONFIGURE PIN " + pinConfigDialog.pinNumber
                            font.pixelSize: 20
                            font.bold: true
                            font.family: "monospace"
                            color: "#00f3ff"
                            width: parent.width - 60
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            color: "transparent"
                            border.color: "#ff006e"
                            border.width: 2
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#ff006e"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    pinConfigDialog.visible = false
                                }
                            }
                        }
                    }

                    // Mode selection
                    Text {
                        text: "PIN MODE"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#888"
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            id: inputModeBtn
                            width: (parent.width - 16) / 3
                            height: 60
                            color: inputModeBtn.selected ? "#00f3ff" : "transparent"
                            border.color: "#00f3ff"
                            border.width: 2
                            radius: 4

                            property bool selected: true

                            Text {
                                anchors.centerIn: parent
                                text: "INPUT"
                                font.pixelSize: 16
                                font.bold: true
                                color: inputModeBtn.selected ? "#000" : "#00f3ff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inputModeBtn.selected = true
                                    outputModeBtn.selected = false
                                    pwmModeBtn.selected = false
                                }
                            }
                        }

                        Rectangle {
                            id: outputModeBtn
                            width: (parent.width - 16) / 3
                            height: 60
                            color: outputModeBtn.selected ? "#ff006e" : "transparent"
                            border.color: "#ff006e"
                            border.width: 2
                            radius: 4

                            property bool selected: false

                            Text {
                                anchors.centerIn: parent
                                text: "OUTPUT"
                                font.pixelSize: 16
                                font.bold: true
                                color: outputModeBtn.selected ? "#fff" : "#ff006e"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inputModeBtn.selected = false
                                    outputModeBtn.selected = true
                                    pwmModeBtn.selected = false
                                }
                            }
                        }

                        Rectangle {
                            id: pwmModeBtn
                            width: (parent.width - 16) / 3
                            height: 60
                            color: pwmModeBtn.selected ? "#ffa500" : "transparent"
                            border.color: "#ffa500"
                            border.width: 2
                            radius: 4

                            property bool selected: false

                            Text {
                                anchors.centerIn: parent
                                text: "PWM"
                                font.pixelSize: 16
                                font.bold: true
                                color: pwmModeBtn.selected ? "#000" : "#ffa500"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    inputModeBtn.selected = false
                                    outputModeBtn.selected = false
                                    pwmModeBtn.selected = true
                                }
                            }
                        }
                    }

                    // Pull mode selection (only for input)
                    Column {
                        width: parent.width
                        spacing: 10
                        visible: inputModeBtn.selected

                        Text {
                            text: "PULL RESISTOR"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#888"
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: ["none", "up", "down"]

                                Rectangle {
                                    width: (parent.width - 16) / 3
                                    height: 50
                                    color: pullModeGroup.selectedIndex === index ? "#00ff41" : "transparent"
                                    border.color: "#00ff41"
                                    border.width: 2
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.toUpperCase()
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: pullModeGroup.selectedIndex === index ? "#000" : "#00ff41"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            pullModeGroup.selectedIndex = index
                                        }
                                    }
                                }
                            }
                        }

                        QtObject {
                            id: pullModeGroup
                            property int selectedIndex: 0
                            property var modes: ["none", "up", "down"]
                            property string selectedMode: modes[selectedIndex]
                        }
                    }

                    // Spacer
                    Item {
                        width: 1
                        height: 20
                    }

                    // Add button
                    Rectangle {
                        width: parent.width
                        height: 60
                        color: "#00f3ff"
                        radius: 8

                        Text {
                            anchors.centerIn: parent
                            text: "ADD PIN"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#000"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var mode = "input"
                                if (outputModeBtn.selected) {
                                    mode = "output"
                                } else if (pwmModeBtn.selected) {
                                    mode = "pwm"
                                }
                                var pullMode = inputModeBtn.selected ? pullModeGroup.selectedMode : "none"

                                var success = gpioController.configurePin(
                                    pinConfigDialog.pinNumber,
                                    mode,
                                    pullMode
                                )

                                if (success) {
                                    pinConfigDialog.visible = false
                                    updateConfiguredPins()

                                    // Select the newly added pin
                                    selectedPin = pinConfigDialog.pinNumber
                                    // Update selected pin info
                                    for (var i = 0; i < configuredPins.length; i++) {
                                        if (configuredPins[i].pin === pinConfigDialog.pinNumber) {
                                            selectedPinInfo = configuredPins[i]
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Spacer
                    Item {
                        width: 1
                        height: parent.height - 400
                    }
                }
            }

            // Placeholder when nothing is selected
            Rectangle {
                anchors.fill: parent
                anchors.margins: 0
                color: "#1a1f3a"
                border.color: "#666"
                border.width: 2
                radius: 8
                visible: !controlPanel.visible && !pinConfigDialog.visible

                Column {
                    anchors.centerIn: parent
                    spacing: 20

                    Text {
                        text: "⚡"
                        font.pixelSize: 64
                        color: "#666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "SELECT A PIN"
                        font.pixelSize: 20
                        font.bold: true
                        color: "#666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Click on an available pin to configure\nor a configured pin to control"
                        font.pixelSize: 12
                        color: "#555"
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
