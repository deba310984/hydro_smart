import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _progressAnimation;

  String _versionLabel = '';
  int _loadingMessageIndex = 0;
  Timer? _statusTimer;

  static const _loadingMessages = [
    'Initializing...',
    'Loading farm data...',
    'Connecting services...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Rotate animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );

    // Shimmer animation (continuous)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _loadVersionLabel();

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _rotateController.forward();
    _progressController.forward();

    _statusTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) return;
      setState(() {
        _loadingMessageIndex =
            (_loadingMessageIndex + 1) % _loadingMessages.length;
      });
    });

    // Navigate after splash completes
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      widget.onComplete();
    });
  }

  Future<void> _loadVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionLabel = 'Version ${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _versionLabel = 'Version 1.0.0');
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8DC), // Cream
              Color(0xFFFFE4B5), // Moccasin
              Color(0xFFF5F5DC), // Beige
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative mandala patterns in corners
            _buildCornerPattern(Alignment.topLeft),
            _buildCornerPattern(Alignment.topRight),
            _buildCornerPattern(Alignment.bottomLeft),
            _buildCornerPattern(Alignment.bottomRight),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animations
                    AnimatedBuilder(
                      animation: _scaleController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Transform.rotate(
                            angle: _rotateAnimation.value * 0.2,
                            child: _buildLogoWithShimmer(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // App name with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFFF9933), // Saffron
                          Color(0xFFFFD700), // Gold
                          Color(0xFF138808), // Green
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'HydroSmart',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                          fontFamily: 'serif',
                          shadows: [
                            Shadow(
                              offset: Offset(3, 3),
                              blurRadius: 8,
                              color: Color(0x40000000),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF138808).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFFF9933),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Future of Farming',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF138808),
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Loading indicator
                    _buildLoadingIndicator(),

                    const SizedBox(height: 20),

                    // Loading text
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        final opacity =
                            (0.5 + (_shimmerAnimation.value.abs() * 0.3))
                                .clamp(0.0, 1.0);
                        return Opacity(
                          opacity: opacity,
                          child: Text(
                            _loadingMessages[_loadingMessageIndex],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666),
                              letterSpacing: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Version info at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Text(
                    _versionLabel.isEmpty ? 'Version 1.0.0' : _versionLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoWithShimmer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Logo image with shadow
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9933).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: const Color(0xFF138808).withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFF8DC),
                        const Color(0xFFFFE4B5),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFF9933),
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop,
                      size: 80,
                      color: Color(0xFF138808),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Shimmer effect overlay
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return ClipOval(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: [
                      _shimmerAnimation.value - 0.3,
                      _shimmerAnimation.value,
                      _shimmerAnimation.value + 0.3,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Animated progress with gradient
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 4,
                  width: 200 * _progressAnimation.value.clamp(0.08, 1.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF9933),
                        Color(0xFFFFD700),
                        Color(0xFF138808),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9933).withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Glowing dots
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final opacity = (((_shimmerAnimation.value + delay) % 2) / 2)
                      .clamp(0.2, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(opacity),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(opacity),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCornerPattern(Alignment alignment) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value * 0.15,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: _MandalaPatternPainter(alignment),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MandalaPatternPainter extends CustomPainter {
  final Alignment alignment;

  _MandalaPatternPainter(this.alignment);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9933).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw decorative Islamic/Indian pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final radius = 40 * (i % 2 == 0 ? 1.0 : 0.7);
      final x = center.dx + radius * math.cos(angle) * alignment.x.sign;
      final y = center.dy + radius * math.sin(angle) * alignment.y.sign;

      canvas.drawCircle(Offset(x, y), 15, paint);

      canvas.drawCircle(
        Offset(x + 8 * math.cos(angle), y + 8 * math.sin(angle)),
        3,
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  @override
  bool shouldRepaint(covariant _MandalaPatternPainter oldDelegate) =>
      oldDelegate.alignment != alignment;
}
