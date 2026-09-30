import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../providers/extraction_jobs_provider.dart';
import 'extraction_progress_card.dart' show PaperProgressTrack;

/// Persistent strip atop the closet while extraction jobs run elsewhere.
/// Tapping resumes the most recent active job; the overflow opens the
/// activity list.
class ActiveJobBanner extends ConsumerWidget {
  const ActiveJobBanner({super.key});

  void _resume(BuildContext context, TrackedJob job) {
    if (job.kind == TrackedJobKind.batch) {
      context.push(Routes.wardrobeBatchProgress, extra: job.jobId);
    } else {
      context.push(Routes.wardrobeAdd, extra: job.jobId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(extractionJobsProvider.select((s) => s.active));
    if (active.isEmpty) return const SizedBox.shrink();
    final job = active.last;
    final tokens = PaperTokens.of(context);
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacing16,
        AppConstants.spacing8,
        AppConstants.spacing16,
        0,
      ),
      child: PaperSurface(
        onTap: () => _resume(context, job),
        semanticLabel: 'Resume ${job.label}',
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacing16,
          AppConstants.spacing12,
          AppConstants.spacing8,
          AppConstants.spacing12,
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: tokens.stock.accent,
                strokeCap: StrokeCap.round,
              ),
            ),
            const SizedBox(width: AppConstants.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    active.length > 1
                        ? 'Finding pieces (${active.length} scans)'
                        : 'Finding pieces in ${job.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  PaperProgressTrack(
                    value: job.progress,
                    semanticLabel: job.progressText,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.progressText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (active.length > 1)
              TextButton(
                onPressed: () => context.push(Routes.wardrobeJobs),
                child: const Text('All'),
              )
            else
              Icon(Icons.chevron_right_rounded, color: tokens.textMuted),
          ],
        ),
      ),
    );
  }
}
