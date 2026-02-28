import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/core/theme/krishi_theme.dart';
import 'package:hydro_smart/core/theme/warli_painter.dart';
import 'package:hydro_smart/features/dashboard/home_screen.dart';
import 'auth_controller.dart';

/// Indian states list
const List<String> _indianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Delhi',
  'Jammu and Kashmir',
  'Ladakh',
  'Puducherry',
];

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedLanguage = 'EN';
  String _accountType = 'farmer'; // 'farmer' or 'company'
  String _selectedState = 'Maharashtra';
  int _currentStep = 0; // 0 = basic info, 1 = preferences

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    KrishiTheme.mediumHaptic();

    try {
      await ref.read(authControllerProvider.notifier).signUpWithProfile(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
            accountType: _accountType,
            companyName: _accountType == 'company'
                ? _companyNameController.text.trim()
                : null,
            selectedState: _selectedState,
            language: _selectedLanguage,
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
          );

      if (mounted) {
        KrishiTheme.mediumHaptic();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: KrishiTheme.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C)
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: WarliPainter(
                color: Colors.white.withOpacity(0.04),
                pattern: WarliPattern.village,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildStepIndicator(),
                            const SizedBox(height: 24),
                            _buildFormCard(authState),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            _selectedLanguage == 'EN' ? 'Create Account' : 'खाता बनाएं',
            style: KrishiTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Language toggle
          GestureDetector(
            onTap: () {
              KrishiTheme.lightHaptic();
              setState(() {
                _selectedLanguage = _selectedLanguage == 'EN' ? 'HI' : 'EN';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Text(
                _selectedLanguage == 'EN' ? '🇮🇳 HI' : '🇬🇧 EN',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(
            0, _selectedLanguage == 'EN' ? 'Basic Info' : 'बुनियादी जानकारी'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 1
                ? KrishiTheme.goldenWheat
                : Colors.white.withOpacity(0.3),
          ),
        ),
        _buildStepDot(
            1, _selectedLanguage == 'EN' ? 'Preferences' : 'प्राथमिकताएं'),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? KrishiTheme.goldenWheat
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? KrishiTheme.goldenWheat
                  : Colors.white.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(
                    step < _currentStep ? Icons.check : Icons.circle,
                    size: step < _currentStep ? 16 : 8,
                    color: KrishiTheme.deepSoil,
                  )
                : Text(
                    '${step + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(AsyncValue<void> authState) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _currentStep == 0 ? _buildStep1() : _buildStep2(authState),
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Basic Info ─────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Type Toggle
        Text(
          _selectedLanguage == 'EN' ? 'I am a' : 'मैं हूं',
          style: KrishiTheme.labelStyle.copyWith(
            color: KrishiTheme.deepSoil,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildAccountTypeToggle(),
        const SizedBox(height: 20),

        // Full Name
        _buildField(
          controller: _nameController,
          label: _selectedLanguage == 'EN'
              ? (_accountType == 'farmer' ? 'Full Name' : 'Contact Person Name')
              : (_accountType == 'farmer' ? 'पूरा नाम' : 'संपर्क व्यक्ति'),
          icon: Icons.person_outline_rounded,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return _selectedLanguage == 'EN'
                  ? 'Name is required'
                  : 'नाम आवश्यक है';
            }
            return null;
          },
        ),

        // Company Name (only for company)
        if (_accountType == 'company') ...[
          const SizedBox(height: 16),
          _buildField(
            controller: _companyNameController,
            label: _selectedLanguage == 'EN' ? 'Company Name' : 'कंपनी का नाम',
            icon: Icons.business_outlined,
            validator: (v) {
              if (_accountType == 'company' &&
                  (v == null || v.trim().isEmpty)) {
                return _selectedLanguage == 'EN'
                    ? 'Company name is required'
                    : 'कंपनी का नाम आवश्यक है';
              }
              return null;
            },
          ),
        ],

        const SizedBox(height: 16),

        // Email
        _buildField(
          controller: _emailController,
          label: _selectedLanguage == 'EN' ? 'Email' : 'ईमेल',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return _selectedLanguage == 'EN'
                  ? 'Email is required'
                  : 'ईमेल आवश्यक है';
            }
            if (!v.contains('@') || !v.contains('.')) {
              return _selectedLanguage == 'EN'
                  ? 'Enter a valid email'
                  : 'एक वैध ईमेल दर्ज करें';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone (optional)
        _buildField(
          controller: _phoneController,
          label: _selectedLanguage == 'EN'
              ? 'Phone (Optional)'
              : 'फ़ोन (वैकल्पिक)',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Password
        _buildField(
          controller: _passwordController,
          label: _selectedLanguage == 'EN' ? 'Password' : 'पासवर्ड',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscurePassword,
          onToggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          validator: (v) {
            if (v == null || v.length < 6) {
              return _selectedLanguage == 'EN'
                  ? 'Password must be at least 6 characters'
                  : 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password
        _buildField(
          controller: _confirmPasswordController,
          label: _selectedLanguage == 'EN'
              ? 'Confirm Password'
              : 'पासवर्ड की पुष्टि करें',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscureConfirm,
          onToggleObscure: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          validator: (v) {
            if (v != _passwordController.text) {
              return _selectedLanguage == 'EN'
                  ? 'Passwords do not match'
                  : 'पासवर्ड मेल नहीं खाते';
            }
            return null;
          },
        ),
        const SizedBox(height: 28),

        // Next button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _emailController.text.trim().isEmpty ||
                  _passwordController.text.trim().length < 6 ||
                  _passwordController.text != _confirmPasswordController.text) {
                _formKey.currentState!.validate();
                return;
              }
              if (_accountType == 'company' &&
                  _companyNameController.text.trim().isEmpty) {
                _formKey.currentState!.validate();
                return;
              }
              KrishiTheme.lightHaptic();
              setState(() => _currentStep = 1);
            },
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
                  _selectedLanguage == 'EN' ? 'Next' : 'अगला',
                  style: KrishiTheme.labelStyle
                      .copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Back to login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedLanguage == 'EN'
                  ? 'Already have an account? '
                  : 'पहले से खाता है? ',
              style:
                  KrishiTheme.bodySmall.copyWith(color: KrishiTheme.monsoonSky),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                _selectedLanguage == 'EN' ? 'Sign In' : 'साइन इन',
                style: KrishiTheme.bodySmall.copyWith(
                  color: KrishiTheme.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Step 2: Preferences ────────────────────────────────────

  Widget _buildStep2(AsyncValue<void> authState) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            GestureDetector(
              onTap: () {
                KrishiTheme.lightHaptic();
                setState(() => _currentStep = 0);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KrishiTheme.parchment,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    size: 18, color: KrishiTheme.deepSoil),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _selectedLanguage == 'EN'
                  ? 'Set Your Preferences'
                  : 'अपनी प्राथमिकताएं सेट करें',
              style: KrishiTheme.labelStyle.copyWith(
                color: KrishiTheme.deepSoil,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // State Selection
        Text(
          _selectedLanguage == 'EN' ? 'Your State' : 'आपका राज्य',
          style: KrishiTheme.bodyMedium.copyWith(
            color: KrishiTheme.deepSoil,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: KrishiTheme.parchment,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: KrishiTheme.primaryGreen.withOpacity(0.15)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedState,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: KrishiTheme.primaryGreen),
              items: _indianStates
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, style: KrishiTheme.bodyMedium),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedState = v);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Language Selection
        Text(
          _selectedLanguage == 'EN' ? 'Preferred Language' : 'पसंदीदा भाषा',
          style: KrishiTheme.bodyMedium.copyWith(
            color: KrishiTheme.deepSoil,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildLanguageOption('EN', '🇬🇧', 'English'),
            const SizedBox(width: 12),
            _buildLanguageOption('HI', '🇮🇳', 'हिंदी'),
          ],
        ),
        const SizedBox(height: 32),

        // Summary card
        _buildSummaryCard(),
        const SizedBox(height: 28),

        // Register button
        SizedBox(
          width: double.infinity,
          child: authState.isLoading
              ? Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: KrishiTheme.primaryGreen,
                    strokeWidth: 2.5,
                  ),
                )
              : ElevatedButton(
                  onPressed: _register,
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
                      const Icon(Icons.person_add_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _selectedLanguage == 'EN'
                            ? 'Create Account'
                            : 'खाता बनाएं',
                        style: KrishiTheme.labelStyle
                            .copyWith(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
        ),

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
                const Icon(Icons.error_outline,
                    color: KrishiTheme.alertRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authState.error.toString(),
                    style: const TextStyle(
                        color: KrishiTheme.alertRed, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrishiTheme.primaryGreen.withOpacity(0.08),
            KrishiTheme.goldenWheat.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KrishiTheme.primaryGreen.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _accountType == 'farmer'
                    ? Icons.agriculture_rounded
                    : Icons.business_rounded,
                color: KrishiTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _selectedLanguage == 'EN' ? 'Account Summary' : 'खाता सारांश',
                style: KrishiTheme.labelStyle.copyWith(
                  color: KrishiTheme.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow(Icons.person_outline,
              _selectedLanguage == 'EN' ? 'Name' : 'नाम', _nameController.text),
          if (_accountType == 'company')
            _summaryRow(
                Icons.business_outlined,
                _selectedLanguage == 'EN' ? 'Company' : 'कंपनी',
                _companyNameController.text),
          _summaryRow(
              Icons.email_outlined,
              _selectedLanguage == 'EN' ? 'Email' : 'ईमेल',
              _emailController.text),
          _summaryRow(Icons.location_on_outlined,
              _selectedLanguage == 'EN' ? 'State' : 'राज्य', _selectedState),
          _summaryRow(
              Icons.translate_outlined,
              _selectedLanguage == 'EN' ? 'Language' : 'भाषा',
              _selectedLanguage == 'EN' ? 'English' : 'हिंदी'),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: KrishiTheme.monsoonSky),
          const SizedBox(width: 8),
          Text('$label: ',
              style: KrishiTheme.bodySmall
                  .copyWith(color: KrishiTheme.monsoonSky)),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: KrishiTheme.bodySmall.copyWith(
                color: KrishiTheme.deepSoil,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Widgets ─────────────────────────────────────────

  Widget _buildAccountTypeToggle() {
    return Row(
      children: [
        Expanded(
            child: _buildTypeChip('farmer', '👨‍🌾',
                _selectedLanguage == 'EN' ? 'Farmer' : 'किसान')),
        const SizedBox(width: 12),
        Expanded(
            child: _buildTypeChip('company', '🏢',
                _selectedLanguage == 'EN' ? 'Company' : 'कंपनी')),
      ],
    );
  }

  Widget _buildTypeChip(String type, String emoji, String label) {
    final selected = _accountType == type;
    return GestureDetector(
      onTap: () {
        KrishiTheme.lightHaptic();
        setState(() => _accountType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? KrishiTheme.primaryGreen.withOpacity(0.1)
              : KrishiTheme.parchment,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? KrishiTheme.primaryGreen : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              label,
              style: KrishiTheme.labelStyle.copyWith(
                color:
                    selected ? KrishiTheme.primaryGreen : KrishiTheme.deepSoil,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle_rounded,
                  color: KrishiTheme.primaryGreen, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String flag, String label) {
    final selected = _selectedLanguage == code;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          KrishiTheme.lightHaptic();
          setState(() => _selectedLanguage = code);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? KrishiTheme.primaryGreen.withOpacity(0.1)
                : KrishiTheme.parchment,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? KrishiTheme.primaryGreen : Colors.grey.shade200,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: KrishiTheme.bodyMedium.copyWith(
                  color: selected
                      ? KrishiTheme.primaryGreen
                      : KrishiTheme.deepSoil,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle_rounded,
                    color: KrishiTheme.primaryGreen, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscure : false,
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
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: KrishiTheme.monsoonSky,
                ),
                onPressed: () {
                  KrishiTheme.lightHaptic();
                  onToggleObscure?.call();
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
          borderSide:
              const BorderSide(color: KrishiTheme.primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}
