import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_ui.dart';

/// Shared status vocabulary for opaque (no real job/queue) async actions —
/// try-on, outfit generation, item save, avatar upload. See docs/exec-plans
/// for the initiative this belongs to.
enum ProcessingPhase { uploading, processing, done, failed }

/// Small inline spinner/icon + text row for buttons and other tight spaces.
///
/// Renders per the shared vocabulary:
/// - uploading/processing: a plain spinner + label (processing also shows
///   elapsed seconds — never a fake percentage, since these flows have no
///   real progress signal).
/// - done/failed: a small static icon + label. In practice most callers only
///   mount this widget while uploading/processing and let the existing
///   ErrorHandler.showSuccess/showError snackbar carry the terminal state,
///   but done/failed are supported here for callers that want an inline
///   terminal indicator too.
///
/// Elapsed time is measured from [startedAt], or from this widget's own
/// mount time if omitted — sufficient because callers typically create a
/// fresh instance exactly when a phase becomes active.
class InlineProcessingStatus extends StatefulWidget {
  const InlineProcessingStatus({
    super.key,
    required this.phase,
    this.startedAt,
    this.uploadingLabel = 'Uploading photo',
    this.processingLabel = 'Processing',
    this.doneLabel = 'Done',
    this.failedLabel = 'Failed',
    this.textStyle,
    this.color,
  });

  final ProcessingPhase phase;
  final DateTime? startedAt;
  final String uploadingLabel;
  final String processingLabel;
  final String doneLabel;
  final String failedLabel;
  final TextStyle? textStyle;

  /// Overrides the spinner/icon color. Defaults to the brand color for
  /// active states and semantic colors for done/failed.
  final Color? color;

  @override
  State<InlineProcessingStatus> createState() =>
      _InlineProcessingStatusState();
}

class _InlineProcessingStatusState extends State<InlineProcessingStatus> {
  Timer? _ticker;
  int _elapsedSeconds = 0;

  bool get _isActive =>
      widget.phase == ProcessingPhase.uploading ||
      widget.phase == ProcessingPhase.processing;

  @override
  void initState() {
    super.initState();
    _restartTicker();
  }

  @override
  void didUpdateWidget(covariant InlineProcessingStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase ||
        oldWidget.startedAt != widget.startedAt) {
      _restartTicker();
    }
  }

  void _restartTicker() {
    _ticker?.cancel();
    if (!_isActive) {
      _elapsedSeconds = 0;
      return;
    }

    // Compute the starting offset once from wall-clock time (handles a
    // caller-supplied startedAt that's already in the past), then just
    // increment per tick rather than re-diffing DateTime.now() every
    // second — a plain counter is simpler and, unlike a DateTime diff,
    // still advances correctly under a fake-async test clock.
    final start = widget.startedAt ?? DateTime.now();
    _elapsedSeconds = DateTime.now().difference(start).inSeconds;
    if (_elapsedSeconds < 0) _elapsedSeconds = 0;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    // Inherit the ambient text color (DefaultTextStyle) rather than a fixed
    // theme color: this widget is dropped inside buttons whose fill/foreground
    // varies (e.g. a brand-colored ElevatedButton with a white label), and a
    // hardcoded dark color there would be unreadable against the fill.
    final ambient = DefaultTextStyle.of(context).style;
    final style = widget.textStyle ??
        ambient.merge(
          Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ambient.color,
                fontWeight: FontWeight.w500,
              ),
        );
    // The spinner stays brand-colored regardless of ambient text color: it's
    // the primary "something is happening" signal and needs to read clearly
    // even against Material's greyed-out disabled-button fill (the state
    // every current call site renders it in).
    final iconColor = widget.color ?? tokens.brandColor;

    final Widget icon;
    final String label;

    switch (widget.phase) {
      case ProcessingPhase.uploading:
        icon = SizedBox(
          width: AppConstants.iconSmall,
          height: AppConstants.iconSmall,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(iconColor),
          ),
        );
        label = '${widget.uploadingLabel}…';
        break;
      case ProcessingPhase.processing:
        icon = SizedBox(
          width: AppConstants.iconSmall,
          height: AppConstants.iconSmall,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(iconColor),
          ),
        );
        label = '${widget.processingLabel}… (${_elapsedSeconds}s elapsed)';
        break;
      case ProcessingPhase.done:
        icon = Icon(
          Icons.check_circle_outline,
          size: AppConstants.iconSmall,
          color: widget.color ?? tokens.brandColor,
        );
        label = widget.doneLabel;
        break;
      case ProcessingPhase.failed:
        icon = Icon(
          Icons.error_outline,
          size: AppConstants.iconSmall,
          color: widget.color ?? Theme.of(context).colorScheme.error,
        );
        label = widget.failedLabel;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppConstants.spacing8),
        Flexible(
          child: Text(
            label,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
