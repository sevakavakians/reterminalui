# Architecture Documentation

**Created**: 2026-01-05
**Last Updated**: 2026-01-05
**Status**: Initial Design

## System Overview

The reTerminal GPIO Control UI is a Python-based touchscreen application for controlling and monitoring GPIO pins on the Seeed Studio reTerminal device. The system follows a layered architecture with clear separation between hardware control, business logic, and user interface.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface Layer                 │
│                      (tkinter)                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Pin Selector │  │ Control Panel│  │ Visualization│ │
│  │     View     │  │     View     │  │     View     │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                   Application Layer                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Pin Manager  │  │Data Logger   │  │Config Manager│ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                  Hardware Abstraction Layer             │
│  ┌──────────────────────────────────────────────────┐  │
│  │           GPIO Controller (Unified API)          │  │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐   │  │
│  │  │ RPi.GPIO   │ │  gpiozero  │ │   pigpio   │   │  │
│  │  │  Adapter   │ │  Adapter   │ │  Adapter   │   │  │
│  │  └────────────┘ └────────────┘ └────────────┘   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────┐
│                    Hardware Layer                       │
│                  Raspberry Pi CM4 GPIO                  │
│              (40-pin header, 26 usable pins)            │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### 1. User Interface Layer (tkinter)

**Purpose**: Touch-optimized interface for GPIO control and monitoring

**Components**:

#### Main Application Window
- **Responsibility**: Root window management, navigation, lifecycle
- **Key Features**:
  - Fullscreen mode (720x1280)
  - View navigation (stack-based)
  - Touch event handling
  - Theme and styling

#### Pin Selector View
- **Responsibility**: GPIO pin selection and mode configuration
- **Key Features**:
  - Visual pinout representation or list view
  - Pin mode selection (Input/Output/PWM)
  - Pull-up/pull-down configuration for inputs
  - Conflict detection display (GPIO 6, 13)

#### Control Panel View
- **Responsibility**: Real-time GPIO pin control
- **Key Features**:
  - Output toggle (HIGH/LOW)
  - Input state display
  - PWM frequency/duty cycle controls
  - Safety warnings (current limits)

#### Visualization View
- **Responsibility**: Real-time data display and plotting
- **Key Features**:
  - Multi-pin state timeline
  - matplotlib integration for time-series plots
  - Zoom/pan controls
  - Export data functionality

**Technology Stack**:
- tkinter (built-in GUI framework)
- matplotlib (embedded plotting)
- Custom touch-optimized widgets

---

### 2. Application Layer

**Purpose**: Business logic, state management, data handling

**Components**:

#### Pin Manager
- **Responsibility**: GPIO pin state management and coordination
- **Key Features**:
  - Pin reservation system
  - Conflict detection (hardware conflicts, current limits)
  - Mode transitions (safe switching between input/output/PWM)
  - State validation

**API Example**:
```python
class PinManager:
    def reserve_pin(self, pin_number, mode, config) -> bool
    def release_pin(self, pin_number) -> bool
    def get_pin_state(self, pin_number) -> PinState
    def set_pin_value(self, pin_number, value) -> bool
    def get_available_pins() -> List[int]
```

#### Data Logger
- **Responsibility**: Time-series data acquisition and storage
- **Key Features**:
  - Multi-channel sampling
  - Configurable sampling rates
  - Buffer management
  - Export to CSV/JSON
  - Timestamp synchronization

**API Example**:
```python
class DataLogger:
    def start_logging(self, pins, sample_rate_hz)
    def stop_logging()
    def get_buffer(self, pin_number, time_range) -> np.array
    def export_data(self, filename, format)
    def clear_buffer()
```

#### Configuration Manager
- **Responsibility**: Persistent configuration storage
- **Key Features**:
  - Save/load pin configurations
  - Profile management (multiple setups)
  - Validation on load
  - Default configurations

**Configuration Format** (JSON):
```json
{
  "name": "LED Test Setup",
  "version": "1.0",
  "timestamp": "2026-01-05T12:00:00",
  "pins": {
    "17": {"mode": "output", "initial_state": "LOW"},
    "27": {"mode": "input", "pull": "up"},
    "18": {"mode": "pwm", "frequency": 1000, "duty_cycle": 50}
  }
}
```

---

### 3. Hardware Abstraction Layer

**Purpose**: Unified GPIO control interface abstracting multiple libraries

**Components**:

#### GPIO Controller (Core Abstraction)
- **Responsibility**: Single API for GPIO operations, library selection
- **Design Pattern**: Adapter pattern for library interoperability

**Unified API**:
```python
class GPIOController:
    # Pin Configuration
    def set_mode(self, pin, mode: PinMode) -> bool
    def get_mode(self, pin) -> PinMode

    # Digital I/O
    def digital_write(self, pin, value: bool) -> bool
    def digital_read(self, pin) -> bool
    def set_pull(self, pin, pull: PullMode) -> bool

    # PWM
    def pwm_start(self, pin, frequency_hz, duty_cycle_percent) -> bool
    def pwm_update(self, pin, frequency_hz, duty_cycle_percent) -> bool
    def pwm_stop(self, pin) -> bool

    # Safety and Validation
    def is_pin_available(self, pin) -> bool
    def get_pin_conflicts(self, pin) -> List[str]
    def cleanup() -> None
```

**Enumerations**:
```python
class PinMode(Enum):
    INPUT = "input"
    OUTPUT = "output"
    PWM = "pwm"
    RESERVED = "reserved"

class PullMode(Enum):
    OFF = "off"
    UP = "up"
    DOWN = "down"
```

#### Library Adapters

**RPi.GPIO Adapter**:
- **Use Case**: Basic digital I/O
- **Strengths**: Lightweight, stable, well-tested
- **Limitations**: Software PWM only (less accurate)

**gpiozero Adapter**:
- **Use Case**: High-level device abstractions
- **Strengths**: Simple API, built-in device classes
- **Limitations**: Less fine-grained control

**pigpio Adapter**:
- **Use Case**: Hardware PWM, high-speed operations
- **Strengths**: Hardware-timed PWM, better performance
- **Limitations**: Requires pigpio daemon running

**Adapter Selection Logic**:
```python
def _select_library(mode: PinMode, requirements: dict):
    if mode == PinMode.PWM and requirements.get("hardware_pwm"):
        return PigpioAdapter()
    elif mode == PinMode.PWM:
        return RPiGPIOAdapter()  # Software PWM fallback
    else:
        return RPiGPIOAdapter()  # Default for digital I/O
```

---

### 4. Hardware Layer

**Fixed Components** (Not modifiable by software):
- Raspberry Pi Compute Module 4 (BCM2711)
- 40-pin GPIO header
- 26 usable GPIO pins (BCM numbering)
- 3.3V logic level
- Current limits: 16mA per pin, 50mA total

**Verified Facts**:
- GPIO 6 and 13 reserved for USB hub (cannot be used)
- I2C, SPI, UART interfaces available
- No native analog input (digital only)

---

## Data Flow

### Digital Output Control Flow
```
User Touch → UI Event Handler → Pin Manager.set_pin_value() →
GPIO Controller.digital_write() → RPi.GPIO Adapter → Hardware
→ Feedback → UI State Update
```

### Digital Input Reading Flow
```
Hardware State → GPIO Controller.digital_read() (polled) →
Pin Manager.get_pin_state() → Data Logger (optional) →
Visualization Update → UI Display
```

### PWM Control Flow
```
User Input (freq, duty) → Pin Manager → GPIO Controller.pwm_start() →
Pigpio Adapter → Hardware PWM → Visual Feedback (LED brightness)
```

### Data Logging Flow
```
Timer Trigger → Data Logger.sample() → GPIO Controller.digital_read()
(multi-pin) → Buffer Storage → Visualization (real-time plot) →
Export (CSV/JSON on demand)
```

---

## State Management

### Pin State Tracking
```python
class PinState:
    pin_number: int
    mode: PinMode
    value: bool  # Current digital state
    pull: PullMode  # For inputs
    pwm_config: Optional[PWMConfig]  # For PWM mode
    reserved_by: Optional[str]  # Conflict tracking
    last_updated: datetime
```

### Application State
- Active view (navigation stack)
- Selected pins (multi-select support)
- Logging status (active/inactive)
- Configuration loaded (current profile)

---

## File Organization

```
/Users/sevakavakians/PROGRAMMING/reterminal/
├── src/
│   ├── ui/                          # User interface layer
│   │   ├── main_app.py              # Main application window
│   │   ├── views/
│   │   │   ├── pin_selector.py      # Pin selection view
│   │   │   ├── control_panel.py     # GPIO control view
│   │   │   └── visualization.py     # Data plotting view
│   │   └── widgets/
│   │       ├── pin_button.py        # Custom pin control widget
│   │       └── touch_slider.py      # Touch-optimized slider
│   ├── app/                         # Application layer
│   │   ├── pin_manager.py           # Pin state management
│   │   ├── data_logger.py           # Time-series logging
│   │   └── config_manager.py        # Configuration persistence
│   ├── hardware/                    # Hardware abstraction layer
│   │   ├── gpio_controller.py       # Unified GPIO API
│   │   └── adapters/
│   │       ├── rpigpio_adapter.py   # RPi.GPIO wrapper
│   │       ├── gpiozero_adapter.py  # gpiozero wrapper
│   │       └── pigpio_adapter.py    # pigpio wrapper
│   └── utils/
│       ├── constants.py             # GPIO pin definitions
│       └── validators.py            # Input validation
├── tests/                           # Unit and integration tests
├── configs/                         # Configuration files
│   ├── default.json
│   └── examples/
├── data/                            # Logged data
└── docs/                            # Documentation
```

---

## Error Handling Strategy

### Hardware Errors
- **GPIO conflicts**: Detect and warn before configuration
- **Permissions errors**: Check gpio group membership, provide instructions
- **Hardware failures**: Graceful degradation, log errors, notify user

### Application Errors
- **Invalid configurations**: Validate before applying, reject with clear message
- **Library failures**: Fallback to alternative library if available
- **Resource exhaustion**: Memory limits, buffer overflow protection

### User Errors
- **Invalid pin selection**: Prevent selection of unavailable pins (6, 13)
- **Unsafe operations**: Warn about current limits, prevent simultaneous high current
- **Configuration mistakes**: Validate all inputs, provide sensible defaults

---

## Performance Considerations

### UI Responsiveness
- **Target**: <100ms touch response
- **Strategy**: Async hardware operations, UI updates on main thread only
- **Optimization**: Minimize redraws, batch state updates

### Sampling Rate
- **Digital Input**: Up to 1 kHz polling (1ms intervals)
- **Limitation**: Python GIL may reduce effective rate
- **Mitigation**: Use pigpio hardware-timed sampling if needed

### Data Visualization
- **Target**: 60fps plot updates
- **Strategy**: Decimation for large datasets, limited history window
- **Optimization**: matplotlib blitting, reduce unnecessary redraws

### Memory Management
- **Buffer Size**: Configurable, default 10,000 samples per pin
- **Circular Buffers**: Prevent unlimited growth
- **Export on Fill**: Auto-export or stop logging when buffer full

---

## Security and Safety

### Electrical Safety
- Current limit monitoring (software warnings)
- Pin conflict detection
- Short circuit warnings (if detectable)

### Software Safety
- Input validation on all GPIO operations
- Safe cleanup on application exit
- Pin state restoration on crash recovery (optional)

### Access Control
- SSH key-based authentication (already configured)
- GPIO group membership required
- No remote GPIO control (local UI only)

---

## Future Architecture Expansion

### Planned Enhancements
1. **External ADC Integration**
   - Plugin architecture for ADC modules
   - Unified analog/digital data handling
   - ADS1115 and MCP3008 drivers

2. **Network Interface**
   - REST API for remote monitoring
   - WebSocket real-time data streaming
   - Web-based UI (optional)

3. **Protocol Analyzers**
   - I2C, SPI, UART decoding
   - Logic analyzer mode
   - Trigger and capture

4. **Advanced Visualization**
   - FFT analysis
   - Statistical tools
   - Waveform comparison

---

## Technology Decisions

### Confirmed Choices
- **UI Framework**: tkinter (verified available, testing needed for touch)
- **GPIO Libraries**: Multi-library support (RPi.GPIO, gpiozero, pigpio)
- **Data Handling**: pandas/numpy (installation to be verified)
- **Plotting**: matplotlib (embedded in tkinter)

### Pending Decisions
- **Touch performance**: May require framework change if tkinter inadequate
- **ADC module**: ADS1115 vs MCP3008 (user choice, both supported)
- **Logging backend**: File-based vs SQLite (depends on data volume)

### Alternative Considered
- **PyQt5/PySide2**: More features but heavier, installation complexity
- **Kivy**: Touch-optimized but unfamiliar, learning curve
- **Web UI (Flask/Django)**: Network overhead, more complex architecture

---

## Deployment and Runtime

### Development Environment
- **Local**: macOS (code editing, planning)
- **Remote**: reTerminal via SSH (testing, deployment)
- **Transfer**: SCP or git pull

### Production Environment
- **Device**: reTerminal (always-on or on-demand)
- **Startup**: Autostart on boot (optional systemd service)
- **Updates**: git pull, restart application

### Dependencies Management
- **Python Version**: 3.7.3 (fixed by reTerminal OS)
- **Package Management**: pip (verify versions compatible with 3.7.3)
- **Virtual Environment**: Optional, depends on system Python cleanliness

---

## Testing Strategy

### Unit Tests
- GPIO Controller adapters (mocked hardware)
- Pin Manager state transitions
- Configuration Manager validation

### Integration Tests
- Full GPIO control flow (hardware required)
- UI navigation and state management
- Data logging accuracy

### Hardware Tests
- Physical test circuits (LED, button, PWM load)
- Performance benchmarks (sampling rate, latency)
- Stress tests (all pins active, continuous logging)

---

## Monitoring and Debugging

### Logging
- Application logs: `/var/log/reterminal-gpio/app.log`
- Error logs: Stderr capture
- Hardware event log: GPIO state transitions

### Debug Mode
- Verbose logging toggle
- Pin state inspector
- Performance metrics overlay

### Troubleshooting
- GPIO permission issues: Check `groups` command
- Library conflicts: Verify cleanup on exit
- Touch issues: Test with mouse/keyboard fallback
