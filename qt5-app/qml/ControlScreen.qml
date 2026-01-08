import QtQuick 2.9

Item {
    id: controlScreen

    // Data model for controllable pins (output and PWM only)
    property var controllablePins: []

    // Load pins when screen becomes visible
    onVisibleChanged: {
        if (visible) {
            updateControllablePins()
        }
    }

    // Update pins when GPIO controller emits changes
    Connections {
        target: gpioController
        onPinsChanged: {
            if (visible) {
                updateControllablePins()
            }
        }
        onPinValueChanged: {
            if (visible) {
                updateControllablePins()
            }
        }
    }

    Component.onCompleted: {
        updateControllablePins()
    }

    function updateControllablePins() {
        var pinsJson = gpioController.getConfiguredPins()
        var allPins = JSON.parse(pinsJson)

        // Filter to only output and PWM pins
        var filtered = []
        for (var i = 0; i < allPins.length; i++) {
            if (allPins[i].mode === 'output' || allPins[i].mode === 'pwm') {
                filtered.push(allPins[i])
            }
        }

        controllablePins = filtered
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1f3a"
        border.color: "#00f3ff"
        border.width: 2
        radius: 8

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            Text {
                text: "PIN CONTROLS"
                font.pixelSize: 28
                font.bold: true
                color: "#00f3ff"
            }

            Text {
                text: controllablePins.length === 0 ? "No output or PWM pins configured. Use GPIO screen to configure pins." :
                      "Control all configured output and PWM pins"
                font.pixelSize: 14
                color: "#888"
                wrapMode: Text.WordWrap
                width: parent.width
            }

            // Scrollable list of controllable pins
            Rectangle {
                width: parent.width
                height: parent.height - 100
                color: "#0f1428"
                border.color: "#666"
                border.width: 1
                radius: 4

                Flickable {
                    id: pinListFlickable
                    anchors.fill: parent
                    anchors.margins: 15
                    contentHeight: pinColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: pinColumn
                        width: parent.width
                        spacing: 15

                        Repeater {
                            model: controllablePins
                            delegate: Rectangle {
                                width: pinColumn.width
                                height: modelData.mode === 'output' ? 90 :
                                        (modelData.mode === 'pwm' && modelData.pwm_frequency >= 45 && modelData.pwm_frequency <= 55) ? 200 : 130
                                color: "#1a1f3a"
                                border.color: modelData.mode === 'output' ? "#00ff41" : "#ffa500"
                                border.width: 2
                                radius: 6

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 15

                                    // Left side: Pin label
                                    Rectangle {
                                        width: 140
                                        height: parent.height
                                        color: "transparent"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 5

                                            Text {
                                                text: "GPIO " + modelData.pin
                                                font.pixelSize: 24
                                                font.bold: true
                                                font.family: "monospace"
                                                color: "#00f3ff"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: modelData.mode.toUpperCase()
                                                font.pixelSize: 12
                                                font.bold: true
                                                font.family: "monospace"
                                                color: modelData.mode === 'output' ? "#00ff41" : "#ffa500"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                visible: modelData.hardware_pwm === true
                                                text: "⚡ HW PWM"
                                                font.pixelSize: 9
                                                font.family: "monospace"
                                                color: "#ffa500"
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }
                                    }

                                    // Right side: Controls
                                    Column {
                                        width: parent.width - 155
                                        height: parent.height
                                        spacing: 8

                                        // OUTPUT controls: OFF/ON buttons
                                        Row {
                                            visible: modelData.mode === 'output'
                                            width: parent.width
                                            spacing: 10
                                            anchors.verticalCenter: parent.verticalCenter

                                            Rectangle {
                                                width: (parent.width - 10) / 2
                                                height: 54
                                                color: modelData.value === 0 ? "#00ff41" : "transparent"
                                                border.color: modelData.value === 0 ? "#00ff41" : "#666"
                                                border.width: 2
                                                radius: 4

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "OFF"
                                                    font.pixelSize: 36
                                                    font.bold: true
                                                    font.family: "monospace"
                                                    color: modelData.value === 0 ? "#000" : "#666"
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: gpioController.writePin(modelData.pin, 0)
                                                }
                                            }

                                            Rectangle {
                                                width: (parent.width - 10) / 2
                                                height: 54
                                                color: modelData.value === 1 ? "#00ff41" : "transparent"
                                                border.color: modelData.value === 1 ? "#00ff41" : "#666"
                                                border.width: 2
                                                radius: 4

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "ON"
                                                    font.pixelSize: 36
                                                    font.bold: true
                                                    font.family: "monospace"
                                                    color: modelData.value === 1 ? "#000" : "#666"
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    onClicked: gpioController.writePin(modelData.pin, 1)
                                                }
                                            }
                                        }

                                        // PWM controls
                                        Column {
                                            visible: modelData.mode === 'pwm'
                                            width: parent.width
                                            spacing: 6

                                            // Duty Cycle slider
                                            Text {
                                                text: "DUTY CYCLE: " + modelData.pwm_duty_cycle.toFixed(1) + "%"
                                                font.pixelSize: 14
                                                font.bold: true
                                                font.family: "monospace"
                                                color: "#ffa500"
                                            }

                                            Rectangle {
                                                width: parent.width
                                                height: 40
                                                color: "#0f1428"
                                                border.color: "#ffa500"
                                                border.width: 2
                                                radius: 4

                                                // Slider track
                                                Rectangle {
                                                    anchors.centerIn: parent
                                                    width: parent.width - 20
                                                    height: 6
                                                    color: "#333"
                                                    radius: 3

                                                    // Filled portion
                                                    Rectangle {
                                                        anchors.left: parent.left
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        width: parent.width * (modelData.pwm_duty_cycle / 100)
                                                        height: parent.height
                                                        color: "#ffa500"
                                                        radius: 3
                                                    }

                                                    // Slider handle
                                                    Rectangle {
                                                        id: dutyHandle
                                                        x: (parent.width - width) * (modelData.pwm_duty_cycle / 100)
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
                                                            drag.maximumX: dutyHandle.parent.width - dutyHandle.width

                                                            onPositionChanged: {
                                                                if (drag.active) {
                                                                    var newDuty = Math.max(0, Math.min(100,
                                                                        (dutyHandle.x / (dutyHandle.parent.width - dutyHandle.width)) * 100))
                                                                    gpioController.setPWMDutyCycle(modelData.pin, newDuty)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            // Servo position slider (for 45-55Hz PWM)
                                            Column {
                                                visible: modelData.pwm_frequency >= 45 && modelData.pwm_frequency <= 55
                                                width: parent.width
                                                spacing: 6

                                                Row {
                                                    width: parent.width
                                                    spacing: 8

                                                    Text {
                                                        text: "SERVO POSITION:"
                                                        font.pixelSize: 14
                                                        font.bold: true
                                                        font.family: "monospace"
                                                        color: "#00f3ff"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    Text {
                                                        property real angle: Math.max(0, Math.min(180, (modelData.pwm_duty_cycle - 5) * 36))
                                                        text: angle.toFixed(0) + "°"
                                                        font.pixelSize: 24
                                                        font.bold: true
                                                        font.family: "monospace"
                                                        color: "#00f3ff"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                }

                                                Rectangle {
                                                    width: parent.width
                                                    height: 40
                                                    color: "#0f1428"
                                                    border.color: "#00f3ff"
                                                    border.width: 2
                                                    radius: 4

                                                    // Slider track
                                                    Rectangle {
                                                        anchors.centerIn: parent
                                                        width: parent.width - 20
                                                        height: 6
                                                        color: "#333"
                                                        radius: 3

                                                        // Center marker
                                                        Rectangle {
                                                            anchors.centerIn: parent
                                                            width: 2
                                                            height: 12
                                                            color: "#666"
                                                        }

                                                        // Filled portion (from 0 to current position)
                                                        Rectangle {
                                                            anchors.left: parent.left
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            width: parent.width * ((modelData.pwm_duty_cycle - 5) / 5)
                                                            height: parent.height
                                                            color: "#00f3ff"
                                                            opacity: 0.5
                                                            radius: 3
                                                        }

                                                        // Slider handle
                                                        Rectangle {
                                                            id: servoHandle
                                                            // Map duty cycle 5-10% to position 0-1
                                                            property real normalizedPos: (modelData.pwm_duty_cycle - 5) / 5
                                                            x: (parent.width - width) * normalizedPos
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            width: 20
                                                            height: 20
                                                            radius: 10
                                                            color: "#00f3ff"
                                                            border.color: "#fff"
                                                            border.width: 2

                                                            MouseArea {
                                                                anchors.fill: parent
                                                                anchors.margins: -10
                                                                drag.target: parent
                                                                drag.axis: Drag.XAxis
                                                                drag.minimumX: 0
                                                                drag.maximumX: servoHandle.parent.width - servoHandle.width

                                                                onPositionChanged: {
                                                                    if (drag.active) {
                                                                        var normalizedPos = servoHandle.x / (servoHandle.parent.width - servoHandle.width)
                                                                        // Map position 0-1 to duty cycle 5-10%
                                                                        var newDuty = 5 + (normalizedPos * 5)
                                                                        gpioController.setPWMDutyCycle(modelData.pin, newDuty)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }

                                                Row {
                                                    width: parent.width
                                                    spacing: 0

                                                    Text {
                                                        text: "0°"
                                                        font.pixelSize: 10
                                                        color: "#666"
                                                        width: parent.width / 3
                                                    }

                                                    Text {
                                                        text: "90°"
                                                        font.pixelSize: 10
                                                        color: "#666"
                                                        width: parent.width / 3
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }

                                                    Text {
                                                        text: "180°"
                                                        font.pixelSize: 10
                                                        color: "#666"
                                                        width: parent.width / 3
                                                        horizontalAlignment: Text.AlignRight
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

                // Scrollbar indicator
                Rectangle {
                    visible: pinListFlickable.contentHeight > pinListFlickable.height
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 2
                    width: 6
                    color: "#222"
                    radius: 3

                    Rectangle {
                        y: (pinListFlickable.visibleArea.yPosition * parent.height)
                        width: parent.width
                        height: Math.max(20, pinListFlickable.visibleArea.heightRatio * parent.height)
                        color: "#00f3ff"
                        radius: 3
                        opacity: 0.6
                    }
                }
            }
        }
    }
}
