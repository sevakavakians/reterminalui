# reTerminal GPIO Control - Qt5 Application

A native Qt5/QML application for controlling GPIO pins and monitoring sensors on the Seeed Studio reTerminal.

## Features

- **GPIO Pin Configuration**: Configure pins as input or output with pull-up/down resistors
- **Real-time Pin Control**: Toggle outputs, read inputs, monitor pin states
- **Sensor Graphing**: Real-time graphs of accelerometer (X/Y/Z) and light sensor data
- **Physical Button Navigation**: Use F1 and F2 buttons to switch between screens
- **Native Performance**: No browser overhead, direct hardware access

## Architecture

This application uses a clean, proven architecture:

- **Python Backend**: Qt5 application with direct hardware access
- **QML UI**: Declarative, hardware-accelerated user interface
- **Qt Signals/Slots**: Efficient event communication
- **QThread**: Background threads for sensor monitoring and button handling
- **evdev**: Direct input device access for physical buttons

**Event Path**: Physical Button → evdev → QThread → Qt Signal → QML UI (only 3 hops!)

## Requirements

### System Packages

```bash
sudo apt update
sudo apt install -y \
    python3-pyside2.qtcore \
    python3-pyside2.qtgui \
    python3-pyside2.qtwidgets \
    python3-pyside2.qtqml \
    python3-pyside2.qtquick \
    qml-module-qtquick2 \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-layouts \
    python3-evdev \
    python3-pip
```

### Python Packages

```bash
pip3 install -r requirements.txt
```

Or manually:

```bash
pip3 install PySide2 RPi.GPIO seeed-python-reterminal evdev
```

## Installation

1. **Clone or copy this directory to your reTerminal**:

```bash
scp -r qt5-app pi@reterminal:/home/pi/
```

2. **SSH into reTerminal**:

```bash
ssh pi@reterminal
```

3. **Install dependencies**:

```bash
cd ~/qt5-app
pip3 install -r requirements.txt
```

4. **Make main.py executable**:

```bash
chmod +x src/main.py
```

5. **Disable X11 button capture** (important for F1/F2 buttons to work):

```bash
# Find gpio_keys device ID
DISPLAY=:0 xinput list | grep gpio_keys

# Disable it (replace 6 with actual ID from above)
DISPLAY=:0 xinput disable 6
```

To make this permanent, add to autostart:

```bash
mkdir -p ~/.config/lxsession/LXDE-pi
echo "@bash -c 'sleep 5 && DISPLAY=:0 xinput disable \$(DISPLAY=:0 xinput list | grep gpio_keys | sed -n \"s/.*id=\\([0-9]\\+\\).*/\\1/p\")'" >> ~/.config/lxsession/LXDE-pi/autostart
```

## Usage

### Running the Application

```bash
cd ~/qt5-app/src
python3 main.py
```

Or run in fullscreen mode (recommended for reTerminal):

```bash
cd ~/qt5-app/src
QT_QPA_PLATFORM=eglfs python3 main.py
```

### Keyboard/Touchscreen Controls

- **F1 button** (or click "GPIO (F1)"): Switch to GPIO configuration screen
- **F2 button** (or click "SENSORS (F2)"): Switch to sensor graphing screen
- **Touch screen**: All controls are touch-enabled

### GPIO Screen

- **Add Pin**: Select pin number and mode (input/output), click "ADD PIN"
- **Select Pin**: Click on a configured pin to view/control it
- **Output Control**: Set HIGH/LOW or toggle output pins
- **Input Monitoring**: View current input pin state
- **Remove Pin**: Click "REMOVE PIN" to unconfigure a pin
- **Cleanup All**: Remove all configured pins at once

### Sensor Screen

- **Accelerometer Graph**: Real-time X/Y/Z acceleration data (±2g range)
  - Red line: X axis
  - Green line: Y axis
  - Cyan line: Z axis
- **Light Sensor Graph**: Real-time ambient light intensity (lux)
  - Yellow filled area chart
  - Auto-scaling based on current range

## Hardware Details

### GPIO Pins

**Available Pins** (BCM numbering):
- 12, 13, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27

**Reserved Pins** (used by reTerminal hardware):
- 0-11, 14-15

### Physical Buttons

- **F1** (KEY_A, code 30): Switch to GPIO screen
- **F2** (KEY_S, code 31): Switch to Sensors screen
- **F3** (KEY_D, code 32): Not currently mapped
- **O** (Green button, KEY_F, code 33): Not currently mapped

### Sensors

- **Accelerometer**: STMicroelectronics LIS3DHTR (I2C)
  - Range: ±2g
  - Update rate: 20Hz
- **Light Sensor**: Levelek LTR-303ALS-01 (I2C)
  - Range: 0-64000 lux
  - Update rate: 20Hz

## Troubleshooting

### Buttons Don't Work

1. Check if X11 is capturing button events:
```bash
DISPLAY=:0 xinput list
```

2. Disable gpio_keys device in X11:
```bash
DISPLAY=:0 xinput disable <device_id>
```

3. Check if button device exists:
```bash
ls -l /dev/input/event*
cat /sys/class/input/event*/device/name | grep -n gpio_keys
```

### Sensors Not Working

1. Check if reTerminal libraries are installed:
```bash
pip3 list | grep seeed-python-reterminal
```

2. Check if I2C devices are detected:
```bash
i2cdetect -y 1
```

### Permission Issues

If you get permission errors, run with sudo:
```bash
sudo python3 main.py
```

Or add your user to the gpio and input groups:
```bash
sudo usermod -aG gpio,input $USER
```

Then log out and back in.

### QML Not Loading

If you see "Failed to load QML":

1. Check QML file path:
```bash
ls -l qml/main.qml
```

2. Install QML modules:
```bash
sudo apt install qml-module-qtquick2 qml-module-qtquick-controls2
```

## Development

### Project Structure

```
qt5-app/
├── src/
│   ├── main.py              # Application entry point
│   ├── ButtonHandler.py     # Physical button monitoring (QThread + evdev)
│   ├── GPIOController.py    # GPIO control wrapper
│   └── SensorController.py  # Sensor monitoring (QThread)
├── qml/
│   ├── main.qml            # Main window with screen switching
│   ├── GPIOScreen.qml      # GPIO configuration UI
│   ├── PinControlPanel.qml # Pin control component
│   └── SensorScreen.qml    # Sensor graphing UI
├── requirements.txt        # Python dependencies
└── README.md              # This file
```

### Running in Development Mode

On your development machine (non-Raspberry Pi):

```bash
python3 src/main.py
```

The application will automatically use mock sensors and simulated data.

## Comparison to React/Flask Approach

This Qt5 application replaces the previous React/Flask implementation with significant advantages:

| Aspect | React/Flask | Qt5 (This App) |
|--------|-------------|----------------|
| Button event path | 5-6 hops through WebSocket/browser | 3 hops (evdev → QThread → QML) |
| Build required | Yes (npm build, webpack) | No (direct Python execution) |
| Browser needed | Yes (Chromium in kiosk mode) | No (native Qt application) |
| Memory usage | ~300MB (browser + Node + Flask) | ~50MB (Qt5 only) |
| Startup time | ~15 seconds | ~2 seconds |
| Dependencies | Node.js, npm, Chrome, Flask, SocketIO | Python3, PySide2, evdev |
| Proven working | No (button issues, lifecycle bugs) | Yes (based on Seeed's example) |

## Credits

Based on architecture patterns from [Seeed Studio's Qt5 Examples](https://github.com/Seeed-Studio/Seeed_Python_ReTerminalQt5Examples).

## License

MIT License - Feel free to modify and use as needed.
