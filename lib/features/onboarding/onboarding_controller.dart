import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/tutorial_step.dart';
import 'widgets/tutorial_overlay.dart';

/// State for the onboarding tutorial
class OnboardingState {
  final bool isActive;
  final int currentStepIndex;
  final List<TutorialStep> steps;
  final bool hasCompletedOnboarding;
  final String currentLanguage;

  const OnboardingState({
    this.isActive = false,
    this.currentStepIndex = 0,
    this.steps = const [],
    this.hasCompletedOnboarding = false,
    this.currentLanguage = 'EN',
  });

  TutorialStep? get currentStep =>
      steps.isNotEmpty && currentStepIndex < steps.length
          ? steps[currentStepIndex]
          : null;

  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex == steps.length - 1;

  OnboardingState copyWith({
    bool? isActive,
    int? currentStepIndex,
    List<TutorialStep>? steps,
    bool? hasCompletedOnboarding,
    String? currentLanguage,
  }) {
    return OnboardingState(
      isActive: isActive ?? this.isActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      steps: steps ?? this.steps,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}

/// Notifier for managing onboarding state
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  static const _onboardingCompletedKey = 'onboarding_completed';

  OnboardingNotifier() : super(const OnboardingState()) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingCompletedKey) ?? false;
    state = state.copyWith(hasCompletedOnboarding: completed);
  }

  /// Start the onboarding tutorial
  void startOnboarding({List<TutorialStep>? customSteps}) {
    final steps = customSteps ?? TutorialSteps.homeScreenSteps;
    state = state.copyWith(
      isActive: true,
      currentStepIndex: 0,
      steps: steps,
    );
  }

  /// Go to the next step
  void nextStep() {
    if (state.currentStepIndex < state.steps.length - 1) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
    } else {
      completeOnboarding();
    }
  }

  /// Go to the previous step
  void previousStep() {
    if (state.currentStepIndex > 0) {
      state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
    }
  }

  /// Go to a specific step
  void goToStep(int index) {
    if (index >= 0 && index < state.steps.length) {
      state = state.copyWith(currentStepIndex: index);
    }
  }

  /// Skip the onboarding tutorial
  void skipOnboarding() {
    completeOnboarding();
  }

  /// Complete the onboarding tutorial
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    state = state.copyWith(
      isActive: false,
      hasCompletedOnboarding: true,
    );
  }

  /// Reset onboarding (for testing or re-showing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, false);
    state = state.copyWith(
      isActive: false,
      currentStepIndex: 0,
      hasCompletedOnboarding: false,
    );
  }

  /// Update the current language
  void setLanguage(String language) {
    state = state.copyWith(currentLanguage: language);
  }

  /// Check if onboarding should be shown automatically
  bool get shouldShowOnboarding => !state.hasCompletedOnboarding;
}

/// Provider for onboarding state
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

/// Widget that wraps content with tutorial overlay
class OnboardingWrapper extends ConsumerWidget {
  final Widget child;

  const OnboardingWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    return Stack(
      children: [
        child,
        if (onboardingState.isActive && onboardingState.currentStep != null)
          TutorialOverlay(
            step: onboardingState.currentStep!,
            currentStepIndex: onboardingState.currentStepIndex,
            totalSteps: onboardingState.steps.length,
            currentLanguage: onboardingState.currentLanguage,
            onNext: onboardingNotifier.nextStep,
            onPrevious: onboardingNotifier.previousStep,
            onSkip: onboardingNotifier.skipOnboarding,
          ),
      ],
    );
  }
}

/// Floating button to restart the tutorial
class TutorialHelpButton extends ConsumerWidget {
  final Color? backgroundColor;
  final Color? iconColor;

  const TutorialHelpButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.small(
      heroTag: 'tutorial_help',
      backgroundColor: backgroundColor ?? Colors.green.shade600,
      onPressed: () {
        _showTutorialOptions(context, ref);
      },
      child: Icon(
        Icons.help_outline,
        color: iconColor ?? Colors.white,
      ),
    );
  }

  void _showTutorialOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Would you like to see the app tutorial again?',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(onboardingProvider.notifier).startOnboarding();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Tutorial'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Extension to easily show tutorial from any widget
extension OnboardingExtension on WidgetRef {
  void startTutorial({List<TutorialStep>? steps}) {
    read(onboardingProvider.notifier).startOnboarding(customSteps: steps);
  }

  void skipTutorial() {
    read(onboardingProvider.notifier).skipOnboarding();
  }

  bool get isTutorialActive => watch(onboardingProvider).isActive;
}
