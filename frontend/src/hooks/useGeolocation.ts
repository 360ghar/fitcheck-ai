import { useState, useCallback, useEffect } from 'react';

export type PermissionState = 'prompt' | 'granted' | 'denied' | 'unknown';

export interface GeolocationCoordinates {
  lat: number;
  lon: number;
}

export interface GeolocationState {
  coordinates: GeolocationCoordinates | null;
  locationString: string | null;
  error: string | null;
  isLoading: boolean;
  permissionState: PermissionState;
}

export interface UseGeolocationOptions {
  enableHighAccuracy?: boolean;
  timeout?: number;
  maximumAge?: number;
}

const ERROR_MESSAGES: Record<number, string> = {
  1: 'Location permission denied. Please enable location access in your browser settings.',
  2: 'Unable to determine your location. Please try again or enter manually.',
  3: 'Location request timed out. Please try again.',
};

export function useGeolocation(options: UseGeolocationOptions = {}) {
  const [state, setState] = useState<GeolocationState>({
    coordinates: null,
    locationString: null,
    error: null,
    isLoading: false,
    permissionState: 'unknown',
  });

  // Check permission state on mount
  useEffect(() => {
    if (!navigator.permissions) {
      return;
    }

    navigator.permissions.query({ name: 'geolocation' }).then((result) => {
      setState((prev) => ({
        ...prev,
        permissionState: result.state as PermissionState,
      }));

      result.addEventListener('change', () => {
        setState((prev) => ({
          ...prev,
          permissionState: result.state as PermissionState,
        }));
      });
    }).catch(() => {
      // Permissions API not fully supported
    });
  }, []);

  const requestLocation = useCallback((): Promise<GeolocationCoordinates | null> => {
    return new Promise((resolve) => {
      if (!navigator.geolocation) {
        setState((prev) => ({
          ...prev,
          error: 'Geolocation is not supported by your browser.',
          isLoading: false,
        }));
        resolve(null);
        return;
      }

      setState((prev) => ({ ...prev, isLoading: true, error: null }));

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const coords: GeolocationCoordinates = {
            lat: Number(position.coords.latitude.toFixed(4)),
            lon: Number(position.coords.longitude.toFixed(4)),
          };
          const locationString = `${coords.lat},${coords.lon}`;

          setState({
            coordinates: coords,
            locationString,
            error: null,
            isLoading: false,
            permissionState: 'granted',
          });

          resolve(coords);
        },
        (error) => {
          const errorMessage = ERROR_MESSAGES[error.code] || 'Failed to get location.';
          setState((prev) => ({
            ...prev,
            error: errorMessage,
            isLoading: false,
            permissionState: error.code === 1 ? 'denied' : prev.permissionState,
          }));
          resolve(null);
        },
        {
          enableHighAccuracy: options.enableHighAccuracy ?? false,
          timeout: options.timeout ?? 10000,
          maximumAge: options.maximumAge ?? 300000, // 5 minutes cache
        }
      );
    });
  }, [options.enableHighAccuracy, options.timeout, options.maximumAge]);

  const clearError = useCallback(() => {
    setState((prev) => ({ ...prev, error: null }));
  }, []);

  return {
    state,
    requestLocation,
    clearError,
  };
}
