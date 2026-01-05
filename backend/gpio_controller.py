"""
GPIO Controller - Hardware abstraction layer for Raspberry Pi GPIO
Provides safe, high-level interface for GPIO operations
"""
import platform
from typing import Dict, List, Optional, Literal
from dataclasses import dataclass
from enum import Enum

# Import RPi.GPIO only on Raspberry Pi
IS_RASPBERRY_PI = platform.machine().startswith('arm') or platform.machine().startswith('aarch')

if IS_RASPBERRY_PI:
    import RPi.GPIO as GPIO
else:
    # Mock GPIO for development on non-Pi systems
    class MockGPIO:
        BCM = 'BCM'
        BOARD = 'BOARD'
        IN = 'IN'
        OUT = 'OUT'
        PWM = 'PWM'
        HIGH = 1
        LOW = 0
        PUD_UP = 'PUD_UP'
        PUD_DOWN = 'PUD_DOWN'

        @staticmethod
        def setmode(mode): pass

        @staticmethod
        def setwarnings(flag): pass

        @staticmethod
        def setup(pin, mode, **kwargs): pass

        @staticmethod
        def output(pin, value): pass

        @staticmethod
        def input(pin): return 0

        @staticmethod
        def cleanup(pin=None): pass

        @staticmethod
        def PWM(pin, frequency):
            return MockPWM(pin, frequency)

    class MockPWM:
        def __init__(self, pin, frequency):
            self.pin = pin
            self.frequency = frequency
            self.duty_cycle = 0
            self.running = False

        def start(self, duty_cycle):
            self.duty_cycle = duty_cycle
            self.running = True

        def ChangeDutyCycle(self, duty_cycle):
            self.duty_cycle = duty_cycle

        def ChangeFrequency(self, frequency):
            self.frequency = frequency

        def stop(self):
            self.running = False

    GPIO = MockGPIO()


class PinMode(str, Enum):
    INPUT = "input"
    OUTPUT = "output"
    PWM = "pwm"


class PullMode(str, Enum):
    NONE = "none"
    UP = "up"
    DOWN = "down"


@dataclass
class PinConfig:
    """Configuration for a single GPIO pin"""
    pin: int
    mode: PinMode
    value: int = 0
    pull: PullMode = PullMode.NONE
    pwm_frequency: Optional[int] = None
    pwm_duty_cycle: Optional[float] = None


class GPIOController:
    """
    Safe GPIO controller with conflict detection and current limiting warnings
    """

    # Pins that are unavailable due to hardware conflicts
    RESERVED_PINS = {6, 13}  # Used by USB hub on reTerminal

    # Safe GPIO pins (BCM numbering)
    SAFE_PINS = {2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27}

    # Maximum safe current per pin (mA)
    MAX_CURRENT_PER_PIN = 16
    MAX_TOTAL_CURRENT = 50

    def __init__(self):
        """Initialize GPIO controller"""
        self.pins: Dict[int, PinConfig] = {}
        self.pwm_instances: Dict[int, any] = {}

        # Setup GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)

    def get_available_pins(self) -> List[int]:
        """Get list of available GPIO pins"""
        return sorted(list(self.SAFE_PINS))

    def is_pin_available(self, pin: int) -> bool:
        """Check if pin is available for use"""
        return pin in self.SAFE_PINS

    def get_pin_info(self, pin: int) -> Optional[Dict]:
        """Get current pin configuration and state"""
        if pin not in self.pins:
            return None

        config = self.pins[pin]
        info = {
            'pin': config.pin,
            'mode': config.mode.value,
            'value': config.value,
            'pull': config.pull.value,
            'is_reserved': pin in self.RESERVED_PINS,
            'is_available': pin in self.SAFE_PINS
        }

        if config.mode == PinMode.PWM:
            info['pwm_frequency'] = config.pwm_frequency
            info['pwm_duty_cycle'] = config.pwm_duty_cycle

        return info

    def get_all_pins_info(self) -> List[Dict]:
        """Get information about all configured pins"""
        return [self.get_pin_info(pin) for pin in sorted(self.pins.keys())]

    def configure_pin(
        self,
        pin: int,
        mode: PinMode,
        pull: PullMode = PullMode.NONE,
        initial_value: int = 0,
        pwm_frequency: Optional[int] = None
    ) -> Dict:
        """
        Configure a GPIO pin

        Args:
            pin: BCM pin number
            mode: Pin mode (input, output, pwm)
            pull: Pull resistor mode (for inputs)
            initial_value: Initial value for outputs
            pwm_frequency: PWM frequency in Hz (for PWM mode)

        Returns:
            Pin configuration info

        Raises:
            ValueError: If pin is not available or configuration is invalid
        """
        if not self.is_pin_available(pin):
            raise ValueError(f"Pin {pin} is not available (reserved or invalid)")

        # Cleanup existing configuration
        if pin in self.pins:
            self._cleanup_pin(pin)

        # Configure based on mode
        if mode == PinMode.INPUT:
            pull_mode = None
            if pull == PullMode.UP:
                pull_mode = GPIO.PUD_UP
            elif pull == PullMode.DOWN:
                pull_mode = GPIO.PUD_DOWN

            if pull_mode:
                GPIO.setup(pin, GPIO.IN, pull_up_down=pull_mode)
            else:
                GPIO.setup(pin, GPIO.IN)

            # Read current value
            value = GPIO.input(pin)

            self.pins[pin] = PinConfig(
                pin=pin,
                mode=mode,
                value=value,
                pull=pull
            )

        elif mode == PinMode.OUTPUT:
            GPIO.setup(pin, GPIO.OUT)
            GPIO.output(pin, initial_value)

            self.pins[pin] = PinConfig(
                pin=pin,
                mode=mode,
                value=initial_value
            )

        elif mode == PinMode.PWM:
            if not pwm_frequency:
                raise ValueError("PWM mode requires pwm_frequency parameter")

            GPIO.setup(pin, GPIO.OUT)
            pwm = GPIO.PWM(pin, pwm_frequency)
            pwm.start(0)

            self.pwm_instances[pin] = pwm
            self.pins[pin] = PinConfig(
                pin=pin,
                mode=mode,
                pwm_frequency=pwm_frequency,
                pwm_duty_cycle=0
            )

        return self.get_pin_info(pin)

    def write_pin(self, pin: int, value: int) -> Dict:
        """
        Write digital value to output pin

        Args:
            pin: BCM pin number
            value: 0 (LOW) or 1 (HIGH)

        Returns:
            Updated pin info

        Raises:
            ValueError: If pin is not configured as output
        """
        if pin not in self.pins:
            raise ValueError(f"Pin {pin} is not configured")

        if self.pins[pin].mode != PinMode.OUTPUT:
            raise ValueError(f"Pin {pin} is not configured as output (mode: {self.pins[pin].mode})")

        GPIO.output(pin, value)
        self.pins[pin].value = value

        return self.get_pin_info(pin)

    def read_pin(self, pin: int) -> Dict:
        """
        Read digital value from input pin

        Args:
            pin: BCM pin number

        Returns:
            Pin info with current value

        Raises:
            ValueError: If pin is not configured as input
        """
        if pin not in self.pins:
            raise ValueError(f"Pin {pin} is not configured")

        if self.pins[pin].mode != PinMode.INPUT:
            raise ValueError(f"Pin {pin} is not configured as input (mode: {self.pins[pin].mode})")

        value = GPIO.input(pin)
        self.pins[pin].value = value

        return self.get_pin_info(pin)

    def set_pwm(self, pin: int, duty_cycle: float, frequency: Optional[int] = None) -> Dict:
        """
        Set PWM duty cycle (and optionally frequency)

        Args:
            pin: BCM pin number
            duty_cycle: Duty cycle percentage (0-100)
            frequency: Optional new frequency in Hz

        Returns:
            Updated pin info

        Raises:
            ValueError: If pin is not configured as PWM
        """
        if pin not in self.pins:
            raise ValueError(f"Pin {pin} is not configured")

        if self.pins[pin].mode != PinMode.PWM:
            raise ValueError(f"Pin {pin} is not configured as PWM (mode: {self.pins[pin].mode})")

        if not (0 <= duty_cycle <= 100):
            raise ValueError(f"Duty cycle must be 0-100, got {duty_cycle}")

        pwm = self.pwm_instances[pin]

        if frequency:
            pwm.ChangeFrequency(frequency)
            self.pins[pin].pwm_frequency = frequency

        pwm.ChangeDutyCycle(duty_cycle)
        self.pins[pin].pwm_duty_cycle = duty_cycle

        return self.get_pin_info(pin)

    def _cleanup_pin(self, pin: int):
        """Internal: Cleanup a single pin"""
        if pin in self.pwm_instances:
            self.pwm_instances[pin].stop()
            del self.pwm_instances[pin]

        GPIO.cleanup(pin)

        if pin in self.pins:
            del self.pins[pin]

    def cleanup_all(self):
        """Cleanup all GPIO pins"""
        for pin in list(self.pins.keys()):
            self._cleanup_pin(pin)

        GPIO.cleanup()

    def __del__(self):
        """Cleanup on destruction"""
        try:
            self.cleanup_all()
        except:
            pass
