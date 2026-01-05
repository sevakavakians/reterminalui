# reTerminal GPIO Control UI - Project Overview

**Created**: 2026-01-05
**Status**: Active Development
**Phase**: Initial Planning Complete

## Project Vision

Transform the reTerminal (Seeed Studio Raspberry Pi CM4-based device) into a versatile electronic device probe with an intuitive touchscreen interface for GPIO control, signal monitoring, and time-series data visualization.

## Core Objectives

1. **GPIO Pin Management**: Configure and control all 26 usable GPIO pins with intuitive touch interface
2. **Signal Monitoring**: Real-time digital signal reading and visualization
3. **Time-Series Logging**: Capture and display multi-channel data streams over time
4. **Analog Support**: Integrate external ADC modules for analog input capabilities
5. **Probe Functionality**: Enable use as an electronics debugging/testing tool

## Target Use Cases

- Electronics prototyping and debugging
- Signal analysis and monitoring
- Data logging from sensors and circuits
- GPIO-based automation testing
- Educational electronics demonstrations

## Hardware Platform

### Device Specifications
- **Device**: Seeed Studio reTerminal
- **Processor**: Raspberry Pi Compute Module 4 (BCM2711, ARMv7l)
- **RAM**: 3.7 GB
- **Display**: 5" IPS capacitive touchscreen (720x1280)
- **Network**: Ethernet + WiFi (IP: 192.168.0.3)
- **OS**: Raspbian/Raspberry Pi OS (Linux 5.10.60)

### GPIO Capabilities
- **40-pin GPIO header** with **26 usable digital pins** (BCM numbering)
- **Voltage**: 3.3V logic level
- **Current Limits**: 16mA per pin safely, 50mA total
- **PWM Support**: Hardware PWM available
- **Interfaces**: I2C, SPI, UART, PWM

### Pin Restrictions
- **GPIO 6 (Pin 31)**: Reserved for USB hub (HUB_DM3)
- **GPIO 13 (Pin 33)**: Reserved for USB hub (HUB_DP3)
- **Usable GPIO BCM Numbers**: 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27

### Analog Input Strategy
- **Native**: Digital only (no analog GPIO)
- **Solution**: External ADC via I2C/SPI (e.g., ADS1115, MCP3008)
- **Built-in Sensors**: Light sensor (LTR-303ALS-01), Accelerometer (LIS3DHTR)

## Technology Stack

### Core Libraries
- **Python 3.7.3** - Primary development language
- **tkinter** - GUI framework (touch-optimized)
- **RPi.GPIO 0.7.0** - GPIO control (verified working)
- **gpiozero 1.6.2** - High-level GPIO abstraction
- **pigpio 1.78** - Hardware PWM and advanced features

### Supporting Libraries
- **spidev 3.5** - SPI communication for ADC modules
- **matplotlib** - Time-series data visualization
- **pandas** - Data logging and analysis
- **numpy** - Numerical operations

### Development Environment
- **Remote Development**: SSH access via `ssh -i ~/.ssh/reterminal_key pi@192.168.0.3`
- **Version Control**: Git repository at `/Users/sevakavakians/PROGRAMMING/reterminal`
- **Testing**: On-device execution with direct hardware access

## Architecture Principles

### UI Design
1. **Touch-First**: Large buttons, swipe gestures, minimal text entry
2. **Screen Optimization**: 720x1280 portrait layout
3. **Real-Time Updates**: Live signal monitoring with minimal latency
4. **Visual Feedback**: Clear state indication (input/output/PWM modes)

### Software Architecture
1. **Modular Design**: Separate GPIO control, UI, data logging, and visualization
2. **Extensibility**: Plugin architecture for external ADC modules
3. **Safety**: Pin conflict detection and current limit warnings
4. **Data Persistence**: Configuration save/load, logged data export

### Performance Targets
- **UI Responsiveness**: <100ms touch response
- **Sampling Rate**: Up to 1kHz for digital signals
- **ADC Sampling**: Hardware-dependent (ADS1115: ~860 SPS)
- **Data Display**: Real-time plotting with 60fps updates

## Project Phases

### Phase 1: Foundation (Current)
- [x] Hardware research and specification
- [x] SSH access and verification
- [x] GPIO control testing
- [x] Library identification
- [x] Project documentation setup

### Phase 2: Core GPIO UI (Next)
- [ ] UI framework and layout design
- [ ] Pin selection and configuration interface
- [ ] Digital input/output control panel
- [ ] Real-time pin state display
- [ ] PWM control interface

### Phase 3: Data Acquisition
- [ ] Time-series data logging backend
- [ ] Multi-channel data capture
- [ ] Data buffer and storage management
- [ ] Export functionality (CSV, JSON)

### Phase 4: Visualization
- [ ] Real-time plotting engine
- [ ] Multi-trace display
- [ ] Zoom and pan controls
- [ ] Trigger and capture modes

### Phase 5: Analog Integration
- [ ] External ADC module support (I2C/SPI)
- [ ] ADS1115 driver integration
- [ ] MCP3008 driver integration
- [ ] Unified analog/digital data handling

### Phase 6: Advanced Features
- [ ] Configuration profiles (save/load pin setups)
- [ ] Automated test sequences
- [ ] Data analysis tools (FFT, statistics)
- [ ] Network data streaming

## Key Decisions Log

### 2026-01-05: Initial Technology Choices
- **Decision**: Use tkinter for UI instead of PyQt/Kivy
- **Rationale**: Pre-installed, lightweight, sufficient for touch interface
- **Confidence**: Medium (may revisit if limitations emerge)

- **Decision**: Support multiple GPIO libraries (RPi.GPIO, gpiozero, pigpio)
- **Rationale**: Different libraries excel at different tasks (gpiozero for simplicity, pigpio for PWM)
- **Confidence**: High

- **Decision**: Modular ADC support rather than single implementation
- **Rationale**: Users may have different ADC hardware; plugin architecture provides flexibility
- **Confidence**: High

## Success Metrics

### Functional Requirements
- [ ] Configure all 26 usable GPIO pins
- [ ] Read/write digital signals reliably
- [ ] Log multi-channel data at 100Hz minimum
- [ ] Display real-time plots with <200ms latency
- [ ] Support at least one external ADC module

### User Experience
- [ ] Single-touch operation for common tasks
- [ ] Clear visual feedback for all pin states
- [ ] Intuitive navigation without documentation
- [ ] Stable operation for continuous 24-hour logging

### Technical Quality
- [ ] Zero GPIO pin conflicts or errors
- [ ] Graceful handling of hardware disconnection
- [ ] Clean shutdown without data loss
- [ ] Memory usage <500MB during normal operation

## Known Constraints

### Hardware Limitations
- No native analog input (requires external ADC)
- GPIO 6 and 13 unavailable (USB hub conflict)
- 3.3V logic only (no 5V tolerance)
- Current limits require careful load management

### Software Limitations
- Python 3.7.3 (older version, limited modern library support)
- tkinter touch support may be limited
- No GPU acceleration for plotting
- Single-core Python GIL may limit sampling rates

### Operational Constraints
- Network-dependent for remote development
- Physical access required for initial setup
- Power cycle requires physical intervention

## Risk Assessment

### High Risk
- **Touch performance**: tkinter may not provide smooth touch experience
  - *Mitigation*: Optimize UI, consider alternative frameworks if needed

### Medium Risk
- **Sampling rate limitations**: Python GIL may bottleneck high-speed acquisition
  - *Mitigation*: Use C extensions or hardware-timed sampling (pigpio)

- **Display performance**: Real-time plotting may lag with multiple traces
  - *Mitigation*: Optimize matplotlib, reduce update frequency, implement decimation

### Low Risk
- **GPIO reliability**: Well-established libraries and hardware
- **Data storage**: Ample storage available (25GB free)

## Future Expansion Possibilities

- Network remote control via web interface
- Waveform generation (DAC support)
- Protocol analyzers (I2C, SPI, UART decoding)
- Logic analyzer functionality
- Oscilloscope-style triggering
- Mobile app integration
- Cloud data logging

## References

- **Hardware Documentation**: `/Users/sevakavakians/PROGRAMMING/reterminal/RETERMINAL_INFO.md`
- **GPIO Pinout**: Standard Raspberry Pi 40-pin header
- **reTerminal Wiki**: https://wiki.seeedstudio.com/reTerminal/
- **RPi.GPIO Documentation**: https://sourceforge.net/projects/raspberry-gpio-python/
- **gpiozero Documentation**: https://gpiozero.readthedocs.io/
