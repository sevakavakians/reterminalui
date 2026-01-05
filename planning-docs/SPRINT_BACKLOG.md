# Sprint Backlog

**Sprint**: Sprint 1 - Core GPIO Control UI
**Duration**: 2026-01-05 to 2026-01-19 (2 weeks)
**Goal**: Complete functional GPIO control interface with digital I/O and PWM support

## Sprint Objectives

1. Establish UI framework and verify touch performance
2. Implement complete digital GPIO control (input/output)
3. Add PWM control for analog-like output
4. Create real-time pin state visualization
5. Deliver testable prototype for electronics probing

## Sprint Tasks

### UI Foundation Track

#### S1.1: Environment Setup and Verification
**Priority**: Critical
**Estimate**: 1 hour
**Status**: Pending

**Tasks**:
- [ ] Verify Python dependencies (matplotlib, pandas, numpy)
- [ ] Install missing libraries
- [ ] Test remote file transfer (development to reTerminal)
- [ ] Configure development workflow

**Definition of Done**:
- All required libraries installed and importable
- File transfer mechanism tested and documented
- Development workflow documented in ARCHITECTURE.md

---

#### S1.2: Touch Interface Testing
**Priority**: Critical
**Estimate**: 2 hours
**Status**: Pending

**Tasks**:
- [ ] Create basic tkinter fullscreen application
- [ ] Test touch event handling
- [ ] Measure response latency
- [ ] Test button sizes for touch usability
- [ ] Document tkinter limitations or issues

**Definition of Done**:
- Touch test application working on reTerminal
- Response time <100ms confirmed or issues documented
- Decision made: continue with tkinter or investigate alternatives

**Risk**: If tkinter touch performance inadequate, may require framework change

---

#### S1.3: Core UI Layout Design
**Priority**: High
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.2

**Tasks**:
- [ ] Design main navigation structure
- [ ] Create GPIO pin selector UI (visual pinout or list)
- [ ] Design control panel layout
- [ ] Implement responsive layout for 720x1280
- [ ] Add navigation between views

**Definition of Done**:
- Main application shell with navigation
- Pin selector view implemented
- Control panel view skeleton created
- All views render correctly on reTerminal

---

### GPIO Control Track

#### S1.4: GPIO Abstraction Layer
**Priority**: High
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.1

**Tasks**:
- [ ] Create GPIOController class
- [ ] Abstract RPi.GPIO, gpiozero, pigpio libraries
- [ ] Implement pin conflict detection (GPIO 6, 13)
- [ ] Add current limit warnings
- [ ] Create pin state tracking

**Definition of Done**:
- GPIOController class with unified API
- Pin reservation and conflict detection working
- Unit tests for core functionality
- Documentation of API

---

#### S1.5: Digital Output Control
**Priority**: High
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.3, S1.4

**Tasks**:
- [ ] Implement output mode configuration
- [ ] Create HIGH/LOW toggle interface
- [ ] Add visual state feedback
- [ ] Test with external LED circuit
- [ ] Add safety checks

**Definition of Done**:
- User can configure any usable pin as output
- Toggle HIGH/LOW reliably
- Visual feedback matches actual pin state
- LED test circuit successfully controlled

---

#### S1.6: Digital Input Reading
**Priority**: High
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.3, S1.4

**Tasks**:
- [ ] Implement input mode configuration
- [ ] Add pull-up/pull-down/floating options
- [ ] Create real-time value display
- [ ] Implement input change detection
- [ ] Test with button/switch circuit

**Definition of Done**:
- User can configure any usable pin as input
- Real-time state display updates correctly
- Pull-up/pull-down modes work as expected
- Button test circuit successfully read

---

#### S1.7: PWM Control
**Priority**: Medium
**Estimate**: 4 hours
**Status**: Pending
**Dependencies**: S1.3, S1.4

**Tasks**:
- [ ] Identify PWM-capable pins
- [ ] Implement pigpio PWM control
- [ ] Create frequency control UI (1 Hz - 40 kHz)
- [ ] Create duty cycle control UI (0-100%)
- [ ] Test with LED brightness control

**Definition of Done**:
- PWM mode configurable on capable pins
- Frequency and duty cycle adjustable
- Visual smooth LED brightness control working
- PWM signal verified with oscilloscope/multimeter if available

---

### Visualization Track

#### S1.8: Real-Time Pin State Display
**Priority**: High
**Estimate**: 4 hours
**Status**: Pending
**Dependencies**: S1.4

**Tasks**:
- [ ] Design pin state visualization (grid/list/diagram)
- [ ] Implement real-time state polling
- [ ] Add color coding for states
- [ ] Show pin modes and configurations
- [ ] Optimize update frequency

**Definition of Done**:
- All 26 usable pins displayed
- States update in real-time (<200ms latency)
- Clear visual distinction between modes
- GPIO 6 and 13 marked unavailable
- Smooth UI performance during updates

---

### Integration and Testing Track

#### S1.9: Hardware Testing Suite
**Priority**: Medium
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.5, S1.6, S1.7

**Tasks**:
- [ ] Create test circuits (LED, button, potentiometer)
- [ ] Document test procedures
- [ ] Execute full functionality tests
- [ ] Measure performance metrics
- [ ] Document issues and limitations

**Definition of Done**:
- All major features tested with real hardware
- Performance metrics documented
- Known issues logged
- Test procedures documented for future regression testing

---

#### S1.10: Configuration Persistence
**Priority**: Low
**Estimate**: 3 hours
**Status**: Pending
**Dependencies**: S1.5, S1.6, S1.7

**Tasks**:
- [ ] Design configuration file format (JSON)
- [ ] Implement save current configuration
- [ ] Implement load configuration
- [ ] Add configuration validation
- [ ] Create default configurations

**Definition of Done**:
- Configurations save to JSON files
- Saved configurations load correctly
- Invalid configurations rejected gracefully
- At least 2 example configurations included

---

## Sprint Metrics

### Planned Capacity
**Total Estimated Hours**: 29 hours
**Available Development Time**: TBD (to be determined based on schedule)

### Velocity Tracking
- **Estimated Story Points**: 29 (using hours as points)
- **Completed Story Points**: 0
- **Burn-down**: Track daily

### Success Criteria

**Must Have** (Sprint cannot succeed without these):
- ✓ Touch interface working acceptably (S1.2)
- ✓ Digital output control functional (S1.5)
- ✓ Digital input reading functional (S1.6)
- ✓ Real-time state display working (S1.8)

**Should Have** (Important but can defer):
- PWM control (S1.7)
- Hardware testing complete (S1.9)

**Nice to Have** (Bonus features):
- Configuration persistence (S1.10)

## Dependencies and Risks

### Critical Path
S1.1 → S1.2 → S1.3 → S1.5/S1.6 → S1.9
**Any delay in S1.1 or S1.2 blocks entire sprint**

### Known Risks

**High Risk**:
- **R1**: tkinter touch performance inadequate
  - *Impact*: Entire UI must be redesigned with different framework
  - *Mitigation*: Test early (S1.2), have PyQt/Kivy as backup plan
  - *Contingency*: Accept 1-week delay for framework swap if needed

**Medium Risk**:
- **R2**: GPIO library conflicts or hardware issues
  - *Impact*: Core functionality unreliable
  - *Mitigation*: Thorough testing in S1.4, isolate library-specific code

- **R3**: Real-time performance insufficient
  - *Impact*: Laggy UI, poor user experience
  - *Mitigation*: Profile early, optimize update loops, reduce polling frequency if needed

**Low Risk**:
- **R4**: PWM functionality limited
  - *Impact*: Reduced analog output capabilities
  - *Mitigation*: Document limitations, defer advanced PWM features

## Sprint Deliverables

### Code Deliverables
- [ ] GPIO controller module with abstraction layer
- [ ] Main UI application with navigation
- [ ] Digital I/O control interface
- [ ] PWM control interface (if time permits)
- [ ] Real-time state visualization

### Documentation Deliverables
- [ ] ARCHITECTURE.md (system design)
- [ ] DECISIONS.md (technical choices)
- [ ] USER_GUIDE.md (basic usage instructions)
- [ ] Test results and performance metrics

### Testing Deliverables
- [ ] Unit tests for GPIO controller
- [ ] Hardware test procedures
- [ ] Performance benchmark results

## Daily Standups

Track daily progress, blockers, and plans:

**Format**:
- Yesterday: [completed tasks]
- Today: [planned tasks]
- Blockers: [impediments]

---

## Sprint Review Notes

**Review Date**: 2026-01-19 (planned)

**Demo Checklist**:
- [ ] Configure GPIO pin as output
- [ ] Toggle LED on/off
- [ ] Configure GPIO pin as input
- [ ] Read button state
- [ ] Adjust PWM duty cycle (LED brightness)
- [ ] View real-time pin states
- [ ] Save/load configuration

---

## Sprint Retrospective

**Retrospective Date**: 2026-01-19 (planned)

**What went well**:
- TBD

**What could improve**:
- TBD

**Action items for next sprint**:
- TBD
