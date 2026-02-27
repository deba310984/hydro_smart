import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/features/dashboard/home_screen.dart';
import 'package:hydro_smart/core/theme/krishi_theme.dart';
import 'package:hydro_smart/core/theme/warli_painter.dart';
import 'auth_controller.dart';

// Demo mode provider
final demoModeProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _obscurePassword = true;
  String _selectedLanguage = 'EN';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    KrishiTheme.mediumHaptic();

    await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  void _toggleLanguage() {
    KrishiTheme.selectionHaptic();
    setState(() {
      _selectedLanguage = _selectedLanguage == 'EN' ? 'HI' : 'EN';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: KrishiTheme.primaryGradient,
        ),
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
            // Decorative circles
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KrishiTheme.goldenWheat.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KrishiTheme.freshLime.withOpacity(0.06),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Language toggle
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _buildLanguageToggle(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Logo section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildLogoSection(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Login card
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildLoginCard(authState),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Features preview
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFeaturesPreview(),
                      ),
                      const SizedBox(height: 20),
                      // Footer
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFooter(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return GestureDetector(
      onTap: _toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              _selectedLanguage == 'EN' ? 'EN' : 'हिंदी',
              style: KrishiTheme.labelStyle.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Animated logo container
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  KrishiTheme.goldenWheat,
                  KrishiTheme.goldenWheat.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: KrishiTheme.goldenWheat.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: KrishiTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      size: 42,
                      color: KrishiTheme.primaryGreen,
                    ),
                    const SizedBox(height: 2),
                    const Text('🌾', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _selectedLanguage == 'EN' ? 'Digital Krishi' : 'डिजिटल कृषि',
          style: KrishiTheme.displayLarge.copyWith(
            color: KrishiTheme.goldenWheat,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 12),
            Text(
              _selectedLanguage == 'EN'
                  ? 'Smart Farming • Bright Future'
                  : 'स्मार्ट खेती • उज्जवल भविष्य',
              style: KrishiTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            const Text('🌿', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginCard(AsyncValue<void> authState) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: KrishiTheme.primaryGreen.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: KrishiTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: KrishiTheme.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedLanguage == 'EN'
                              ? 'Welcome Back'
                              : 'वापस स्वागत है',
                          style: KrishiTheme.titleLarge.copyWith(
                            color: KrishiTheme.deepSoil,
                          ),
                        ),
                        Text(
                          _selectedLanguage == 'EN'
                              ? 'Sign in to continue'
                              : 'जारी रखने के लिए साइन इन करें',
                          style: KrishiTheme.bodySmall.copyWith(
                            color: KrishiTheme.monsoonSky,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _emailController,
                  label: _selectedLanguage == 'EN' ? 'Email' : 'ईमेल',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _passwordController,
                  label: _selectedLanguage == 'EN' ? 'Password' : 'पासवर्ड',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 28),
                _buildSignInButton(authState),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selectedLanguage == 'EN' ? 'or' : 'या',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDemoButton(),
                if (authState.hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: KrishiTheme.alertRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: KrishiTheme.alertRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error.toString(),
                            style: TextStyle(
                                color: KrishiTheme.alertRed, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: KrishiTheme.bodyLarge.copyWith(color: KrishiTheme.deepSoil),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            KrishiTheme.bodyMedium.copyWith(color: KrishiTheme.monsoonSky),
        prefixIcon: Icon(icon, color: KrishiTheme.primaryGreen, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: KrishiTheme.monsoonSky,
                ),
                onPressed: () {
                  KrishiTheme.lightHaptic();
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
        filled: true,
        fillColor: KrishiTheme.parchment,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: KrishiTheme.primaryGreen.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: KrishiTheme.primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return _selectedLanguage == 'EN'
              ? 'This field is required'
              : 'यह फ़ील्ड आवश्यक है';
        }
        return null;
      },
    );
  }

  Widget _buildSignInButton(AsyncValue<void> authState) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: authState.isLoading
          ? Container(
              height: 56,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: KrishiTheme.primaryGreen,
                strokeWidth: 2.5,
              ),
            )
          : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: KrishiTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedLanguage == 'EN' ? 'Sign In' : 'साइन इन करें',
                    style: KrishiTheme.labelStyle
                        .copyWith(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildDemoButton() {
    return OutlinedButton(
      onPressed: () {
        KrishiTheme.mediumHaptic();
        ref.read(demoModeProvider.notifier).state = true;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(0.05, 0), end: Offset.zero)
                      .animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: KrishiTheme.primaryGreen,
        side: BorderSide(
            color: KrishiTheme.primaryGreen.withOpacity(0.3), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌾', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(
            _selectedLanguage == 'EN' ? 'Explore Demo' : 'डेमो देखें',
            style: KrishiTheme.labelStyle
                .copyWith(color: KrishiTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesPreview() {
    final features = [
      {'emoji': '🌱', 'label': _selectedLanguage == 'EN' ? 'Crops' : 'फसल'},
      {'emoji': '💰', 'label': _selectedLanguage == 'EN' ? 'Finance' : 'वित्त'},
      {'emoji': '🤖', 'label': _selectedLanguage == 'EN' ? 'AI' : 'AI'},
      {
        'emoji': '📊',
        'label': _selectedLanguage == 'EN' ? 'Analytics' : 'विश्लेषण'
      },
    ];

    return Column(
      children: [
        Text(
          _selectedLanguage == 'EN' ? 'Features' : 'सुविधाएं',
          style: KrishiTheme.labelStyle.copyWith(
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: features
              .map((f) => _buildFeaturePreviewItem(f['emoji']!, f['label']!))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturePreviewItem(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child:
              Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: KrishiTheme.bodySmall
              .copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🌿', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Text(
          _selectedLanguage == 'EN'
              ? 'Made with ❤️ for Indian Farmers'
              : 'भारतीय किसानों के लिए ❤️ से बनाया',
          style: KrishiTheme.bodySmall
              .copyWith(color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(width: 8),
        const Text('🌿', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
