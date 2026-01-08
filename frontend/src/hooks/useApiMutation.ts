import { useMutation, UseMutationOptions, UseMutationResult } from '@tanstack/react-query';
import { getApiError, ApiError } from '@/api/client';

/**
 * Custom hook that wraps useMutation with standardized error handling.
 * Automatically converts errors to ApiError type.
 *
 * @example
 * const createItem = useApiMutation({
 *   mutationFn: (data: CreateItemData) => itemsApi.createItem(data),
 *   onSuccess: () => {
 *     queryClient.invalidateQueries({ queryKey: ['items'] });
 *     showSuccess('Item created');
 *   },
 * });
 *
 * // In component:
 * createItem.mutate(formData);
 * // Access: createItem.isPending, createItem.error, createItem.data
 */
export function useApiMutation<TData = unknown, TVariables = void, TContext = unknown>(
  options: Omit<UseMutationOptions<TData, ApiError, TVariables, TContext>, 'onError'> & {
    onError?: (error: ApiError, variables: TVariables, context: TContext | undefined) => void;
  }
): UseMutationResult<TData, ApiError, TVariables, TContext> {
  return useMutation<TData, ApiError, TVariables, TContext>({
    ...options,
    onError: (error, variables, context) => {
      // Error is already ApiError due to our type, but ensure conversion
      const apiError = error instanceof Error && 'code' in error
        ? error as ApiError
        : getApiError(error);

      options.onError?.(apiError, variables, context);
    },
  });
}

export default useApiMutation;
