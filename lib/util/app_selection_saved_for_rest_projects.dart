import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/theme/light_theme.dart';
import 'package:ride_sharing_user_app/theme/dark_theme.dart';
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
    return MaterialApp(
      title: 'Select App Mode',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
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
        notificationTitle: 'Restarting App',
        notificationBody: 'Please tap here to open the app again.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting app mode. Please try again.'),
          backgroundColor: Colors.red,
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Floating Particles
          _buildFloatingParticles(),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  _buildAnimatedLogo(colorScheme),

                  SizedBox(height: 50),

                  // Animated Welcome Text
                  _buildAnimatedWelcomeText(),

                  SizedBox(height: 80),

                  // Selection Buttons or Loading
                  if (_isLoading)
                    _buildLoadingAnimation()
                  else
                    _buildSelectionButtons(),

                  SizedBox(height: 50),

                  // Animated Footer Text
                  _buildAnimatedFooterText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  kPrimaryBlack,
                  kRichBlack,
                  (math.sin(_backgroundController.value * 2 * math.pi) + 1) / 2,
                )!,
                Color.lerp(
                  kRichBlack,
                  kDarkGold.withOpacity(0.3),
                  (math.cos(_backgroundController.value * 2 * math.pi) + 1) / 2,
                )!,
                Color.lerp(
                  kPrimaryBlack,
                  kDarkGold.withOpacity(0.2),
                  (math.sin(_backgroundController.value * 3 * math.pi) + 1) / 2,
                )!,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: GoldSparklesPainter(_backgroundController.value),
            size: MediaQuery.of(context).size,
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final offset = Offset(
              (math.sin(_backgroundController.value * 2 * math.pi + index) *
                      50) +
                  (MediaQuery.of(context).size.width * (index / 15)),
              (math.cos(_backgroundController.value * 1.5 * math.pi + index) *
                      100) +
                  (MediaQuery.of(context).size.height * ((index % 3) / 3)),
            );

            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Opacity(
                opacity: (0.1 +
                        (0.2 *
                            math.sin(
                                _backgroundController.value * math.pi + index)))
                    .clamp(0.0, 1.0),
                child: Container(
                  width: 20 + (10 * (index % 3)),
                  height: 20 + (index % 2 == 0 ? 10 : 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kLightGold.withOpacity(0.8),
                        kPrimaryGold.withOpacity(0.6),
                      ],
                    ),
                    shape:
                        index % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        index % 3 != 0 ? BorderRadius.circular(8) : null,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryGold.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
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

  Widget _buildAnimatedLogo(ColorScheme colorScheme) {
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
                    kChampagneGold,
                    kPrimaryGold,
                    kDarkGold,
                  ],
                ),
                borderRadius: BorderRadius.circular(70),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.4),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                  BoxShadow(
                    color: kLightGold.withOpacity(0.6),
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
                            color: kLightGold.withOpacity(0.8),
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
                        // Fallback to icon if image fails to load
                        return Icon(
                          Icons.directions_car_rounded,
                          size: 70,
                          color: kPrimaryBlack,
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

  Widget _buildAnimatedWelcomeText() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [kChampagneGold, kPrimaryGold, kLightGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                'Welcome to Ra7ty',
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
              'Choose how you want to use the app',
              style: TextStyle(
                fontSize: 18,
                color: kChampagneGold.withOpacity(0.9),
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGold),
                strokeWidth: 3,
              ),
            ),
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _backgroundController.value * 2 * math.pi,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/image/logo_png.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                      color: kPrimaryGold,
                      colorBlendMode: BlendMode.srcIn,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.directions_car_rounded,
                          color: kPrimaryGold,
                          size: 30,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 24),
        Text(
          'Preparing your experience...',
          style: TextStyle(
            color: kChampagneGold,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionButtons() {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Column(
        children: [
          // User Button
          _buildEnhancedSelectionButton(
            icon: Icons.person_rounded,
            title: 'I\'m a Passenger',
            subtitle: 'Book rides and travel comfortably',
            onTap: () => _selectAppMode(1),
            gradient: LinearGradient(
              colors: [kPrimaryGold, kDarkGold],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            delay: 0,
          ),

          SizedBox(height: 24),

          // Driver Button
          _buildEnhancedSelectionButton(
            icon: Icons.drive_eta_rounded,
            title: 'I\'m a Driver',
            subtitle: 'Drive and earn money with your car',
            onTap: () => _selectAppMode(0),
            gradient: LinearGradient(
              colors: [kRichBlack, kPrimaryBlack],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            delay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSelectionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
    required int delay,
  }) {
    final isGoldButton = gradient.colors.contains(kPrimaryGold);

    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _buttonController.value) * 50),
          child: Opacity(
            opacity: _buttonController.value,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isGoldButton
                        ? kPrimaryGold.withOpacity(0.3)
                        : kRichBlack.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isGoldButton
                          ? kPrimaryGold.withOpacity(0.2)
                          : kRichBlack.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: gradient.colors.first.withOpacity(0.4),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 35,
                        color: isGoldButton ? kRichBlack : kPrimaryGold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kRichBlack,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: kRichBlack.withOpacity(0.7),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kChampagneGold.withOpacity(0.2),
                            kPrimaryGold.withOpacity(0.1)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: kDarkGold,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFooterText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Interval(0.5, 1.0, curve: Curves.easeOut),
        )),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryGold.withOpacity(0.1),
                kDarkGold.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: kPrimaryGold.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '✨ You can change this later in the app settings',
            style: TextStyle(
              fontSize: 14,
              color: kChampagneGold,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Custom painter for gold sparkles effect
class GoldSparklesPainter extends CustomPainter {
  final double animationValue;

  GoldSparklesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create sparkles effect
    for (int i = 0; i < 30; i++) {
      final x = (math.sin(animationValue * 2 * math.pi + i) * size.width / 4) +
          (size.width * (i / 30));
      final y =
          (math.cos(animationValue * 1.5 * math.pi + i) * size.height / 4) +
              (size.height * ((i % 4) / 4));

      final opacity =
          (0.1 + 0.3 * math.sin(animationValue * math.pi + i)).clamp(0.0, 1.0);

      paint.color = kLightGold.withOpacity(opacity);

      // Draw different shapes for variety
      if (i % 3 == 0) {
        // Star shape
        _drawStar(canvas, paint, Offset(x, y), 3 + (i % 3));
      } else if (i % 2 == 0) {
        // Circle
        canvas.drawCircle(Offset(x, y), 2 + (i % 2), paint);
      } else {
        // Diamond
        _drawDiamond(canvas, paint, Offset(x, y), 4 + (i % 2));
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    final angle = 2 * math.pi / 5;

    for (int i = 0; i < 5; i++) {
      final x = center.dx + size * math.cos(i * angle - math.pi / 2);
      final y = center.dy + size * math.sin(i * angle - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Inner point
      final innerX =
          center.dx + (size / 2) * math.cos((i + 0.5) * angle - math.pi / 2);
      final innerY =
          center.dy + (size / 2) * math.sin((i + 0.5) * angle - math.pi / 2);
      path.lineTo(innerX, innerY);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
