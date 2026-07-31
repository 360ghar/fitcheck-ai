import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/feedback_repository.dart';
import '../models/feedback_model.dart';
import '../../../core/utils/frame_safe.dart';
import '../../../core/utils/error_handler.dart';

/// Controller for feedback submission
class FeedbackController extends GetxController {
  final FeedbackRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _successResetTimer;

  FeedbackController({FeedbackRepository? repository})
    : _repository = repository ?? FeedbackRepository();

  // Form state
  final Rx<TicketCategory> category = TicketCategory.generalFeedback.obs;
  final RxString subject = ''.obs;
  final RxString description = ''.obs;
  final RxList<File> attachments = <File>[].obs;

  /// Stable controllers so category/Obx rebuilds don't wipe typed text
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Loading states
  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingTickets = false.obs;
  final RxString error = ''.obs;

  // Success state
  final RxBool showSuccess = false.obs;

  // User's tickets
  final RxList<TicketListItem> tickets = <TicketListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    subjectController.addListener(() {
      subject.value = subjectController.text;
    });
    descriptionController.addListener(() {
      description.value = descriptionController.text;
    });
    fetchTickets();
  }

  @override
  void onClose() {
    _successResetTimer?.cancel();
    _successResetTimer = null;
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    if (attachments.length >= 5) {
      ErrorHandler.showValidation(
        'Maximum 5 attachments allowed',
        title: 'Limit Reached',
      );
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (isClosed) return;
      final file = File(pickedFile.path);
      final size = await file.length();
      if (isClosed) return;

      if (size > 5 * 1024 * 1024) {
        ErrorHandler.showValidation(
          'Image must be under 5MB',
          title: 'File Too Large',
        );
        return;
      }

      attachments.add(file);
    }
  }

  /// Take photo with camera
  Future<void> takePhoto() async {
    if (attachments.length >= 5) {
      ErrorHandler.showValidation(
        'Maximum 5 attachments allowed',
        title: 'Limit Reached',
      );
      return;
    }

    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (isClosed) return;
      final file = File(pickedFile.path);
      final size = await file.length();
      if (isClosed) return;

      if (size > 5 * 1024 * 1024) {
        ErrorHandler.showValidation(
          'Image must be under 5MB',
          title: 'File Too Large',
        );
        return;
      }

      attachments.add(file);
    }
  }

  /// Remove attachment
  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  /// Submit feedback
  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isSubmitting.value = true;
    error.value = '';

    try {
      await _repository.submitFeedback(
        category: category.value,
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
        attachments: attachments.isNotEmpty ? attachments.toList() : null,
      );

      if (isClosed) return;

      // Reset form
      category.value = TicketCategory.generalFeedback;
      subjectController.clear();
      descriptionController.clear();
      subject.value = '';
      description.value = '';
      attachments.clear();

      showSuccess.value = true;
      scheduleSuccessDismissal();

      // Reload tickets
      fetchTickets();

      ErrorHandler.showInfo(
        'Your feedback has been submitted successfully.',
        title: 'Thank You!',
      );
    } catch (e) {
      if (isClosed) return;
      error.value = ErrorHandler.extractMessage(e);
      ErrorHandler.showError(
        'Failed to submit feedback. Please try again.',
        title: 'Error',
      );
    } finally {
      if (!isClosed) isSubmitting.value = false;
    }
  }

  /// Fetch user's tickets
  Future<void> fetchTickets() async {
    if (!await settleBuildPhase(stillAlive: () => !isClosed)) return;
    isLoadingTickets.value = true;
    try {
      final result = await _repository.getMyTickets();
      if (isClosed) return;
      tickets.assignAll(result);
    } catch (e) {
      if (isClosed) return;
      error.value = ErrorHandler.extractMessage(e);
    } finally {
      if (!isClosed) isLoadingTickets.value = false;
    }
  }

  @visibleForTesting
  void scheduleSuccessDismissal({
    Duration duration = const Duration(seconds: 5),
  }) {
    _successResetTimer?.cancel();
    _successResetTimer = Timer(duration, () {
      if (!isClosed) showSuccess.value = false;
    });
  }

  /// Set category and optionally navigate from help page
  void setCategory(TicketCategory cat) {
    category.value = cat;
  }
}
