import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tutorial_step.dart';

/// An animated 2D farmer character for the onboarding tutorial
class AnimatedTutorialCharacter extends StatefulWidget {
  final CharacterEmotion emotion;
  final CharacterGesture gesture;
  final double size;
  final bool isAnimating;
  final VoidCallback? onTap;

  const AnimatedTutorialCharacter({
    super.key,
    this.emotion = CharacterEmotion.happy,
    this.gesture = CharacterGesture.wave,
    this.size = 120,
    this.isAnimating = true,
    this.onTap,
  });

  @override
  State<AnimatedTutorialCharacter> createState() =>
      _AnimatedTutorialCharacterState();
}

class _AnimatedTutorialCharacterState extends State<AnimatedTutorialCharacter>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _waveController;
  late AnimationController _blinkController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Bounce animation for idle movement
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Wave animation for hand/arm movement
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation =
        Tween<double>(begin: 1, end: 0.1).animate(_blinkController);

    if (widget.isAnimating) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _bounceController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
    _startBlinkLoop();
  }

  void _startBlinkLoop() async {
    while (mounted && widget.isAnimating) {
      await Future.delayed(
          Duration(milliseconds: 2000 + math.Random().nextInt(2000)));
      if (mounted) {
        await _blinkController.forward();
        await _blinkController.reverse();
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedTutorialCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _startAnimations();
    } else if (!widget.isAnimating && oldWidget.isAnimating) {
      _bounceController.stop();
      _waveController.stop();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _waveController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_bounceAnimation, _waveAnimation, _blinkAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: SizedBox(
              width: widget.size,
              height: widget.size * 1.4,
              child: CustomPaint(
                painter: _FarmerCharacterPainter(
                  emotion: widget.emotion,
                  gesture: widget.gesture,
                  waveAngle: _waveAnimation.value,
                  blinkValue: _blinkAnimation.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FarmerCharacterPainter extends CustomPainter {
  final CharacterEmotion emotion;
  final CharacterGesture gesture;
  final double waveAngle;
  final double blinkValue;

  _FarmerCharacterPainter({
    required this.emotion,
    required this.gesture,
    required this.waveAngle,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final scale = size.width / 120;

    // Colors
    final skinColor = const Color(0xFFD4A574);
    final skinDark = const Color(0xFFC49464);
    final hatColor = const Color(0xFF8B4513);
    final hatBand = const Color(0xFFFFD700);
    final shirtColor = const Color(0xFF4CAF50);
    final shirtDark = const Color(0xFF388E3C);
    final pantsColor = const Color(0xFF5D4037);

    // Body (torso)
    final bodyPaint = Paint()
      ..color = shirtColor
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(centerX - 25 * scale, 70 * scale);
    bodyPath.quadraticBezierTo(
        centerX - 30 * scale, 95 * scale, centerX - 20 * scale, 115 * scale);
    bodyPath.lineTo(centerX + 20 * scale, 115 * scale);
    bodyPath.quadraticBezierTo(
        centerX + 30 * scale, 95 * scale, centerX + 25 * scale, 70 * scale);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Shirt collar
    final collarPaint = Paint()
      ..color = shirtDark
      ..style = PaintingStyle.fill;
    final collarPath = Path();
    collarPath.moveTo(centerX - 15 * scale, 68 * scale);
    collarPath.lineTo(centerX, 78 * scale);
    collarPath.lineTo(centerX + 15 * scale, 68 * scale);
    collarPath.lineTo(centerX + 10 * scale, 72 * scale);
    collarPath.lineTo(centerX, 74 * scale);
    collarPath.lineTo(centerX - 10 * scale, 72 * scale);
    collarPath.close();
    canvas.drawPath(collarPath, collarPaint);

    // Arms
    _drawArms(canvas, centerX, scale, skinColor, shirtColor);

    // Head
    final headPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, 42 * scale),
        width: 50 * scale,
        height: 55 * scale,
      ),
      headPaint,
    );

    // Ears
    canvas.drawCircle(
      Offset(centerX - 24 * scale, 42 * scale),
      7 * scale,
      headPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 24 * scale, 42 * scale),
      7 * scale,
      headPaint,
    );

    // Inner ear
    final innerEarPaint = Paint()..color = skinDark;
    canvas.drawCircle(
      Offset(centerX - 24 * scale, 42 * scale),
      4 * scale,
      innerEarPaint,
    );
    canvas.drawCircle(
      Offset(centerX + 24 * scale, 42 * scale),
      4 * scale,
      innerEarPaint,
    );

    // Farmer's hat (straw hat style)
    _drawHat(canvas, centerX, scale, hatColor, hatBand);

    // Face features
    _drawFace(canvas, centerX, scale);

    // Legs hint at bottom
    final legsPaint = Paint()
      ..color = pantsColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            centerX - 18 * scale, 115 * scale, 14 * scale, 20 * scale),
        Radius.circular(4 * scale),
      ),
      legsPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + 4 * scale, 115 * scale, 14 * scale, 20 * scale),
        Radius.circular(4 * scale),
      ),
      legsPaint,
    );
  }

  void _drawHat(Canvas canvas, double centerX, double scale, Color hatColor,
      Color hatBand) {
    final hatPaint = Paint()
      ..color = hatColor
      ..style = PaintingStyle.fill;

    // Hat brim
    final brimPath = Path();
    brimPath.addOval(Rect.fromCenter(
      center: Offset(centerX, 22 * scale),
      width: 65 * scale,
      height: 18 * scale,
    ));
    canvas.drawPath(brimPath, hatPaint);

    // Hat top (dome)
    final topPath = Path();
    topPath.moveTo(centerX - 22 * scale, 22 * scale);
    topPath.quadraticBezierTo(
        centerX - 25 * scale, 5 * scale, centerX, 2 * scale);
    topPath.quadraticBezierTo(
        centerX + 25 * scale, 5 * scale, centerX + 22 * scale, 22 * scale);
    topPath.close();
    canvas.drawPath(topPath, hatPaint);

    // Hat band
    final bandPaint = Paint()
      ..color = hatBand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, 18 * scale),
        width: 44 * scale,
        height: 12 * scale,
      ),
      0,
      math.pi,
      false,
      bandPaint,
    );
  }

  void _drawArms(Canvas canvas, double centerX, double scale, Color skinColor,
      Color shirtColor) {
    final armPaint = Paint()
      ..color = shirtColor
      ..style = PaintingStyle.fill;
    final handPaint = Paint()
      ..color = skinColor
      ..style = PaintingStyle.fill;

    // Left arm
    canvas.save();
    canvas.translate(centerX - 28 * scale, 75 * scale);
    canvas.rotate(waveAngle);

    final leftArmPath = Path();
    leftArmPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(-8 * scale, 0, 16 * scale, 35 * scale),
      Radius.circular(8 * scale),
    ));
    canvas.drawPath(leftArmPath, armPaint);

    // Left hand
    canvas.drawCircle(Offset(0, 38 * scale), 8 * scale, handPaint);
    canvas.restore();

    // Right arm (waving based on gesture)
    canvas.save();
    canvas.translate(centerX + 28 * scale, 75 * scale);

    double rightArmAngle = 0;
    if (gesture == CharacterGesture.wave ||
        gesture == CharacterGesture.welcome) {
      rightArmAngle = -0.8 + waveAngle * 2;
    } else if (gesture == CharacterGesture.point) {
      rightArmAngle = -0.6;
    } else if (gesture == CharacterGesture.thumbsUp ||
        gesture == CharacterGesture.celebrate) {
      rightArmAngle = -1.0;
    } else {
      rightArmAngle = -waveAngle;
    }
    canvas.rotate(rightArmAngle);

    final rightArmPath = Path();
    rightArmPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(-8 * scale, 0, 16 * scale, 35 * scale),
      Radius.circular(8 * scale),
    ));
    canvas.drawPath(rightArmPath, armPaint);

    // Right hand
    if (gesture == CharacterGesture.thumbsUp) {
      // Thumbs up hand
      canvas.drawCircle(Offset(0, 38 * scale), 8 * scale, handPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-3 * scale, 30 * scale, 6 * scale, 12 * scale),
          Radius.circular(3 * scale),
        ),
        handPaint,
      );
    } else if (gesture == CharacterGesture.point) {
      // Pointing hand
      canvas.drawCircle(Offset(0, 38 * scale), 7 * scale, handPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-2 * scale, 38 * scale, 4 * scale, 15 * scale),
          Radius.circular(2 * scale),
        ),
        handPaint,
      );
    } else {
      canvas.drawCircle(Offset(0, 38 * scale), 8 * scale, handPaint);
    }
    canvas.restore();
  }

  void _drawFace(Canvas canvas, double centerX, double scale) {
    // Eyes
    final eyeWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final eyePupilPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.fill;

    // Eye positions
    final leftEyeX = centerX - 10 * scale;
    final rightEyeX = centerX + 10 * scale;
    final eyeY = 40 * scale;

    // Draw eye whites
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(leftEyeX, eyeY),
        width: 12 * scale * blinkValue,
        height: 14 * scale * blinkValue,
      ),
      eyeWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rightEyeX, eyeY),
        width: 12 * scale * blinkValue,
        height: 14 * scale * blinkValue,
      ),
      eyeWhitePaint,
    );

    // Draw pupils (with slight movement based on emotion)
    double pupilOffsetX = 0;
    double pupilOffsetY = 0;
    if (emotion == CharacterEmotion.thinking) {
      pupilOffsetX = 2 * scale;
      pupilOffsetY = -2 * scale;
    } else if (emotion == CharacterEmotion.excited) {
      pupilOffsetY = -1 * scale;
    }

    if (blinkValue > 0.5) {
      canvas.drawCircle(
        Offset(leftEyeX + pupilOffsetX, eyeY + pupilOffsetY),
        4 * scale,
        eyePupilPaint,
      );
      canvas.drawCircle(
        Offset(rightEyeX + pupilOffsetX, eyeY + pupilOffsetY),
        4 * scale,
        eyePupilPaint,
      );

      // Eye shine
      final shinePaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(leftEyeX + pupilOffsetX + 1.5 * scale,
            eyeY + pupilOffsetY - 1.5 * scale),
        1.5 * scale,
        shinePaint,
      );
      canvas.drawCircle(
        Offset(rightEyeX + pupilOffsetX + 1.5 * scale,
            eyeY + pupilOffsetY - 1.5 * scale),
        1.5 * scale,
        shinePaint,
      );
    }

    // Eyebrows
    final eyebrowPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double leftBrowAngle = 0;
    double rightBrowAngle = 0;
    if (emotion == CharacterEmotion.excited ||
        emotion == CharacterEmotion.celebrating) {
      leftBrowAngle = -0.15;
      rightBrowAngle = 0.15;
    } else if (emotion == CharacterEmotion.thinking) {
      leftBrowAngle = 0.1;
      rightBrowAngle = -0.2;
    }

    canvas.save();
    canvas.translate(leftEyeX, eyeY - 10 * scale);
    canvas.rotate(leftBrowAngle);
    canvas.drawLine(
      Offset(-6 * scale, 0),
      Offset(6 * scale, 0),
      eyebrowPaint,
    );
    canvas.restore();

    canvas.save();
    canvas.translate(rightEyeX, eyeY - 10 * scale);
    canvas.rotate(rightBrowAngle);
    canvas.drawLine(
      Offset(-6 * scale, 0),
      Offset(6 * scale, 0),
      eyebrowPaint,
    );
    canvas.restore();

    // Nose
    final nosePaint = Paint()
      ..color = const Color(0xFFC49464)
      ..style = PaintingStyle.fill;
    final nosePath = Path();
    nosePath.moveTo(centerX, 45 * scale);
    nosePath.quadraticBezierTo(
        centerX + 5 * scale, 52 * scale, centerX, 54 * scale);
    nosePath.quadraticBezierTo(
        centerX - 5 * scale, 52 * scale, centerX, 45 * scale);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth based on emotion
    _drawMouth(canvas, centerX, scale);

    // Cheeks (blush for happy emotions)
    if (emotion == CharacterEmotion.happy ||
        emotion == CharacterEmotion.celebrating ||
        emotion == CharacterEmotion.excited) {
      final blushPaint = Paint()
        ..color = const Color(0xFFE57373).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX - 18 * scale, 52 * scale),
          width: 10 * scale,
          height: 6 * scale,
        ),
        blushPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX + 18 * scale, 52 * scale),
          width: 10 * scale,
          height: 6 * scale,
        ),
        blushPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, double centerX, double scale) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 2.5 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mouthFillPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    final mouthY = 60 * scale;

    switch (emotion) {
      case CharacterEmotion.happy:
      case CharacterEmotion.waving:
        // Happy smile
        final smilePath = Path();
        smilePath.moveTo(centerX - 10 * scale, mouthY);
        smilePath.quadraticBezierTo(
            centerX, mouthY + 8 * scale, centerX + 10 * scale, mouthY);
        canvas.drawPath(smilePath, mouthPaint);
        break;

      case CharacterEmotion.excited:
      case CharacterEmotion.celebrating:
        // Big open smile
        final excitedPath = Path();
        excitedPath.moveTo(centerX - 12 * scale, mouthY - 2 * scale);
        excitedPath.quadraticBezierTo(centerX, mouthY + 12 * scale,
            centerX + 12 * scale, mouthY - 2 * scale);
        excitedPath.quadraticBezierTo(centerX, mouthY + 4 * scale,
            centerX - 12 * scale, mouthY - 2 * scale);
        canvas.drawPath(excitedPath, mouthFillPaint);
        canvas.drawPath(excitedPath, mouthPaint);
        break;

      case CharacterEmotion.thinking:
        // Thoughtful expression
        canvas.drawLine(
          Offset(centerX - 6 * scale, mouthY + 2 * scale),
          Offset(centerX + 6 * scale, mouthY),
          mouthPaint,
        );
        break;

      case CharacterEmotion.explaining:
        // Slightly open mouth
        final explainPath = Path();
        explainPath.addOval(Rect.fromCenter(
          center: Offset(centerX, mouthY + 2 * scale),
          width: 12 * scale,
          height: 8 * scale,
        ));
        canvas.drawPath(explainPath, mouthFillPaint);
        mouthPaint.style = PaintingStyle.stroke;
        canvas.drawPath(explainPath, mouthPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(_FarmerCharacterPainter oldDelegate) {
    return oldDelegate.emotion != emotion ||
        oldDelegate.gesture != gesture ||
        oldDelegate.waveAngle != waveAngle ||
        oldDelegate.blinkValue != blinkValue;
  }
}

/// Speech bubble widget for character dialogue
class CharacterSpeechBubble extends StatelessWidget {
  final String title;
  final String message;
  final double maxWidth;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;
  final int currentStep;
  final int totalSteps;
  final bool showNavigation;

  const CharacterSpeechBubble({
    super.key,
    required this.title,
    required this.message,
    this.maxWidth = 300,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.currentStep = 0,
    this.totalSteps = 1,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                if (showNavigation) ...[
                  const SizedBox(height: 16),
                  // Progress indicator
                  Row(
                    children: [
                      ...List.generate(
                        totalSteps,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: index == currentStep ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == currentStep
                                ? const Color(0xFF4CAF50)
                                : index < currentStep
                                    ? const Color(0xFF81C784)
                                    : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentStep > 0)
                        TextButton.icon(
                          onPressed: onPrevious,
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                        )
                      else
                        TextButton(
                          onPressed: onSkip,
                          child: Text(
                            'Skip',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          currentStep == totalSteps - 1 ? 'Finish' : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Speech bubble pointer
          Positioned(
            bottom: 0,
            left: maxWidth / 2 - 12,
            child: CustomPaint(
              size: const Size(24, 14),
              painter: _SpeechBubblePointerPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubblePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    // Shadow
    canvas.save();
    canvas.translate(0, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
