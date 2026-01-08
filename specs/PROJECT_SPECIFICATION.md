# reTerminal GPIO Control System - Project Specification

**Version:** 1.0.0
**Last Updated:** 2026-01-07
**Status:** Active Development

## Executive Summary

The reTerminal GPIO Control System is a native Qt5/QML application designed for the Seeed Studio reTerminal, providing comprehensive GPIO control, PWM management, and servo motor control through an optimized touchscreen interface. The system enables industrial-grade hardware interaction for IoT, robotics, and embedded systems applications.

## Project Goals

### Primary Objectives

1. **Native Touchscreen Interface**
   - Provide an intuitive, kiosk-mode Qt5/QML application
   - Optimize for 720x1280 portrait touchscreen
   - Ensure all controls fit on screen without scrolling
   - Support touch-friendly UI elements (minimum 40px touch targets)

2. **Comprehensive GPIO Control**
   - Support all available GPIO pins (0-27) on Raspberry Pi CM4
   - Enable input/output modes with configurable pull resistors
   - Real-time pin value monitoring and control
   - Visual status indicators for all configured pins

3. **Professional PWM Management**
   - Hardware PWM on GPIO 12, 18, 19 (BCM2711 hardware channels)
   - Software PWM on all other available pins
   - Frequency range: 0.1 Hz to 100 kHz
   - Duty cycle control: 0% to 100%
   - Visual distinction between hardware and software PWM

4. **Servo Motor Control**
   - Dedicated servo control interface for 50Hz PWM
   - Position presets (0°, 45°, 90°, 135°, 180°)
   - Directional rotation with adjustable step sizes
   - Real-time angle display and feedback
   - Support for standard hobby servos (SG90, MG996R, etc.)

5. **Sensor Integration**
   - DHT11/DHT22 temperature and humidity monitoring
   - BME280 environmental sensor support
   - Real-time data visualization
   - Historical data graphing

6. **System Integration**
   - Physical button navigation (GPIO screen ↔ Sensor screen)
   - Systemd service for auto-start on boot
   - Graceful GPIO cleanup on shutdown
   - Robust error handling and recovery

### Secondary Objectives

1. **Development Efficiency**
   - Well-documented codebase with inline comments
   - Comprehensive specification documents
   - Clear separation of concerns (MVC pattern)
   - Reusable components and controllers

2. **Maintainability**
   - Version control with Git/GitHub
   - Structured project organization
   - Comprehensive documentation
   - Testing procedures and validation

3. **Extensibility**
   - Modular architecture for easy feature addition
   - Well-defined API contracts
   - Plugin-ready sensor controller
   - Future-proof design patterns

## Project Scope

### In Scope

**Core Features:**
- GPIO pin configuration and control (input/output)
- Hardware and software PWM generation
- Servo motor control interface
- Sensor data acquisition and display
- Physical button integration
- Touchscreen UI optimized for reTerminal
- Systemd service configuration
- Auto-start on boot

**Hardware Support:**
- Seeed Studio reTerminal (Raspberry Pi CM4-based)
- BCM2711 SoC GPIO (28 pins: GPIO 0-27)
- Hardware PWM channels (PWM0: GPIO 12, 18; PWM1: GPIO 19)
- DHT11/DHT22 temperature/humidity sensors
- BME280 environmental sensor
- Standard hobby servo motors (50Hz PWM)

**Documentation:**
- Technical specifications
- API documentation
- User guides (servo control, PWM usage)
- Hardware pinout reference
- Deployment procedures
- Development guidelines

### Out of Scope

**Excluded Features:**
- Web-based interface (legacy, deprecated)
- Remote network control (may be added in future)
- Multi-user authentication
- Database persistence
- Over-the-air (OTA) updates
- Custom PWM waveform generation
- Advanced servo types (digital servos, brushless motors)
- CAN bus or industrial protocols
- Cloud integration

**Unsupported Hardware:**
- Non-reTerminal Raspberry Pi boards (without testing)
- Non-standard GPIO expanders
- High-voltage GPIO (>3.3V)
- AC control circuits
- Industrial motor controllers

## Success Criteria

### Technical Criteria

1. **Performance**
   - Application startup time < 5 seconds
   - GPIO read/write latency < 10ms
   - Hardware PWM frequency accuracy ±1%
   - Software PWM frequency accuracy ±5% (depends on CPU load)
   - UI responsiveness < 100ms for touch interactions

2. **Reliability**
   - Zero GPIO state corruption during normal operation
   - Graceful handling of all hardware errors
   - 99.9% uptime during continuous operation
   - Successful recovery from sensor disconnection
   - No memory leaks over 24-hour operation

3. **Compatibility**
   - Works on reTerminal (CM4, 4GB RAM, 32GB eMMC)
   - Compatible with Raspberry Pi OS Buster/Bullseye
   - Python 3.7+ support
   - Qt 5.11+ (QtQuick 2.9+)

### Functional Criteria

1. **GPIO Control**
   - All available GPIO pins (excluding reserved pins) configurable
   - Real-time input value monitoring
   - Output pin toggling with visual feedback
   - Pull resistor configuration (none, up, down)

2. **PWM Functionality**
   - Hardware PWM: 0.1 Hz - 100 kHz, accurate timing
   - Software PWM: 1 Hz - 1 kHz, acceptable jitter
   - Duty cycle adjustable to 0.1% precision
   - Visual differentiation of PWM types

3. **Servo Control**
   - 50Hz frequency lock for standard servos
   - 0-180° position control
   - Step-based rotation (1°, 5°, 10°, 15°, 30°)
   - Position presets for common angles
   - Real-time angle display

4. **Sensor Monitoring**
   - DHT11/DHT22: Temperature ±2°C, Humidity ±5%
   - BME280: Temperature ±1°C, Humidity ±3%, Pressure ±1 hPa
   - Update rate: 1-5 seconds per reading
   - Graph display with 60-second history

### User Experience Criteria

1. **Usability**
   - Intuitive pin selection (visual pin grid)
   - Clear visual feedback for all actions
   - Large, readable text (32-52px for buttons and values)
   - Color-coded status indicators
   - No hidden controls or overflow issues

2. **Documentation**
   - Complete technical specifications
   - Step-by-step servo control guide
   - PWM usage examples
   - Hardware safety warnings
   - Troubleshooting guides

## Target Audience

### Primary Users

1. **Embedded Systems Engineers**
   - Prototyping GPIO-based systems
   - Testing hardware interfacing
   - Developing IoT applications
   - Motor control experimentation

2. **Robotics Developers**
   - Servo motor testing and calibration
   - Multi-servo coordination
   - Sensor integration validation
   - Robot control systems

3. **Industrial Automation Technicians**
   - PLC replacement prototypes
   - Sensor validation
   - Actuator testing
   - Process control development

### Secondary Users

1. **Educators and Students**
   - Teaching embedded systems
   - GPIO and PWM demonstrations
   - Robotics coursework
   - Hands-on hardware labs

2. **Makers and Hobbyists**
   - Home automation projects
   - DIY robotics
   - Sensor monitoring setups
   - Hardware experimentation

## Technical Stack

### Frontend (Qt5/QML)

- **Framework:** Qt 5.11+ with QtQuick 2.9
- **Language:** QML (declarative UI)
- **Display:** 720x1280 touchscreen, portrait orientation
- **Input:** Capacitive touch, physical buttons

### Backend (Python)

- **Language:** Python 3.7+
- **Framework:** PySide2 (Qt for Python)
- **GPIO Library:** RPi.GPIO (BCM2711 support)
- **Sensor Libraries:** Adafruit_DHT, bme280

### System Integration

- **Operating System:** Raspberry Pi OS (Buster/Bullseye)
- **Init System:** systemd
- **Service Management:** reterminal-gpio.service
- **Display Server:** X11 (DISPLAY=:0)

### Development Tools

- **Version Control:** Git, GitHub
- **IDE:** Any Python/QML editor
- **Deployment:** SSH, systemd
- **Documentation:** Markdown

## Key Constraints

### Hardware Constraints

1. **GPIO Limitations**
   - Maximum current per pin: 16mA
   - Maximum total GPIO current: 50mA
   - Voltage levels: 3.3V logic only
   - Reserved pins: GPIO 2, 3 (I2C), GPIO 6 (OLED), GPIO 13 (USB hub)

2. **PWM Limitations**
   - Hardware PWM shares channels (GPIO 12/18 share PWM0)
   - Software PWM subject to CPU scheduling jitter
   - Maximum reliable software PWM frequency: ~1 kHz

3. **Touchscreen Constraints**
   - Fixed resolution: 720x1280 pixels
   - No scrolling support in kiosk mode
   - All UI must fit within viewport

### Software Constraints

1. **Python Version**
   - Minimum: Python 3.7 (reTerminal ships with 3.7)
   - RPi.GPIO library compatibility
   - PySide2 availability

2. **Memory**
   - Target: < 100MB RAM usage
   - No persistent data storage
   - Minimal caching

3. **Performance**
   - GPIO polling rate: 10 Hz max
   - Sensor reading rate: 0.2-1 Hz
   - UI update rate: 30-60 FPS

### Operational Constraints

1. **Safety**
   - No high-voltage control without external relays
   - Servo power must be external (not from GPIO 5V/3.3V)
   - Common ground required for all external circuits

2. **Deployment**
   - Single reTerminal device
   - Local operation only (no network requirements)
   - Manual deployment via SSH/SCP

## Project Timeline

### Completed Milestones

✅ **Phase 1: Research and Planning** (Completed)
- Hardware research (reTerminal, GPIO, PWM)
- Architecture design
- Technology stack selection

✅ **Phase 2: Core GPIO Implementation** (Completed)
- GPIO controller backend
- Basic QML UI
- Pin configuration system

✅ **Phase 3: PWM Implementation** (Completed)
- Hardware PWM support
- Software PWM fallback
- Frequency and duty cycle control

✅ **Phase 4: Servo Control** (Completed)
- Servo control interface
- Position presets
- Directional rotation
- Step-based movement

✅ **Phase 5: UI Optimization** (Completed)
- Touchscreen layout optimization
- Font size adjustments
- Button text readability improvements
- Fixed-height layout without scrolling

✅ **Phase 6: Documentation** (Completed)
- PWM implementation status
- Servo control guide
- Hardware pinout reference

### Future Milestones

⏳ **Phase 7: Testing and Validation** (Planned)
- Comprehensive PWM testing
- Servo motor validation
- Long-running stability tests
- Performance benchmarking

⏳ **Phase 8: Sensor Enhancements** (Planned)
- Improved graph visualization
- Data export functionality
- Configurable update rates
- Multi-sensor support

⏳ **Phase 9: Advanced Features** (Future)
- Custom PWM waveforms
- GPIO sequences and macros
- Configuration persistence
- Network API (optional)

## Risk Assessment

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| GPIO state corruption | High | Low | Graceful cleanup, error handling |
| Software PWM jitter | Medium | High | Document limitations, use hardware PWM |
| Touchscreen calibration drift | Medium | Low | OS-level calibration tools |
| Memory leaks | Medium | Medium | Regular testing, proper cleanup |
| I2C conflicts | High | Low | Reserve I2C pins, clear documentation |

### Operational Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Hardware damage | High | Low | Safety warnings, voltage protection docs |
| Service crash | Medium | Low | Systemd auto-restart, error logging |
| Display failure | High | Low | SSH fallback access |
| Power loss | Low | Medium | Graceful cleanup on shutdown signal |

## References

### Internal Documents

- [Technical Architecture](./TECHNICAL_ARCHITECTURE.md)
- [API Specification](./API_SPECIFICATION.md)
- [UI/UX Specification](./UI_UX_SPECIFICATION.md)
- [Hardware Specification](./HARDWARE_SPECIFICATION.md)
- [Development Guidelines](./DEVELOPMENT_GUIDELINES.md)
- [Deployment Specification](./DEPLOYMENT_SPECIFICATION.md)

### External Resources

- [Seeed Studio reTerminal Documentation](https://wiki.seeedstudio.com/reTerminal/)
- [Raspberry Pi GPIO Documentation](https://www.raspberrypi.org/documentation/hardware/gpio/)
- [BCM2711 Datasheet](https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf)
- [Qt/QML Documentation](https://doc.qt.io/)
- [RPi.GPIO Library](https://pypi.org/project/RPi.GPIO/)

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0.0 | 2026-01-07 | Claude Code | Initial project specification |

---

**Document Owner:** Project Team
**Approval Required:** Technical Lead, Project Manager
**Review Cycle:** Quarterly or on major feature updates
