# Daily Backlog

**Date**: 2026-01-05
**Sprint Focus**: Core GPIO UI Implementation
**Estimated Capacity**: TBD

## High Priority (Do Today)

### 1. Verify Python Dependencies on reTerminal
**Estimate**: 15 minutes
**Dependencies**: None
**Description**: SSH to reTerminal and verify installation status of matplotlib, pandas, numpy. Install if missing.

**Acceptance Criteria**:
- [ ] matplotlib import successful
- [ ] pandas import successful
- [ ] numpy import successful
- [ ] Version numbers documented

---

### 2. Create Basic tkinter Touch Test
**Estimate**: 30 minutes
**Dependencies**: Task 1
**Description**: Create minimal tkinter application to test touch responsiveness on reTerminal display. Test button presses, swipes, and multi-touch.

**Acceptance Criteria**:
- [ ] Window displays in fullscreen on 720x1280 screen
- [ ] Touch events register correctly
- [ ] Button press response time measured (<100ms target)
- [ ] Results documented

---

### 3. Design GPIO Pin Selector UI Mockup
**Estimate**: 1 hour
**Dependencies**: Task 2
**Description**: Design UI layout for GPIO pin selection and mode configuration. Consider visual pinout diagram or list-based selection.

**Acceptance Criteria**:
- [ ] Layout mockup created (sketch or code)
- [ ] Pin selection method defined
- [ ] Mode configuration UI designed (Input/Output/PWM)
- [ ] Touch-optimized button sizes (minimum 44x44px)

---

## Medium Priority (This Week)

### 4. Implement GPIO Pin State Display
**Estimate**: 2 hours
**Dependencies**: Task 3
**Description**: Create real-time display showing current state of all GPIO pins (HIGH/LOW, mode, conflicts).

**Acceptance Criteria**:
- [ ] Visual representation of 26 usable pins
- [ ] Real-time state updates
- [ ] Color coding for states (HIGH/LOW/disabled)
- [ ] GPIO 6 and 13 marked as unavailable

---

### 5. Build Digital Output Control Interface
**Estimate**: 2 hours
**Dependencies**: Task 4
**Description**: Implement UI controls to set GPIO pins as outputs and toggle HIGH/LOW states.

**Acceptance Criteria**:
- [ ] Pin selection for output mode
- [ ] Toggle button for HIGH/LOW
- [ ] Safety warnings for current limits
- [ ] Test with external LED circuit

---

### 6. Build Digital Input Reading Interface
**Estimate**: 2 hours
**Dependencies**: Task 4
**Description**: Implement UI to configure pins as inputs and display real-time readings with pull-up/pull-down configuration.

**Acceptance Criteria**:
- [ ] Pin selection for input mode
- [ ] Pull-up/pull-down/floating options
- [ ] Real-time value display
- [ ] Test with button/switch circuit

---

### 7. Create PWM Control Interface
**Estimate**: 3 hours
**Dependencies**: Task 5
**Description**: Add PWM configuration UI with frequency and duty cycle controls using pigpio library.

**Acceptance Criteria**:
- [ ] PWM-capable pins identified
- [ ] Frequency control (Hz)
- [ ] Duty cycle control (0-100%)
- [ ] Test with LED brightness control

---

## Lower Priority (Future)

### 8. Implement Pin Configuration Persistence
**Estimate**: 2 hours
**Dependencies**: Tasks 5, 6, 7
**Description**: Save/load pin configurations to JSON files for quick setup restoration.

**Acceptance Criteria**:
- [ ] Export current configuration
- [ ] Load saved configuration
- [ ] Configuration validation
- [ ] Multiple profile support

---

### 9. Add Multi-Pin Control
**Estimate**: 2 hours
**Dependencies**: Task 5
**Description**: Enable simultaneous control of multiple pins (grouped operations).

**Acceptance Criteria**:
- [ ] Select multiple pins
- [ ] Apply state changes to group
- [ ] Pattern generation (sequences)
- [ ] Timing control

---

## Blocked Tasks

**None currently**

## Completed Today

**None yet** (planning phase complete)

## Notes

### Time Estimates Confidence
- Tasks 1-2: High confidence (straightforward verification/testing)
- Tasks 3-7: Medium confidence (UI design iteration may be needed)
- Tasks 8-9: Low confidence (depends on architecture decisions)

### Resource Requirements
- SSH access to reTerminal (192.168.0.3)
- External test circuits (LEDs, buttons, resistors)
- Documentation tools for mockups

### Risk Factors
- tkinter touch performance unknown until Task 2 complete
- If touch responsiveness poor, may need framework change (impacts all UI tasks)
- Python 3.7.3 may limit library versions (check during Task 1)

## Daily Velocity Tracking

**Target**: Establish baseline during first week
**Actual**: TBD

| Date | Estimated Hours | Actual Hours | Tasks Completed | Notes |
|------|----------------|--------------|-----------------|-------|
| 2026-01-05 | - | - | Planning phase | Documentation created |
