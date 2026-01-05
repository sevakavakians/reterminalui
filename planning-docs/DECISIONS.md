# Technical Decisions Log

**Purpose**: Record all significant technical decisions with rationale, alternatives considered, and confidence levels.

---

## Decision Format

Each decision includes:
- **Date**: When decision was made
- **Decision**: What was decided
- **Rationale**: Why this choice was made
- **Alternatives Considered**: Other options evaluated
- **Confidence Level**: High/Medium/Low
- **Status**: Confirmed/Tentative/Revisit
- **Impact**: What this affects
- **Reversibility**: Easy/Moderate/Difficult to change

---

## D001: Use Web-Based Architecture (Flask + React + Arwes)

**Date**: 2026-01-05 (Updated after architectural pivot)
**Decision**: Use Flask backend with React + TypeScript + Arwes cyberpunk UI framework
**Status**: Confirmed (user selected after UI framework comparison)

**Rationale**:
- Modern, polished UI with cyberpunk aesthetic (Arwes framework)
- Better separation of concerns (backend API vs frontend UI)
- Touch-optimized React components
- Real-time updates via WebSocket
- Network access capability (optional, not required)
- Extensive component ecosystem
- Better development experience with TypeScript

**Alternatives Considered**:
1. **tkinter (original plan)**
   - Pros: Lightweight, no dependencies, direct hardware access
   - Cons: Limited styling, basic UI, uncertain touch performance

2. **PyQt5/PySide2 with LCARS theme**
   - Pros: Native performance, LCARS aesthetic available
   - Cons: Heavy dependencies, licensing complexity

3. **Kivy with custom cyberpunk theme**
   - Pros: Touch-optimized, mobile-friendly
   - Cons: Unfamiliar, learning curve, limited theming

**User Choice**: Arwes cyberpunk aesthetic selected over LCARS or custom designs

**Confidence Level**: High

**Impact**: Complete architecture change - backend API layer, frontend framework, deployment model

**Reversibility**: Difficult (major architectural decision, significant work invested)

**Implementation Details**:
- Backend: Flask with REST API + WebSocket support
- Frontend: React + TypeScript + Arwes UI framework
- Display: Chromium kiosk mode for fullscreen touch UI
- GPIO: Python backend with abstraction layer (RPi.GPIO, gpiozero, pigpio)

---

## D002: Multi-Library GPIO Support

**Date**: 2026-01-05
**Decision**: Support multiple GPIO libraries (RPi.GPIO, gpiozero, pigpio) with adapter pattern
**Status**: Confirmed

**Rationale**:
- Different libraries excel at different tasks:
  - RPi.GPIO: Lightweight digital I/O
  - gpiozero: High-level device abstractions
  - pigpio: Hardware-timed PWM, better performance
- Provides flexibility for future features
- Allows fallback if one library has issues
- Adapter pattern isolates library-specific code

**Alternatives Considered**:
1. **Single library (RPi.GPIO only)**
   - Pros: Simpler codebase, fewer dependencies
   - Cons: Limited PWM quality (software only), less flexibility

2. **Single library (pigpio only)**
   - Pros: Best performance, hardware PWM
   - Cons: Requires daemon running, more complex setup

**Confidence Level**: High

**Impact**: Hardware abstraction layer architecture, testing complexity

**Reversibility**: Difficult (core architectural decision)

**Notes**: Adapter pattern provides good separation; low risk of library conflicts

---

## D003: Modular ADC Support (Plugin Architecture)

**Date**: 2026-01-05
**Decision**: Design plugin architecture for external ADC modules rather than hardcoding single ADC
**Status**: Confirmed

**Rationale**:
- Users may have different ADC hardware (ADS1115, MCP3008, etc.)
- Allows adding new ADC support without core changes
- Extensibility for future sensors (I2C/SPI devices)
- Clean separation between digital and analog acquisition

**Alternatives Considered**:
1. **Hardcode ADS1115 support only**
   - Pros: Simpler initial implementation
   - Cons: Not flexible for users with different hardware

2. **No analog support initially**
   - Pros: Reduced scope, faster delivery
   - Cons: Limits usefulness as electronics probe

**Confidence Level**: High

**Impact**: Hardware abstraction layer, data logger design, configuration management

**Reversibility**: Easy (plugin architecture allows adding/removing modules)

**Implementation Note**: Defer to Phase 5, but design core architecture with this in mind

---

## D004: JSON Configuration Format

**Date**: 2026-01-05
**Decision**: Use JSON for configuration file format
**Status**: Confirmed

**Rationale**:
- Human-readable and editable
- Native Python support (json module)
- Widely understood format
- Easy to validate and version
- Supports nested structures for complex configs

**Alternatives Considered**:
1. **YAML**
   - Pros: More human-friendly syntax
   - Cons: Requires additional library (PyYAML), parsing complexity

2. **INI files**
   - Pros: Simple, configparser in stdlib
   - Cons: Limited nesting, less expressive

3. **SQLite database**
   - Pros: Structured, queryable, good for large configs
   - Cons: Overkill for simple pin configurations, binary format

**Confidence Level**: High

**Impact**: Configuration Manager implementation, user documentation

**Reversibility**: Easy (configuration layer is isolated)

---

## D005: Polling-Based Input Reading (Initial Implementation)

**Date**: 2026-01-05
**Decision**: Use polling for digital input reading initially, not interrupt-based
**Status**: Tentative (may add interrupts later)

**Rationale**:
- Simpler implementation for initial version
- Consistent with data logging approach (time-series sampling)
- Easier to synchronize multi-pin reads
- Sufficient for target 1kHz sampling rate

**Alternatives Considered**:
1. **Interrupt-driven (edge detection)**
   - Pros: More efficient, immediate response to changes
   - Cons: Complexity in multi-pin management, callback overhead
   - Note: Consider for future enhancement (event logging mode)

**Confidence Level**: Medium

**Impact**: Data Logger design, CPU usage, latency

**Reversibility**: Easy (can add interrupt mode alongside polling)

**Future Enhancement**: Add interrupt mode for event-driven applications (button presses, etc.)

---

## D006: Embedded matplotlib for Visualization

**Date**: 2026-01-05
**Decision**: Use matplotlib embedded in tkinter for time-series plotting
**Status**: Tentative (pending performance testing)

**Rationale**:
- Tight integration with tkinter
- Rich plotting capabilities (zoom, pan, etc.)
- Familiar to Python developers
- Good documentation

**Alternatives Considered**:
1. **Custom plotting with tkinter Canvas**
   - Pros: Lightweight, full control, potentially faster
   - Cons: Reinventing wheel, limited features, more development time

2. **pyqtgraph**
   - Pros: Optimized for real-time data, better performance
   - Cons: Requires PyQt, changes entire UI framework decision

3. **plotly**
   - Pros: Interactive, modern, web-based
   - Cons: Heavyweight, requires web server, overkill for embedded use

**Confidence Level**: Medium

**Impact**: Visualization View implementation, real-time performance

**Reversibility**: Moderate (visualization layer is isolated but tightly coupled to tkinter)

**Revisit Condition**: If matplotlib performance inadequate (target: 60fps, <200ms latency), consider custom Canvas plotting

---

## D007: File-Based Data Logging (Not Database)

**Date**: 2026-01-05
**Decision**: Use file-based logging (CSV/JSON export) rather than database
**Status**: Tentative

**Rationale**:
- Simple export for analysis in external tools (Excel, Python scripts)
- No database dependencies
- Easy to archive and transfer
- Sufficient for expected data volumes (MB to GB range)

**Alternatives Considered**:
1. **SQLite database**
   - Pros: Structured queries, efficient storage, atomic operations
   - Cons: Adds complexity, binary format (less portable)
   - Reconsider if: Logging sessions generate >1GB data regularly

**Confidence Level**: Medium

**Impact**: Data Logger implementation, export functionality

**Reversibility**: Easy (can add SQLite export option later)

---

## D008: BCM Pin Numbering (Not Physical)

**Date**: 2026-01-05
**Decision**: Use BCM (Broadcom) GPIO numbering throughout application
**Status**: Confirmed

**Rationale**:
- Consistent with RPi.GPIO, gpiozero, pigpio defaults
- More intuitive for developers (matches BCM2711 datasheet)
- Avoids confusion with physical pin numbers
- Standard in Raspberry Pi community

**Alternatives Considered**:
1. **Physical pin numbering (BOARD)**
   - Pros: Matches physical pinout labels
   - Cons: Less common in libraries, more confusing for hardware reference

**Confidence Level**: High

**Impact**: All GPIO code, documentation, UI labels

**Reversibility**: Difficult (embedded throughout codebase)

**Note**: Provide pinout diagram in UI showing BCM-to-physical mapping for user reference

---

## D009: Circular Buffers for Data Logging

**Date**: 2026-01-05
**Decision**: Use circular buffers with configurable size for in-memory data storage
**Status**: Confirmed

**Rationale**:
- Prevents unlimited memory growth
- Configurable size balances memory vs. history
- Automatic old data eviction
- Simple to implement with deque or numpy

**Alternatives Considered**:
1. **Unlimited buffering with disk swap**
   - Pros: No data loss
   - Cons: Memory exhaustion risk, performance degradation

2. **Fixed-size with stop on full**
   - Pros: Guaranteed memory limit
   - Cons: Logging stops unexpectedly, poor UX

**Confidence Level**: High

**Impact**: Data Logger memory management, buffer size configuration

**Reversibility**: Easy (implementation detail)

**Default Size**: 10,000 samples per pin (configurable)

---

## D010: Network-Capable Architecture (Optional Remote Access)

**Date**: 2026-01-05 (Revised with web architecture)
**Decision**: Web-based architecture supports network access, but not required for primary use case
**Status**: Confirmed

**Rationale**:
- Flask backend provides REST API by default
- Chromium kiosk mode runs on localhost (127.0.0.1)
- Can optionally expose network interface (0.0.0.0) for remote access
- No security complexity if kept on localhost
- Enables future remote monitoring without architectural changes

**Deployment Options**:
1. **Local-only (primary)**: Flask on 127.0.0.1, Chromium kiosk accessing localhost
2. **Network-accessible (optional)**: Flask on 0.0.0.0, accessible from LAN

**Security Approach**:
- Default: localhost only
- Optional: Basic authentication if network exposed
- Future: Token-based auth, HTTPS (Phase 6)

**Confidence Level**: High

**Impact**: Architecture enables flexibility without requiring network exposure

**Reversibility**: Easy (deployment configuration change only)

**Implementation**: Primary use case remains on-device touchscreen UI via Chromium kiosk

---

## D011: Flask Backend with Mock GPIO Development Support

**Date**: 2026-01-05
**Decision**: Implement GPIO abstraction layer with mock GPIO for development on non-Pi systems
**Status**: Confirmed (Implemented)

**Rationale**:
- Enables development and testing on macOS/Windows without hardware
- Reduces deployment cycles (test locally, deploy to reTerminal only when ready)
- Prevents accidental hardware damage during development
- Mock GPIO simulates pin states for UI development

**Implementation**:
- `GPIOController` class with abstraction layer
- Automatic detection: uses RPi.GPIO on Raspberry Pi, mock on other systems
- Mock GPIO tracks pin states in memory
- Safety features: pin conflict detection, current limit warnings

**Features Implemented**:
- Pin configuration (input/output/PWM modes)
- Digital read/write operations
- PWM control (frequency, duty cycle)
- Pull-up/pull-down resistor configuration
- Pin conflict detection (GPIO 6, 13 reserved)

**Confidence Level**: High

**Impact**: Development velocity (can work without hardware), code safety

**Reversibility**: Easy (abstraction layer design allows swapping implementations)

**Status**: Backend complete (`backend/app.py`, `backend/gpio_controller.py`)

---

## D012: REST API + WebSocket Dual Interface

**Date**: 2026-01-05
**Decision**: Provide both REST API (for control) and WebSocket (for real-time monitoring)
**Status**: Confirmed (Implemented in backend)

**Rationale**:
- REST API: Stateless, simple for pin configuration and control
- WebSocket: Real-time bidirectional updates for monitoring
- Best of both patterns for different use cases

**API Design**:
- REST endpoints: `/api/pins`, `/api/pin/<id>/configure`, `/api/pin/<id>/set`, etc.
- WebSocket namespace: `/gpio` for real-time pin state broadcasts

**Implementation Details**:
- Flask-CORS for cross-origin support (development)
- Flask-SocketIO for WebSocket
- JSON response format throughout
- Error handling with appropriate HTTP status codes

**Confidence Level**: High

**Impact**: Frontend development (API contract), real-time UI updates

**Reversibility**: Moderate (API contract affects frontend)

**Status**: Backend API complete, WebSocket implemented

---

## Decisions Under Review

### R001: Touch Button Minimum Size

**Date**: 2026-01-05
**Question**: What minimum button size for reliable touch input?
**Current Assumption**: 44x44px (iOS HIG standard)
**Status**: Test in Sprint 1 Task S1.2
**Impact**: UI density, layout design

---

### R002: Sampling Rate Target

**Date**: 2026-01-05
**Question**: What maximum sampling rate to support?
**Current Assumption**: 1kHz (1ms polling)
**Status**: Benchmark in Sprint 1 Task S1.9
**Impact**: Performance requirements, CPU usage

---

### R003: PWM Frequency Range

**Date**: 2026-01-05
**Question**: What PWM frequency range to support?
**Current Assumption**: 1 Hz - 40 kHz
**Status**: Test hardware limits in Sprint 1 Task S1.7
**Impact**: UI controls, pigpio configuration

---

## Decision Review Process

**When to Revisit**:
- New information contradicts assumptions
- Performance testing reveals issues
- User feedback indicates different needs
- Technology limitations discovered

**Review Trigger Events**:
- Sprint retrospectives
- Major milestone completions
- Blocker resolution requiring architectural change
- External dependency changes

**Review Cadence**: After each sprint or as needed
