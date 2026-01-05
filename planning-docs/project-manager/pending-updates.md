# Pending Updates - Human Review Required

**Purpose**: Items flagged by project-manager agent that need human attention

---

## High Priority

### H1: Update ARCHITECTURE.md for Web Stack
**Flagged**: 2026-01-05
**Category**: Documentation Drift
**Issue**: ARCHITECTURE.md still describes tkinter 4-layer architecture; project pivoted to Flask + React + Arwes
**Recommendation**: Rewrite architecture diagram and component details for web stack
**Impact**: Outdated documentation may cause confusion in future sessions
**Status**: Pending

---

## Medium Priority

### M1: Verify Arwes Framework Compatibility
**Flagged**: 2026-01-05 (Updated)
**Category**: Risk Mitigation
**Issue**: Arwes performance on reTerminal display unknown; touch responsiveness not tested
**Recommendation**: Install Arwes, test basic components on development machine, then reTerminal
**Impact**: May affect UI polish and performance if framework struggles on hardware
**Status**: Pending

---

### M2: Test WebSocket Real-Time Performance
**Flagged**: 2026-01-05
**Category**: Critical Path Risk
**Issue**: WebSocket latency for real-time GPIO monitoring unknown
**Recommendation**: Test WebSocket updates with simulated high-frequency pin changes
**Impact**: If latency too high, may need to optimize update frequency or batching
**Status**: Pending

---

## Low Priority

### L1: Consider Version Constraints for Python 3.7.3
**Flagged**: 2026-01-05
**Category**: Dependency Management
**Issue**: Some modern library features may not work with Python 3.7.3 (EOL June 2023)
**Recommendation**: During dependency installation (Task S1.1), note version constraints
**Impact**: May limit feature set or require workarounds
**Status**: Pending

---

## Informational

### I1: ADC Module Recommendation Needed
**Flagged**: 2026-01-05
**Category**: Future Planning
**Issue**: Phase 5 requires external ADC module; ADS1115 vs MCP3008 choice not made
**Recommendation**: Research ADC options before Phase 5; document pros/cons
**Impact**: No immediate impact (Phase 5 is future work)
**Status**: Deferred to Phase 4 completion

---

## Resolved

### R1: Verify Python Dependencies Early
**Resolved**: 2026-01-05
**Resolution**: Architectural pivot to Flask + React; Python dependencies for backend minimal (Flask, Flask-CORS, Flask-SocketIO)
**Status**: Backend dependencies confirmed, visualization moved to frontend (chart libraries)

---

### R2: Test tkinter Touch Performance
**Resolved**: 2026-01-05
**Resolution**: Architectural pivot eliminated tkinter; using React + Arwes instead
**Status**: No longer relevant; React touch events to be tested instead

---

## Metadata

**Total Pending**: 4 (1 high, 2 medium, 1 low, 0 informational)
**Total Resolved**: 2
**Last Updated**: 2026-01-05
**Next Review**: After Arwes installation and initial frontend testing
