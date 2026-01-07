#!/usr/bin/env python3
"""
reTerminal GPIO Control - Qt5 Application
Main application entry point
"""
import os
import sys
import platform
import logging

# Qt imports - support both PySide2 and PyQt5
try:
    from PySide2.QtQml import QQmlApplicationEngine
    from PySide2.QtWidgets import QApplication
    from PySide2.QtCore import QUrl, QObject, Signal, Slot
    print("Using PySide2")
except ImportError:
    from PyQt5.QtQml import QQmlApplicationEngine
    from PyQt5.QtWidgets import QApplication
    from PyQt5.QtCore import QUrl, QObject, pyqtSignal as Signal, pyqtSlot as Slot
    print("Using PyQt5")

# Import our controllers
from ButtonHandler import ButtonHandler
from GPIOController import GPIOController
from SensorController import SensorController, SensorDataModel

# Logging setup
LOG_FORMAT = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)


class AppController(QObject):
    """
    Main application controller
    Coordinates button events, screen navigation, and data flow
    """
    # Signal to change screen
    screenChanged = Signal(str)  # 'gpio' or 'sensors'

    def __init__(self):
        super().__init__()
        self._current_screen = 'gpio'

    @Slot(str, str)
    def handleButtonEvent(self, button, state):
        """
        Handle button press events

        Args:
            button: Button name ('F1', 'F2', 'F3', 'O')
            state: Button state ('pressed' or 'released')
        """
        # Only act on button press (not release)
        if state != 'pressed':
            return

        print(f"[AppController] Button {button} pressed")

        # F1 = GPIO screen, F2 = Sensors screen
        if button == 'F1':
            print("[AppController] Switching to GPIO screen")
            self._current_screen = 'gpio'
            self.screenChanged.emit('gpio')
        elif button == 'F2':
            print("[AppController] Switching to Sensors screen")
            self._current_screen = 'sensors'
            self.screenChanged.emit('sensors')

    @Slot(result=str)
    def getCurrentScreen(self):
        """Get current screen name"""
        return self._current_screen


def find_button_device():
    """
    Auto-discover the gpio_keys input device
    Returns device path or None if not found
    """
    device_file_path = '/sys/class/input/'
    input_dev_path = '/dev/input/'

    if not os.path.exists(device_file_path):
        print("[main] Warning: /sys/class/input/ not found, assuming development mode")
        return None

    try:
        # Scan input devices
        for entry in os.listdir(device_file_path):
            if entry.startswith('event'):
                name_path = os.path.join(device_file_path, entry, 'device', 'name')

                if os.path.isfile(name_path):
                    try:
                        with open(name_path, 'r') as f:
                            dev_name = f.read().strip()

                            if dev_name == 'gpio_keys':
                                device_path = os.path.join(input_dev_path, entry)
                                print(f"[main] Found gpio_keys device: {device_path}")
                                return device_path
                    except Exception as e:
                        print(f"[main] Error reading {name_path}: {e}")

        print("[main] Warning: gpio_keys device not found")
        return None

    except Exception as e:
        print(f"[main] Error discovering button device: {e}")
        return None


def main():
    """Main application entry point"""
    print("=" * 60)
    print("reTerminal GPIO Control - Qt5 Application")
    print("=" * 60)

    # Create Qt application
    app = QApplication(sys.argv)
    app.setApplicationName("reTerminal GPIO Control")

    # Create QML engine
    engine = QQmlApplicationEngine()

    # Create controllers
    gpio_controller = GPIOController()
    sensor_data_model = SensorDataModel()
    app_controller = AppController()

    # Expose controllers to QML
    context = engine.rootContext()
    context.setContextProperty("gpioController", gpio_controller)
    context.setContextProperty("sensorData", sensor_data_model)
    context.setContextProperty("appController", app_controller)

    # Auto-discover and initialize button handler
    button_device_path = find_button_device()
    if button_device_path:
        button_handler = ButtonHandler(button_device_path)
        # Connect button events to app controller
        button_handler.buttonEvent.connect(app_controller.handleButtonEvent)
        button_handler.start()
        print("[main] Button handler started")
    else:
        print("[main] Running without button handler (development mode)")
        button_handler = None

    # Initialize sensor controller
    sensor_controller = SensorController(interval_ms=50)  # 20Hz update rate
    # Connect sensor data to model
    sensor_controller.sensorData.connect(sensor_data_model.updateSensorData)
    sensor_controller.start()
    print("[main] Sensor controller started")

    # Load QML UI
    qml_file = os.path.join(os.path.dirname(__file__), '../qml/main.qml')
    qml_url = QUrl.fromLocalFile(qml_file)

    print(f"[main] Loading QML from: {qml_file}")
    engine.load(qml_url)

    # Check if QML loaded successfully
    if not engine.rootObjects():
        print("[main] ERROR: Failed to load QML")
        return 1

    print("[main] Application started successfully")
    print("  - Press F1 for GPIO configuration screen")
    print("  - Press F2 for sensor graphing screen")
    print("=" * 60)

    # Run application
    exit_code = app.exec_()

    # Cleanup
    print("[main] Shutting down...")
    sensor_controller.stop()
    if button_handler:
        button_handler.stop()
    gpio_controller.cleanup()

    return exit_code


if __name__ == '__main__':
    sys.exit(main())
