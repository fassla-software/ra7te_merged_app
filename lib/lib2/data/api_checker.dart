import 'package:get/get.dart';
import 'package:ride_sharing_user_app/lib2/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/lib2/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/lib2/helper/display_helper.dart';
import 'error_response.dart';

import 'dart:convert'; // Import this to decode JSON

class ApiChecker {
  static void checkApi(Response response) {
    if (response.statusCode == 401) {
      Get.find<SplashController>().removeSharedData();
      Get.offAll(() => const SignInScreen());
    } else if (response.statusCode == 403) {
      try {
        var decodedBody;

        if (response.body is String) {
          // Check if response body is plain text, not JSON
          if (response.body.trim().startsWith('{')) {
            decodedBody = jsonDecode(response.body);
          } else {
            // Handle plain text error messages
            showCustomSnackBar(response.body);
            return;
          }
        } else {
          decodedBody = response.body;
        }

        ErrorResponse errorResponse = ErrorResponse.fromJson(decodedBody);

        if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
          showCustomSnackBar(errorResponse.errors![0].message!);
        } else {
          showCustomSnackBar(errorResponse.message ?? "Unknown error");
        }
      } catch (e) {
        print("Error decoding response body: $e");
        showCustomSnackBar("An unexpected error occurred");
      }
    } else {
      showCustomSnackBar(response.statusText ?? "Unknown error");
    }
  }
}
