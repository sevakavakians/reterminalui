# Servo Motor Control Guide - reTerminal GPIO

This guide explains how to control servo motors using PWM (Pulse Width Modulation) on the reTerminal GPIO application.

## Overview

Servo motors require precise PWM signals to control their position. The reTerminal's hardware PWM channels provide the timing accuracy needed for reliable servo control.

## Pin Selection

### Recommended Pins (Hardware PWM Only)

**Always use hardware PWM pins for servo control.** Software PWM will cause jitter and unreliable positioning.

| GPIO Pin | PWM Channel | Notes |
|----------|-------------|-------|
| **GPIO 12** | Channel 0 | **Recommended** - Independent use |
| **GPIO 18** | Channel 0 | Shares frequency with GPIO 12 |
| **GPIO 19** | Channel 1 | **Recommended** - Independent frequency control |

### Why Hardware PWM?

- **Precise timing**: Hardware-controlled, no CPU jitter
- **No overhead**: Doesn't consume CPU cycles
- **Reliable**: Critical for servo positioning accuracy
- **Industry standard**: Required for professional servo applications

**Visual Indicator**: Hardware PWM pins (12, 18, 19) are highlighted with an **orange border** (#ffa500) in the GPIO pin grid.

## PWM Settings for Servos

### Standard Servo Specifications

Most hobby servos follow these industry standards:

**Frequency**: **50 Hz** (20ms period)
- This is the standard PWM frequency for hobby servos
- Do not change this value for standard servos

**Duty Cycle Range**: **5% to 10%**
- Controls the pulse width from 1ms to 2ms
- Pulse width determines servo position

### Duty Cycle to Position Mapping

| Servo Position | Duty Cycle | Pulse Width | Angle |
|----------------|------------|-------------|-------|
| Minimum        | 5.0%       | 1.0ms       | 0°    |
| Quarter        | 6.25%      | 1.25ms      | 45°   |
| **Center**     | **7.5%**   | **1.5ms**   | **90°** |
| Three-quarter  | 8.75%      | 1.75ms      | 135°  |
| Maximum        | 10.0%      | 2.0ms       | 180°  |

### Calculating Duty Cycle

```
Duty Cycle (%) = (Pulse Width in ms / 20ms) × 100

Examples:
- 1.0ms pulse = (1.0 / 20) × 100 = 5.0%
- 1.5ms pulse = (1.5 / 20) × 100 = 7.5%
- 2.0ms pulse = (2.0 / 20) × 100 = 10.0%
```

## Step-by-Step Configuration

### 1. Select Hardware PWM Pin

In the GPIO screen:
1. Click on **GPIO 12**, **18**, or **19** (orange-bordered pins)
2. Verify the "HW PWM" label appears on the pin

### 2. Configure for PWM Mode

In the configuration dialog:
1. Click the **"PWM"** mode button (orange color)
2. Click **"ADD PIN"**

### 3. Set Servo Parameters

In the Pin Control Panel:
1. Verify the **"⚡ HARDWARE PWM"** indicator appears
2. **Set Frequency to 50Hz**:
   - Click the **"50Hz"** preset button
   - Verify "Current: 50.0 Hz" appears below
3. **Set Initial Position to Center (7.5%)**:
   - Drag the duty cycle slider to 7.5%
   - The servo should move to its center position (90°)

### 4. Control Servo Position

Adjust the duty cycle slider between **5% and 10%**:
- **Left (5%)** = 0° position
- **Center (7.5%)** = 90° position (neutral)
- **Right (10%)** = 180° position

## Wiring Diagram

### Power Supply Configuration

```
                    ┌─────────────────┐
                    │   reTerminal    │
                    │                 │
                    │  GPIO 12 ●──────┼─── Signal (Orange/Yellow wire)
                    │                 │
                    │     GND  ●──────┼─┐
                    └─────────────────┘ │
                                        │
    ┌───────────────────────────────────┼─── Ground (Brown/Black wire)
    │                                   │
    │  ┌──────────────────┐             │         ┌─────────┐
    │  │ External 5-6V    │             │         │  Servo  │
    │  │ Power Supply     │             │         │  Motor  │
    │  │                  │             │         │         │
    └──┤ GND       +5V/6V ├─────────────┴─────────┤ Power   │
       └──────────────────┘                       │ (Red)   │
                                                  └─────────┘
```

### Connection Details

| Servo Wire | Connect To | Notes |
|------------|-----------|-------|
| **Signal** (Orange/Yellow/White) | GPIO 12, 18, or 19 | PWM control signal (3.3V logic) |
| **Power** (Red) | External 5V or 6V supply | **DO NOT** connect to reTerminal 3.3V or 5V pins |
| **Ground** (Brown/Black) | Common ground | Connect both reTerminal GND and power supply GND |

## Safety Warnings

### ⚠️ Critical Safety Information

1. **External Power Required**
   - Servos draw significant current (100mA - 2A under load)
   - **NEVER** power servos from reTerminal's GPIO 3.3V or 5V pins
   - Use external 5V or 6V power supply rated for servo current draw
   - **Common ground is essential** - connect GND from both reTerminal and power supply

2. **Duty Cycle Limits**
   - **Never exceed 10% duty cycle** at 50Hz (2ms pulse width)
   - Exceeding limits can damage servo mechanics
   - Some servos may have narrower ranges (check datasheet)

3. **Hardware PWM Required**
   - **DO NOT** use software PWM (other GPIO pins) for servos
   - Software PWM causes jitter and mechanical stress
   - Only GPIO 12, 18, 19 are suitable for servo control

4. **Shared Frequency Constraint**
   - GPIO 12 and 18 share PWM Channel 0
   - They **must** use the same frequency (both 50Hz for servos)
   - GPIO 19 is on Channel 1 (independent frequency)

## Testing Your Servo

### Initial Test Procedure

1. **Setup**:
   - Connect servo with external power supply
   - Configure GPIO 12 as PWM at 50Hz
   - Set duty cycle to 7.5% (center position)

2. **Center Position Test**:
   - Servo should move to mechanical center (90°)
   - Should hold position firmly
   - No jittering or oscillation

3. **Range Test**:
   - Slowly adjust duty cycle from 7.5% to 5%
   - Servo should smoothly move to 0° position
   - Slowly adjust duty cycle from 7.5% to 10%
   - Servo should smoothly move to 180° position

4. **Response Test**:
   - Move slider quickly between positions
   - Servo should respond immediately
   - Movement should be smooth without jerking

### Troubleshooting

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| Servo jitters/shakes | Using software PWM | Switch to GPIO 12, 18, or 19 (hardware PWM) |
| No movement | Wrong frequency | Set to 50Hz |
| Limited range | Duty cycle too narrow | Adjust between 5-10% |
| Erratic behavior | Insufficient power | Check external power supply capacity |
| No response | Wrong wiring | Verify signal wire to GPIO pin |
| Servo buzzes | Position unreachable | Reduce duty cycle range |

## Common Servo Types

### Standard Hobby Servos

**Examples**: SG90, MG996R, HS-311
- **Frequency**: 50Hz
- **Range**: 5-10% duty cycle (1-2ms)
- **Voltage**: 4.8V - 6V
- **Use Case**: Robotics, RC vehicles, pan/tilt mechanisms

### Continuous Rotation Servos

**Examples**: FS90R, SpringRC SM-S4303R
- **Frequency**: 50Hz
- **Behavior**:
  - 5% = Full speed counterclockwise
  - 7.5% = Stop
  - 10% = Full speed clockwise
- **Voltage**: 4.8V - 6V
- **Use Case**: Wheeled robots, conveyor systems

### High-Precision Servos

**Examples**: Digital servos, high-torque servos
- May support higher frequencies (200-300Hz)
- Check manufacturer specifications
- Hardware PWM still required

## Advanced Configuration

### Multiple Servos

**Using GPIO 12 and 18** (same frequency):
```
GPIO 12 → Servo 1 (50Hz, 5-10% range)
GPIO 18 → Servo 2 (50Hz, 5-10% range)
Both servos can have different positions (duty cycles)
```

**Using GPIO 12 and 19** (independent):
```
GPIO 12 → Standard Servo (50Hz, 5-10% range)
GPIO 19 → Digital Servo (200Hz, different range)
Completely independent control
```

### Servo Speed Control

Standard servos don't have speed control - they move to position as fast as possible. To control speed:
1. Read current duty cycle
2. Calculate small incremental steps
3. Update duty cycle gradually over time
4. Requires external timing logic (not built into UI)

## Example Applications

### Pan-Tilt Camera Mount

```
GPIO 12 → Pan servo (horizontal rotation)
  - 5% = Far left
  - 7.5% = Center
  - 10% = Far right

GPIO 19 → Tilt servo (vertical rotation)
  - 5% = Down
  - 7.5% = Level
  - 10% = Up
```

### Robotic Arm Joint

```
GPIO 12 → Base rotation
GPIO 18 → Shoulder joint
GPIO 19 → Elbow joint (if using digital servo with different freq)
```

### Door Lock Mechanism

```
GPIO 12 → Lock servo
  - 5% = Locked position
  - 10% = Unlocked position
```

## Reference Resources

### PWM Theory
- **Period (T)**: 1/Frequency = 1/50Hz = 20ms
- **Pulse Width**: Duty Cycle × Period
- **Example**: 7.5% × 20ms = 1.5ms pulse

### Hardware PWM Channels (BCM2711)
- **PWM0**: GPIO 12, 18 (shared frequency)
- **PWM1**: GPIO 13 (RESERVED - USB hub), 19

### reTerminal GPIO Constraints
- GPIO 2, 3 (I2C - reserved)
- GPIO 6 (OLED - reserved)
- GPIO 13 (USB hub - reserved)
- Total available hardware PWM: GPIO 12, 18, 19

## Quick Reference Card

```
╔══════════════════════════════════════════════════════════╗
║  SERVO CONTROL QUICK REFERENCE - reTerminal GPIO         ║
╠══════════════════════════════════════════════════════════╣
║  PINS:        GPIO 12, 18, or 19 (Hardware PWM only)     ║
║  FREQUENCY:   50 Hz (standard servos)                    ║
║  DUTY CYCLE:  5% to 10%                                  ║
║                                                          ║
║  POSITIONS:                                              ║
║    5.0%  (1.0ms) = 0°   (minimum)                       ║
║    7.5%  (1.5ms) = 90°  (center)                        ║
║    10.0% (2.0ms) = 180° (maximum)                       ║
║                                                          ║
║  POWER:       External 5-6V supply (NOT from GPIO!)      ║
║  GROUND:      Common ground (reTerminal + supply)        ║
║                                                          ║
║  WARNING:     Never exceed 10% duty cycle at 50Hz        ║
╚══════════════════════════════════════════════════════════╝
```

## Revision History

- **2026-01-07**: Initial guide created with PWM implementation
  - Hardware PWM support for GPIO 12, 18, 19
  - 50Hz frequency preset for servo control
  - Duty cycle slider (0-100% range, use 5-10% for servos)
  - Hardware PWM visual indicators in UI
