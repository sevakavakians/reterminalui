import QtQuick 2.9

Rectangle {
    id: controlPanel
    color: "#1a1f3a"
    border.color: "#00f3ff"
    border.width: 2
    radius: 8

    property int pinNumber: -1
    property var pinInfo: null
    signal closed()

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Header
        Row {
            width: parent.width
            spacing: 10

            Text {
                text: "PIN " + pinNumber
                font.pixelSize: 22
                font.bold: true
                font.family: "monospace"
                color: "#00f3ff"
                width: parent.width - 60
            }

            Rectangle {
                width: 40
                height: 40
                color: closeBtn.pressed ? "#ff006e" : "transparent"
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
                    id: closeBtn
                    anchors.fill: parent
                    property bool pressed: false
                    onPressedChanged: pressed = pressed
                    onClicked: closed()
                }
            }
        }

        // Pin info section
        Rectangle {
            width: parent.width
            height: 75
            color: "#0f1428"
            border.color: "#666"
            border.width: 1
            radius: 4

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Text {
                    text: "MODE: " + (pinInfo ? pinInfo.mode.toUpperCase() : "")
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "monospace"
                    color: pinInfo && pinInfo.mode === "input" ? "#00ff41" : (pinInfo && pinInfo.mode === "pwm" ? "#ffa500" : "#ff006e")
                }

                Text {
                    visible: pinInfo && pinInfo.mode === "input"
                    text: "PULL: " + (pinInfo ? pinInfo.pull_mode.toUpperCase() : "")
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#888"
                }

                Text {
                    visible: pinInfo && pinInfo.mode !== "pwm"
                    text: "VALUE: " + (pinInfo ? pinInfo.value : "")
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#fff"
                }

                Text {
                    visible: pinInfo && pinInfo.mode === "pwm"
                    text: "DUTY: " + (pinInfo ? pinInfo.pwm_duty_cycle.toFixed(1) + "%" : "0%")
                    font.pixelSize: 11
                    font.family: "monospace"
                    color: "#ffa500"
                }
            }
        }

        // Output controls
        Column {
            visible: pinInfo && pinInfo.mode === "output"
            width: parent.width
            spacing: 8

            Text {
                text: "OUTPUT CONTROL"
                font.pixelSize: 16
                font.bold: true
                font.family: "monospace"
                color: "#00f3ff"
            }

            Row {
                width: parent.width
                spacing: 10

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 50
                    color: pinInfo && pinInfo.value === 0 ? "#333" : "transparent"
                    border.color: "#666"
                    border.width: 2
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "LOW (0)"
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "monospace"
                        color: "#888"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: gpioController.writePin(pinNumber, 0)
                    }
                }

                Rectangle {
                    width: (parent.width - 10) / 2
                    height: 50
                    color: pinInfo && pinInfo.value === 1 ? "#00ff41" : "transparent"
                    border.color: "#00ff41"
                    border.width: 2
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "HIGH (1)"
                        font.pixelSize: 32
                        font.bold: true
                        font.family: "monospace"
                        color: "#00ff41"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: gpioController.writePin(pinNumber, 1)
                    }
                }
            }

            // Toggle button
            Rectangle {
                width: parent.width
                height: 50
                color: "#00f3ff"
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: "TOGGLE"
                    font.pixelSize: 36
                    font.bold: true
                    font.family: "monospace"
                    color: "#000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (pinInfo) {
                            gpioController.writePin(pinNumber, pinInfo.value === 1 ? 0 : 1)
                        }
                    }
                }
            }
        }

        // Input info
        Rectangle {
            visible: pinInfo && pinInfo.mode === "input"
            width: parent.width
            height: 80
            color: "#0f1428"
            border.color: "#00ff41"
            border.width: 2
            radius: 4

            Row {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20

                Text {
                    text: "INPUT VALUE:"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                    color: "#00ff41"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 50
                    height: 50
                    radius: 25
                    color: pinInfo && pinInfo.value === 1 ? "#00ff41" : "#333"
                    border.color: "#00ff41"
                    border.width: 2
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: pinInfo ? pinInfo.value : ""
                        font.pixelSize: 44
                        font.bold: true
                        font.family: "monospace"
                        color: pinInfo && pinInfo.value === 1 ? "#000" : "#00ff41"
                    }
                }
            }
        }

        // PWM controls
        Column {
            visible: pinInfo && pinInfo.mode === "pwm"
            width: parent.width
            spacing: 8

            // PWM Type indicator
            Rectangle {
                width: parent.width
                height: 30
                color: "#0f1428"
                border.color: pinInfo && pinInfo.hardware_pwm ? "#ffa500" : "#888"
                border.width: 2
                radius: 4

                Text {
                    anchors.centerIn: parent
                    text: pinInfo && pinInfo.hardware_pwm ? "⚡ HARDWARE PWM" : "SOFTWARE PWM"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "monospace"
                    color: pinInfo && pinInfo.hardware_pwm ? "#ffa500" : "#888"
                }
            }

            // Duty Cycle Control
            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "DUTY CYCLE"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                    color: "#ffa500"
                }

                Row {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        width: parent.width - 148
                        height: 40
                        color: "#0f1428"
                        border.color: "#ffa500"
                        border.width: 2
                        radius: 4

                        // Custom slider track
                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 10
                            width: parent.width - 20
                            height: 6
                            color: "#333"
                            radius: 3

                            // Filled portion
                            Rectangle {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width * (pinInfo ? pinInfo.pwm_duty_cycle / 100 : 0)
                                height: parent.height
                                color: "#ffa500"
                                radius: 3
                            }

                            // Slider handle
                            Rectangle {
                                x: (parent.width - width) * (pinInfo ? pinInfo.pwm_duty_cycle / 100 : 0)
                                anchors.verticalCenter: parent.verticalCenter
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffa500"
                                border.color: "#fff"
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -10
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.minimumX: 0
                                    drag.maximumX: parent.parent.width - parent.width

                                    onPositionChanged: {
                                        if (drag.active && pinInfo) {
                                            var newDuty = Math.max(0, Math.min(100, (parent.x / (parent.parent.width - parent.width)) * 100))
                                            gpioController.setPWMDutyCycle(pinNumber, newDuty)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: pinInfo ? pinInfo.pwm_duty_cycle.toFixed(1) + "%" : "0%"
                        font.pixelSize: 40
                        font.bold: true
                        font.family: "monospace"
                        color: "#ffa500"
                        width: 140
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Servo Controls (for 50Hz PWM)
            Column {
                visible: pinInfo && pinInfo.pwm_frequency >= 45 && pinInfo.pwm_frequency <= 55
                width: parent.width
                spacing: 6

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#444"
                }

                Text {
                    text: "SERVO CONTROL"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                    color: "#00f3ff"
                }

                // Angle display and presets in one row
                Row {
                    width: parent.width
                    spacing: 6

                    // Angle display
                    Rectangle {
                        width: 80
                        height: 50
                        color: "#0f1428"
                        border.color: "#00f3ff"
                        border.width: 2
                        radius: 4

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                text: "POS"
                                font.pixelSize: 8
                                font.family: "monospace"
                                color: "#888"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                property real angle: pinInfo ? Math.max(0, Math.min(180, (pinInfo.pwm_duty_cycle - 5) * 36)) : 0
                                text: angle.toFixed(0) + "°"
                                font.pixelSize: 52
                                font.bold: true
                                font.family: "monospace"
                                color: "#00f3ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    // Quick position presets
                    Column {
                        width: parent.width - 86
                        spacing: 4

                        Text {
                            text: "PRESETS"
                            font.pixelSize: 8
                            font.family: "monospace"
                            color: "#888"
                        }

                        Row {
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: [
                                    {angle: 0, label: "0°"},
                                    {angle: 45, label: "45°"},
                                    {angle: 90, label: "90°"},
                                    {angle: 135, label: "135°"},
                                    {angle: 180, label: "180°"}
                                ]

                                Rectangle {
                                    width: (parent.width - 16) / 5
                                    height: 32
                                    property real targetDuty: (modelData.angle / 36) + 5
                                    property bool isActive: pinInfo && Math.abs(pinInfo.pwm_duty_cycle - targetDuty) < 0.3
                                    color: isActive ? "#00f3ff" : "transparent"
                                    border.color: "#00f3ff"
                                    border.width: 2
                                    radius: 4

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font.pixelSize: 26
                                        font.bold: true
                                        font.family: "monospace"
                                        color: parent.isActive ? "#000" : "#00f3ff"
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            gpioController.setPWMDutyCycle(pinNumber, parent.targetDuty)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Direction and step controls
                Text {
                    text: "ROTATE"
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "monospace"
                    color: "#888"
                }

                Row {
                    width: parent.width
                    spacing: 6

                    // Rotate Left button
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 45
                        color: leftRotateBtn.pressed ? "#00f3ff" : "transparent"
                        border.color: "#00f3ff"
                        border.width: 2
                        radius: 4

                        Column {
                            anchors.centerIn: parent
                            spacing: 1

                            Text {
                                text: "◄"
                                font.pixelSize: 40
                                font.bold: true
                                color: leftRotateBtn.pressed ? "#000" : "#00f3ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "LEFT"
                                font.pixelSize: 24
                                font.bold: true
                                font.family: "monospace"
                                color: leftRotateBtn.pressed ? "#000" : "#00f3ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            id: leftRotateBtn
                            anchors.fill: parent
                            property bool pressed: false
                            onPressedChanged: pressed = pressed
                            onClicked: {
                                if (pinInfo) {
                                    var currentAngle = Math.max(0, Math.min(180, (pinInfo.pwm_duty_cycle - 5) * 36))
                                    var newAngle = Math.max(0, currentAngle - stepSelector.stepSize)
                                    var newDuty = (newAngle / 36) + 5
                                    gpioController.setPWMDutyCycle(pinNumber, newDuty)
                                }
                            }
                        }
                    }

                    // Step size selector
                    Rectangle {
                        id: stepSelector
                        width: (parent.width - 12) / 3
                        height: 45
                        color: "#0f1428"
                        border.color: "#ffa500"
                        border.width: 2
                        radius: 4

                        property int stepIndex: 1
                        property var stepSizes: [1, 5, 10, 15, 30]
                        property int stepSize: stepSizes[stepIndex]

                        Column {
                            anchors.centerIn: parent
                            spacing: 1

                            Text {
                                text: "STEP"
                                font.pixelSize: 8
                                font.family: "monospace"
                                color: "#888"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: stepSelector.stepSize + "°"
                                font.pixelSize: 40
                                font.bold: true
                                font.family: "monospace"
                                color: "#ffa500"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stepSelector.stepIndex = (stepSelector.stepIndex + 1) % stepSelector.stepSizes.length
                            }
                        }
                    }

                    // Rotate Right button
                    Rectangle {
                        width: (parent.width - 12) / 3
                        height: 45
                        color: rightRotateBtn.pressed ? "#00f3ff" : "transparent"
                        border.color: "#00f3ff"
                        border.width: 2
                        radius: 4

                        Column {
                            anchors.centerIn: parent
                            spacing: 1

                            Text {
                                text: "►"
                                font.pixelSize: 40
                                font.bold: true
                                color: rightRotateBtn.pressed ? "#000" : "#00f3ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "RIGHT"
                                font.pixelSize: 24
                                font.bold: true
                                font.family: "monospace"
                                color: rightRotateBtn.pressed ? "#000" : "#00f3ff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            id: rightRotateBtn
                            anchors.fill: parent
                            property bool pressed: false
                            onPressedChanged: pressed = pressed
                            onClicked: {
                                if (pinInfo) {
                                    var currentAngle = Math.max(0, Math.min(180, (pinInfo.pwm_duty_cycle - 5) * 36))
                                    var newAngle = Math.min(180, currentAngle + stepSelector.stepSize)
                                    var newDuty = (newAngle / 36) + 5
                                    gpioController.setPWMDutyCycle(pinNumber, newDuty)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#444"
                }
            }

            // Frequency Control
            Column {
                width: parent.width
                spacing: 5

                Text {
                    text: "FREQUENCY"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "monospace"
                    color: "#ffa500"
                }

                Row {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: ["50Hz", "100Hz", "1kHz", "10kHz"]

                        Rectangle {
                            width: (parent.width - 18) / 4
                            height: 38
                            color: {
                                if (!pinInfo) return "transparent"
                                var freq = pinInfo.pwm_frequency
                                var targetFreq = modelData === "50Hz" ? 50 : (modelData === "100Hz" ? 100 : (modelData === "1kHz" ? 1000 : 10000))
                                return Math.abs(freq - targetFreq) < 1 ? "#ffa500" : "transparent"
                            }
                            border.color: "#ffa500"
                            border.width: 2
                            radius: 4

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 28
                                font.bold: true
                                font.family: "monospace"
                                color: {
                                    if (!pinInfo) return "#ffa500"
                                    var freq = pinInfo.pwm_frequency
                                    var targetFreq = modelData === "50Hz" ? 50 : (modelData === "100Hz" ? 100 : (modelData === "1kHz" ? 1000 : 10000))
                                    return Math.abs(freq - targetFreq) < 1 ? "#000" : "#ffa500"
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var freq = modelData === "50Hz" ? 50 : (modelData === "100Hz" ? 100 : (modelData === "1kHz" ? 1000 : 10000))
                                    gpioController.setPWMFrequency(pinNumber, freq)
                                }
                            }
                        }
                    }
                }

                Text {
                    text: pinInfo ? "Now: " + pinInfo.pwm_frequency.toFixed(0) + " Hz" : ""
                    font.pixelSize: 9
                    font.family: "monospace"
                    color: "#888"
                }
            }
        }

        // Spacer
        Item {
            width: 1
            height: Math.max(5, parent.height - (pinInfo && pinInfo.mode === "pwm" ? 520 : 380))
        }

        // Remove button
        Rectangle {
            width: parent.width
            height: 50
            color: "#ff006e"
            radius: 4

            Text {
                anchors.centerIn: parent
                text: "REMOVE PIN"
                font.pixelSize: 36
                font.bold: true
                font.family: "monospace"
                color: "#fff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gpioController.removePin(pinNumber)
                    closed()
                }
            }
        }
    }
}
