# reTerminal GPIO Control System - UI/UX Specification

**Version:** 1.0.0  
**Last Updated:** 2026-01-07

## Design Principles

1. **Touch-First Design**: All interactions optimized for touchscreen (minimum 44px targets)
2. **No Scrolling**: All content fits within 720x1280 viewport
3. **Immediate Feedback**: Visual response to all user actions within 100ms
4. **Color-Coded Status**: Consistent color scheme for pin states and modes
5. **Large, Readable Text**: Button text 32-52px, values 40-52px

## Screen Layouts

### GPIO Screen (GPIOScreen.qml)

**Layout:** 45% pin grid (left) | 55% control panel (right)

**Pin Grid (Left Panel):**
- 28 GPIO pins displayed in Flow layout
- Pin size: 70x70px with 10px spacing
- States:
  - **Available**: Dark background (#1a1f3a), cyan border (#00f3ff)
  - **Reserved**: Dark red (#1a0a0a), pink border (#ff006e), 40% opacity
  - **Hardware PWM**: Orange border (#ffa500), 3px width, "HW PWM" label
  - **Configured**: Green (#0a2e0a) background, green border (#00ff41), shows mode/value

**Control Panel (Right Panel):**
- Dynamically displays:
  - PinControlPanel (when pin selected)
  - Configuration Dialog (when adding new pin)
  - Placeholder (when nothing selected)

### Pin Control Panel (PinControlPanel.qml)

**Sections (Vertical Layout):**

1. **Header** (40px height)
   - Pin number (22px font, monospace)
   - Close button (40x40px, "×" symbol)

2. **Pin Info** (75px height)
   - Mode indicator (13px font)
   - Pull resistor (input mode only)
   - Current value/duty cycle

3. **Output Controls** (visible: mode === "output")
   - LOW/HIGH buttons: 50px height, 32px font
   - TOGGLE button: 50px height, 36px font

4. **PWM Controls** (visible: mode === "pwm")
   - PWM type indicator: 30px height, shows "⚡ HARDWARE PWM" or "SOFTWARE PWM"
   - Duty cycle slider + percentage (40px font)
   - Frequency presets: 4 buttons, 38px height, 28px font
   - Servo controls (if 45-55Hz)

5. **Servo Controls** (visible: frequency 45-55Hz)
   - Angle display: 50px height, 52px font
   - Position presets: 5 buttons (0°, 45°, 90°, 135°, 180°), 32px height, 26px font
   - LEFT/RIGHT buttons: 45px height, arrow 40px, label 24px font
   - Step selector: Shows current step size, 40px font

6. **Remove Button** (50px height, 36px font)

### Sensor Screen (SensorScreen.qml)

**Layout:** Vertical stack
- Temperature display (large font, 48px)
- Humidity display (large font, 48px)
- Graph visualization (line chart, 60-second history)
- Status indicator (sensor connection state)

## Color Palette

| Element | Color Code | Usage |
|---------|-----------|-------|
| Background Dark | `#1a1f3a` | Main backgrounds |
| Background Darker | `#0f1428` | Cards, panels |
| Primary Cyan | `#00f3ff` | Interactive elements, highlights |
| Success Green | `#00ff41` | Configured pins, active states |
| Warning Orange | `#ffa500` | PWM indicators, hardware PWM |
| Error Pink | `#ff006e` | Reserved pins, remove button |
| Text White | `#fff` | Primary text |
| Text Gray | `#888` | Secondary text, labels |
| Text Dark Gray | `#555` | Disabled text |
| Border Gray | `#666` | Subtle borders |
| Divider | `#444` | Section separators |

## Typography

**Fonts:**
- **Monospace**: Pin numbers, values, technical info
- **Default**: All other text

**Sizes:**
| Element | Size | Weight |
|---------|------|--------|
| Button Text | 32-36px | Bold |
| Value Display | 40-52px | Bold |
| Headers | 14-22px | Bold |
| Labels | 11-14px | Normal/Bold |
| Descriptions | 8-11px | Normal |

## Touch Interaction Patterns

### Tap
- **Pin Selection**: Tap pin in grid to select
- **Button Activation**: Tap button to trigger action
- **Toggle**: Tap to switch state

### Drag
- **Slider Control**: Drag PWM duty cycle handle
- **Custom Positioning**: Direct manipulation of values

### Visual Feedback
- **Button Press**: Color inversion or fill change
- **Selection**: Border highlight + background change
- **Active State**: Color fill indicating current selection
- **Disabled**: 40% opacity, no interaction

## Accessibility

- Minimum touch target: 44x44px (WCAG AA)
- Color contrast ratio: >4.5:1 for text
- Large text for readability (32-52px for critical info)
- Clear visual states (not relying on color alone)

---

**Owner:** UX Team  
**Review Cycle:** On UI changes
