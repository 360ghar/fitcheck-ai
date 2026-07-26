import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_bottom_navigation_bar.dart';
import 'profile_content.dart';

/// Pushed `/profile` route. The same content is the "More" tab in
/// MainShellPage; this wrapper only adds a Scaffold and its own navbar.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const ProfileContent(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: AppBottomNavigationBar.getIndexForRoute(Get.currentRoute),
      ),
    );
  }
}
