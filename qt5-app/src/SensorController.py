"""
Sensor Controller for reTerminal
Monitors accelerometer, light sensor, and provides data via Qt signals
"""
import sys
import platform
import time

try:
    from PySide2.QtCore import QThread, QObject, Signal, Slot, Property
except ImportError:
    from PyQt5.QtCore import QThread, QObject, pyqtSignal as Signal, pyqtSlot as Slot, pyqtProperty as Property

# Detect if running on Raspberry Pi
IS_RASPBERRY_PI = platform.machine().startswith('arm') or platform.machine().startswith('aarch')

if IS_RASPBERRY_PI:
    try:
        import seeed_python_reterminal.core as rt
        import seeed_python_reterminal.acceleration as rt_accel
        RETERMINAL_AVAILABLE = True
    except ImportError:
        print("Warning: seeed-python-reterminal not installed. Using mock sensors.")
        RETERMINAL_AVAILABLE = False
else:
    RETERMINAL_AVAILABLE = False


class SensorController(QThread):
    """
    Qt thread that monitors reTerminal sensors
    Emits signals with sensor data at regular intervals
    """
    # Signal: emits JSON string with all sensor data
    # Format: {"timestamp": float, "accel_x": float, "accel_y": float, "accel_z": float, "light": int}
    sensorData = Signal(str)

    def __init__(self, interval_ms=50):
        """
        Initialize sensor controller

        Args:
            interval_ms: Update interval in milliseconds (default 50ms = 20Hz)
        """
        super().__init__()
        self.interval = interval_ms / 1000.0  # Convert to seconds
        self.running = True

        # Initialize sensors
        if RETERMINAL_AVAILABLE:
            try:
                self.accel_device = rt.get_acceleration_device()
                print("[SensorController] Real sensors initialized")
                self.use_mock = False
            except Exception as e:
                print(f"[SensorController] Error initializing sensors: {e}, using mock")
                self.use_mock = True
        else:
            print("[SensorController] Using mock sensors")
            self.use_mock = True

        # State tracking
        self.accel_values = {'X': 0.0, 'Y': 0.0, 'Z': 1.0}  # At rest, Z = 1g
        self.light_value = 300

        # Mock sensor simulation
        if self.use_mock:
            import random
            self.random = random
            self.accel_drift = {'X': 0.0, 'Y': 0.0, 'Z': 0.0}

    def run(self):
        """Main thread loop - reads sensors continuously"""
        print(f"[SensorController] Thread started, monitoring sensors at {1/self.interval:.1f}Hz...")

        while self.running:
            try:
                # Read all sensors
                if not self.use_mock:
                    self._read_real_sensors()
                else:
                    self._read_mock_sensors()

                # Emit sensor data as JSON
                import json
                data = {
                    'timestamp': time.time(),
                    'accel_x': self.accel_values['X'],
                    'accel_y': self.accel_values['Y'],
                    'accel_z': self.accel_values['Z'],
                    'light': self.light_value
                }
                self.sensorData.emit(json.dumps(data))

                # Wait for next interval
                time.sleep(self.interval)

            except Exception as e:
                print(f"[SensorController] Error: {e}")
                time.sleep(self.interval)

        print("[SensorController] Thread stopped")

    def _read_real_sensors(self):
        """Read real sensor values from hardware"""
        try:
            # Read accelerometer
            events = self.accel_device.read()
            for event in events:
                accelEvent = rt_accel.AccelerationEvent(event)
                if accelEvent.name:
                    # Update acceleration values
                    self.accel_values[accelEvent.name.name] = accelEvent.value

            # Read light sensor
            with open('/sys/bus/iio/devices/iio:device0/in_illuminance_input', 'r') as f:
                self.light_value = int(f.read().strip())

        except BlockingIOError:
            # No accelerometer events available - this is normal
            pass
        except Exception as e:
            print(f"[SensorController] Error reading real sensors: {e}")

    def _read_mock_sensors(self):
        """Generate mock sensor values for development"""
        # Mock accelerometer with smooth random motion
        for axis in ['X', 'Y', 'Z']:
            self.accel_drift[axis] += self.random.uniform(-0.05, 0.05)
            self.accel_drift[axis] *= 0.95  # Damping

            # Update value with drift
            self.accel_values[axis] += self.accel_drift[axis]

            # Clamp to realistic range (-2g to +2g)
            self.accel_values[axis] = max(-2.0, min(2.0, self.accel_values[axis]))

        # Z axis should average around 1g (gravity)
        self.accel_values['Z'] = self.accel_values['Z'] * 0.9 + 1.0 * 0.1

        # Mock light sensor - slowly varying
        change = self.random.uniform(-20, 20)
        self.light_value += change
        self.light_value = max(50, min(800, self.light_value))
        self.light_value = int(self.light_value)

    def stop(self):
        """Stop the sensor monitoring thread"""
        print("[SensorController] Stopping...")
        self.running = False


class SensorDataModel(QObject):
    """
    QObject wrapper to expose sensor data to QML
    Receives data from SensorController thread and provides properties
    """
    # Signals for property changes
    accelXChanged = Signal()
    accelYChanged = Signal()
    accelZChanged = Signal()
    lightChanged = Signal()

    def __init__(self):
        super().__init__()
        self._accel_x = 0.0
        self._accel_y = 0.0
        self._accel_z = 1.0
        self._light = 0

    @Slot(str)
    def updateSensorData(self, json_data):
        """
        Update sensor data from JSON string

        Args:
            json_data: JSON string with sensor data
        """
        import json
        try:
            data = json.loads(json_data)

            # Update accelerometer
            if data['accel_x'] != self._accel_x:
                self._accel_x = data['accel_x']
                self.accelXChanged.emit()

            if data['accel_y'] != self._accel_y:
                self._accel_y = data['accel_y']
                self.accelYChanged.emit()

            if data['accel_z'] != self._accel_z:
                self._accel_z = data['accel_z']
                self.accelZChanged.emit()

            # Update light
            if data['light'] != self._light:
                self._light = data['light']
                self.lightChanged.emit()

        except Exception as e:
            print(f"[SensorDataModel] Error updating data: {e}")

    # Qt Properties for QML access
    @Property(float, notify=accelXChanged)
    def accelX(self):
        return self._accel_x

    @Property(float, notify=accelYChanged)
    def accelY(self):
        return self._accel_y

    @Property(float, notify=accelZChanged)
    def accelZ(self):
        return self._accel_z

    @Property(int, notify=lightChanged)
    def light(self):
        return self._light
