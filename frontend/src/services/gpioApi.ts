/**
 * GPIO API Service
 * Handles REST API calls to Flask backend
 */
import axios from 'axios';
import { io, Socket } from 'socket.io-client';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

export interface PinInfo {
  pin: number;
  mode: 'input' | 'output' | 'pwm';
  value: number;
  pull: 'none' | 'up' | 'down';
  is_reserved: boolean;
  is_available: boolean;
  pwm_frequency?: number;
  pwm_duty_cycle?: number;
}

export interface PinsResponse {
  available_pins: number[];
  configured_pins: PinInfo[];
  reserved_pins: number[];
}

export interface ConfigurePin Request {
  mode: 'input' | 'output' | 'pwm';
  pull?: 'none' | 'up' | 'down';
  initial_value?: 0 | 1;
  pwm_frequency?: number;
}

export interface WriteValue Request {
  value: 0 | 1;
}

export interface PWMRequest {
  duty_cycle: number;
  frequency?: number;
}

class GPIOApiService {
  private socket: Socket | null = null;
  private connectionCallbacks: Array<(connected: boolean) => void> = [];
  private pinReadingsCallbacks: Array<(data: any) => void> = [];

  /**
   * Get health status of the API
   */
  async getHealth(): Promise<{ status: string; message: string }> {
    const response = await axios.get(`${API_BASE_URL}/api/health`);
    return response.data;
  }

  /**
   * Get all pins information
   */
  async getPins(): Promise<PinsResponse> {
    const response = await axios.get(`${API_BASE_URL}/api/pins`);
    return response.data;
  }

  /**
   * Get specific pin information
   */
  async getPin(pin: number): Promise<PinInfo> {
    const response = await axios.get(`${API_BASE_URL}/api/pins/${pin}`);
    return response.data;
  }

  /**
   * Configure a GPIO pin
   */
  async configurePin(pin: number, config: ConfigurePinRequest): Promise<PinInfo> {
    const response = await axios.post(`${API_BASE_URL}/api/pins/${pin}/config`, config);
    return response.data;
  }

  /**
   * Write value to output pin
   */
  async writePin(pin: number, value: 0 | 1): Promise<PinInfo> {
    const response = await axios.post(`${API_BASE_URL}/api/pins/${pin}/write`, { value });
    return response.data;
  }

  /**
   * Read value from input pin
   */
  async readPin(pin: number): Promise<PinInfo> {
    const response = await axios.get(`${API_BASE_URL}/api/pins/${pin}/read`);
    return response.data;
  }

  /**
   * Set PWM parameters
   */
  async setPWM(pin: number, params: PWMRequest): Promise<PinInfo> {
    const response = await axios.post(`${API_BASE_URL}/api/pins/${pin}/pwm`, params);
    return response.data;
  }

  /**
   * Cleanup specific pin
   */
  async cleanupPin(pin: number): Promise<{ message: string }> {
    const response = await axios.delete(`${API_BASE_URL}/api/pins/${pin}`);
    return response.data;
  }

  /**
   * Cleanup all pins
   */
  async cleanupAll(): Promise<{ message: string }> {
    const response = await axios.post(`${API_BASE_URL}/api/cleanup`);
    return response.data;
  }

  /**
   * Initialize WebSocket connection
   */
  connectWebSocket(onConnectionChange?: (connected: boolean) => void): void {
    if (this.socket) {
      console.log('WebSocket already connected');
      return;
    }

    this.socket = io(API_BASE_URL);

    this.socket.on('connect', () => {
      console.log('WebSocket connected');
      this.connectionCallbacks.forEach(cb => cb(true));
      if (onConnectionChange) onConnectionChange(true);
    });

    this.socket.on('disconnect', () => {
      console.log('WebSocket disconnected');
      this.connectionCallbacks.forEach(cb => cb(false));
      if (onConnectionChange) onConnectionChange(false);
    });

    this.socket.on('connected', (data) => {
      console.log('Server message:', data.message);
    });

    this.socket.on('pin_configured', (data: PinInfo) => {
      console.log('Pin configured:', data);
    });

    this.socket.on('pin_changed', (data: PinInfo) => {
      console.log('Pin changed:', data);
    });

    this.socket.on('pin_readings', (data) => {
      this.pinReadingsCallbacks.forEach(cb => cb(data));
    });

    this.socket.on('monitoring_started', (data) => {
      console.log('Monitoring started:', data);
    });

    this.socket.on('monitoring_stopped', (data) => {
      console.log('Monitoring stopped:', data);
    });

    this.socket.on('error', (data) => {
      console.error('WebSocket error:', data);
    });
  }

  /**
   * Disconnect WebSocket
   */
  disconnectWebSocket(): void {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
      this.connectionCallbacks = [];
      this.pinReadingsCallbacks = [];
    }
  }

  /**
   * Subscribe to connection status changes
   */
  onConnectionChange(callback: (connected: boolean) => void): void {
    this.connectionCallbacks.push(callback);
  }

  /**
   * Subscribe to pin readings
   */
  onPinReadings(callback: (data: any) => void): void {
    this.pinReadingsCallbacks.push(callback);
  }

  /**
   * Start monitoring specific pins
   */
  startMonitoring(pins: number[], interval: number = 100): void {
    if (!this.socket) {
      console.error('WebSocket not connected');
      return;
    }

    this.socket.emit('start_monitoring', { pins, interval });
  }

  /**
   * Stop monitoring
   */
  stopMonitoring(): void {
    if (!this.socket) {
      console.error('WebSocket not connected');
      return;
    }

    this.socket.emit('stop_monitoring');
  }

  /**
   * Check if WebSocket is connected
   */
  isConnected(): boolean {
    return this.socket?.connected || false;
  }
}

// Export singleton instance
export const gpioApi = new GPIOApiService();
