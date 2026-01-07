"""
Button Handler for reTerminal Physical Buttons
Uses evdev to directly read button events and emit Qt signals
Based on Seeed's LedsKey.py implementation
"""
import sys
import os

try:
    from PySide2.QtCore import QThread, Signal, Slot
except ImportError:
    from PyQt5.QtCore import QThread, pyqtSignal as Signal, pyqtSlot as Slot

from evdev import InputDevice, ecodes


class ButtonHandler(QThread):
    """
    Qt thread that monitors reTerminal physical buttons
    Emits signals when buttons are pressed/released
    """
    # Signal: (button_name: str, state: str)
    # button_name: 'F1', 'F2', 'F3', 'O'
    # state: 'pressed' or 'released'
    buttonEvent = Signal(str, str)

    def __init__(self, device_path):
        """
        Initialize button handler

        Args:
            device_path: Path to input device (e.g., /dev/input/event0)
        """
        super().__init__()
        self.device_path = device_path
        self.running = True
        print(f"[ButtonHandler] Initialized with device: {device_path}")

    def run(self):
        """Main thread loop - reads button events continuously"""
        print("[ButtonHandler] Thread started, monitoring buttons...")

        while self.running:
            try:
                # Open device (will auto-close when context ends)
                device = InputDevice(self.device_path)

                # Grab device exclusively to prevent X11 from consuming events
                try:
                    device.grab()
                    print("[ButtonHandler] Device grabbed exclusively")
                except Exception as e:
                    print(f"[ButtonHandler] Warning: Could not grab device exclusively: {e}")

                # Read events in a loop
                for event in device.read_loop():
                    if not self.running:
                        break

                    # Only process keyboard events
                    if event.type == ecodes.EV_KEY:
                        # Parse event representation
                        # Format: "event at 1234567890.123456, code 30, type 01, val 1"
                        keyevents = repr(event)
                        val_list = keyevents.replace('(', '').replace(')', '').replace(' ', '').split(',')

                        if len(val_list) >= 5:
                            code = val_list[3]  # Key code
                            value = int(val_list[4])  # 0=released, 1=pressed, 2=held

                            # Map key codes to button names
                            # reTerminal button mappings:
                            # F1 = KEY_A (code 30)
                            # F2 = KEY_S (code 31)
                            # F3 = KEY_D (code 32)
                            # O  = KEY_F (code 33)
                            button_map = {
                                '30': 'F1',
                                '31': 'F2',
                                '32': 'F3',
                                '33': 'O'
                            }

                            if code in button_map:
                                button_name = button_map[code]
                                # Only emit on press (1) or release (0), ignore hold (2)
                                if value in [0, 1]:
                                    state = 'pressed' if value == 1 else 'released'
                                    print(f"[ButtonHandler] {button_name} {state}")
                                    self.buttonEvent.emit(button_name, state)

            except OSError as e:
                print(f"[ButtonHandler] Device error: {e}")
                # Device might be temporarily unavailable, retry
                import time
                time.sleep(0.5)
            except Exception as e:
                print(f"[ButtonHandler] Unexpected error: {e}")
                import time
                time.sleep(0.5)

        print("[ButtonHandler] Thread stopped")

    def stop(self):
        """Stop the button monitoring thread"""
        print("[ButtonHandler] Stopping...")
        self.running = False
