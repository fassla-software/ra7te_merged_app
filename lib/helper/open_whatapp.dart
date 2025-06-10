import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsApp(String issueTitle) async {
  const String phoneNumber = "+201220065480";
  final String message = "Hello! I need help with: $issueTitle";

  // Encode the message for URL
  final String encodedMessage = Uri.encodeComponent(message);

  // Create WhatsApp URL
  final String whatsappUrl = "https://wa.me/$phoneNumber?text=$encodedMessage";

  try {
    final Uri uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback: try opening WhatsApp app directly
      final String fallbackUrl =
          "whatsapp://send?phone=$phoneNumber&text=$encodedMessage";
      final Uri fallbackUri = Uri.parse(fallbackUrl);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'WhatsApp is not installed on your device',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Unable to open WhatsApp: ${e.toString()}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
