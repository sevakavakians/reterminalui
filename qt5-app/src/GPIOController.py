"""
GPIO Controller for reTerminal
Qt-enabled wrapper around RPi.GPIO with signals for real-time updates
"""
import sys
import platform
from typing import List, Dict, Optional

try:
    from PySide2.QtCore import QObject, Signal, Slot, Property
except ImportError:
    from PyQt5.QtCore import QObject, pyqtSignal as Signal, pyqtSlot as Slot, pyqtProperty as Property

# Detect if running on Raspberry Pi
IS_RASPBERRY_PI = platform.machine().startswith('arm') or platform.machine().startswith('aarch')

if IS_RASPBERRY_PI:
    try:
        import RPi.GPIO as GPIO
        GPIO_AVAILABLE = True
    except ImportError:
        print("Warning: RPi.GPIO not available, using mock mode")
        GPIO_AVAILABLE = False
else:
    GPIO_AVAILABLE = False
    print("Running on non-Raspberry Pi platform, using mock mode")


class GPIOController(QObject):
    """
    GPIO controller with Qt signals for real-time updates
    Manages pin configuration, reading, and writing
    """

    # Signals
    pinsChanged = Signal()  # Emitted when pin configuration changes
    pinValueChanged = Signal(int, int)  # Emitted when a pin value changes (pin, value)
    errorOccurred = Signal(str)  # Emitted when an error occurs

    def __init__(self):
        super().__init__()

        # Pin state tracking
        self._configured_pins = []  # List of configured pin numbers
        self._pin_modes = {}  # {pin: 'input', 'output', or 'pwm'}
        self._pin_values = {}  # {pin: value}
        self._pin_pull_modes = {}  # {pin: 'up', 'down', or 'none'}

        # PWM tracking
        self._pin_pwm = {}  # {pin: PWM object}
        self._pin_pwm_frequency = {}  # {pin: frequency in Hz}
        self._pin_pwm_duty_cycle = {}  # {pin: duty cycle 0-100}

        # Reserved pins (used by reTerminal hardware)
        # GPIO 2, 3: I2C bus (touchscreen, accelerometer, light sensor, RTC, crypto chip, IO expander)
        # GPIO 6: USB hub (HUB_DM3)
        # GPIO 13: USB hub (HUB_DP3)
        self._reserved_pins = [2, 3, 6, 13]

        # Hardware PWM capable pins (BCM2711)
        # GPIO 12, 18: PWM0 (channel 0)
        # GPIO 19: PWM1 (channel 1)
        # Note: GPIO 13 is also PWM1 but reserved for USB hub
        self._hardware_pwm_pins = [12, 18, 19]

        # Available GPIO pins on Raspberry Pi
        # BCM numbering
        # Note: GPIO 0, 1 (ID EEPROM), GPIO 14, 15 (UART) can be used with caution
        self._available_pins = [4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]

        # Initialize GPIO if available
        if GPIO_AVAILABLE:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            print("[GPIOController] Initialized with RPi.GPIO")
        else:
            print("[GPIOController] Running in mock mode")

    @Slot(result=str)
    def getAvailablePins(self):
        """Get list of available pins as JSON string"""
        import json
        return json.dumps(self._available_pins)

    @Slot(result=str)
    def getConfiguredPins(self):
        """Get list of configured pins with their info as JSON string"""
        import json
        pins_info = []
        for pin in self._configured_pins:
            info = {
                'pin': pin,
                'mode': self._pin_modes.get(pin, 'unknown'),
                'value': self._pin_values.get(pin, 0),
                'pull_mode': self._pin_pull_modes.get(pin, 'none'),
                'pwm_enabled': pin in self._pin_pwm,
                'pwm_frequency': self._pin_pwm_frequency.get(pin, 0),
                'pwm_duty_cycle': self._pin_pwm_duty_cycle.get(pin, 0),
                'hardware_pwm': pin in self._hardware_pwm_pins
            }
            pins_info.append(info)
        return json.dumps(pins_info)

    @Slot(result=str)
    def getReservedPins(self):
        """Get list of reserved pins as JSON string"""
        import json
        return json.dumps(self._reserved_pins)

    @Slot(result=str)
    def getHardwarePWMPins(self):
        """Get list of hardware PWM capable pins as JSON string"""
        import json
        return json.dumps(self._hardware_pwm_pins)

    @Slot(int, str, str, result=bool)
    def configurePin(self, pin, mode, pull_mode='none'):
        """
        Configure a GPIO pin

        Args:
            pin: Pin number (BCM)
            mode: 'input' or 'output'
            pull_mode: 'up', 'down', or 'none' (for input pins)

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Validate pin
            if pin in self._reserved_pins:
                self.errorOccurred.emit(f"Pin {pin} is reserved by reTerminal hardware")
                return False

            if pin not in self._available_pins:
                self.errorOccurred.emit(f"Pin {pin} is not a valid GPIO pin")
                return False

            # Cleanup if already configured
            if pin in self._configured_pins:
                self._cleanupPin(pin)

            # Configure pin
            if GPIO_AVAILABLE:
                if mode == 'input':
                    # Set pull mode
                    pull = GPIO.PUD_OFF
                    if pull_mode == 'up':
                        pull = GPIO.PUD_UP
                    elif pull_mode == 'down':
                        pull = GPIO.PUD_DOWN

                    GPIO.setup(pin, GPIO.IN, pull_up_down=pull)
                    value = GPIO.input(pin)
                elif mode == 'output':
                    GPIO.setup(pin, GPIO.OUT)
                    GPIO.output(pin, GPIO.LOW)
                    value = 0
                elif mode == 'pwm':
                    # Setup as output first
                    GPIO.setup(pin, GPIO.OUT)
                    GPIO.output(pin, GPIO.LOW)

                    # Create PWM object with default frequency
                    default_freq = 1000  # 1kHz default
                    pwm = GPIO.PWM(pin, default_freq)
                    pwm.start(0)  # Start with 0% duty cycle

                    # Store PWM object and settings
                    self._pin_pwm[pin] = pwm
                    self._pin_pwm_frequency[pin] = default_freq
                    self._pin_pwm_duty_cycle[pin] = 0
                    value = 0

                    pwm_type = "Hardware" if pin in self._hardware_pwm_pins else "Software"
                    print(f"[GPIOController] Started {pwm_type} PWM on pin {pin} at {default_freq}Hz")
                else:
                    self.errorOccurred.emit(f"Invalid mode: {mode}")
                    return False
            else:
                # Mock mode
                value = 0

            # Update state
            self._configured_pins.append(pin)
            self._pin_modes[pin] = mode
            self._pin_values[pin] = value
            self._pin_pull_modes[pin] = pull_mode

            print(f"[GPIOController] Configured pin {pin} as {mode} (pull={pull_mode})")
            self.pinsChanged.emit()
            return True

        except Exception as e:
            error_msg = f"Error configuring pin {pin}: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, result=bool)
    def removePin(self, pin):
        """
        Remove a pin configuration

        Args:
            pin: Pin number (BCM)

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            if pin not in self._configured_pins:
                return False

            self._cleanupPin(pin)

            # Update state
            self._configured_pins.remove(pin)
            del self._pin_modes[pin]
            del self._pin_values[pin]
            if pin in self._pin_pull_modes:
                del self._pin_pull_modes[pin]

            print(f"[GPIOController] Removed pin {pin}")
            self.pinsChanged.emit()
            return True

        except Exception as e:
            error_msg = f"Error removing pin {pin}: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, int, result=bool)
    def writePin(self, pin, value):
        """
        Write a value to an output pin

        Args:
            pin: Pin number (BCM)
            value: 0 (LOW) or 1 (HIGH)

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            if pin not in self._configured_pins:
                self.errorOccurred.emit(f"Pin {pin} is not configured")
                return False

            if self._pin_modes.get(pin) != 'output':
                self.errorOccurred.emit(f"Pin {pin} is not configured as output")
                return False

            if GPIO_AVAILABLE:
                GPIO.output(pin, GPIO.HIGH if value else GPIO.LOW)

            self._pin_values[pin] = value
            print(f"[GPIOController] Write pin {pin} = {value}")
            self.pinValueChanged.emit(pin, value)
            return True

        except Exception as e:
            error_msg = f"Error writing to pin {pin}: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, result=int)
    def readPin(self, pin):
        """
        Read a value from an input pin

        Args:
            pin: Pin number (BCM)

        Returns:
            int: Pin value (0 or 1), or -1 on error
        """
        try:
            if pin not in self._configured_pins:
                return -1

            if self._pin_modes.get(pin) != 'input':
                return -1

            if GPIO_AVAILABLE:
                value = GPIO.input(pin)
            else:
                # Mock mode - return previous value
                value = self._pin_values.get(pin, 0)

            # Update cached value if changed
            if value != self._pin_values.get(pin):
                self._pin_values[pin] = value
                self.pinValueChanged.emit(pin, value)

            return value

        except Exception as e:
            print(f"[GPIOController] Error reading pin {pin}: {str(e)}")
            return -1

    @Slot(result=bool)
    def cleanupAll(self):
        """
        Cleanup all configured pins

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            # Cleanup all pins
            for pin in list(self._configured_pins):
                self._cleanupPin(pin)

            # Clear state
            self._configured_pins.clear()
            self._pin_modes.clear()
            self._pin_values.clear()
            self._pin_pull_modes.clear()
            self._pin_pwm.clear()
            self._pin_pwm_frequency.clear()
            self._pin_pwm_duty_cycle.clear()

            print("[GPIOController] Cleaned up all pins")
            self.pinsChanged.emit()
            return True

        except Exception as e:
            error_msg = f"Error during cleanup: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    def _cleanupPin(self, pin):
        """Internal: cleanup a single pin"""
        # Stop PWM if running
        if pin in self._pin_pwm:
            try:
                self._pin_pwm[pin].stop()
                del self._pin_pwm[pin]
                if pin in self._pin_pwm_frequency:
                    del self._pin_pwm_frequency[pin]
                if pin in self._pin_pwm_duty_cycle:
                    del self._pin_pwm_duty_cycle[pin]
            except Exception as e:
                print(f"[GPIOController] Warning: Error stopping PWM on pin {pin}: {e}")

        if GPIO_AVAILABLE:
            try:
                GPIO.cleanup(pin)
            except Exception as e:
                print(f"[GPIOController] Warning: Error cleaning up pin {pin}: {e}")

    def cleanup(self):
        """Cleanup on exit"""
        print("[GPIOController] Shutting down...")
        self.cleanupAll()
        if GPIO_AVAILABLE:
            GPIO.cleanup()

    @Slot(int, float, result=bool)
    def setPWMDutyCycle(self, pin, duty_cycle):
        """
        Set PWM duty cycle for a pin

        Args:
            pin: Pin number (BCM)
            duty_cycle: Duty cycle percentage (0.0-100.0)

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            if pin not in self._pin_pwm:
                self.errorOccurred.emit(f"Pin {pin} is not configured for PWM")
                return False

            # Clamp duty cycle to valid range
            duty_cycle = max(0.0, min(100.0, duty_cycle))

            if GPIO_AVAILABLE:
                self._pin_pwm[pin].ChangeDutyCycle(duty_cycle)

            self._pin_pwm_duty_cycle[pin] = duty_cycle
            print(f"[GPIOController] Set PWM duty cycle on pin {pin} to {duty_cycle}%")
            self.pinsChanged.emit()
            return True

        except Exception as e:
            error_msg = f"Error setting PWM duty cycle on pin {pin}: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False

    @Slot(int, float, result=bool)
    def setPWMFrequency(self, pin, frequency):
        """
        Set PWM frequency for a pin

        Args:
            pin: Pin number (BCM)
            frequency: Frequency in Hz (0.1-100000)

        Returns:
            bool: True if successful, False otherwise
        """
        try:
            if pin not in self._pin_pwm:
                self.errorOccurred.emit(f"Pin {pin} is not configured for PWM")
                return False

            # Clamp frequency to valid range
            frequency = max(0.1, min(100000.0, frequency))

            if GPIO_AVAILABLE:
                self._pin_pwm[pin].ChangeFrequency(frequency)

            self._pin_pwm_frequency[pin] = frequency
            print(f"[GPIOController] Set PWM frequency on pin {pin} to {frequency}Hz")
            self.pinsChanged.emit()
            return True

        except Exception as e:
            error_msg = f"Error setting PWM frequency on pin {pin}: {str(e)}"
            print(f"[GPIOController] {error_msg}")
            self.errorOccurred.emit(error_msg)
            return False
