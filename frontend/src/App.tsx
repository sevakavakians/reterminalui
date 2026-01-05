/**
 * Main Application Component
 * reTerminal GPIO Control UI
 */
import React, { useState, useEffect } from 'react';
import { PinSelector } from './components/PinSelector';
import { PinControl } from './components/PinControl';
import { gpioApi, PinInfo } from './services/gpioApi';
import './styles/cyberpunk.css';

function App() {
  const [availablePins, setAvailablePins] = useState<number[]>([]);
  const [configuredPins, setConfiguredPins] = useState<PinInfo[]>([]);
  const [reservedPins, setReservedPins] = useState<number[]>([]);
  const [selectedPin, setSelectedPin] = useState<number | null>(null);
  const [selectedPinInfo, setSelectedPinInfo] = useState<PinInfo | null>(null);
  const [connected, setConnected] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Load pins on mount
  useEffect(() => {
    loadPins();
    connectWebSocket();

    return () => {
      gpioApi.disconnectWebSocket();
    };
  }, []);

  // Update selected pin info when selected pin or configured pins change
  useEffect(() => {
    if (selectedPin) {
      const info = configuredPins.find(p => p.pin === selectedPin) || null;
      setSelectedPinInfo(info);
    } else {
      setSelectedPinInfo(null);
    }
  }, [selectedPin, configuredPins]);

  const connectWebSocket = () => {
    gpioApi.connectWebSocket((isConnected) => {
      setConnected(isConnected);
    });

    gpioApi.onPinReadings((data) => {
      // Update configured pins with new readings
      setConfiguredPins(prev => {
        const updated = [...prev];
        data.readings.forEach((reading: PinInfo) => {
          const index = updated.findIndex(p => p.pin === reading.pin);
          if (index >= 0) {
            updated[index] = reading;
          }
        });
        return updated;
      });
    });
  };

  const loadPins = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await gpioApi.getPins();
      setAvailablePins(response.available_pins);
      setConfiguredPins(response.configured_pins);
      setReservedPins(response.reserved_pins);
    } catch (err: any) {
      setError(err.message || 'Failed to load pins');
    } finally {
      setLoading(false);
    }
  };

  const handlePinSelect = (pin: number) => {
    setSelectedPin(pin === selectedPin ? null : pin);
  };

  const handlePinUpdated = () => {
    loadPins();
  };

  const handleStartMonitoring = () => {
    const inputPins = configuredPins.filter(p => p.mode === 'input').map(p => p.pin);
    if (inputPins.length > 0) {
      gpioApi.startMonitoring(inputPins, 100);
    }
  };

  const handleStopMonitoring = () => {
    gpioApi.stopMonitoring();
  };

  const handleCleanupAll = async () => {
    try {
      await gpioApi.cleanupAll();
      loadPins();
      setSelectedPin(null);
    } catch (err: any) {
      setError(err.message);
    }
  };

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        flexDirection: 'column',
        gap: '20px'
      }}>
        <div className="cyber-spinner"></div>
        <div className="cyber-glow-text">INITIALIZING SYSTEM</div>
      </div>
    );
  }

  return (
    <div>
      {/* Cyberpunk background effects */}
      <div className="cyber-grid-bg"></div>
      <div className="cyber-scanline"></div>

      <div style={{ position: 'relative', zIndex: 10, height: '100vh', display: 'flex', flexDirection: 'column' }}>
        {/* Header */}
        <header className="cyber-header">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
            <div>
              <h1 className="cyber-glow-text" style={{ fontSize: '32px', marginBottom: '8px' }}>
                reTerminal GPIO
              </h1>
              <div style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>
                <span className={`status-indicator ${connected ? 'status-active' : 'status-error'}`}></span>
                {connected ? 'CONNECTED' : 'DISCONNECTED'}
                <span style={{ marginLeft: '16px', marginRight: '8px' }}>|</span>
                <span>{configuredPins.length} PINS CONFIGURED</span>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
              <button
                className="cyber-button"
                onClick={handleStartMonitoring}
                disabled={configuredPins.filter(p => p.mode === 'input').length === 0}
              >
                START MONITOR
              </button>
              <button
                className="cyber-button"
                onClick={handleStopMonitoring}
              >
                STOP MONITOR
              </button>
              <button
                className="cyber-button danger"
                onClick={handleCleanupAll}
                disabled={configuredPins.length === 0}
              >
                CLEANUP ALL
              </button>
            </div>
          </div>
        </header>

        {/* Error message */}
        {error && (
          <div style={{
            margin: '16px',
            background: 'rgba(255, 0, 110, 0.2)',
            border: '2px solid var(--cyber-danger)',
            borderRadius: '4px',
            padding: '12px',
            color: 'var(--cyber-danger)'
          }}>
            {error}
          </div>
        )}

        {/* Main content */}
        <main style={{
          flex: 1,
          overflow: 'auto',
          padding: '20px',
          display: 'grid',
          gridTemplateColumns: selectedPin ? '1fr 400px' : '1fr',
          gap: '20px'
        }}>
          {/* Pin selector */}
          <PinSelector
            availablePins={availablePins}
            configuredPins={configuredPins}
            reservedPins={reservedPins}
            selectedPin={selectedPin}
            onSelectPin={handlePinSelect}
          />

          {/* Pin control panel */}
          {selectedPin && (
            <PinControl
              pin={selectedPin}
              pinInfo={selectedPinInfo}
              onPinUpdated={handlePinUpdated}
            />
          )}
        </main>

        {/* Footer */}
        <footer style={{
          padding: '16px',
          borderTop: '2px solid var(--border-color)',
          background: 'var(--bg-panel)',
          color: 'var(--text-muted)',
          fontSize: '12px',
          textAlign: 'center'
        }}>
          <div>reTerminal GPIO Control System v1.0</div>
          <div style={{ marginTop: '4px' }}>
            Raspberry Pi CM4 • Python Flask API • React Frontend
          </div>
        </footer>
      </div>
    </div>
  );
}

export default App;
