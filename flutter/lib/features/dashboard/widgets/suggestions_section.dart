import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_ui.dart';
import '../controllers/dashboard_controller.dart';

/// The daily outfit already leads Home; this section adds only weather guidance.
class SuggestionsSection extends StatelessWidget {
  const SuggestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final text = Theme.of(context).textTheme;
    return Obx(() {
      final weather = controller.dashboard.value?.suggestions.weatherBased;
      if (weather == null) return const SizedBox.shrink();
      return Material(
        color: AppCoreColors.editorialSlate,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: AppCoreColors.editorialInk,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.temperature == null
                          ? 'Dress for the day'
                          : '${weather.temperature!.toStringAsFixed(1)} °C',
                      style: text.titleMedium?.copyWith(
                        color: AppCoreColors.editorialInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weather.recommendation ??
                          'Style smart for the day ahead.',
                      style: text.bodyMedium?.copyWith(
                        color: AppCoreColors.editorialInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
