import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/features/sensors/sensor_provider.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';
import 'package:hydro_smart/features/farm/farm_controller.dart';
import 'package:hydro_smart/features/subsidy/subsidy_screen.dart';
import 'package:hydro_smart/features/crop_recommendation/presentation/pages/crop_recommendation_page.dart';
import 'package:hydro_smart/features/finance/finance_screen.dart';
import 'package:hydro_smart/features/marketplace/marketplace_screen.dart';
import 'package:hydro_smart/features/growth/growth_screen.dart';
import 'package:hydro_smart/features/ai_chat/chat_screen.dart';
import 'package:hydro_smart/core/theme/krishi_theme.dart';
import 'package:hydro_smart/core/theme/krishi_components.dart';
import 'package:hydro_smart/core/theme/warli_painter.dart';
import 'package:hydro_smart/features/onboarding/onboarding.dart';
import 'package:hydro_smart/features/market_prices/market_price_provider.dart';
import 'package:hydro_smart/features/market_prices/market_price_service.dart'
    as mkt;
import 'package:hydro_smart/features/profile/profile_settings_page.dart';
import 'package:hydro_smart/features/auth/login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _currentLanguage = 'EN';
  bool _onboardingChecked = false;

  // Scaffold key for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Global keys for tutorial targeting
  final GlobalKey _profileHeaderKey = GlobalKey();
  final GlobalKey _mandiTrackerKey = GlobalKey();
  final GlobalKey _soilHealthKey = GlobalKey();
  final GlobalKey _cropAdvisorKey = GlobalKey();
  final GlobalKey _financeKey = GlobalKey();
  final GlobalKey _marketplaceKey = GlobalKey();
  final GlobalKey _growthKey = GlobalKey();
  final GlobalKey _aiAssistantKey = GlobalKey();
  final GlobalKey _subsidiesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeFarmController();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  void _checkAndStartOnboarding() {
    if (_onboardingChecked) return;
    _onboardingChecked = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingState = ref.read(onboardingProvider);
      if (!onboardingState.hasCompletedOnboarding) {
        // Create tutorial steps with the actual GlobalKeys
        final steps = _createTutorialSteps();
        ref
            .read(onboardingProvider.notifier)
            .startOnboarding(customSteps: steps);
      }
    });
  }

  List<TutorialStep> _createTutorialSteps() {
    return [
      const TutorialStep(
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
        targetKey: _profileHeaderKey,
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
        targetKey: _mandiTrackerKey,
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
        targetKey: _soilHealthKey,
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
        targetKey: _cropAdvisorKey,
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
        targetKey: _financeKey,
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
        targetKey: _marketplaceKey,
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
        targetKey: _growthKey,
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
        targetKey: _aiAssistantKey,
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
        targetKey: _subsidiesKey,
        characterPosition: Alignment.topLeft,
        emotion: CharacterEmotion.explaining,
        gesture: CharacterGesture.explain,
        featureIcon: Icons.account_balance,
        highlightColor: Colors.indigo,
      ),
      const TutorialStep(
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeFarmController() {
    final authState = ref.read(authStateProvider);

    authState.whenData((user) {
      if (user != null) {
        Future.microtask(() {
          ref.read(farmControllerProvider(user.uid).notifier).loadFarms();
        });
      }
    });
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage == 'EN' ? 'HI' : 'EN';
    });
    // Sync with onboarding language
    ref.read(onboardingProvider.notifier).setLanguage(_currentLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authState = ref.watch(authStateProvider);

    // Check onboarding status after first build
    _checkAndStartOnboarding();

    return OnboardingWrapper(
      child: authState.when(
        data: (user) {
          if (user == null) {
            return _buildDemoModeContent(context, isMobile);
          }
          return _buildDashboard(context, user.uid, isMobile);
        },
        loading: () => const Scaffold(
          backgroundColor: KrishiTheme.parchment,
          body: Center(
            child: CircularProgressIndicator(color: KrishiTheme.primaryGreen),
          ),
        ),
        error: (error, _) => Scaffold(
          backgroundColor: KrishiTheme.parchment,
          body: Center(child: Text("Auth Error: $error")),
        ),
      ),
    );
  }

  // ─── Navigation Drawer ───────────────────────────────────────
  Widget _buildAppDrawer() {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: KrishiTheme.primaryGradient,
              ),
              child: profileAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => _buildDrawerHeaderBasic(user),
                data: (profile) {
                  if (profile == null) return _buildDrawerHeaderBasic(user);
                  return _buildDrawerHeaderProfile(profile);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Menu items
            _drawerItem(Icons.person_outline_rounded, 'Profile Settings',
                'Manage your account', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingsPage()),
              );
            }),
            _drawerItem(Icons.agriculture_rounded, 'Crop Advisor',
                'AI-powered recommendations', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CropRecommendationPage()),
              );
            }),
            _drawerItem(Icons.account_balance_wallet_outlined, 'Finance',
                'Track expenses & income', () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FinanceScreen()));
            }),
            _drawerItem(
                Icons.store_outlined, 'Marketplace', 'Buy & sell produce', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
              );
            }),
            _drawerItem(
                Icons.local_offer_outlined, 'Subsidies', 'Government schemes',
                () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SubsidyScreen()));
            }),
            _drawerItem(
                Icons.smart_toy_outlined, 'AI Chat', 'Ask farming questions',
                () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AIChatScreen()));
            }),

            const Spacer(),
            const Divider(indent: 24, endIndent: 24),

            // Language toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded,
                      size: 20, color: KrishiTheme.monsoonSky),
                  const SizedBox(width: 12),
                  Text('Language',
                      style: KrishiTheme.bodyMedium
                          .copyWith(color: KrishiTheme.deepSoil)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _toggleLanguage();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KrishiTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentLanguage == 'EN' ? '🇬🇧 EN' : '🇮🇳 HI',
                        style: KrishiTheme.labelStyle.copyWith(
                          color: KrishiTheme.primaryGreen,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sign Out
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label:
                      Text(_currentLanguage == 'EN' ? 'Sign Out' : 'साइन आउट'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KrishiTheme.alertRed,
                    side: BorderSide(
                        color: KrishiTheme.alertRed.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeaderBasic(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
          ),
          child: const Center(
            child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'Welcome',
          style: KrishiTheme.headlineSmall
              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        if (user?.email != null)
          Text(
            user!.email!,
            style: KrishiTheme.bodySmall.copyWith(color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildDrawerHeaderProfile(UserProfile profile) {
    final initials = profile.displayName
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: KrishiTheme.goldenWheat, width: 2),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.displayName,
          style: KrishiTheme.headlineSmall
              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        if (profile.accountType == 'company' && profile.companyName != null)
          Text(profile.companyName!,
              style: KrishiTheme.bodySmall.copyWith(color: Colors.white70)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              profile.accountType == 'farmer'
                  ? Icons.agriculture_rounded
                  : Icons.business_rounded,
              color: KrishiTheme.goldenWheat,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              profile.accountType == 'farmer' ? 'Farmer' : 'Company',
              style: KrishiTheme.bodySmall
                  .copyWith(color: KrishiTheme.goldenWheat),
            ),
            const SizedBox(width: 12),
            Icon(Icons.location_on_outlined, color: Colors.white60, size: 14),
            const SizedBox(width: 2),
            Text(
              profile.state,
              style: KrishiTheme.bodySmall.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }

  Widget _drawerItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: KrishiTheme.primaryGreen.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: KrishiTheme.primaryGreen, size: 22),
      ),
      title: Text(title,
          style: KrishiTheme.bodyMedium.copyWith(
              color: KrishiTheme.deepSoil, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: KrishiTheme.bodySmall
              .copyWith(color: KrishiTheme.monsoonSky, fontSize: 11)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
    );
  }

  Widget _buildDemoModeContent(BuildContext context, bool isMobile) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildAppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: KrishiTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Warli art background
              Positioned.fill(
                child: CustomPaint(
                  painter: WarliPainter(
                    pattern: WarliPattern.village,
                    opacity: 0.04,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                children: [
                  // Profile header
                  Container(
                    key: _profileHeaderKey,
                    child: FarmerProfileHeader(
                      name: ref
                              .watch(userProfileProvider)
                              .valueOrNull
                              ?.displayName ??
                          (_currentLanguage == 'EN'
                              ? 'Welcome, Farmer'
                              : 'स्वागत है, किसान'),
                      kisanId: null,
                      currentLanguage: _currentLanguage,
                      onLanguageToggle: _toggleLanguage,
                      onNotificationTap: () {},
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                  ),
                  // Live Mandi Tracker - Real-time domestic & international prices
                  Padding(
                    key: _mandiTrackerKey,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildLiveMandiTracker(),
                  ),
                  const SizedBox(height: 16),
                  // Main content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: KrishiTheme.parchment,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Featured card - Soil Health
                                Container(
                                  key: _soilHealthKey,
                                  child: const SoilHealthCard(
                                    ph: 6.8,
                                    nitrogen: 72,
                                    phosphorus: 58,
                                    potassium: 85,
                                    moisture: 48,
                                    lastUpdated: 'Today, 10:30 AM',
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _currentLanguage == 'EN'
                                      ? 'Explore Features'
                                      : 'सुविधाओं का अन्वेषण करें',
                                  style: KrishiTheme.headlineSmall.copyWith(
                                    color: KrishiTheme.deepSoil,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _currentLanguage == 'EN'
                                      ? 'Smart farming at your fingertips'
                                      : 'आपकी उंगलियों पर स्मार्ट खेती',
                                  style: KrishiTheme.bodyMedium.copyWith(
                                    color: KrishiTheme.monsoonSky,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildFeatureGrid(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const TutorialHelpButton(),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    // Feature items with their corresponding GlobalKeys
    final featureKeys = [
      _cropAdvisorKey,
      _financeKey,
      _marketplaceKey,
      _growthKey,
      _aiAssistantKey,
      _subsidiesKey,
    ];

    final features = [
      _FeatureItem(
        icon: Icons.eco_rounded,
        title: _currentLanguage == 'EN' ? 'Crop Advisor' : 'फसल सलाहकार',
        subtitle:
            _currentLanguage == 'EN' ? 'AI recommendations' : 'AI अनुशंसाएं',
        color: KrishiTheme.primaryGreen,
        pattern: WarliPattern.crops,
        emoji: '🌱',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CropRecommendationPage())),
      ),
      _FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        title: _currentLanguage == 'EN' ? 'Finance' : 'वित्त',
        subtitle:
            _currentLanguage == 'EN' ? 'Track expenses' : 'खर्च ट्रैक करें',
        color: KrishiTheme.terracotta,
        pattern: WarliPattern.village,
        emoji: '💰',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const FinanceScreen())),
      ),
      _FeatureItem(
        icon: Icons.store_rounded,
        title: _currentLanguage == 'EN' ? 'Marketplace' : 'बाज़ार',
        subtitle: _currentLanguage == 'EN' ? 'Buy equipment' : 'उपकरण खरीदें',
        color: KrishiTheme.goldenWheat,
        pattern: WarliPattern.farmer,
        emoji: '🛒',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
      ),
      _FeatureItem(
        icon: Icons.trending_up_rounded,
        title: _currentLanguage == 'EN' ? 'Growth' : 'विकास',
        subtitle:
            _currentLanguage == 'EN' ? 'Monitor progress' : 'प्रगति देखें',
        color: KrishiTheme.freshLime,
        pattern: WarliPattern.sun,
        emoji: '📈',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GrowthTrackerScreen())),
      ),
      _FeatureItem(
        icon: Icons.smart_toy_rounded,
        title: _currentLanguage == 'EN' ? 'AI Assistant' : 'AI सहायक',
        subtitle:
            _currentLanguage == 'EN' ? 'Get expert help' : 'विशेषज्ञ सहायता',
        color: KrishiTheme.earthBrown,
        pattern: WarliPattern.mandala,
        emoji: '🤖',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
      ),
      _FeatureItem(
        icon: Icons.account_balance_rounded,
        title: _currentLanguage == 'EN' ? 'Subsidies' : 'सब्सिडी',
        subtitle: _currentLanguage == 'EN' ? 'Gov schemes' : 'सरकारी योजनाएं',
        color: KrishiTheme.deepSoil,
        pattern: WarliPattern.village,
        emoji: '🏛️',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SubsidyScreen())),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];
        return Container(
          key: featureKeys[index],
          child: KrishiFeatureCard(
            heroTag: 'feature_${item.title}',
            icon: item.icon,
            title: item.title,
            subtitle: item.subtitle,
            accentColor: item.color,
            warliPattern: item.pattern,
            emoji: item.emoji,
            onTap: item.onTap,
          ),
        );
      },
    );
  }

  Widget _buildDashboard(BuildContext context, String userId, bool isMobile) {
    final farmState = ref.watch(farmControllerProvider(userId));

    if (farmState.isLoading && farmState.farms.isEmpty) {
      return const Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(
            child: CircularProgressIndicator(color: KrishiTheme.primaryGreen)),
      );
    }

    if (farmState.error != null && farmState.farms.isEmpty) {
      return Scaffold(
        backgroundColor: KrishiTheme.parchment,
        body: Center(child: Text("Error: ${farmState.error}")),
      );
    }

    if (farmState.farms.isEmpty) {
      return _buildDemoModeContent(context, isMobile);
    }

    final selectedFarm = farmState.selectedFarm ?? farmState.farms.first;
    final sensorDataAsync =
        ref.watch(sensorDataStreamProvider(selectedFarm.deviceId));

    return Scaffold(
      drawer: _buildAppDrawer(),
      body: Builder(
        builder: (scaffoldContext) => Container(
          decoration: BoxDecoration(
            gradient: KrishiTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Warli background
                Positioned.fill(
                  child: CustomPaint(
                    painter: WarliPainter(
                      pattern: WarliPattern.farmer,
                      opacity: 0.03,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  children: [
                    // Farmer Profile Header
                    FarmerProfileHeader(
                      name: ref
                              .watch(userProfileProvider)
                              .valueOrNull
                              ?.displayName ??
                          selectedFarm.name,
                      kisanId:
                          'KID${selectedFarm.deviceId.substring(0, 8).toUpperCase()}',
                      currentLanguage: _currentLanguage,
                      onLanguageToggle: _toggleLanguage,
                      onNotificationTap: () {},
                      onMenuTap: () =>
                          Scaffold.of(scaffoldContext).openDrawer(),
                    ),
                    // Mandi Tracker - Real-time domestic & international prices
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildLiveMandiTracker(),
                    ),
                    const SizedBox(height: 16),
                    // Main content
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: KrishiTheme.parchment,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: sensorDataAsync.when(
                              loading: () => const Center(
                                  child: CircularProgressIndicator(
                                      color: KrishiTheme.primaryGreen)),
                              error: (e, _) =>
                                  Center(child: Text("Sensor Error: $e")),
                              data: (sensorData) {
                                if (sensorData.isEmpty) {
                                  return Center(
                                    child: Text(
                                      _currentLanguage == 'EN'
                                          ? "No Sensor Data"
                                          : "कोई सेंसर डेटा नहीं",
                                      style: KrishiTheme.bodyLarge,
                                    ),
                                  );
                                }
                                return SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Soil Health Card
                                      SoilHealthCard(
                                        ph: (sensorData['ph'] ?? 6.5)
                                            .toDouble(),
                                        nitrogen: 72,
                                        phosphorus: 58,
                                        potassium: 85,
                                        moisture: (sensorData['humidity'] ?? 45)
                                            .toDouble(),
                                        lastUpdated: 'Live',
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        _currentLanguage == 'EN'
                                            ? 'Sensor Readings'
                                            : 'सेंसर रीडिंग',
                                        style:
                                            KrishiTheme.headlineSmall.copyWith(
                                          color: KrishiTheme.deepSoil,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildSensorGrid(sensorData),
                                      const SizedBox(height: 28),
                                      Text(
                                        _currentLanguage == 'EN'
                                            ? 'Quick Access'
                                            : 'त्वरित पहुँच',
                                        style: KrishiTheme.titleLarge.copyWith(
                                          color: KrishiTheme.deepSoil,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildQuickAccessRow(context),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid(Map<String, dynamic> sensorData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Temperature' : 'तापमान',
          value: sensorData['temperature'] ?? 0,
          unit: '°C',
          icon: Icons.thermostat_rounded,
          color: KrishiTheme.terracotta,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Humidity' : 'नमी',
          value: sensorData['humidity'] ?? 0,
          unit: '%',
          icon: Icons.water_drop_rounded,
          color: KrishiTheme.primaryGreen,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'pH Level' : 'पीएच स्तर',
          value: sensorData['ph'] ?? 0,
          unit: '',
          icon: Icons.science_rounded,
          color: KrishiTheme.freshLime,
        ),
        _SensorCard(
          title: _currentLanguage == 'EN' ? 'Water Level' : 'जल स्तर',
          value: sensorData['waterLevel'] ?? 0,
          unit: '%',
          icon: Icons.waves_rounded,
          color: KrishiTheme.goldenWheat,
        ),
      ],
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickAccessPanel(
            icon: Icons.eco_rounded,
            label: _currentLanguage == 'EN' ? 'Crops' : 'फसलें',
            color: KrishiTheme.primaryGreen,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CropRecommendationPage())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.account_balance_wallet_rounded,
            label: _currentLanguage == 'EN' ? 'Finance' : 'वित्त',
            color: KrishiTheme.terracotta,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FinanceScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.store_rounded,
            label: _currentLanguage == 'EN' ? 'Shop' : 'दुकान',
            color: KrishiTheme.goldenWheat,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MarketplaceScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.trending_up_rounded,
            label: _currentLanguage == 'EN' ? 'Growth' : 'विकास',
            color: KrishiTheme.freshLime,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const GrowthTrackerScreen())),
          ),
          const SizedBox(width: 14),
          _QuickAccessPanel(
            icon: Icons.smart_toy_rounded,
            label: _currentLanguage == 'EN' ? 'AI Help' : 'AI सहायता',
            color: KrishiTheme.earthBrown,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AIChatScreen())),
          ),
        ],
      ),
    );
  }

  /// Builds the live MandiTracker from Riverpod market price state
  Widget _buildLiveMandiTracker() {
    final priceState = ref.watch(marketPriceProvider);

    // Convert MarketPrice → MandiPrice for the widget
    final domesticMandi = priceState.domesticPrices
        .map((p) => MandiPrice(
              crop: p.commodity,
              price: p.price,
              change: p.change,
              currency: p.currency,
              source: p.source,
              market: 'Domestic',
            ))
        .toList();

    final intlMandi = priceState.internationalPrices
        .map((p) => MandiPrice(
              crop: p.commodity,
              price: p.priceUsd ?? p.price,
              change: p.change,
              currency: '\$',
              source: p.source,
              market: 'International',
            ))
        .toList();

    return MandiTracker(
      domesticPrices: domesticMandi,
      internationalPrices: intlMandi,
      isLoading: priceState.isLoading,
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final WarliPattern pattern;
  final String emoji;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.pattern,
    required this.emoji,
    required this.onTap,
  });
}

class _SensorCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;
  final Color color;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KrishiTheme.radiusMedium),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              const Icon(Icons.north_east_rounded,
                  color: KrishiTheme.freshLime, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: KrishiTheme.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style:
                KrishiTheme.bodySmall.copyWith(color: KrishiTheme.monsoonSky),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessPanel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessPanel({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          KrishiTheme.lightHaptic();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 80,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: KrishiTheme.labelStyle.copyWith(
                  color: KrishiTheme.deepSoil,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
