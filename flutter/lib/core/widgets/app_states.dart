import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/error_handler.dart';
import 'paper.dart';
import 'paper_scene.dart';
import 'skeletons.dart';

/// A scene, a title, one line of help and at most one action.
///
/// For a sliver list, wrap in `SliverFillRemaining(hasScrollBody: false)`.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.scene,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondary,
  });

  final PaperScenePreset scene;
  final String title;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Optional quiet second action (for example a text button).
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing16,
            vertical: AppConstants.spacing24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PaperSurface(
                padding: EdgeInsets.zero,
                deckle: PaperEdge.bottom,
                clipBehavior: Clip.antiAlias,
                // A step off the page tone, so all four edges read.
                color: tokens.stock.sunk,
                child: PaperScene(
                  preset: scene,
                  height: 168,
                  parallax: 0,
                  background: tokens.stock.sunk,
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),
              Text(
                title,
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  message!,
                  style: text.bodyMedium?.copyWith(color: tokens.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppConstants.spacing20),
                actionIcon == null
                    ? ElevatedButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      )
                    : ElevatedButton.icon(
                        onPressed: onAction,
                        icon: Icon(actionIcon, size: 20),
                        label: Text(actionLabel!),
                      ),
              ],
              if (secondary != null) ...[
                const SizedBox(height: AppConstants.spacing8),
                secondary!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What kind of failure an error is, for copy and artwork.
enum AppErrorKind { offline, server, notFound, auth, other }

AppErrorKind classifyError(Object? error) {
  if (error is SocketException) return AppErrorKind.offline;
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => AppErrorKind.offline,
      _ => classifyError(handleDioException(error)),
    };
  }
  if (error is NetworkException) {
    return switch (error.errorCode) {
      'NO_CONNECTION' || 'TIMEOUT' => AppErrorKind.offline,
      _ => AppErrorKind.server,
    };
  }
  if (error is ServerException) return AppErrorKind.server;
  if (error is NotFoundException) return AppErrorKind.notFound;
  if (error is AuthException) return AppErrorKind.auth;
  return AppErrorKind.other;
}

/// Full-area error with a retry. Picks copy and a scene from the error type.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, required this.error, this.onRetry});

  /// An [AppException], [DioException], other exception, or a message.
  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final kind = classifyError(error);
    final (title, message, scene) = switch (kind) {
      AppErrorKind.offline => (
        "You're offline",
        'Check your connection, then try again.',
        PaperScenes.offline,
      ),
      AppErrorKind.server => (
        'Our studio is down',
        'This is on our side. Try again in a minute.',
        PaperScenes.oops,
      ),
      AppErrorKind.notFound => (
        "This isn't here anymore",
        'It may have been deleted.',
        PaperScenes.oops,
      ),
      AppErrorKind.auth => (
        'Please sign in again',
        'Your session has ended.',
        PaperScenes.oops,
      ),
      AppErrorKind.other => (
        'Something went wrong',
        ErrorHandler.extractMessage(error),
        PaperScenes.oops,
      ),
    };
    return AppEmptyState(
      scene: scene,
      title: title,
      message: message,
      actionLabel: kind == AppErrorKind.notFound ? null : 'Try again',
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}

/// Renders an [AsyncValue] with the app's state rule:
///
/// 1. Loading with no data: [loading] (a skeleton).
/// 2. Error with no data: [AppErrorState] with retry.
/// 3. Data that is empty: [empty].
/// 4. Data: [data], with an [AppErrorBanner] on top if a refresh failed.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.isEmpty,
    this.empty,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (!value.hasValue) {
      if (value.hasError) {
        return AppErrorState(error: value.error, onRetry: onRetry);
      }
      return loading ?? const SkeletonListLoaderBox();
    }
    final v = value.requireValue;
    final content = (empty != null && (isEmpty?.call(v) ?? false))
        ? empty!
        : data(v);
    if (!value.hasError) return content;
    return Column(
      children: [
        AppErrorBanner(error: value.error, onRetry: onRetry),
        Expanded(child: content),
      ],
    );
  }
}

/// A slim inline banner for a failure over content that is still shown.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, this.message, this.error, this.onRetry})
    : assert(message != null || error != null);

  final String? message;
  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    final offline = classifyError(error ?? message) == AppErrorKind.offline;
    final text =
        message ??
        (offline
            ? "You're offline. Showing what we have."
            : ErrorHandler.extractMessage(error));
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        AppConstants.spacing8,
      ),
      child: PaperSurface(
        lift: 0,
        color: tokens.stock.tint,
        grain: false,
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing12,
          AppConstants.spacing4,
          AppConstants.spacing4,
          AppConstants.spacing4,
        ),
        child: Row(
          children: [
            Icon(
              offline ? Icons.cloud_off_outlined : Icons.error_outline_rounded,
              size: 20,
              color: tokens.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacing8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacing8,
                ),
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
