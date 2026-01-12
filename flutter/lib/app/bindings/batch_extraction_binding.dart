import 'package:get/get.dart';
import '../../features/wardrobe/controllers/batch_extraction_controller.dart';

/// Batch extraction binding - provides required controllers
/// Uses standardized lazy loading with fenix for automatic recreation
class BatchExtractionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BatchExtractionController>(
      () => BatchExtractionController(),
      fenix: true,
    );
  }
}
