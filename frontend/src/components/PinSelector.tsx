/**
 * Pin Selector Component
 * Visual grid for selecting GPIO pins
 */
import React from 'react';
import { PinInfo } from '../services/gpioApi';

interface PinSelectorProps {
  availablePins: number[];
  configuredPins: PinInfo[];
  reservedPins: number[];
  selectedPin: number | null;
  onSelectPin: (pin: number) => void;
}

export const PinSelector: React.FC<PinSelectorProps> = ({
  availablePins,
  configuredPins,
  reservedPins,
  selectedPin,
  onSelectPin
}) => {
  const getPinStatus = (pin: number): 'available' | 'configured' | 'reserved' | 'selected' => {
    if (reservedPins.includes(pin)) return 'reserved';
    if (selectedPin === pin) return 'selected';
    if (configuredPins.some(p => p.pin === pin)) return 'configured';
    return 'available';
  };

  const getPinInfo = (pin: number): PinInfo | undefined => {
    return configuredPins.find(p => p.pin === pin);
  };

  const getStatusColor = (status: string): string => {
    switch (status) {
      case 'selected': return 'var(--cyber-primary)';
      case 'configured': return 'var(--cyber-success)';
      case 'reserved': return 'var(--cyber-danger)';
      default: return 'var(--text-muted)';
    }
  };

  const handlePinClick = (pin: number) => {
    if (!reservedPins.includes(pin)) {
      onSelectPin(pin);
    }
  };

  return (
    <div className="cyber-panel fade-in">
      <h2 className="cyber-glow-text" style={{ marginBottom: '16px' }}>
        GPIO PIN SELECTOR
      </h2>

      <div className="pin-grid">
        {availablePins.map(pin => {
          const status = getPinStatus(pin);
          const pinInfo = getPinInfo(pin);
          const isReserved = status === 'reserved';

          return (
            <div
              key={pin}
              className={`pin-item ${status}`}
              onClick={() => handlePinClick(pin)}
              style={{
                cursor: isReserved ? 'not-allowed' : 'pointer',
                opacity: isReserved ? 0.5 : 1
              }}
            >
              <div style={{
                fontSize: '24px',
                fontWeight: 'bold',
                color: getStatusColor(status),
                fontFamily: 'Orbitron, monospace'
              }}>
                {pin}
              </div>

              {pinInfo && (
                <div style={{
                  fontSize: '12px',
                  color: 'var(--text-secondary)',
                  marginTop: '4px',
                  textTransform: 'uppercase'
                }}>
                  {pinInfo.mode}
                </div>
              )}

              {pinInfo && pinInfo.mode === 'input' && (
                <div className={`status-indicator ${pinInfo.value === 1 ? 'status-high' : 'status-low'}`}></div>
              )}

              {pinInfo && pinInfo.mode === 'output' && (
                <div className={`status-indicator ${pinInfo.value === 1 ? 'status-high' : 'status-low'}`}></div>
              )}

              {isReserved && (
                <div style={{
                  fontSize: '10px',
                  color: 'var(--cyber-danger)',
                  marginTop: '4px'
                }}>
                  RESERVED
                </div>
              )}
            </div>
          );
        })}
      </div>

      <div style={{ marginTop: '16px', fontSize: '14px', color: 'var(--text-secondary)' }}>
        <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
          <div>
            <span className="status-indicator status-active"></span>
            <span>Available</span>
          </div>
          <div>
            <span className="status-indicator status-high"></span>
            <span>Configured</span>
          </div>
          <div>
            <span className="status-indicator status-error"></span>
            <span>Reserved</span>
          </div>
        </div>
      </div>
    </div>
  );
};
