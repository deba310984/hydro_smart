import 'package:flutter/material.dart';
import '../models/tutorial_step.dart';
import 'animated_character.dart';

/// Overlay widget that displays the tutorial with spotlight highlighting
class TutorialOverlay extends StatefulWidget {
  final TutorialStep step;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final String currentLanguage;

  const TutorialOverlay({
    super.key,
    required this.step,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    this.currentLanguage = 'EN',
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
    _updateTargetRect();
  }

  @override
  void didUpdateWidget(TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _animationController.reset();
      _animationController.forward();
      _updateTargetRect();
    }
  }

  void _updateTargetRect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = widget.step.targetKey?.currentContext;
      if (targetContext != null) {
        // First, scroll the target into view so the user can see it
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment:
              0.1, // position target near top so character+bubble fit below
        ).then((_) {
          // After scrolling completes, measure the target's on-screen position
          _measureAndSetTargetRect();
        });
      } else {
        setState(() {
          _targetRect = null;
        });
      }
    });
  }

  void _measureAndSetTargetRect() {
    if (!mounted) return;
    final RenderBox? box =
        widget.step.targetKey?.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final position = box.localToGlobal(Offset.zero);
      setState(() {
        _targetRect = Rect.fromLTWH(
          position.dx,
          position.dy,
          box.size.width,
          box.size.height,
        );
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final title =
        widget.currentLanguage == 'HI' && widget.step.titleHindi != null
            ? widget.step.titleHindi!
            : widget.step.title;
    final description =
        widget.currentLanguage == 'HI' && widget.step.descriptionHindi != null
            ? widget.step.descriptionHindi!
            : widget.step.description;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Dimmed background with spotlight
            if (widget.step.showSpotlight && _targetRect != null)
              _SpotlightOverlay(
                targetRect: _targetRect!,
                opacity: _fadeAnimation.value * 0.85,
                highlightColor: widget.step.highlightColor,
              )
            else
              Container(
                color: Colors.black.withOpacity(_fadeAnimation.value * 0.7),
              ),

            // Character and speech bubble
            Positioned.fill(
              child: SafeArea(
                child: _buildCharacterWithBubble(
                  context,
                  screenSize,
                  title,
                  description,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCharacterWithBubble(
    BuildContext context,
    Size screenSize,
    String title,
    String description,
  ) {
    // Calculate position based on target and character position preference
    double characterTop = 0;
    double characterLeft = screenSize.width / 2 - 60;
    double bubbleTop = 170;
    double bubbleLeft = 20;
    double bubbleMaxWidth = screenSize.width - 40;

    if (_targetRect != null && widget.step.showSpotlight) {
      // Position character based on target location
      final targetCenter = _targetRect!.center;
      final isTargetInUpperHalf = targetCenter.dy < screenSize.height / 2;

      if (isTargetInUpperHalf) {
        // Place character below target
        characterTop = _targetRect!.bottom + 20;
        bubbleTop = characterTop + 165;
      } else {
        // Place character above target
        characterTop = _targetRect!.top - 200;
        if (characterTop < 50) characterTop = 50;
        bubbleTop = characterTop + 165;
      }

      // Horizontal positioning
      switch (widget.step.characterPosition) {
        case Alignment.topLeft:
        case Alignment.centerLeft:
        case Alignment.bottomLeft:
          characterLeft = 30;
          bubbleLeft = 20;
          break;
        case Alignment.topRight:
        case Alignment.centerRight:
        case Alignment.bottomRight:
          characterLeft = screenSize.width - 150;
          bubbleLeft = screenSize.width - bubbleMaxWidth - 20;
          break;
        default:
          characterLeft = screenSize.width / 2 - 60;
          bubbleLeft = (screenSize.width - bubbleMaxWidth) / 2;
      }
    } else {
      // Center character for welcome/finish screens
      characterTop = screenSize.height * 0.2;
      characterLeft = screenSize.width / 2 - 60;
      bubbleTop = characterTop + 180;
      bubbleLeft = (screenSize.width - bubbleMaxWidth) / 2;
    }

    // Ensure the speech bubble (needs ~280px height) fits on screen
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final maxBubbleTop = screenSize.height - 300 - safeBottom;
    bubbleTop = bubbleTop.clamp(100, maxBubbleTop);
    // Keep the character above the bubble
    characterTop = characterTop.clamp(20, bubbleTop - 140);

    return Stack(
      children: [
        // Animated character
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          top: characterTop,
          left: characterLeft,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedTutorialCharacter(
              emotion: widget.step.emotion,
              gesture: widget.step.gesture,
              size: 120,
            ),
          ),
        ),

        // Speech bubble
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          top: bubbleTop,
          left: bubbleLeft,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: CharacterSpeechBubble(
                title: title,
                message: description,
                maxWidth: bubbleMaxWidth.clamp(200, 340),
                currentStep: widget.currentStepIndex,
                totalSteps: widget.totalSteps,
                onNext: widget.onNext,
                onPrevious: widget.onPrevious,
                onSkip: widget.onSkip,
              ),
            ),
          ),
        ),

        // Highlight arrow pointing to target
        if (_targetRect != null && widget.step.showSpotlight)
          _buildTargetArrow(),
      ],
    );
  }

  Widget _buildTargetArrow() {
    if (_targetRect == null) return const SizedBox();

    return Positioned(
      top: _targetRect!.center.dy - 30,
      left: _targetRect!.center.dx - 15,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 10),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: child,
            );
          },
          onEnd: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_downward,
                color: widget.step.highlightColor ?? Colors.amber,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for spotlight effect
class _SpotlightOverlay extends StatelessWidget {
  final Rect targetRect;
  final double opacity;
  final Color? highlightColor;

  const _SpotlightOverlay({
    required this.targetRect,
    required this.opacity,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _SpotlightPainter(
        targetRect: targetRect,
        opacity: opacity,
        highlightColor: highlightColor ?? Colors.amber,
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double opacity;
  final Color highlightColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.opacity,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Expand the target rect slightly for padding
    final expandedRect = targetRect.inflate(8);

    // Create the spotlight path
    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final spotlightPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(expandedRect, const Radius.circular(12)));

    // Combine paths to create the hole effect
    final combinedPath = Path.combine(
      PathOperation.difference,
      outerPath,
      spotlightPath,
    );

    // Draw the dimmed overlay with spotlight hole
    canvas.drawPath(
      combinedPath,
      Paint()..color = Colors.black.withOpacity(opacity),
    );

    // Draw highlight border around the target
    final borderPaint = Paint()
      ..color = highlightColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(expandedRect, const Radius.circular(12)),
      borderPaint,
    );

    // Draw glow effect
    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRRect(
      RRect.fromRectAndRadius(expandedRect, const Radius.circular(12)),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.opacity != opacity ||
        oldDelegate.highlightColor != highlightColor;
  }
}

/// Pulsing highlight animation widget
class PulsingHighlight extends StatefulWidget {
  final Widget child;
  final Color color;
  final bool isActive;

  const PulsingHighlight({
    super.key,
    required this.child,
    this.color = Colors.amber,
    this.isActive = true,
  });

  @override
  State<PulsingHighlight> createState() => _PulsingHighlightState();
}

class _PulsingHighlightState extends State<PulsingHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 + _animation.value * 0.3),
                blurRadius: 8 + _animation.value * 12,
                spreadRadius: _animation.value * 4,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
