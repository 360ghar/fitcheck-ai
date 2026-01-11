import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_ui.dart';
import '../../wardrobe/controllers/wardrobe_controller.dart';

/// Export dialog for wardrobe data
class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppUiTokens.of(context);

    return AlertDialog(
      title: const Text('Export Wardrobe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('JSON Format'),
            subtitle: const Text('Full data with all details'),
            onTap: () => _exportAs('json'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('CSV Format'),
            subtitle: const Text('Spreadsheet compatible'),
            onTap: () => _exportAs('csv'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _exportAs(String format) {
    Get.back();
    Get.snackbar(
      'Exporting',
      'Preparing your $format file...',
      snackPosition: SnackPosition.TOP,
    );
    // Would trigger actual export
  }
}
