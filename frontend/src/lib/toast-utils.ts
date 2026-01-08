/**
 * Toast convenience utilities for showing notifications.
 *
 * Provides simple functions for showing success, error, warning, and info toasts
 * throughout the application with consistent styling.
 */

import { toast } from '@/components/ui/use-toast';
import type { ApiError } from '@/api/client';
import { isApiError, getApiError } from '@/api/client';

/**
 * Get a user-friendly error title based on HTTP status code
 */
export function getErrorTitle(status?: number): string {
    if (!status) return 'Error';

    if (status >= 500) {
        return 'Server Error';
    } else if (status === 404) {
        return 'Not Found';
    } else if (status === 403) {
        return 'Access Denied';
    } else if (status === 401) {
        return 'Authentication Required';
    } else if (status === 400) {
        return 'Invalid Request';
    } else if (status === 422) {
        return 'Validation Error';
    } else if (status === 429) {
        return 'Too Many Requests';
    } else if (status >= 400) {
        return 'Request Failed';
    }

    return 'Error';
}

/**
 * Show a success toast notification
 */
export function showSuccess(message: string, title?: string) {
    return toast({
        title: title || 'Success',
        description: message,
        variant: 'default',
        className: 'bg-green-50 border-green-200 text-green-900',
    });
}

/**
 * Show an error toast notification
 */
export function showError(message: string, title?: string) {
    return toast({
        title: title || 'Error',
        description: message,
        variant: 'destructive',
    });
}

/**
 * Show an error toast from an API error
 * Properly extracts error details and shows correlation ID for server errors
 */
export function showApiError(error: ApiError | unknown, fallbackMessage = 'An error occurred') {
    // Extract the API error using the helper from client
    const apiError: ApiError = isApiError(error) ? error : getApiError(error);
    const message = apiError.message || fallbackMessage;
    const status = apiError.status;
    const title = getErrorTitle(status);

    // Log full error details to console for debugging
    console.error('[API Error]', {
        message: apiError.message,
        code: apiError.code,
        status: apiError.status,
        details: apiError.details,
        correlationId: apiError.correlationId,
    });

    // For 500+ errors, include the correlation ID reference if available
    let displayMessage = message;
    if (status && status >= 500 && apiError.correlationId) {
        const shortRef = apiError.correlationId.substring(0, 8);
        displayMessage = `${message}\n\nReference: ${shortRef}`;
    }

    return toast({
        title,
        description: displayMessage,
        variant: 'destructive',
    });
}

/**
 * Show a network error toast for connection failures
 */
export function showNetworkError(message?: string) {
    const defaultMessage = 'Unable to connect to the server. Please check your internet connection and try again.';

    console.error('[Network Error]', { message: message || defaultMessage });

    return toast({
        title: 'Connection Error',
        description: message || defaultMessage,
        variant: 'destructive',
    });
}

/**
 * Show validation errors toast for form validation failures
 */
export function showValidationErrors(errors: Array<{ field: string; message: string }>) {
    if (!errors || errors.length === 0) {
        return showError('Please check your input and try again.', 'Validation Error');
    }

    console.error('[Validation Errors]', errors);

    // Format errors as a readable list
    const formattedErrors = errors
        .map(err => `${err.field}: ${err.message}`)
        .join('\n');

    return toast({
        title: 'Validation Error',
        description: errors.length === 1
            ? `${errors[0].field}: ${errors[0].message}`
            : `Please fix the following:\n${formattedErrors}`,
        variant: 'destructive',
    });
}

/**
 * Show a warning toast notification
 */
export function showWarning(message: string, title?: string) {
    return toast({
        title: title || 'Warning',
        description: message,
        variant: 'default',
        className: 'bg-yellow-50 border-yellow-200 text-yellow-900',
    });
}

/**
 * Show an info toast notification
 */
export function showInfo(message: string, title?: string) {
    return toast({
        title: title || 'Info',
        description: message,
        variant: 'default',
        className: 'bg-blue-50 border-blue-200 text-blue-900',
    });
}

/**
 * Show a loading toast (useful for long operations)
 */
export function showLoading(message: string, title?: string) {
    return toast({
        title: title || 'Loading',
        description: message,
        variant: 'default',
        className: 'bg-gray-50 border-gray-200 text-gray-900',
        // This toast won't auto-dismiss - caller should dismiss it manually
        duration: Infinity,
    });
}
