/**
 * Pin Control Component
 * Configure and control GPIO pins
 */
import React, { useState, useEffect } from 'react';
import { PinInfo, gpioApi, ConfigurePinRequest } from '../services/gpioApi';

interface PinControlProps {
  pin: number;
  pinInfo: PinInfo | null;
  onPinUpdated: () => void;
}

export const PinControl: React.FC<PinControlProps> = ({ pin, pinInfo, onPinUpdated }) => {
  const [mode, setMode] = useState<'input' | 'output' | 'pwm'>('output');
  const [pull, setPull] = useState<'none' | 'up' | 'down'>('none');
  const [outputValue, setOutputValue] = useState<0 | 1>(0);
  const [pwmDutyCycle, setPwmDutyCycle] = useState<number>(0);
  const [pwmFrequency, setPwmFrequency] = useState<number>(1000);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (pinInfo) {
      setMode(pinInfo.mode as any);
      setPull(pinInfo.pull);
      setOutputValue(pinInfo.value as any);
      if (pinInfo.pwm_duty_cycle !== undefined) {
        setPwmDutyCycle(pinInfo.pwm_duty_cycle);
      }
      if (pinInfo.pwm_frequency !== undefined) {
        setPwmFrequency(pinInfo.pwm_frequency);
      }
    }
  }, [pinInfo]);

  const handleConfigure = async () => {
    console.log('[PinControl] Configure started, active element:', document.activeElement?.tagName);

    // Explicitly blur any focused element to prevent focus issues on re-render
    if (document.activeElement instanceof HTMLElement) {
      document.activeElement.blur();
    }
    console.log('[PinControl] After blur, active element:', document.activeElement?.tagName);

    setError(null);

    try {
      const config: ConfigurePinRequest = {
        mode,
        pull: mode === 'input' ? pull : undefined,
        initial_value: mode === 'output' ? outputValue : undefined,
        pwm_frequency: mode === 'pwm' ? pwmFrequency : undefined
      };

      console.log('[PinControl] Calling API...');
      await gpioApi.configurePin(pin, config);
      console.log('[PinControl] API returned successfully');
      onPinUpdated();
      console.log('[PinControl] onPinUpdated called');
    } catch (err: any) {
      console.error('[PinControl] Error:', err);
      setError(err.response?.data?.error || err.message);
    }
  };

  const handleWrite = async (value: 0 | 1) => {
    setError(null);

    try {
      await gpioApi.writePin(pin, value);
      setOutputValue(value);
      setTimeout(() => onPinUpdated(), 100);
    } catch (err: any) {
      setError(err.response?.data?.error || err.message);
    }
  };

  const handlePWMUpdate = async () => {
    setError(null);

    try {
      await gpioApi.setPWM(pin, { duty_cycle: pwmDutyCycle, frequency: pwmFrequency });
      setTimeout(() => onPinUpdated(), 100);
    } catch (err: any) {
      setError(err.response?.data?.error || err.message);
    }
  };

  const handleCleanup = async () => {
    setError(null);

    try {
      await gpioApi.cleanupPin(pin);
      setTimeout(() => onPinUpdated(), 100);
    } catch (err: any) {
      setError(err.response?.data?.error || err.message);
    }
  };

  return (
    <div className="cyber-panel slide-in-right">
      <h2 className="cyber-glow-text" style={{ marginBottom: '16px' }}>
        PIN {pin} CONTROL
      </h2>

      {error && (
        <div style={{
          background: 'rgba(255, 0, 110, 0.2)',
          border: '2px solid var(--cyber-danger)',
          borderRadius: '4px',
          padding: '12px',
          marginBottom: '16px',
          color: 'var(--cyber-danger)'
        }}>
          {error}
        </div>
      )}

      {!pinInfo ? (
        <>
          <div style={{ marginBottom: '16px' }}>
            <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
              PIN MODE
            </label>
            <select
              className="cyber-select"
              value={mode}
              onChange={(e) => setMode(e.target.value as any)}
            >
              <option value="input">INPUT</option>
              <option value="output">OUTPUT</option>
              <option value="pwm">PWM</option>
            </select>
          </div>

          {mode === 'input' && (
            <div style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
                PULL RESISTOR
              </label>
              <select
                className="cyber-select"
                value={pull}
                onChange={(e) => setPull(e.target.value as any)}
              >
                <option value="none">NONE</option>
                <option value="up">PULL UP</option>
                <option value="down">PULL DOWN</option>
              </select>
            </div>
          )}

          {mode === 'output' && (
            <div style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
                INITIAL VALUE
              </label>
              <div style={{ display: 'flex', gap: '12px' }}>
                <button
                  className={`cyber-button ${outputValue === 0 ? 'active' : ''}`}
                  onClick={() => setOutputValue(0)}
                >
                  LOW
                </button>
                <button
                  className={`cyber-button ${outputValue === 1 ? 'active' : ''}`}
                  onClick={() => setOutputValue(1)}
                >
                  HIGH
                </button>
              </div>
            </div>
          )}

          {mode === 'pwm' && (
            <div style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
                PWM FREQUENCY (Hz)
              </label>
              <input
                type="number"
                className="cyber-input"
                value={pwmFrequency}
                onChange={(e) => setPwmFrequency(parseInt(e.target.value) || 1000)}
                min="1"
                max="100000"
              />
            </div>
          )}

          <button
            className="cyber-button"
            onClick={handleConfigure}
            style={{ width: '100%' }}
          >
            CONFIGURE PIN
          </button>
        </>
      ) : (
        <>
          <div style={{ marginBottom: '24px' }}>
            <div style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
              MODE
            </div>
            <div className="cyber-glow-text-success" style={{ fontSize: '18px' }}>
              {pinInfo.mode.toUpperCase()}
            </div>
          </div>

          {pinInfo.mode === 'input' && (
            <div style={{ textAlign: 'center', marginBottom: '24px' }}>
              <div style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
                CURRENT VALUE
              </div>
              <div className={`value-display ${pinInfo.value === 1 ? 'value-high' : 'value-low'}`}>
                {pinInfo.value === 1 ? 'HIGH' : 'LOW'}
              </div>
              <div className={`status-indicator ${pinInfo.value === 1 ? 'status-high' : 'status-low'}`}
                   style={{ width: '24px', height: '24px', margin: '0 auto' }}></div>
            </div>
          )}

          {pinInfo.mode === 'output' && (
            <div style={{ marginBottom: '24px' }}>
              <div style={{ textAlign: 'center', marginBottom: '16px' }}>
                <div style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '8px' }}>
                  CURRENT VALUE
                </div>
                <div className={`value-display ${pinInfo.value === 1 ? 'value-high' : 'value-low'}`}>
                  {pinInfo.value === 1 ? 'HIGH' : 'LOW'}
                </div>
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                <button
                  className="cyber-button"
                  onClick={() => handleWrite(0)}
                  style={{ flex: 1 }}
                >
                  SET LOW
                </button>
                <button
                  className="cyber-button"
                  onClick={() => handleWrite(1)}
                  style={{ flex: 1 }}
                >
                  SET HIGH
                </button>
              </div>
            </div>
          )}

          {pinInfo.mode === 'pwm' && (
            <div style={{ marginBottom: '24px' }}>
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
                  DUTY CYCLE: {pwmDutyCycle.toFixed(1)}%
                </label>
                <input
                  type="range"
                  min="0"
                  max="100"
                  step="0.1"
                  value={pwmDutyCycle}
                  onChange={(e) => setPwmDutyCycle(parseFloat(e.target.value))}
                  style={{ width: '100%' }}
                />
              </div>

              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-secondary)' }}>
                  FREQUENCY: {pwmFrequency} Hz
                </label>
                <input
                  type="number"
                  className="cyber-input"
                  value={pwmFrequency}
                  onChange={(e) => setPwmFrequency(parseInt(e.target.value) || 1000)}
                  min="1"
                  max="100000"
                />
              </div>

              <button
                className="cyber-button"
                onClick={handlePWMUpdate}
                style={{ width: '100%' }}
              >
                UPDATE PWM
              </button>
            </div>
          )}

          <button
            className="cyber-button danger"
            onClick={handleCleanup}
            style={{ width: '100%' }}
          >
            RELEASE PIN
          </button>
        </>
      )}
    </div>
  );
};
