"""
Flask GPIO Control API Server
Provides REST API and WebSocket interface for GPIO control
"""
from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_socketio import SocketIO, emit
import threading
import time
from gpio_controller import GPIOController, PinMode, PullMode

app = Flask(__name__)
CORS(app)
socketio = SocketIO(app, cors_allowed_origins="*")

# Initialize GPIO controller
gpio = GPIOController()

# Background monitoring
monitoring_active = False
monitoring_thread = None


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'message': 'GPIO Control API is running'
    })


@app.route('/api/pins', methods=['GET'])
def get_pins():
    """Get list of available GPIO pins"""
    available_pins = gpio.get_available_pins()
    configured_pins = gpio.get_all_pins_info()

    return jsonify({
        'available_pins': available_pins,
        'configured_pins': configured_pins,
        'reserved_pins': list(gpio.RESERVED_PINS)
    })


@app.route('/api/pins/<int:pin>', methods=['GET'])
def get_pin(pin):
    """Get specific pin information"""
    info = gpio.get_pin_info(pin)

    if not info:
        return jsonify({
            'error': f'Pin {pin} is not configured',
            'pin': pin,
            'is_available': gpio.is_pin_available(pin)
        }), 404

    return jsonify(info)


@app.route('/api/pins/<int:pin>/config', methods=['POST'])
def configure_pin(pin):
    """
    Configure a GPIO pin

    Request body:
    {
        "mode": "input" | "output" | "pwm",
        "pull": "none" | "up" | "down" (for input),
        "initial_value": 0 | 1 (for output),
        "pwm_frequency": int (for pwm)
    }
    """
    try:
        data = request.get_json()

        mode_str = data.get('mode')
        if not mode_str:
            return jsonify({'error': 'mode is required'}), 400

        mode = PinMode(mode_str)
        pull = PullMode(data.get('pull', 'none'))
        initial_value = data.get('initial_value', 0)
        pwm_frequency = data.get('pwm_frequency')

        result = gpio.configure_pin(
            pin=pin,
            mode=mode,
            pull=pull,
            initial_value=initial_value,
            pwm_frequency=pwm_frequency
        )

        # Emit configuration change via WebSocket
        socketio.emit('pin_configured', result)

        return jsonify(result)

    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


@app.route('/api/pins/<int:pin>/write', methods=['POST'])
def write_pin(pin):
    """
    Write value to output pin

    Request body:
    {
        "value": 0 | 1
    }
    """
    try:
        data = request.get_json()
        value = data.get('value')

        if value not in [0, 1]:
            return jsonify({'error': 'value must be 0 or 1'}), 400

        result = gpio.write_pin(pin, value)

        # Emit value change via WebSocket
        socketio.emit('pin_changed', result)

        return jsonify(result)

    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


@app.route('/api/pins/<int:pin>/read', methods=['GET'])
def read_pin(pin):
    """Read value from input pin"""
    try:
        result = gpio.read_pin(pin)
        return jsonify(result)

    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


@app.route('/api/pins/<int:pin>/pwm', methods=['POST'])
def set_pwm(pin):
    """
    Set PWM parameters

    Request body:
    {
        "duty_cycle": float (0-100),
        "frequency": int (optional)
    }
    """
    try:
        data = request.get_json()
        duty_cycle = data.get('duty_cycle')
        frequency = data.get('frequency')

        if duty_cycle is None:
            return jsonify({'error': 'duty_cycle is required'}), 400

        result = gpio.set_pwm(pin, duty_cycle, frequency)

        # Emit PWM change via WebSocket
        socketio.emit('pin_changed', result)

        return jsonify(result)

    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


@app.route('/api/pins/<int:pin>', methods=['DELETE'])
def cleanup_pin(pin):
    """Cleanup/release a specific pin"""
    try:
        gpio._cleanup_pin(pin)
        return jsonify({'message': f'Pin {pin} cleaned up successfully'})

    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


@app.route('/api/cleanup', methods=['POST'])
def cleanup_all():
    """Cleanup all GPIO pins"""
    try:
        gpio.cleanup_all()
        return jsonify({'message': 'All pins cleaned up successfully'})

    except Exception as e:
        return jsonify({'error': f'Internal error: {str(e)}'}), 500


# WebSocket events
@socketio.on('connect')
def handle_connect():
    """Handle WebSocket connection"""
    print('Client connected')
    emit('connected', {'message': 'Connected to GPIO Control API'})


@socketio.on('disconnect')
def handle_disconnect():
    """Handle WebSocket disconnection"""
    print('Client disconnected')


@socketio.on('start_monitoring')
def start_monitoring(data):
    """
    Start monitoring specific pins

    data: {
        "pins": [pin numbers to monitor],
        "interval": polling interval in ms (default 100)
    }
    """
    global monitoring_active, monitoring_thread

    pins = data.get('pins', [])
    interval = data.get('interval', 100) / 1000.0  # Convert to seconds

    if not pins:
        emit('error', {'message': 'No pins specified for monitoring'})
        return

    monitoring_active = True

    def monitor_loop():
        """Background monitoring loop"""
        while monitoring_active:
            readings = []
            for pin in pins:
                try:
                    info = gpio.get_pin_info(pin)
                    if info:
                        # If it's an input pin, read current value
                        if info['mode'] == 'input':
                            info = gpio.read_pin(pin)
                        readings.append(info)
                except Exception as e:
                    print(f"Error reading pin {pin}: {e}")

            if readings:
                socketio.emit('pin_readings', {
                    'timestamp': time.time(),
                    'readings': readings
                })

            time.sleep(interval)

    monitoring_thread = threading.Thread(target=monitor_loop, daemon=True)
    monitoring_thread.start()

    emit('monitoring_started', {'pins': pins, 'interval': interval * 1000})


@socketio.on('stop_monitoring')
def stop_monitoring():
    """Stop monitoring pins"""
    global monitoring_active
    monitoring_active = False
    emit('monitoring_stopped', {'message': 'Monitoring stopped'})


if __name__ == '__main__':
    try:
        print('Starting GPIO Control API Server...')
        print(f'Available pins: {gpio.get_available_pins()}')
        print(f'Reserved pins: {list(gpio.RESERVED_PINS)}')
        print('Server running on http://0.0.0.0:5000')

        socketio.run(app, host='0.0.0.0', port=5000, debug=True)
    except KeyboardInterrupt:
        print('\nShutting down...')
        gpio.cleanup_all()
    except Exception as e:
        print(f'Error: {e}')
        gpio.cleanup_all()
