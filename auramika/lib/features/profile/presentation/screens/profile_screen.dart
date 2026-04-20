import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Phase 1 Placeholder — Profile / Account screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PROFILE', style: AppTextStyles.brandLogo.copyWith(fontSize: 18)),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.goldLight,
                    child: Icon(Icons.person_outline_rounded, size: 40, color: AppColors.forestGreen),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text('My Profile', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    'Orders · Wishlist · Settings',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
