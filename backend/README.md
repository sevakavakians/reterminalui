# GPIO Control API Backend

Flask-based REST API and WebSocket server for Raspberry Pi GPIO control on reTerminal.

## Features

- REST API for GPIO configuration and control
- WebSocket support for real-time pin monitoring
- Hardware abstraction layer with mock GPIO for development
- Safety features (pin conflict detection, current limiting warnings)
- Support for digital I/O and PWM

## Installation

### On reTerminal (Raspberry Pi):
```bash
cd backend
pip3 install -r requirements.txt
python3 app.py
```

### On development machine (Mac/Linux):
```bash
cd backend
pip3 install -r requirements.txt
python3 app.py
# Will run with mock GPIO for testing
```

## API Endpoints

### GET /api/health
Health check endpoint

### GET /api/pins
Get all available and configured pins

### GET /api/pins/{pin}
Get specific pin information

### POST /api/pins/{pin}/config
Configure a pin
```json
{
  "mode": "input|output|pwm",
  "pull": "none|up|down",
  "initial_value": 0,
  "pwm_frequency": 1000
}
```

### POST /api/pins/{pin}/write
Write to output pin
```json
{
  "value": 0|1
}
```

### GET /api/pins/{pin}/read
Read from input pin

### POST /api/pins/{pin}/pwm
Set PWM parameters
```json
{
  "duty_cycle": 50.0,
  "frequency": 1000
}
```

### DELETE /api/pins/{pin}
Cleanup specific pin

### POST /api/cleanup
Cleanup all pins

## WebSocket Events

### Client → Server

**start_monitoring**: Start monitoring pins
```json
{
  "pins": [17, 18, 27],
  "interval": 100
}
```

**stop_monitoring**: Stop monitoring

### Server → Client

**connected**: Connection established

**pin_configured**: Pin configuration changed

**pin_changed**: Pin value changed

**pin_readings**: Real-time pin readings
```json
{
  "timestamp": 1234567890.123,
  "readings": [
    {"pin": 17, "mode": "input", "value": 1},
    {"pin": 18, "mode": "output", "value": 0}
  ]
}
```

## GPIO Safety

- Pins 6 and 13 are reserved (USB hub conflict on reTerminal)
- Maximum 16mA per pin, 50mA total
- Automatic cleanup on shutdown
