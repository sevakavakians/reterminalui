# reTerminal GPIO Control System - API Specification

**Version:** 1.0.0
**Last Updated:** 2026-01-07

## Overview

This document specifies the Python API exposed to QML through PySide2 context properties. All controllers are singleton instances accessible via global QML context.

## GPIOController API

### Context Property
**Name:** `gpioController`
**Type:** `GPIOController (QObject)`

### Constants

```python
HARDWARE_PWM_PINS = [12, 18, 19]  # BCM2711 hardware PWM capable pins
RESERVED_PINS = [2, 3, 6, 13]     # I2C, OLED, USB hub (do not configure)
```

### Signals

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `pinsChanged()` | None | Emitted when pin configuration changes |
| `pinValueChanged(int, int)` | pin, value | Emitted when pin value changes |

### Methods

#### `configurePin(pin: int, mode: str, pull_mode: str) → bool`

Configure a GPIO pin.

**Parameters:**
- `pin` (int): GPIO pin number (0-27, BCM numbering)
- `mode` (str): Pin mode - "input", "output", or "pwm"
- `pull_mode` (str): Pull resistor - "none", "up", or "down" (input mode only)

**Returns:** `bool` - True if successful, False otherwise

**Example:**
```qml
var success = gpioController.configurePin(17, "output", "none")
if (success) {
    console.log("GPIO 17 configured as output")
}
```

**Errors:**
- Returns False if pin is reserved
- Returns False if invalid mode/pull_mode
- Logs warning on GPIO error

---

#### `writePin(pin: int, value: int) → bool`

Write value to output pin.

**Parameters:**
- `pin` (int): GPIO pin number
- `value` (int): 0 (LOW) or 1 (HIGH)

**Returns:** `bool` - True if successful

**Example:**
```qml
gpioController.writePin(17, 1)  // Set GPIO 17 HIGH
```

**Preconditions:**
- Pin must be configured as output
- Emits `pinValueChanged(pin, value)` on success

---

#### `readPin(pin: int) → int`

Read value from input pin.

**Parameters:**
- `pin` (int): GPIO pin number

**Returns:** `int` - 0 (LOW) or 1 (HIGH), or -1 on error

**Example:**
```qml
var value = gpioController.readPin(27)
console.log("GPIO 27 value:", value)
```

**Preconditions:**
- Pin must be configured as input

---

#### `removePin(pin: int) → bool`

Remove pin configuration and cleanup.

**Parameters:**
- `pin` (int): GPIO pin number

**Returns:** `bool` - True if successful

**Example:**
```qml
gpioController.removePin(17)
```

**Side Effects:**
- Stops PWM if active
- Calls GPIO.cleanup(pin)
- Removes from internal state
- Emits `pinsChanged()`

---

#### `setPWMDutyCycle(pin: int, duty_cycle: float) → bool`

Set PWM duty cycle.

**Parameters:**
- `pin` (int): GPIO pin number
- `duty_cycle` (float): Duty cycle percentage (0.0 - 100.0)

**Returns:** `bool` - True if successful

**Example:**
```qml
// Set 50% duty cycle
gpioController.setPWMDutyCycle(18, 50.0)

// Servo position (7.5% = 90°)
gpioController.setPWMDutyCycle(18, 7.5)
```

**Preconditions:**
- Pin must be configured as PWM
- duty_cycle clamped to [0.0, 100.0]

**Side Effects:**
- Calls `pwm.ChangeDutyCycle(duty_cycle)`
- Emits `pinValueChanged(pin, duty_cycle)`

---

#### `setPWMFrequency(pin: int, frequency: float) → bool`

Set PWM frequency.

**Parameters:**
- `pin` (int): GPIO pin number
- `frequency` (float): Frequency in Hz (0.1 - 100000.0)

**Returns:** `bool` - True if successful

**Example:**
```qml
// Servo standard frequency
gpioController.setPWMFrequency(18, 50.0)

// LED dimming
gpioController.setPWMFrequency(17, 1000.0)
```

**Preconditions:**
- Pin must be configured as PWM
- Frequency clamped to [0.1, 100000.0]

**Side Effects:**
- Stops current PWM
- Creates new PWM object with new frequency
- Restores previous duty cycle
- Emits `pinsChanged()`

**Warning:** Changing frequency on GPIO 12 or 18 affects both pins (shared PWM channel 0)

---

#### `getConfiguredPins() → str`

Get all configured pins as JSON.

**Returns:** `str` - JSON array of pin configurations

**Example:**
```qml
var pinsJson = gpioController.getConfiguredPins()
var pins = JSON.parse(pinsJson)
// pins = [
//   {
//     "pin": 17,
//     "mode": "output",
//     "value": 1,
//     "pull_mode": "none"
//   },
//   {
//     "pin": 18,
//     "mode": "pwm",
//     "pwm_frequency": 50.0,
//     "pwm_duty_cycle": 7.5,
//     "hardware_pwm": true
//   }
// ]
```

**JSON Schema:**
```json
[
  {
    "pin": <int>,
    "mode": <"input" | "output" | "pwm">,
    "pull_mode": <"none" | "up" | "down">,
    "value": <0 | 1>,
    "pwm_enabled": <bool>,
    "pwm_frequency": <float>,
    "pwm_duty_cycle": <float>,
    "hardware_pwm": <bool>
  }
]
```

---

#### `getHardwarePWMPins() → str`

Get hardware PWM capable pins as JSON.

**Returns:** `str` - JSON array of pin numbers

**Example:**
```qml
var hwPinsJson = gpioController.getHardwarePWMPins()
var hwPins = JSON.parse(hwPinsJson)
// hwPins = [12, 18, 19]
```

---

## SensorController API

### Context Property
**Name:** `sensorController`
**Type:** `SensorController (QObject)`

### Signals

| Signal | Parameters | Description |
|--------|-----------|-------------|
| `sensorDataUpdated(str)` | json_data | Emitted when sensor data is read |
| `sensorError(str)` | error_msg | Emitted on sensor read error |

### Methods

#### `readDHT(gpio_pin: int) → str`

Read DHT11/DHT22 sensor.

**Parameters:**
- `gpio_pin` (int): GPIO pin connected to DHT sensor

**Returns:** `str` - JSON sensor data

**Example:**
```qml
var dataJson = sensorController.readDHT(4)
var data = JSON.parse(dataJson)
// data = {
//   "temperature": 23.5,
//   "humidity": 45.0,
//   "status": "ok",
//   "timestamp": 1641556800
// }
```

**Errors:**
- status: "error" if read fails
- status: "timeout" if sensor doesn't respond

---

#### `readBME280(i2c_address: int) → str`

Read BME280 environmental sensor.

**Parameters:**
- `i2c_address` (int): I2C address (0x76 or 0x77)

**Returns:** `str` - JSON sensor data

**Example:**
```qml
var dataJson = sensorController.readBME280(0x76)
var data = JSON.parse(dataJson)
// data = {
//   "temperature": 23.5,
//   "humidity": 45.0,
//   "pressure": 1013.25,
//   "status": "ok",
//   "timestamp": 1641556800
// }
```

---

#### `startAutoRead(interval: int)`

Start automatic sensor reading.

**Parameters:**
- `interval` (int): Read interval in milliseconds (default: 2000)

**Side Effects:**
- Starts QTimer to read sensor periodically
- Emits `sensorDataUpdated(json)` on each read

---

#### `stopAutoRead()`

Stop automatic sensor reading.

---

## Data Types

### Pin Configuration Object

```typescript
interface PinConfig {
  pin: number;                // GPIO pin number (0-27)
  mode: "input" | "output" | "pwm";
  pull_mode: "none" | "up" | "down";
  value: 0 | 1;               // Current pin value
  pwm_enabled: boolean;
  pwm_frequency: number;      // Hz (0.1 - 100000)
  pwm_duty_cycle: number;     // % (0.0 - 100.0)
  hardware_pwm: boolean;      // True if GPIO 12, 18, or 19
}
```

### Sensor Data Object

```typescript
interface SensorData {
  temperature: number;    // °C
  humidity: number;       // %
  pressure?: number;      // hPa (BME280 only)
  status: "ok" | "error" | "timeout" | "disconnected";
  timestamp: number;      // Unix timestamp
  error?: string;         // Error message if status != "ok"
}
```

## Error Handling

### Error Response Pattern

All methods return False or error status on failure. QML should check return values:

```qml
var success = gpioController.configurePin(99, "output", "none")
if (!success) {
    console.error("Failed to configure pin 99")
    // Display error message to user
}
```

### Error Logging

All errors are logged to console with severity level:
- INFO: Normal operations
- WARNING: Recoverable errors (e.g., invalid parameters)
- ERROR: Critical errors (e.g., hardware failures)

Example log output:
```
INFO: Configured GPIO 17 as output
WARNING: Attempted to configure reserved pin 2
ERROR: GPIO.setup failed for pin 17: permission denied
```

## Usage Examples

### Complete GPIO Configuration Flow

```qml
// 1. Configure pin as output
var success = gpioController.configurePin(17, "output", "none")

if (success) {
    // 2. Set pin HIGH
    gpioController.writePin(17, 1)

    // 3. Wait 1 second
    // ... (use Timer)

    // 4. Set pin LOW
    gpioController.writePin(17, 0)

    // 5. Remove pin when done
    gpioController.removePin(17)
}
```

### PWM LED Dimming

```qml
// Configure pin as PWM
gpioController.configurePin(18, "pwm", "none")

// Set frequency to 1kHz
gpioController.setPWMFrequency(18, 1000)

// Fade in from 0% to 100%
for (var i = 0; i <= 100; i += 5) {
    gpioController.setPWMDutyCycle(18, i)
    // Add delay between steps
}
```

### Servo Motor Control

```qml
// Configure hardware PWM pin for servo
gpioController.configurePin(12, "pwm", "none")

// Set servo frequency (50Hz standard)
gpioController.setPWMFrequency(12, 50)

// Move to center position (90°)
// 90° = 1.5ms pulse = 7.5% duty cycle at 50Hz
gpioController.setPWMDutyCycle(12, 7.5)

// Move to 0° position
gpioController.setPWMDutyCycle(12, 5.0)

// Move to 180° position
gpioController.setPWMDutyCycle(12, 10.0)
```

### Sensor Reading with Auto-Update

```qml
Component.onCompleted: {
    // Start reading DHT sensor every 2 seconds
    sensorController.startAutoRead(2000)
}

Connections {
    target: sensorController
    onSensorDataUpdated: (jsonData) => {
        var data = JSON.parse(jsonData)
        if (data.status === "ok") {
            temperatureText.text = data.temperature.toFixed(1) + "°C"
            humidityText.text = data.humidity.toFixed(1) + "%"
        } else {
            statusText.text = "Sensor error: " + data.error
        }
    }
}
```

---

**Last Updated:** 2026-01-07
**Owner:** API Development Team
**Review Cycle:** On API changes or major versions
