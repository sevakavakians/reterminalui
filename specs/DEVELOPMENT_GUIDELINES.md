# reTerminal GPIO Control System - Development Guidelines

**Version:** 1.0.0  
**Last Updated:** 2026-01-07

## Code Style Standards

### Python (PEP 8)

- **Indentation:** 4 spaces (no tabs)
- **Line Length:** 100 characters max
- **Naming Conventions:**
  - Classes: `PascalCase` (e.g., `GPIOController`)
  - Functions/Methods: `snake_case` (e.g., `configure_pin`)
  - Constants: `UPPER_SNAKE_CASE` (e.g., `HARDWARE_PWM_PINS`)
  - Private members: prefix with `_` (e.g., `_configured_pins`)

### QML

- **Indentation:** 4 spaces
- **Naming Conventions:**
  - Components: `PascalCase` (e.g., `PinControlPanel`)
  - Properties: `camelCase` (e.g., `selectedPin`)
  - IDs: `camelCase` (e.g., `controlPanel`)

### Documentation

- **Python:** Docstrings for all public methods
- **QML:** Comments for complex logic
- **Inline:** Explain "why", not "what"

## Project Structure

```
reterminal/
├── qt5-app/                    # Main Qt5 application
│   ├── src/                    # Python source code
│   │   ├── main.py            # Entry point
│   │   ├── GPIOController.py  # GPIO management
│   │   ├── SensorController.py
│   │   └── ButtonHandler.py
│   ├── qml/                    # QML UI files
│   │   ├── main.qml           # Root window
│   │   ├── GPIOScreen.qml
│   │   ├── PinControlPanel.qml
│   │   └── SensorScreen.qml
│   ├── requirements.txt        # Python dependencies
│   ├── reterminal-gpio.service # systemd service
│   └── README.md
├── specs/                      # Technical specifications
├── *.md                        # Documentation (guides, pinouts)
└── README.md                   # Project overview
```

## Git Workflow

### Branch Strategy

- **main:** Stable, production-ready code
- **feature/***:** New features (e.g., `feature/multi-servo`)
- **fix/***:** Bug fixes (e.g., `fix/pwm-jitter`)
- **docs/***:** Documentation updates

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Example:**
```
feat(gpio): add hardware PWM support for servos

- Implement hardware PWM on GPIO 12, 18, 19
- Add frequency and duty cycle controls
- Visual indicator for hardware vs software PWM

Closes #42
```

### Pull Request Process

1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Submit PR with description
5. Code review (1 approver minimum)
6. Merge to `main`

## Testing Procedures

### Manual Testing Checklist

**GPIO Functionality:**
- [ ] Configure pin as input (with pull-up/pull-down)
- [ ] Configure pin as output
- [ ] Toggle output pin (LOW/HIGH)
- [ ] Read input pin value
- [ ] Remove pin configuration

**PWM Functionality:**
- [ ] Configure hardware PWM pin (12, 18, or 19)
- [ ] Configure software PWM pin
- [ ] Set duty cycle (0%, 50%, 100%)
- [ ] Change frequency (50Hz, 1kHz, 10kHz)
- [ ] Verify hardware PWM indicator

**Servo Control:**
- [ ] Configure GPIO 12 as PWM
- [ ] Set frequency to 50Hz
- [ ] Use position presets (0°, 90°, 180°)
- [ ] Test LEFT/RIGHT rotation
- [ ] Verify angle display updates
- [ ] Test step size selector

**UI Responsiveness:**
- [ ] All buttons respond within 100ms
- [ ] No scrolling or overflow
- [ ] Text readable (32-52px for buttons/values)
- [ ] Physical buttons work (F1/F3)

### Test Scripts

Create test scripts in `tests/` directory:

```python
# tests/test_gpio.py
import sys
sys.path.insert(0, '../qt5-app/src')
from GPIOController import GPIOController

def test_configure_output():
    gpio = GPIOController()
    assert gpio.configurePin(17, "output", "none") == True
    assert gpio.writePin(17, 1) == True
    gpio.removePin(17)

if __name__ == "__main__":
    test_configure_output()
    print("GPIO tests passed!")
```

## Code Review Checklist

**Functionality:**
- [ ] Code meets requirements
- [ ] Edge cases handled
- [ ] Error handling implemented
- [ ] No hardcoded values (use constants)

**Quality:**
- [ ] Follows code style guidelines
- [ ] No code duplication
- [ ] Clear variable/function names
- [ ] Comments explain complex logic

**Documentation:**
- [ ] Docstrings for public methods
- [ ] README updated if needed
- [ ] Specification documents updated
- [ ] User guides updated (if UI changes)

**Testing:**
- [ ] Manual testing performed
- [ ] No regressions introduced
- [ ] GPIO cleanup on exit

## Debugging

### Python Debugging

Enable detailed logging:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

Check logs:
```bash
tail -f /tmp/gpio-app.log
```

### QML Debugging

Enable QML console output:
```bash
export QT_LOGGING_RULES="*.debug=true"
python3 main.py
```

### GPIO State Inspection

Check GPIO state:
```bash
# Show configured GPIO pins
gpio readall

# Monitor GPIO changes
watch -n 0.1 'gpio readall'
```

## Performance Guidelines

- **Avoid polling:** Use signals/slots for updates
- **Limit PWM objects:** Reuse instead of recreating
- **Batch updates:** Group GPIO operations
- **Lazy loading:** Load UI components as needed

---

**Owner:** Development Team  
**Review Cycle:** Quarterly
