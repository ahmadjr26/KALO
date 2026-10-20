import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PermissionUtils {
  /// Request camera permission with clear error/explanation handling
  static Future<bool> requestCameraPermission(BuildContext context, {String? reason}) async {
    final status = await Permission.camera.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Camera Access Required',
          message: reason ?? 'Camera access is required to capture food photos and scan barcodes. Please enable camera access in your device settings.',
        );
      }
      return false;
    }

    final result = await Permission.camera.request();
    if (result.isGranted || result.isLimited) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Camera Access Disabled',
          message: reason ?? 'Camera permission was permanently denied. Please navigate to settings to grant camera access.',
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission was denied. Cannot capture images.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    return false;
  }

  /// Request microphone permission for voice food logging
  static Future<bool> requestMicrophonePermission(BuildContext context, {String? reason}) async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Microphone Access Required',
          message: reason ?? 'Microphone access is required to log meals via voice. Please enable microphone permission in device settings.',
        );
      }
      return false;
    }

    final result = await Permission.microphone.request();
    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(
          context,
          title: 'Microphone Access Disabled',
          message: reason ?? 'Microphone permission was permanently denied. Please enable microphone in device settings.',
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission was denied. Cannot record voice.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
    return false;
  }

  static void _showSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: AppTypography.base.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.sm.copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Open Settings',
              style: AppTypography.sm.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
