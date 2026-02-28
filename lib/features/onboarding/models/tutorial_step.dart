import 'package:flutter/material.dart';

/// Represents a single step in the onboarding tutorial
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? titleHindi;
  final String? descriptionHindi;
  final GlobalKey? targetKey;
  final Alignment characterPosition;
  final CharacterEmotion emotion;
  final CharacterGesture gesture;
  final IconData? featureIcon;
  final Color? highlightColor;
  final bool showSpotlight;
  final Duration? autoAdvanceDelay;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.titleHindi,
    this.descriptionHindi,
    this.targetKey,
    this.characterPosition = Alignment.topCenter,
    this.emotion = CharacterEmotion.happy,
    this.gesture = CharacterGesture.wave,
    this.featureIcon,
    this.highlightColor,
    this.showSpotlight = true,
    this.autoAdvanceDelay,
  });

  TutorialStep copyWith({
    String? id,
    String? title,
    String? description,
    String? titleHindi,
    String? descriptionHindi,
    GlobalKey? targetKey,
    Alignment? characterPosition,
    CharacterEmotion? emotion,
    CharacterGesture? gesture,
    IconData? featureIcon,
    Color? highlightColor,
    bool? showSpotlight,
    Duration? autoAdvanceDelay,
  }) {
    return TutorialStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      titleHindi: titleHindi ?? this.titleHindi,
      descriptionHindi: descriptionHindi ?? this.descriptionHindi,
      targetKey: targetKey ?? this.targetKey,
      characterPosition: characterPosition ?? this.characterPosition,
      emotion: emotion ?? this.emotion,
      gesture: gesture ?? this.gesture,
      featureIcon: featureIcon ?? this.featureIcon,
      highlightColor: highlightColor ?? this.highlightColor,
      showSpotlight: showSpotlight ?? this.showSpotlight,
      autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
    );
  }
}

/// Character emotions for different tutorial contexts
enum CharacterEmotion {
  happy,
  excited,
  thinking,
  explaining,
  celebrating,
  waving,
}

/// Character gestures/poses
enum CharacterGesture {
  wave,
  point,
  thumbsUp,
  think,
  celebrate,
  welcome,
  explain,
}

/// Predefined tutorial steps for the app
class TutorialSteps {
  // Keys for targeting UI elements
  static final GlobalKey profileHeaderKey = GlobalKey();
  static final GlobalKey mandiTrackerKey = GlobalKey();
  static final GlobalKey soilHealthKey = GlobalKey();
  static final GlobalKey cropAdvisorKey = GlobalKey();
  static final GlobalKey financeKey = GlobalKey();
  static final GlobalKey marketplaceKey = GlobalKey();
  static final GlobalKey growthKey = GlobalKey();
  static final GlobalKey aiAssistantKey = GlobalKey();
  static final GlobalKey subsidiesKey = GlobalKey();

  static List<TutorialStep> get homeScreenSteps => [
        TutorialStep(
          id: 'welcome',
          title: 'Welcome to HydroSmart! 🌱',
          description:
              'Hi! I\'m Krishi, your farming assistant. Let me show you around this smart farming app designed just for you!',
          titleHindi: 'HydroSmart में आपका स्वागत है! 🌱',
          descriptionHindi:
              'नमस्ते! मैं कृषि हूं, आपका खेती सहायक। मुझे इस स्मार्ट खेती ऐप के बारे में बताने दीजिए!',
          characterPosition: Alignment.center,
          emotion: CharacterEmotion.waving,
          gesture: CharacterGesture.wave,
          showSpotlight: false,
        ),
        TutorialStep(
          id: 'profile',
          title: 'Your Farmer Profile',
          description:
              'This is your profile section. You can see your name, Kisan ID, and switch between English and Hindi languages.',
          titleHindi: 'आपकी किसान प्रोफ़ाइल',
          descriptionHindi:
              'यह आपकी प्रोफ़ाइल है। यहां आप अपना नाम, किसान आईडी देख सकते हैं और भाषा बदल सकते हैं।',
          targetKey: profileHeaderKey,
          characterPosition: Alignment.bottomCenter,
          emotion: CharacterEmotion.explaining,
          gesture: CharacterGesture.point,
          featureIcon: Icons.person,
          highlightColor: Colors.blue,
        ),
        TutorialStep(
          id: 'mandi',
          title: 'Live Mandi Prices',
          description:
              'Track real-time market prices for your crops. This helps you decide the best time to sell and maximize profits!',
          titleHindi: 'लाइव मंडी भाव',
          descriptionHindi:
              'अपनी फसलों के रियल-टाइम बाजार भाव देखें। इससे आप बेहतर बिक्री का समय चुन सकते हैं!',
          targetKey: mandiTrackerKey,
          characterPosition: Alignment.bottomCenter,
          emotion: CharacterEmotion.excited,
          gesture: CharacterGesture.point,
          featureIcon: Icons.trending_up,
          highlightColor: Colors.green,
        ),
        TutorialStep(
          id: 'soil_health',
          title: 'Soil Health Monitor',
          description:
              'Keep track of your soil\'s pH level, nutrients (N-P-K), and moisture. Healthy soil means healthy crops!',
          titleHindi: 'मिट्टी स्वास्थ्य मॉनिटर',
          descriptionHindi:
              'अपनी मिट्टी का pH, पोषक तत्व (N-P-K), और नमी देखें। स्वस्थ मिट्टी = स्वस्थ फसल!',
          targetKey: soilHealthKey,
          characterPosition: Alignment.topCenter,
          emotion: CharacterEmotion.thinking,
          gesture: CharacterGesture.explain,
          featureIcon: Icons.grass,
          highlightColor: Colors.brown,
        ),
        TutorialStep(
          id: 'crop_advisor',
          title: 'AI Crop Advisor 🌾',
          description:
              'Get personalized crop recommendations based on your soil conditions, weather, and market trends. AI-powered smart farming!',
          titleHindi: 'AI फसल सलाहकार 🌾',
          descriptionHindi:
              'अपनी मिट्टी, मौसम और बाजार के अनुसार फसल सुझाव पाएं। AI-संचालित स्मार्ट खेती!',
          targetKey: cropAdvisorKey,
          characterPosition: Alignment.topRight,
          emotion: CharacterEmotion.excited,
          gesture: CharacterGesture.thumbsUp,
          featureIcon: Icons.eco,
          highlightColor: Colors.green,
        ),
        TutorialStep(
          id: 'finance',
          title: 'Finance Tracker 💰',
          description:
              'Manage your farming expenses and income. Track profits, set budgets, and plan your financial future!',
          titleHindi: 'वित्त ट्रैकर 💰',
          descriptionHindi:
              'अपने खेती के खर्च और आय को प्रबंधित करें। लाभ ट्रैक करें और बजट योजना बनाएं!',
          targetKey: financeKey,
          characterPosition: Alignment.topLeft,
          emotion: CharacterEmotion.explaining,
          gesture: CharacterGesture.explain,
          featureIcon: Icons.account_balance_wallet,
          highlightColor: Colors.orange,
        ),
        TutorialStep(
          id: 'marketplace',
          title: 'Marketplace 🛒',
          description:
              'Buy seeds, fertilizers, equipment, and more at the best prices. One-stop shop for all farming needs!',
          titleHindi: 'बाज़ार 🛒',
          descriptionHindi:
              'बीज, खाद, उपकरण और बहुत कुछ सर्वोत्तम कीमतों पर खरीदें। खेती की सभी ज़रूरतों की एक दुकान!',
          targetKey: marketplaceKey,
          characterPosition: Alignment.topRight,
          emotion: CharacterEmotion.happy,
          gesture: CharacterGesture.point,
          featureIcon: Icons.store,
          highlightColor: Colors.amber,
        ),
        TutorialStep(
          id: 'growth',
          title: 'Growth Tracker 📈',
          description:
              'Monitor your crop growth progress, set milestones, and get alerts for important farming activities.',
          titleHindi: 'विकास ट्रैकर 📈',
          descriptionHindi:
              'अपनी फसल की वृद्धि प्रगति देखें, माइलस्टोन सेट करें और महत्वपूर्ण गतिविधियों के लिए अलर्ट पाएं।',
          targetKey: growthKey,
          characterPosition: Alignment.topLeft,
          emotion: CharacterEmotion.celebrating,
          gesture: CharacterGesture.celebrate,
          featureIcon: Icons.trending_up,
          highlightColor: Colors.lightGreen,
        ),
        TutorialStep(
          id: 'ai_assistant',
          title: 'AI Assistant 🤖',
          description:
              'Have questions? Ask our AI assistant! Get expert advice on crops, diseases, weather, and farming techniques.',
          titleHindi: 'AI सहायक 🤖',
          descriptionHindi:
              'कोई सवाल? AI सहायक से पूछें! फसलों, बीमारियों, मौसम और खेती तकनीकों पर विशेषज्ञ सलाह पाएं।',
          targetKey: aiAssistantKey,
          characterPosition: Alignment.topRight,
          emotion: CharacterEmotion.thinking,
          gesture: CharacterGesture.think,
          featureIcon: Icons.smart_toy,
          highlightColor: Colors.brown,
        ),
        TutorialStep(
          id: 'subsidies',
          title: 'Government Subsidies 🏛️',
          description:
              'Access information about government schemes, subsidies, and benefits available for farmers. Never miss an opportunity!',
          titleHindi: 'सरकारी सब्सिडी 🏛️',
          descriptionHindi:
              'किसानों के लिए उपलब्ध सरकारी योजनाओं, सब्सिडी और लाभों की जानकारी प्राप्त करें!',
          targetKey: subsidiesKey,
          characterPosition: Alignment.topLeft,
          emotion: CharacterEmotion.explaining,
          gesture: CharacterGesture.explain,
          featureIcon: Icons.account_balance,
          highlightColor: Colors.indigo,
        ),
        TutorialStep(
          id: 'complete',
          title: 'You\'re All Set! 🎉',
          description:
              'Congratulations! You now know all the features. Start exploring and make your farming smarter! I\'m always here to help.',
          titleHindi: 'आप तैयार हैं! 🎉',
          descriptionHindi:
              'बधाई हो! अब आप सभी सुविधाओं को जानते हैं। अपनी खेती को स्मार्ट बनाएं! मैं हमेशा मदद के लिए यहां हूं।',
          characterPosition: Alignment.center,
          emotion: CharacterEmotion.celebrating,
          gesture: CharacterGesture.celebrate,
          showSpotlight: false,
        ),
      ];
}
