# reTerminal Device Information

## Connection Details
- **IP Address**: 192.168.0.3
- **SSH Access**: `ssh -i ~/.ssh/reterminal_key pi@192.168.0.3`
- **Default User**: pi
- **Original Password**: raspberry (SSH key now configured)

## Hardware Specifications
- **Processor**: Raspberry Pi Compute Module 4 (BCM2711, ARMv7l)
- **RAM**: 3.7 GB
- **Storage**: 29 GB (25 GB available)
- **Display**: 5" IPS capacitive touchscreen (720x1280)
- **Kernel**: Linux 5.10.60-v7l+ #1449

## GPIO Capabilities

### Digital GPIO
- **40-pin header** with **26 usable GPIO pins**
- **BCM GPIO numbering**: 2-27 available
- **Current limit**: 50mA total across all pins, 16mA per pin safely
- **Voltage**: 3.3V logic level
- **Verified working**: Read/Write operations successful

### Pin Conflicts
- **GPIO 6 (Physical Pin 31)**: Used by USB hub (HUB_DM3)
- **GPIO 13 (Physical Pin 33)**: Used by USB hub (HUB_DP3)
- These pins should be avoided for GPIO use

### Interfaces Available
- **I2C**: Enabled (dtparam=i2c_arm=on)
- **SPI**: Available (spidev installed)
- **UART**: 5 UART interfaces available
- **PWM**: Available via pigpio library
- **PCM**: 1 interface
- **DPI**: Parallel RGB Display interface

### Analog Input
**IMPORTANT**: The Raspberry Pi GPIO pins are **digital only** (0V or 3.3V).

For analog input, you will need to use:
1. **External ADC via I2C/SPI** (e.g., ADS1115, MCP3008)
2. **PWM-based analog output** (for DAC simulation)

The reTerminal does include:
- Light sensor (LTR-303ALS-01) accessible via I2C
- Accelerometer (LIS3DHTR) accessible via I2C

## Python Libraries Installed
- **RPi.GPIO** 0.7.0 - Standard GPIO control ✓ Tested
- **gpiozero** 1.6.2 - High-level GPIO interface
- **pigpio** 1.78 - Hardware PWM and advanced features
- **spidev** 3.5 - SPI communication
- **tkinter** - GUI framework ✓ Available
- **Python** 3.7.3

## Device Tree Overlays
- reTerminal-specific overlay loaded
- I2C enabled on pins 4 & 5 (i2c3)
- Video: vc4-kms-v3d-pi4

## System Access Verified
- ✓ SSH connection established
- ✓ Read/write access confirmed
- ✓ GPIO control verified
- ✓ User 'pi' in 'gpio' group (hardware access enabled)

## Standard 40-Pin GPIO Pinout Reference
```
Pin Layout (Physical numbering):
        3.3V  [ 1] [ 2]  5V
   I2C1 SDA  [ 3] [ 4]  5V
   I2C1 SCL  [ 5] [ 6]  GND
      GPIO4  [ 7] [ 8]  GPIO14 (UART TX)
        GND  [ 9] [10]  GPIO15 (UART RX)
     GPIO17  [11] [12]  GPIO18 (PWM0)
     GPIO27  [13] [14]  GND
     GPIO22  [15] [16]  GPIO23
       3.3V  [17] [18]  GPIO24
 SPI0 MOSI  [19] [20]  GND
 SPI0 MISO  [21] [22]  GPIO25
 SPI0 SCLK  [23] [24]  SPI0 CE0
        GND  [25] [26]  SPI0 CE1
   I2C0 SDA  [27] [28]  I2C0 SCL
      GPIO5  [29] [30]  GND
      GPIO6* [31] [32]  GPIO12 (PWM0)
     GPIO13* [33] [34]  GND
     GPIO19  [35] [36]  GPIO16
     GPIO26  [37] [38]  GPIO20
        GND  [39] [40]  GPIO21

* Pins 31 and 33 (GPIO6, GPIO13) are used by USB hub
```

BCM GPIO numbers that are safe to use:
- 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27
- Avoid: 6, 13
