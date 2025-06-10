import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/lib2/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/lib2/main.dart';
import 'package:ride_sharing_user_app/lib2/util/app_constants.dart'
    as AppConstants2;
import 'package:ride_sharing_user_app/util/app_constants.dart' as AppConstants;
import 'package:ride_sharing_user_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_sharing_user_app/lib2/helper/di_container.dart' as di2;

import 'package:restart_app/restart_app.dart';

class AppSwitcher {
  // Restart the app without closing it
  static void restartApp() {
    Restart.restartApp(
      notificationTitle: 'Restarting App',
      notificationBody: 'Please tap here to open the app again.',
    );
  }

  // Switch from main user app to driver app
  static void switchToDriverApp(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SwitchDialog(
          title: 'Switch to Driver App',
          content:
              'Do you want to switch to the Driver App? The app will restart automatically.',
          onConfirm: () async {
            // Save app state before switching
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setInt('isUserApp', 0); // 0 = driver app

            Get.reset();
            Get.clearRouteTree();
            Get.clearTranslations();
            // await FirebaseMessaging.instance
            //     .unsubscribeFromTopic(AppConstants.AppConstants.topic);
            // await FirebaseMessaging.instance
            //     .subscribeToTopic(AppConstants2.AppConstants.topic);
            await Future.delayed(const Duration(milliseconds: 2000), () {});

            // Restart the app to switch to driver mode
            AppSwitcher.restartApp();
          },
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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SwitchDialog(
          title: 'Switch to User App',
          content:
              'Do you want to switch to the User App? The app will restart automatically.',
          onConfirm: () async {
            // Save app state before switching
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setInt('isUserApp', 1); // 1 = user app

            Get.reset();
            Get.clearRouteTree();
            Get.clearTranslations();
            // await FirebaseMessaging.instance
            //     .unsubscribeFromTopic(AppConstants2.AppConstants.topic);
            // await FirebaseMessaging.instance
            //     .subscribeToTopic(AppConstants.AppConstants.topic);
            await Future.delayed(const Duration(milliseconds: 4000), () {});

            // Restart the app to switch to user mode
            AppSwitcher.restartApp();
          },
        );
      },
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class _SwitchDialog extends StatefulWidget {
  final String title;
  final String content;
  final Future<void> Function() onConfirm;

  const _SwitchDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  State<_SwitchDialog> createState() => _SwitchDialogState();
}

class _SwitchDialogState extends State<_SwitchDialog> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.content,
            style: TextStyle(color: Colors.black),
          ),
          if (isLoading) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(
                  'Switching app...',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: isLoading
          ? null
          : [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await widget.onConfirm();
                },
                child: Text('Yes', style: TextStyle(color: Colors.black)),
              ),
            ],
    );
  }
}
