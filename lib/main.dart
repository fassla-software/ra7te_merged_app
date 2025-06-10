import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/helper/responsive_helper.dart';
import 'package:ride_sharing_user_app/helper/di_container.dart' as di;
import 'package:ride_sharing_user_app/lib2/helper/di_container.dart' as di2;
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/lib2/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/lib2/main.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/localization/messages.dart';
import 'package:ride_sharing_user_app/theme/dark_theme.dart';
import 'package:ride_sharing_user_app/theme/light_theme.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if (ResponsiveHelper.isMobilePhone) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //firebase crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  //
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Map<String, Map<String, String>> languages = {};
  RemoteMessage? remoteMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check which app to load based on shared preference
  int isUserApp = prefs.getInt('isUserApp') ?? 1;

  // Initialize the correct dependency injection based on app mode
  if (isUserApp == 1) {
    print("Starting as User App");
    languages = await di.init();
    await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } else {
    print("Starting as Driver App");
    languages = await di2.init();
    await NotificationHelper2.initialize(flutterLocalNotificationsPlugin);
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler2);

    // Add any other driver app initialization here
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Launch the correct app based on the preference
  runApp(RestartWidget(
      child: isUserApp == 1
          ? MyApp(languages: languages, notificationData: remoteMessage?.data)
          : MyApp2(
              languages: languages, notificationData: remoteMessage?.data)));
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final Map<String, dynamic>? notificationData;
  const MyApp({super.key, required this.languages, this.notificationData});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? darkTheme : lightTheme,
            locale: localizeController.locale,
            initialRoute:
                RouteHelper.getSplashRoute(notificationData: notificationData),
            getPages: RouteHelper.routes,
            translations: Messages(languages: languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode,
                AppConstants.languages[0].countryCode),
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (context, child) {
              return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: child!);
            });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static Future<void> restartApp(BuildContext context, Widget newApp) async {
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp(newApp);
    await Restart.restartApp(
      /// In Web Platform, Fill webOrigin only when your new origin is different than the app's origin
      // webOrigin: 'http://example.com',

      // Customizing the restart notification message (only needed on iOS)
      notificationTitle: 'Restarting App',
      notificationBody: 'Please tap here to open the app again.',
    );
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  late Widget _child;

  @override
  void initState() {
    super.initState();
    _child = widget.child;
  }

  void restartApp(Widget newApp) {
    setState(() {
      _child = newApp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _child;
  }
}
