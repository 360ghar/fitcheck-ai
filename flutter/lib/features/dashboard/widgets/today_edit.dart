import 'package:flutter/material.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/dashboard_models.dart';
import '../../wardrobe/repositories/item_repository.dart';

/// An editorial spread built around the user's actual daily outfit.
class TodayEdit extends StatelessWidget {
  const TodayEdit({
    super.key,
    this.outfit,
    this.hasItems = false,
    required this.onOpen,
  });

  final DashboardOutfitOfTheDay? outfit;
  final bool hasItems;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final photo = outfit?.imageUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;
    final text = Theme.of(context).textTheme;
    final label = outfit == null
        ? hasItems
              ? 'Create an outfit'
              : 'Add your first pieces'
        : 'Explore this outfit';

    return Material(
      color: AppCoreColors.editorialRose,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = MediaQuery.textScalerOf(context).scale(14) > 16;
                final compact = constraints.maxWidth < 330;
                final image = hasPhoto
                    ? AppImage(
                        imageUrl: photo,
                        storagePath: outfit?.storagePath,
                        remintUrl: ItemRepository().remintImageUrl,
                        fit: BoxFit.contain,
                        enableZoom: false,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        memCacheWidth: 1000,
                        memCacheHeight: 1200,
                      )
                    : Image.asset(
                        'assets/images/wardrobe-editorial.webp',
                        fit: BoxFit.cover,
                        semanticLabel: 'Wardrobe inspiration',
                      );
                final headline = Padding(
                  padding: EdgeInsets.all(compact ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.auto_awesome_outlined,
                        color: AppCoreColors.editorialInk,
                        size: 24,
                      ),
                      SizedBox(height: compact ? 12 : 20),
                      Text(
                        stacked ? 'Your next look.' : 'Your\nnext\nlook.',
                        style: text.displaySmall?.copyWith(
                          color: AppCoreColors.editorialInk,
                          fontSize: compact ? 32 : 38,
                          height: 1.08,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 20),
                      Text(
                        hasPhoto
                            ? 'From your wardrobe. For today.'
                            : 'Style inspiration. Make it yours.',
                        style: text.bodySmall?.copyWith(
                          color: AppCoreColors.editorialInk,
                        ),
                      ),
                    ],
                  ),
                );
                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      headline,
                      AspectRatio(aspectRatio: 1, child: image),
                    ],
                  );
                }
                return SizedBox(
                  height: (constraints.maxWidth * .8).clamp(230, 440),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: headline),
                      Expanded(flex: 6, child: image),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (outfit?.name != null) ...[
                          Text(
                            outfit!.name!,
                            style: text.titleMedium?.copyWith(
                              color: AppCoreColors.editorialInk,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          label,
                          style: text.labelLarge?.copyWith(
                            color: AppCoreColors.editorialInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppCoreColors.editorialInk,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
