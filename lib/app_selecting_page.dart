import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/theme/light_theme.dart';
import 'package:ride_sharing_user_app/theme/dark_theme.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/localization/messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';
import 'dart:math' as math;

// Premium Black and Gold color constants
const Color kPrimaryBlack = Color.fromARGB(255, 0, 0, 0);
const Color kPrimaryGold = Color(0xFFc9a236);
const Color kRichBlack = Color(0xFF1a1a1a);
const Color kDarkGold = Color(0xFF8b7429);
const Color kLightGold = Color(0xFFf4d03f);
const Color kChampagneGold = Color(0xFFf7dc6f);

class AppSelectionApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;

  const AppSelectionApp({Key? key, required this.languages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_mode_selection'.tr,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      translations: Messages(languages: languages),
      locale: Get.find<LocalizationController>().locale,
      fallbackLocale: Locale('en', 'US'),
      home: AppSelectionPage(),
    );
  }
}

class AppSelectionPage extends StatefulWidget {
  @override
  _AppSelectionPageState createState() => _AppSelectionPageState();
}

class _AppSelectionPageState extends State<AppSelectionPage>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _backgroundController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.bounceOut,
    ));

    // Start animations with delays
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _scaleController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _rotationController.forward();

    await Future.delayed(Duration(milliseconds: 400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _selectAppMode(int mode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('isUserApp', mode);

      // Show loading for a brief moment
      await Future.delayed(Duration(milliseconds: 1500));

      // Restart the app to reinitialize with the selected mode
      await Restart.restartApp(
        notificationTitle: 'restarting_app'.tr,
        notificationBody: 'tap_to_open_app_again'.tr,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('error_selecting_app_mode'.tr),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBackgroundColor =
        isDark ? theme.primaryColor : theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(theme, isDark),

          // Floating Particles
          _buildFloatingParticles(theme, isDark),

          // Main Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Logo Section
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedLogo(theme, isDark),
                        SizedBox(height: 30),
                        _buildAnimatedWelcomeText(theme, isDark),
                      ],
                    ),
                  ),

                  // Selection Cards Row
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Passenger Button
                          SizedBox(
                            width: 160,
                            height: 200,
                            child: _buildSelectionCard(
                              title: 'passenger_mode'.tr,
                              subtitle: 'passenger_subtitle'.tr,
                              icon: Icons.person_rounded,
                              onTap: () => _selectAppMode(1),
                              isSelected: false,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),

                          SizedBox(width: 20),

                          // Driver Button
                          SizedBox(
                            width: 160,
                            height: 200,
                            child: _buildSelectionCard(
                              title: 'driver_mode'.tr,
                              subtitle: 'driver_subtitle'.tr,
                              icon: Icons.drive_eta_rounded,
                              onTap: () => _selectAppMode(0),
                              isSelected: false,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'change_later_settings'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: (isDark
                                    ? theme.colorScheme.onSurface
                                    : theme.primaryColor)
                                .withOpacity(0.6),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading) _buildLoadingOverlay(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme, bool isDark) {
    // Use proper background colors based on theme
    final backgroundColor =
        isDark ? theme.primaryColor : theme.colorScheme.surface;
    final accentColor = theme.primaryColorDark; // Gold color

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                isDark
                    ? Color.lerp(
                        backgroundColor, accentColor.withOpacity(0.2), 0.3)!
                    : Color.lerp(
                        backgroundColor, accentColor.withOpacity(0.1), 0.1)!,
                backgroundColor,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles(ThemeData theme, bool isDark) {
    final primaryGold = theme.primaryColorDark;

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final offset = Offset(
              (math.sin(_backgroundController.value * 1.5 * math.pi + index) *
                      30) +
                  (MediaQuery.of(context).size.width * (index / 8)),
              (math.cos(_backgroundController.value * 1.2 * math.pi + index) *
                      40) +
                  (MediaQuery.of(context).size.height * ((index % 2) / 2)),
            );

            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Opacity(
                opacity: (0.05 +
                        (0.1 *
                            math.sin(
                                _backgroundController.value * math.pi + index)))
                    .clamp(0.0, 1.0),
                child: Container(
                  width: 15 + (5 * (index % 2)),
                  height: 15 + (5 * (index % 2)),
                  decoration: BoxDecoration(
                    color: primaryGold.withOpacity(isDark ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(isDark ? 0.2 : 0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme, bool isDark) {
    final primaryGold = theme.primaryColorDark;
    final scaffoldBackgroundColor =
        isDark ? theme.primaryColor : theme.colorScheme.surface;
    final logoBackgroundColor = isDark ? primaryGold : primaryGold;
    final ringColor =
        isDark ? theme.colorScheme.surface : primaryGold.withOpacity(0.3);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scaffoldBackgroundColor.withOpacity(0.9),
                    scaffoldBackgroundColor,
                    scaffoldBackgroundColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(isDark ? 0.4 : 0.3),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                  BoxShadow(
                    color:
                        (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing ring
                  AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Container(
                        width: 120 +
                            (20 *
                                math.sin(
                                    _backgroundController.value * 4 * math.pi)),
                        height: 120 +
                            (20 *
                                math.sin(
                                    _backgroundController.value * 4 * math.pi)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ringColor,
                            width: 3,
                          ),
                        ),
                      );
                    },
                  ),
                  // App Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.asset(
                      'assets/image/logo_png.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.directions_car_rounded,
                          size: 70,
                          color: isDark
                              ? theme.colorScheme.surface
                              : theme.primaryColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedWelcomeText(ThemeData theme, bool isDark) {
    final primaryGold = theme.primaryColorDark;
    final textColor = isDark ? theme.colorScheme.onSurface : primaryGold;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  primaryGold,
                  primaryGold.withOpacity(0.8),
                  primaryGold.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                '${'welcome_to'.tr} Ra7ty',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'choose_app_mode_subtitle'.tr,
              style: TextStyle(
                fontSize: 18,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme, bool isDark) {
    final primaryGold = theme.primaryColorDark;
    final backgroundColor =
        isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.8);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated loading icon
                  AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _backgroundController.value * 2 * math.pi,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryGold,
                                primaryGold.withOpacity(0.6)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryGold.withOpacity(0.3),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 24),

                  // Loading text
                  Text(
                    'preparing_experience'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? theme.colorScheme.onSurface
                          : theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8),

                  // Loading dots animation
                  AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.3;
                          final opacity = (math.sin(
                                      (_backgroundController.value + delay) *
                                          2 *
                                          math.pi) +
                                  1) /
                              2;
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: primaryGold.withOpacity(opacity),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
    required ThemeData theme,
    required bool isDark,
  }) {
    final primaryGold = theme.primaryColorDark;
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final textColor = isDark ? theme.colorScheme.onSurface : theme.primaryColor;
    final subtitleColor = isDark
        ? theme.colorScheme.onSurface.withOpacity(0.7)
        : theme.primaryColor.withOpacity(0.7);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  primaryGold.withOpacity(0.15),
                  primaryGold.withOpacity(0.08),
                  primaryGold.withOpacity(0.05),
                ]
              : [cardColor, cardColor, cardColor],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? primaryGold.withOpacity(0.6)
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1)),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryGold.withOpacity(0.3)
                : (isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1)),
            blurRadius: isSelected ? 20 : 10,
            offset: Offset(0, isSelected ? 8 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [primaryGold, primaryGold.withOpacity(0.8)]
                          : [
                              primaryGold.withOpacity(0.2),
                              primaryGold.withOpacity(0.1)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(isSelected ? 0.4 : 0.1),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? theme.colorScheme.onSurface : primaryGold),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
