import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSwitcher {
  // Switch from main user app to driver app
  static void switchToDriverApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch to Driver App'),
          content: const Text(
              'Do you want to switch to the Driver App? The app will close and you\'ll need to reopen it.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Save app state before exiting
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('isUserApp', 0); // 0 = driver app

                // Exit the app
                exit(0);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> changeAppState(int isUserApp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('isUserApp', isUserApp);
  }
}

class UserAppSwitcher {
  // Switch from driver app to user app
  static void switchToUserApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Switch to User App'),
          content: const Text(
              'Do you want to switch to the User App? The app will close and you\'ll need to reopen it.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Save app state before exiting
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setInt('isUserApp', 1); // 1 = user app

                // Exit the app
                exit(0);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
