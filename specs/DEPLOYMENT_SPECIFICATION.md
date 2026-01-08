# reTerminal GPIO Control System - Deployment Specification

**Version:** 1.0.0  
**Last Updated:** 2026-01-07

## Deployment Overview

**Target Device:** Seeed Studio reTerminal (Raspberry Pi CM4)  
**Deployment Method:** SSH/SCP + systemd service  
**Auto-start:** Yes (systemd service on boot)

## Prerequisites

### Hardware Setup

1. **reTerminal Device:**
   - Power: 5V 3A USB-C adapter connected
   - Network: Ethernet or Wi-Fi configured
   - SSH: Enabled (`sudo raspi-config` → Interface Options → SSH → Enable)

2. **Development Machine:**
   - SSH client installed
   - SSH key configured (for passwordless access)
   - Python 3.7+ (for local development)

### Software Requirements (reTerminal)

**Install dependencies:**

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Python dependencies
sudo apt-get install -y python3-pip python3-pyqt5 python3-pyqt5.qtquick qml-module-qtquick2 qml-module-qtquick-controls2 qml-module-qtquick-window2

# Install RPi.GPIO
sudo pip3 install RPi.GPIO

# Install PySide2
sudo pip3 install PySide2

# Install sensor libraries
sudo pip3 install Adafruit-DHT smbus2 bme280

# Install evdev for button handling
sudo pip3 install evdev
```

## Deployment Procedure

### Step 1: Prepare Development Machine

Create SSH key (if not exists):

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/reterminal_key

# Copy public key to reTerminal
ssh-copy-id -i ~/.ssh/reterminal_key.pub pi@192.168.0.3
```

Add to SSH config (`~/.ssh/config`):

```
Host reterminal
    HostName 192.168.0.3
    User pi
    IdentityFile ~/.ssh/reterminal_key
```

### Step 2: Deploy Application Files

From project root directory:

```bash
# Create app directory on reTerminal
ssh reterminal 'mkdir -p ~/qt5-app/src ~/qt5-app/qml'

# Deploy Python source files
scp qt5-app/src/*.py reterminal:~/qt5-app/src/

# Deploy QML files
scp qt5-app/qml/*.qml reterminal:~/qt5-app/qml/

# Deploy requirements and service file
scp qt5-app/requirements.txt reterminal:~/qt5-app/
scp qt5-app/reterminal-gpio.service reterminal:~/
```

### Step 3: Install Python Dependencies

```bash
ssh reterminal 'cd ~/qt5-app && pip3 install -r requirements.txt'
```

### Step 4: Configure systemd Service

```bash
# Copy service file to systemd
ssh reterminal 'sudo cp ~/reterminal-gpio.service /etc/systemd/system/'

# Reload systemd
ssh reterminal 'sudo systemctl daemon-reload'

# Enable service (auto-start on boot)
ssh reterminal 'sudo systemctl enable reterminal-gpio.service'

# Start service
ssh reterminal 'sudo systemctl start reterminal-gpio.service'
```

### Step 5: Verify Deployment

```bash
# Check service status
ssh reterminal 'sudo systemctl status reterminal-gpio.service'

# View logs
ssh reterminal 'sudo journalctl -u reterminal-gpio.service -f'

# Check if app is running
ssh reterminal 'pgrep -f "python3 main.py"'
```

Expected output: Process ID (e.g., `1234`)

## Service Management

### Start/Stop/Restart

```bash
# Start service
sudo systemctl start reterminal-gpio.service

# Stop service
sudo systemctl stop reterminal-gpio.service

# Restart service (after code changes)
sudo systemctl restart reterminal-gpio.service

# View status
sudo systemctl status reterminal-gpio.service
```

### Enable/Disable Auto-Start

```bash
# Enable auto-start on boot
sudo systemctl enable reterminal-gpio.service

# Disable auto-start
sudo systemctl disable reterminal-gpio.service
```

### View Logs

```bash
# View all logs
sudo journalctl -u reterminal-gpio.service

# Follow logs (real-time)
sudo journalctl -u reterminal-gpio.service -f

# View last 50 lines
sudo journalctl -u reterminal-gpio.service -n 50
```

## Quick Deployment Script

Save as `deploy.sh` in project root:

```bash
#!/bin/bash
# Quick deployment script for reTerminal GPIO app

REMOTE="reterminal"
REMOTE_DIR="~/qt5-app"

echo "Deploying to reTerminal..."

# Deploy Python files
echo "Copying Python files..."
scp qt5-app/src/*.py $REMOTE:$REMOTE_DIR/src/

# Deploy QML files
echo "Copying QML files..."
scp qt5-app/qml/*.qml $REMOTE:$REMOTE_DIR/qml/

# Restart service
echo "Restarting service..."
ssh $REMOTE 'sudo systemctl restart reterminal-gpio.service'

# Show status
echo "Service status:"
ssh $REMOTE 'sudo systemctl status reterminal-gpio.service --no-pager -l'

echo "Deployment complete!"
```

Make executable: `chmod +x deploy.sh`  
Run: `./deploy.sh`

## Troubleshooting

### App Not Starting

**Check service status:**
```bash
sudo systemctl status reterminal-gpio.service
```

**Common Issues:**

1. **Permission denied on GPIO:**
   ```bash
   # Add user to gpio group
   sudo usermod -a -G gpio pi
   # Reboot
   sudo reboot
   ```

2. **Display not found (DISPLAY=:0):**
   ```bash
   # Check X server running
   ps aux | grep X
   # If not, start X server or configure auto-login
   ```

3. **Missing dependencies:**
   ```bash
   cd ~/qt5-app
   pip3 install -r requirements.txt
   ```

4. **QML module not found:**
   ```bash
   sudo apt-get install qml-module-qtquick2 qml-module-qtquick-controls2
   ```

### Black Screen or UI Issues

**Check QML errors:**
```bash
sudo journalctl -u reterminal-gpio.service | grep -i "qml"
```

**Common QML errors:**
- Missing component: Install missing QML modules
- Syntax error: Check QML files for typos
- Property binding loop: Review property bindings

### GPIO Errors

**Error: "RuntimeError: No access to /dev/mem"**
- Solution: Add user to `gpio` group (see above)

**Error: "Pin already in use"**
- Solution: Clean up GPIO before starting app
  ```bash
  python3 -c "import RPi.GPIO as GPIO; GPIO.setmode(GPIO.BCM); GPIO.cleanup()"
  ```

### Service Crashes on Boot

**Disable auto-start:**
```bash
sudo systemctl disable reterminal-gpio.service
```

**Manual start for debugging:**
```bash
cd ~/qt5-app/src
DISPLAY=:0 python3 main.py
```

### Updating Application

**Method 1: Quick Update (Python/QML files only)**

```bash
# Copy files
scp qt5-app/src/GPIOController.py reterminal:~/qt5-app/src/
scp qt5-app/qml/PinControlPanel.qml reterminal:~/qt5-app/qml/

# Restart service
ssh reterminal 'sudo systemctl restart reterminal-gpio.service'
```

**Method 2: Full Redeployment**

```bash
./deploy.sh  # Use deployment script
```

## Backup and Recovery

### Backup Configuration

```bash
# Backup entire app directory
ssh reterminal 'tar -czf qt5-app-backup.tar.gz ~/qt5-app'
scp reterminal:~/qt5-app-backup.tar.gz ./backups/
```

### Restore from Backup

```bash
scp ./backups/qt5-app-backup.tar.gz reterminal:~/
ssh reterminal 'tar -xzf qt5-app-backup.tar.gz'
ssh reterminal 'sudo systemctl restart reterminal-gpio.service'
```

---

**Owner:** DevOps Team  
**Review Cycle:** On deployment process changes
