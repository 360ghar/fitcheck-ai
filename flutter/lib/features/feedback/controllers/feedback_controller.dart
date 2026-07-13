import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/feedback_repository.dart';
import '../models/feedback_model.dart';

/// Controller for feedback submission
class FeedbackController extends GetxController {
  final FeedbackRepository _repository = FeedbackRepository();
  final ImagePicker _imagePicker = ImagePicker();

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
    subjectController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// Pick image from gallery
  Future<void> pickImage() async {
    if (attachments.length >= 5) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 5 attachments allowed',
        snackPosition: SnackPosition.TOP,
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
      final file = File(pickedFile.path);
      final size = await file.length();

      if (size > 5 * 1024 * 1024) {
        Get.snackbar(
          'File Too Large',
          'Image must be under 5MB',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      attachments.add(file);
    }
  }

  /// Take photo with camera
  Future<void> takePhoto() async {
    if (attachments.length >= 5) {
      Get.snackbar(
        'Limit Reached',
        'Maximum 5 attachments allowed',
        snackPosition: SnackPosition.TOP,
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
      final file = File(pickedFile.path);
      final size = await file.length();

      if (size > 5 * 1024 * 1024) {
        Get.snackbar(
          'File Too Large',
          'Image must be under 5MB',
          snackPosition: SnackPosition.TOP,
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

      // Reset form
      category.value = TicketCategory.generalFeedback;
      subjectController.clear();
      descriptionController.clear();
      subject.value = '';
      description.value = '';
      attachments.clear();

      showSuccess.value = true;
      Future.delayed(const Duration(seconds: 5), () {
        showSuccess.value = false;
      });

      // Reload tickets
      fetchTickets();

      Get.snackbar(
        'Thank You!',
        'Your feedback has been submitted successfully.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to submit feedback. Please try again.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Fetch user's tickets
  Future<void> fetchTickets() async {
    isLoadingTickets.value = true;
    try {
      final result = await _repository.getMyTickets();
      tickets.assignAll(result);
    } catch (e) {
      // Ignore - user might not be authenticated
    } finally {
      isLoadingTickets.value = false;
    }
  }

  /// Set category and optionally navigate from help page
  void setCategory(TicketCategory cat) {
    category.value = cat;
  }
}
