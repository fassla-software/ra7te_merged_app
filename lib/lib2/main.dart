import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/lib2/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/lib2/helper/notification_helper.dart';
import 'package:ride_sharing_user_app/lib2/util/dimensions.dart';
import 'package:ride_sharing_user_app/lib2/util/images.dart';
import 'package:ride_sharing_user_app/lib2/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/lib2/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/lib2/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/lib2/helper/responsive_helper.dart';
import 'package:ride_sharing_user_app/lib2/helper/di_container.dart' as di;
import 'package:ride_sharing_user_app/lib2/helper/route_helper.dart';
import 'package:ride_sharing_user_app/lib2/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/lib2/localization/messages.dart';
import 'package:ride_sharing_user_app/lib2/theme/dark_theme.dart';
import 'package:ride_sharing_user_app/lib2/theme/light_theme.dart';
import 'package:ride_sharing_user_app/lib2/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/lib2/util/app_constants.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // dark text for status bar
        statusBarColor: Colors.transparent),
  );

  if (ResponsiveHelper.isMobilePhone) {
    HttpOverrides.global = MyHttpOverrides();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //firebase crashlytics
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  //
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  Map<String, Map<String, String>> languages = await di.init();

  final RemoteMessage? remoteMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  await NotificationHelper2.initialize(flutterLocalNotificationsPlugin);
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler2);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  runApp(MyApp2(languages: languages, notificationData: remoteMessage?.data));
}

class MyApp2 extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  final Map<String, dynamic>? notificationData;
  const MyApp2({super.key, required this.languages, this.notificationData});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor:
            Get.isDarkMode ? const Color(0xFF053B35) : const Color(0xFF00A08D),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark));
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
    }

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (configController) {
          return (GetPlatform.isWeb && configController.config == null)
              ? const SizedBox()
              : GetMaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  navigatorKey: Get.key,
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch
                    },
                  ),
                  theme: themeController.darkTheme ? darkTheme : lightTheme,
                  locale: localizeController.locale,
                  translations: Messages(languages: languages),
                  fallbackLocale: Locale(AppConstants.languages[0].languageCode,
                      AppConstants.languages[0].countryCode),
                  initialRoute: RouteHelper.getSplashRoute(
                      notificationData: notificationData),
                  getPages: RouteHelper.routes,
                  defaultTransition: Transition.fade,
                  transitionDuration: const Duration(milliseconds: 500),
                  builder: (context, child) {
                    return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.noScaling),
                        child: GetBuilder<RideController>(
                            builder: (rideController) {
                          return Stack(
                            children: [
                              child!,
                              if (rideController.notSplashRoute) ...[
                                if (!(Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode !=
                                            null &&
                                        Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode!
                                                .maintenanceStatus ==
                                            1 &&
                                        Get.find<SplashController>()
                                                .config!
                                                .maintenanceMode!
                                                .selectedMaintenanceSystem!
                                                .driverApp ==
                                            1) ||
                                    Get.find<SplashController>()
                                        .haveOngoingRides()) ...[
                                  Positioned(
                                    top: Get.height * 0.3,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        Response res =
                                            await rideController.getRideDetails(
                                                rideController.rideId ?? '1',
                                                fromHomeScreen: true);
                                        if (res.statusCode == 403 ||
                                            rideController.tripDetail
                                                    ?.currentStatus ==
                                                'returning' ||
                                            rideController.tripDetail
                                                    ?.currentStatus ==
                                                'returned') {
                                          Get.find<RiderMapController>()
                                              .setRideCurrentState(
                                                  RideState.initial);
                                        }
                                        Get.to(() => const MapScreen());
                                      },
                                      onHorizontalDragEnd:
                                          (DragEndDetails details) {
                                        _onHorizontalDrag(details);
                                        Get.to(() => const MapScreen());
                                      },
                                      child: Stack(children: [
                                        SizedBox(
                                            width:
                                                Dimensions.iconSizeExtraLarge,
                                            child: Image.asset(
                                                Images.homeToMapIcon,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        Positioned(
                                            top: 0,
                                            bottom: 0,
                                            left: 5,
                                            right: 5,
                                            child: SizedBox(
                                                width: 15,
                                                child: Image.asset(Images.map,
                                                    color: Get.isDarkMode
                                                        ? Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .tertiaryFixed)))
                                      ]),
                                    ),
                                  ),
                                ]
                              ]
                            ],
                          );
                        }));
                  });
        });
      });
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0) return;

    if (details.primaryVelocity!.compareTo(0) == -1) {
      debugPrint('dragged from left');
    } else {
      debugPrint('dragged from right');
    }
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
