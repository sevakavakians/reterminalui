# reTerminal GPIO Pin Configuration Reference

## Hardware Overview

The reTerminal is based on the Raspberry Pi Compute Module 4 (CM4) and exposes a 40-pin GPIO header. Note that the GPIO header is mounted backwards on the reTerminal.

**Display:** 5-inch LCD touchscreen (1280x720)
**GPIO Numbering:** BCM (Broadcom) numbering used throughout
**Total GPIO Pins:** 28 (GPIO 0-27)

## Pin Classification

### Reserved Pins (4 pins) - DO NOT USE

These pins are actively used by reTerminal hardware and must not be configured:

| GPIO | Function | Hardware Usage |
|------|----------|----------------|
| 2 | I2C SDA | I2C bus for touchscreen, accelerometer, light sensor, RTC, crypto chip, IO expander |
| 3 | I2C SCL | I2C bus for touchscreen, accelerometer, light sensor, RTC, crypto chip, IO expander |
| 6 | USB Hub | HUB_DM3 - USB hub control |
| 13 | USB Hub | HUB_DP3 - USB hub control |

**Color in UI:** Red (#ff006e)
**Label in UI:** "RSVD"
**Clickable:** No

### Available Pins (24 pins) - SAFE TO USE

These pins are available for general GPIO usage:

```
GPIO: 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27
```

**Color in UI:** Cyan (#00f3ff)
**Clickable:** Yes
**Modes:** INPUT (with pull-up/down/none) or OUTPUT

### Caution Pins - USE WITH CARE

The following pins can be used but may conflict with certain system functions:

| GPIO | Function | Notes |
|------|----------|-------|
| 0, 1 | ID EEPROM | Used for HAT identification EEPROM. Can be used if no HAT EEPROM is present. |
| 14, 15 | UART TX/RX | Used for serial console if enabled in boot config. Safe if console is disabled. |

**Current Status:** Included in available pins (14, 15 are in the available list)
**Recommendation:** Test thoroughly if using GPIO 0, 1, 14, or 15

## I2C Bus Details (GPIO 2, 3)

The I2C bus on GPIO 2 and 3 connects to multiple internal reTerminal components:

- **Touchscreen Controller:** Capacitive touch input
- **LIS3DHTR Accelerometer:** Motion sensing (0x19)
- **Light Sensor:** Ambient light detection
- **RTC (Real-Time Clock):** Battery-backed clock
- **ATECC608 Crypto Chip:** Hardware cryptography
- **STM32 IO Expander:** Additional I/O control

**Critical:** Never configure GPIO 2 or 3 as GPIO pins - this will break the touchscreen and sensors.

## Physical Header Pinout

The 40-pin header is mounted backwards. When looking at the reTerminal from the front with the screen facing you:
- Physical pins 1-2 are on the LEFT side
- Physical pins 39-40 are on the RIGHT side

### Power Pins
- 3.3V: Physical pins 1, 17
- 5V: Physical pins 2, 4
- Ground: Physical pins 6, 9, 14, 20, 25, 30, 34, 39

### GPIO to Physical Pin Mapping (Selected)

| GPIO | Physical Pin | Notes |
|------|--------------|-------|
| 2 | 3 | I2C SDA - RESERVED |
| 3 | 5 | I2C SCL - RESERVED |
| 4 | 7 | AVAILABLE |
| 5 | 29 | AVAILABLE |
| 6 | 31 | USB Hub - RESERVED |
| 7 | 26 | AVAILABLE |
| 8 | 24 | AVAILABLE (SPI CE0) |
| 9 | 21 | AVAILABLE (SPI MISO) |
| 10 | 19 | AVAILABLE (SPI MOSI) |
| 11 | 23 | AVAILABLE (SPI CLK) |
| 12 | 32 | AVAILABLE (PWM0) |
| 13 | 33 | USB Hub - RESERVED |
| 14 | 8 | AVAILABLE (UART TX) |
| 15 | 10 | AVAILABLE (UART RX) |
| 16 | 36 | AVAILABLE |
| 17 | 11 | AVAILABLE |
| 18 | 12 | AVAILABLE (PWM0) |
| 19 | 35 | AVAILABLE (PWM1) |
| 20 | 38 | AVAILABLE |
| 21 | 40 | AVAILABLE |
| 22 | 15 | AVAILABLE |
| 23 | 16 | AVAILABLE |
| 24 | 18 | AVAILABLE |
| 25 | 22 | AVAILABLE |
| 26 | 37 | AVAILABLE |
| 27 | 13 | AVAILABLE |

## Implementation Details

### GPIOController.py Configuration

```python
# Reserved pins (used by reTerminal hardware)
# GPIO 2, 3: I2C bus (touchscreen, accelerometer, light sensor, RTC, crypto chip, IO expander)
# GPIO 6: USB hub (HUB_DM3)
# GPIO 13: USB hub (HUB_DP3)
self._reserved_pins = [2, 3, 6, 13]

# Available GPIO pins on Raspberry Pi (BCM numbering)
# Note: GPIO 0, 1 (ID EEPROM), GPIO 14, 15 (UART) can be used with caution
self._available_pins = [4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]
```

### GPIOScreen.qml Configuration

```qml
property var reservedPins: [2, 3, 6, 13]
```

## Pin Modes

### INPUT Mode
- **Pull Resistor Options:**
  - `none`: No pull resistor (floating)
  - `up`: Pull-up resistor (~50kΩ to 3.3V)
  - `down`: Pull-down resistor (~50kΩ to GND)
- **Value:** 0 (LOW) or 1 (HIGH)
- **Use Cases:** Reading button states, sensor outputs, detecting external signals

### OUTPUT Mode
- **Pull Resistor:** Not applicable
- **Value:** 0 (LOW, ~0V) or 1 (HIGH, ~3.3V)
- **Current Limit:** ~16mA per pin (use transistor/relay for higher current)
- **Use Cases:** Controlling LEDs, triggering relays, signaling to external devices

## Special Function Pins

Some GPIO pins have alternate functions when enabled:

| GPIO | Alt Function | Notes |
|------|--------------|-------|
| 8, 9, 10, 11 | SPI0 | Hardware SPI bus |
| 12, 18 | PWM0 | Hardware PWM channel 0 |
| 13, 19 | PWM1 | Hardware PWM channel 1 |
| 14, 15 | UART | Hardware serial (console if enabled) |

**Note:** When using GPIO mode, these alternate functions are disabled for that pin.

## Voltage Levels

- **Logic High:** 3.3V
- **Logic Low:** 0V
- **Absolute Maximum Input:** 3.6V (do not exceed!)
- **5V Tolerant:** NO - Do not connect 5V signals directly

## Current Limits

- **Per Pin:** ~16mA source/sink
- **Total GPIO Current:** 50mA maximum across all pins
- **Recommendation:** Use external drivers (transistors, MOSFETs, relays) for loads > 10mA

## Testing Recommendations

When testing GPIO on the reTerminal:

1. Start with low-risk pins (17, 22, 23, 24, 25, 27)
2. Use current-limiting resistors (220Ω-1kΩ) with LEDs
3. Avoid GPIO 2, 3, 6, 13 entirely
4. Test GPIO 0, 1, 14, 15 last and verify no conflicts

## Common Issues

### Touchscreen Stops Working
- **Cause:** GPIO 2 or 3 was configured as GPIO
- **Fix:** Never configure these pins; reboot to restore I2C

### Pin Not Responding
- **Cause:** May be used by other hardware
- **Fix:** Check physical pinout, verify no external conflicts

### Permission Errors
- **Cause:** GPIO requires root access
- **Fix:** Run application with sudo or configure GPIO permissions

## Document Version

- **Created:** 2026-01-07
- **Last Updated:** 2026-01-07
- **reTerminal Model:** CM4 based
- **Application:** Qt5 GPIO Control v1.0

## References

- Raspberry Pi GPIO Documentation: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html
- reTerminal Wiki: https://wiki.seeedstudio.com/reTerminal/
- BCM2711 Datasheet (CM4): Broadcom BCM2711 ARM Peripherals
