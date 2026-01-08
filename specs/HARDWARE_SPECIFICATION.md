# reTerminal GPIO Control System - Hardware Specification

**Version:** 1.0.0  
**Last Updated:** 2026-01-07

## Supported Hardware

**Primary Platform:** Seeed Studio reTerminal  
- **SoC:** Raspberry Pi Compute Module 4 (CM4)
- **Processor:** Broadcom BCM2711, Quad-core Cortex-A72 @ 1.5GHz
- **RAM:** 4GB LPDDR4
- **Storage:** 32GB eMMC
- **Display:** 5-inch IPS, 720x1280 pixels, capacitive touch
- **GPIO:** 40-pin header (Raspberry Pi compatible)

## GPIO Pinout (BCM Numbering)

### Available GPIO Pins (0-27)

| GPIO | Function | PWM | Notes |
|------|----------|-----|-------|
| 0 | General I/O | No | ID_SD (I2C ID EEPROM) |
| 1 | General I/O | No | ID_SC (I2C ID EEPROM) |
| 2 | **RESERVED** | No | **I2C1 SDA (OLED, Accelerometer)** |
| 3 | **RESERVED** | No | **I2C1 SCL (OLED, Accelerometer)** |
| 4 | General I/O | No | Common for DHT sensors |
| 5 | General I/O | No | |
| 6 | **RESERVED** | No | **OLED Display** |
| 7 | General I/O | No | |
| 8 | General I/O | No | |
| 9 | General I/O | No | |
| 10 | General I/O | No | |
| 11 | General I/O | No | |
| 12 | General I/O | **HW PWM0** | **Hardware PWM Channel 0** |
| 13 | **RESERVED** | HW PWM1 | **USB Hub Control (Do Not Use)** |
| 14 | General I/O | No | UART TX |
| 15 | General I/O | No | UART RX |
| 16 | General I/O | No | |
| 17 | General I/O | No | |
| 18 | General I/O | **HW PWM0** | **Hardware PWM Channel 0** |
| 19 | General I/O | **HW PWM1** | **Hardware PWM Channel 1** |
| 20 | General I/O | No | |
| 21 | General I/O | No | |
| 22 | General I/O | No | |
| 23 | General I/O | No | |
| 24 | General I/O | No | |
| 25 | General I/O | No | |
| 26 | General I/O | No | |
| 27 | General I/O | No | |

### Reserved Pins (Do Not Configure)

**GPIO 2, 3:** I2C bus for OLED display and accelerometer  
**GPIO 6:** OLED display control  
**GPIO 13:** USB hub enable (critical system function)

## PWM Specifications

### Hardware PWM (BCM2711)

**Channels:**
- **PWM0:** GPIO 12, 18 (shared channel - must use same frequency)
- **PWM1:** GPIO 19 (independent channel)

**Characteristics:**
- Frequency range: 0.1 Hz - 100 kHz (practical)
- Duty cycle: 0% - 100% (0.1% resolution)
- Timing accuracy: ±0.1% (hardware-controlled)
- CPU overhead: None (DMA-driven)
- Jitter: <1μs

**Use Cases:**
- Servo motor control (50Hz, 5-10% duty cycle)
- Motor speed control (20-100Hz)
- Audio generation (100Hz - 20kHz)
- Precise LED dimming (1-10kHz)

### Software PWM (RPi.GPIO)

**Available on:** All GPIO pins except reserved

**Characteristics:**
- Frequency range: 1 Hz - 10 kHz (recommended: 1-1kHz)
- Duty cycle: 0% - 100%
- Timing accuracy: ±5-10% (OS scheduling dependent)
- CPU overhead: Moderate (1-3% per active pin)
- Jitter: 100μs - 1ms

**Use Cases:**
- LED dimming (100-1000Hz)
- Simple fan control (25-100Hz)
- Non-critical timing applications

**Limitations:**
- Not suitable for servo motors (jitter causes position drift)
- Accuracy degrades under CPU load
- Multiple software PWM pins increase jitter

## Electrical Specifications

### GPIO Pin Specifications (BCM2711)

- **Logic Levels:** 3.3V (NOT 5V tolerant)
- **Input HIGH:** >2.0V
- **Input LOW:** <0.8V
- **Output HIGH:** 3.3V
- **Output LOW:** 0V
- **Max Current (source/sink):** 16mA per pin
- **Max Total GPIO Current:** 50mA (all pins combined)

### Power Supply

- **3.3V Rail:** 500mA maximum (shared with peripherals)
- **5V Rail:** 3A maximum (from USB-C power)
- **Recommended Power Supply:** 5V 3A USB-C

### Safety Warnings

⚠️ **CRITICAL WARNINGS:**

1. **Never connect 5V signals** to GPIO pins (will damage CM4)
2. **Do not exceed 16mA** per pin (use transistors for higher loads)
3. **Never power servos** from GPIO 3.3V/5V rails (use external power supply)
4. **Always use common ground** when interfacing external circuits
5. **ESD sensitive:** Use proper grounding and anti-static precautions

## Sensor Specifications

### DHT11/DHT22 Temperature & Humidity

**Connector:** Single GPIO data pin + VCC (3.3V) + GND

**DHT11:**
- Temperature: 0-50°C, ±2°C accuracy
- Humidity: 20-80% RH, ±5% accuracy
- Sampling: Max 1Hz

**DHT22/AM2302:**
- Temperature: -40-80°C, ±0.5°C accuracy
- Humidity: 0-100% RH, ±2-5% accuracy
- Sampling: Max 0.5Hz

**Typical Connections:**
- Data: GPIO 4 (configurable)
- VCC: 3.3V
- GND: Ground
- Pull-up resistor: 4.7kΩ (often built-in)

### BME280 Environmental Sensor

**Interface:** I2C (GPIO 2/3 - uses system I2C bus)

**Specifications:**
- Temperature: -40-85°C, ±1°C accuracy
- Humidity: 0-100% RH, ±3% accuracy
- Pressure: 300-1100 hPa, ±1 hPa accuracy
- I2C Address: 0x76 or 0x77 (configurable)

**Connection:**
- SDA: GPIO 2 (system I2C)
- SCL: GPIO 3 (system I2C)
- VCC: 3.3V
- GND: Ground

## Servo Motor Specifications

### Standard Hobby Servos (Recommended)

**Examples:** SG90, MG90S, MG996R, HS-311

**Electrical:**
- Voltage: 4.8V - 6V (use external power supply)
- Current: 100mA - 2A (varies by model and load)
- Control Signal: 3.3V PWM (compatible with GPIO)

**PWM Requirements:**
- Frequency: 50Hz (20ms period) **REQUIRED**
- Pulse Width: 1.0ms - 2.0ms
- Duty Cycle: 5% - 10%
  - 5% (1.0ms) = 0° position
  - 7.5% (1.5ms) = 90° position (center)
  - 10% (2.0ms) = 180° position

**GPIO Pins:** Use GPIO 12, 18, or 19 (Hardware PWM only)

**Wiring:**
```
Servo Wire          Connect To
────────────────────────────────────────────
Signal (Orange)  →  GPIO 12/18/19 (PWM)
Power (Red)      →  External 5-6V Supply (+)
Ground (Brown)   →  Common Ground (-)
                    (reTerminal GND + Supply GND)
```

⚠️ **DO NOT power servos from reTerminal's 5V pin** (will brown-out the system)

## Physical Buttons

### reTerminal Built-in Buttons

- **Location:** Front panel, below display
- **Count:** 3 buttons (F1, F2, F3)
- **Interface:** Event-driven input device (`/dev/input/eventX`)
- **Debouncing:** Hardware-level (no software debouncing needed)

**Button Mapping:**
- **F1 (Left):** Switch to GPIO Screen
- **F2 (Middle):** Reserved for future use
- **F3 (Right):** Switch to Sensor Screen

## Display Specifications

- **Size:** 5 inches diagonal
- **Resolution:** 720x1280 pixels (WXGA)
- **Orientation:** Portrait (default), can be rotated
- **Type:** IPS LCD
- **Touch:** Capacitive, multi-touch (10 points)
- **Connector:** MIPI DSI
- **Backlight:** PWM-controlled (adjustable brightness)

## System Requirements

### Software Requirements

- **OS:** Raspberry Pi OS (32-bit or 64-bit)
  - Tested: Buster (10), Bullseye (11)
- **Kernel:** 5.4+ (for GPIO character device support)
- **Python:** 3.7+ (system Python)
- **Qt:** 5.11+ with QtQuick 2.9

### Minimum System Resources

- **RAM:** 512MB free (application uses ~100MB)
- **Storage:** 50MB for application + dependencies
- **CPU:** 10-20% average load (1 core)

---

**Owner:** Hardware Team  
**Review Cycle:** On hardware changes or new platform support
