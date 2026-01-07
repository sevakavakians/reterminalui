import QtQuick 2.9

Item {
    id: sensorScreen

    // Data buffers for graphing (keep last 100 points)
    property var accelXData: []
    property var accelYData: []
    property var accelZData: []
    property var lightData: []
    property int maxDataPoints: 100

    // Update graphs when sensor data changes
    Connections {
        target: sensorData
        onAccelXChanged: { updateAccelData() }
        onAccelYChanged: { updateAccelData() }
        onAccelZChanged: { updateAccelData() }
        onLightChanged: { updateLightData() }
    }

    function updateAccelData() {
        // Add new data points
        accelXData.push(sensorData.accelX)
        accelYData.push(sensorData.accelY)
        accelZData.push(sensorData.accelZ)

        // Keep only last maxDataPoints
        if (accelXData.length > maxDataPoints) {
            accelXData.shift()
            accelYData.shift()
            accelZData.shift()
        }

        // Trigger repaint
        accelCanvas.requestPaint()
    }

    function updateLightData() {
        // Add new data point
        lightData.push(sensorData.light)

        // Keep only last maxDataPoints
        if (lightData.length > maxDataPoints) {
            lightData.shift()
        }

        // Trigger repaint
        lightCanvas.requestPaint()
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Accelerometer section
        Rectangle {
            width: parent.width
            height: (parent.height - 40) / 2
            color: "#1a1f3a"
            border.color: "#00f3ff"
            border.width: 2
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Header with current values
                Row {
                    width: parent.width
                    spacing: 20

                    Text {
                        text: "ACCELEROMETER"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#00f3ff"
                        width: parent.width - 400
                    }

                    // Current values
                    Row {
                        spacing: 20

                        Text {
                            text: "X: " + sensorData.accelX.toFixed(2) + "g"
                            font.pixelSize: 14
                            color: "#ff006e"
                        }

                        Text {
                            text: "Y: " + sensorData.accelY.toFixed(2) + "g"
                            font.pixelSize: 14
                            color: "#00ff41"
                        }

                        Text {
                            text: "Z: " + sensorData.accelZ.toFixed(2) + "g"
                            font.pixelSize: 14
                            color: "#00f3ff"
                        }
                    }
                }

                // Graph
                Rectangle {
                    width: parent.width
                    height: parent.height - 50
                    color: "#0a0e27"
                    border.color: "#333"
                    border.width: 1
                    radius: 4

                    Canvas {
                        id: accelCanvas
                        anchors.fill: parent
                        anchors.margins: 10

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            if (accelXData.length === 0) return

                            // Draw grid
                            ctx.strokeStyle = "#1a1f3a"
                            ctx.lineWidth = 1
                            for (var i = 0; i <= 4; i++) {
                                var y = (height / 4) * i
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(width, y)
                                ctx.stroke()
                            }

                            // Draw zero line
                            ctx.strokeStyle = "#333"
                            ctx.lineWidth = 2
                            var zeroY = height / 2
                            ctx.beginPath()
                            ctx.moveTo(0, zeroY)
                            ctx.lineTo(width, zeroY)
                            ctx.stroke()

                            // Helper function to draw line
                            function drawLine(data, color) {
                                ctx.strokeStyle = color
                                ctx.lineWidth = 2
                                ctx.beginPath()

                                var xStep = width / (maxDataPoints - 1)
                                for (var i = 0; i < data.length; i++) {
                                    var x = i * xStep
                                    // Map -2g to +2g to canvas height
                                    var value = data[i]
                                    var y = height / 2 - (value / 2) * (height / 2)

                                    if (i === 0) {
                                        ctx.moveTo(x, y)
                                    } else {
                                        ctx.lineTo(x, y)
                                    }
                                }
                                ctx.stroke()
                            }

                            // Draw lines for each axis
                            drawLine(accelXData, "#ff006e")
                            drawLine(accelYData, "#00ff41")
                            drawLine(accelZData, "#00f3ff")
                        }
                    }
                }
            }
        }

        // Light sensor section
        Rectangle {
            width: parent.width
            height: (parent.height - 40) / 2
            color: "#1a1f3a"
            border.color: "#ffbe0b"
            border.width: 2
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Header with current value
                Row {
                    width: parent.width

                    Text {
                        text: "LIGHT SENSOR"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#ffbe0b"
                        width: parent.width - 200
                    }

                    Text {
                        text: sensorData.light + " lux"
                        font.pixelSize: 18
                        color: "#ffbe0b"
                    }
                }

                // Graph
                Rectangle {
                    width: parent.width
                    height: parent.height - 50
                    color: "#0a0e27"
                    border.color: "#333"
                    border.width: 1
                    radius: 4

                    Canvas {
                        id: lightCanvas
                        anchors.fill: parent
                        anchors.margins: 10

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            if (lightData.length === 0) return

                            // Draw grid
                            ctx.strokeStyle = "#1a1f3a"
                            ctx.lineWidth = 1
                            for (var i = 0; i <= 4; i++) {
                                var y = (height / 4) * i
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(width, y)
                                ctx.stroke()
                            }

                            // Find min/max for scaling
                            var minLight = Math.min.apply(null, lightData)
                            var maxLight = Math.max.apply(null, lightData)
                            var range = maxLight - minLight
                            if (range === 0) range = 1  // Prevent division by zero

                            // Draw filled area
                            ctx.fillStyle = "rgba(255, 190, 11, 0.2)"
                            ctx.strokeStyle = "#ffbe0b"
                            ctx.lineWidth = 2
                            ctx.beginPath()

                            var xStep = width / (maxDataPoints - 1)

                            // Start from bottom
                            ctx.moveTo(0, height)

                            for (var i = 0; i < lightData.length; i++) {
                                var x = i * xStep
                                var normalizedValue = (lightData[i] - minLight) / range
                                var y = height - (normalizedValue * height)
                                ctx.lineTo(x, y)
                            }

                            // Close the path
                            ctx.lineTo(lightData.length * xStep, height)
                            ctx.closePath()
                            ctx.fill()

                            // Draw line
                            ctx.beginPath()
                            for (var j = 0; j < lightData.length; j++) {
                                var x2 = j * xStep
                                var normalizedValue2 = (lightData[j] - minLight) / range
                                var y2 = height - (normalizedValue2 * height)
                                if (j === 0) {
                                    ctx.moveTo(x2, y2)
                                } else {
                                    ctx.lineTo(x2, y2)
                                }
                            }
                            ctx.stroke()
                        }
                    }
                }
            }
        }
    }
}
