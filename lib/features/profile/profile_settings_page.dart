import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydro_smart/core/theme/krishi_theme.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';
import 'package:hydro_smart/features/auth/login_screen.dart';

// ── Language database ───────────────────────────────────────────────────────

class _IndianLang {
  final String code;
  final String name;
  final String native;
  const _IndianLang(this.code, this.name, this.native);
}

/// 22 Scheduled + major regional languages
const List<_IndianLang> _allLangs = [
  _IndianLang('EN', 'English', 'English'),
  _IndianLang('HI', 'Hindi', 'हिन्दी'),
  _IndianLang('TE', 'Telugu', 'తెలుగు'),
  _IndianLang('BN', 'Bengali', 'বাংলা'),
  _IndianLang('MR', 'Marathi', 'मराठी'),
  _IndianLang('TA', 'Tamil', 'தமிழ்'),
  _IndianLang('GU', 'Gujarati', 'ગુજરાતી'),
  _IndianLang('KN', 'Kannada', 'ಕನ್ನಡ'),
  _IndianLang('ML', 'Malayalam', 'മലയാളം'),
  _IndianLang('PA', 'Punjabi', 'ਪੰਜਾਬੀ'),
  _IndianLang('OR', 'Odia', 'ଓଡ଼ିଆ'),
  _IndianLang('UR', 'Urdu', 'اردو'),
  _IndianLang('AS', 'Assamese', 'অসমীয়া'),
  _IndianLang('KS', 'Kashmiri', 'كٲشُر'),
  _IndianLang('NE', 'Nepali', 'नेपाली'),
  _IndianLang('KOK', 'Konkani', 'कोंकणी'),
  _IndianLang('MAI', 'Maithili', 'मैथिली'),
  _IndianLang('DOG', 'Dogri', 'डोगरी'),
  _IndianLang('BO', 'Bodo', 'बड़ो'),
  _IndianLang('SAT', 'Santali', 'ᱥᱟᱱᱛᱟᱲᱤ'),
  _IndianLang('MNI', 'Meitei', 'মৈতৈলোন্'),
  _IndianLang('SA', 'Sanskrit', 'संस्कृतम्'),
  _IndianLang('SD', 'Sindhi', 'سنڌي'),
  _IndianLang('KHA', 'Khasi', 'Khasi'),
  _IndianLang('GAR', 'Garo', 'Garo'),
  _IndianLang('MZO', 'Mizo', 'Mizo ṭawng'),
  _IndianLang('KOB', 'Kokborok', 'Kokborok'),
  _IndianLang('LAD', 'Ladakhi', 'ལ་དྭགས་སྐད'),
  _IndianLang('RAJ', 'Rajasthani', 'राजस्थानी'),
  _IndianLang('CHH', 'Chhattisgarhi', 'छत्तीसगढ़ी'),
];

/// State-wise official / widely-used language codes
const Map<String, List<String>> _stateLangs = {
  'Andhra Pradesh': ['TE', 'UR'],
  'Arunachal Pradesh': ['EN', 'BN', 'BO', 'HI'],
  'Assam': ['AS', 'BN', 'BO'],
  'Bihar': ['HI', 'MAI', 'UR'],
  'Chhattisgarh': ['HI', 'CHH'],
  'Goa': ['KOK', 'MR', 'EN'],
  'Gujarat': ['GU'],
  'Haryana': ['HI'],
  'Himachal Pradesh': ['HI', 'SA'],
  'Jharkhand': ['HI', 'SAT', 'BN', 'UR', 'OR'],
  'Karnataka': ['KN'],
  'Kerala': ['ML'],
  'Madhya Pradesh': ['HI'],
  'Maharashtra': ['MR'],
  'Manipur': ['MNI', 'EN'],
  'Meghalaya': ['KHA', 'GAR', 'EN'],
  'Mizoram': ['MZO', 'EN', 'HI'],
  'Nagaland': ['EN'],
  'Odisha': ['OR', 'HI'],
  'Punjab': ['PA'],
  'Rajasthan': ['HI', 'RAJ'],
  'Sikkim': ['NE', 'EN'],
  'Tamil Nadu': ['TA'],
  'Telangana': ['TE', 'UR'],
  'Tripura': ['BN', 'KOB', 'MNI'],
  'Uttar Pradesh': ['HI', 'UR'],
  'Uttarakhand': ['HI', 'SA'],
  'West Bengal': ['BN'],
  'Delhi': ['HI', 'PA', 'UR'],
  'Jammu and Kashmir': ['KS', 'DOG', 'UR', 'HI', 'PA', 'EN'],
  'Ladakh': ['LAD', 'HI', 'UR'],
  'Puducherry': ['TA', 'TE', 'ML'],
  'Chandigarh': ['HI', 'PA'],
  'Andaman and Nicobar Islands': ['BN', 'HI', 'TA', 'TE', 'ML'],
  'Lakshadweep': ['ML'],
  'Dadra and Nagar Haveli and Daman and Diu': ['GU', 'HI'],
};

_IndianLang? _findLang(String? code) {
  if (code == null) return null;
  try {
    return _allLangs.firstWhere((l) => l.code == code);
  } catch (_) {
    return null;
  }
}

String _langDisplayName(String? code) {
  final l = _findLang(code);
  return l == null ? 'Not set' : '${l.name} · ${l.native}';
}

// ── Indian states list ────────────────────────────────────────────────────────

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

class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() =>
      _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  String? _editState;
  String? _editLanguage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _companyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _startEditing(UserProfile profile) {
    setState(() {
      _isEditing = true;
      _nameController.text = profile.displayName;
      _phoneController.text = profile.phone ?? '';
      _companyController.text = profile.companyName ?? '';
      _editState = profile.state;
      _editLanguage = profile.language;
    });
  }

  Future<void> _saveProfile(UserProfile profile) async {
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            uid: profile.uid,
            displayName: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            companyName: _companyController.text.trim(),
            selectedState: _editState,
            language: _editLanguage,
          );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: KrishiTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: KrishiTheme.alertRed,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: KrishiTheme.alertRed),
            SizedBox(width: 8),
            Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KrishiTheme.alertRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: KrishiTheme.parchment,
      appBar: AppBar(
        backgroundColor: KrishiTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile Settings',
          style: KrishiTheme.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                final profile = profileAsync.valueOrNull;
                if (profile != null) _startEditing(profile);
              },
              icon: const Icon(Icons.edit_rounded, size: 22),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: KrishiTheme.primaryGreen)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            // No Firestore profile yet — show basic Firebase data
            return _buildFallbackProfile(user);
          }
          return _isEditing ? _buildEditMode(profile) : _buildViewMode(profile);
        },
      ),
    );
  }

  Widget _buildFallbackProfile(User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildAvatar(user?.displayName ?? 'User', null),
          const SizedBox(height: 16),
          Text(user?.displayName ?? 'User',
              style:
                  KrishiTheme.titleLarge.copyWith(color: KrishiTheme.deepSoil)),
          Text(user?.email ?? '',
              style: KrishiTheme.bodyMedium
                  .copyWith(color: KrishiTheme.monsoonSky)),
          const SizedBox(height: 32),
          _buildInfoCard('Account', [
            _infoRow(Icons.email_outlined, 'Email', user?.email ?? ''),
            _infoRow(Icons.calendar_today, 'Member Since',
                user?.metadata.creationTime?.toString().split(' ')[0] ?? ''),
          ]),
          const SizedBox(height: 24),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildViewMode(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: KrishiTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildAvatar(profile.displayName, profile.photoUrl),
                const SizedBox(height: 16),
                Text(
                  profile.displayName,
                  style: KrishiTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (profile.accountType == 'company' &&
                    profile.companyName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.companyName!,
                    style:
                        KrishiTheme.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.accountType == 'farmer'
                            ? Icons.agriculture_rounded
                            : Icons.business_rounded,
                        color: KrishiTheme.goldenWheat,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.accountType == 'farmer'
                            ? '👨‍🌾 Farmer'
                            : '🏢 Company',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Information
          _buildInfoCard('Contact Information', [
            _infoRow(Icons.email_outlined, 'Email', profile.email),
            if (profile.phone != null && profile.phone!.isNotEmpty)
              _infoRow(Icons.phone_outlined, 'Phone', profile.phone!),
          ]),
          const SizedBox(height: 16),

          // Preferences
          _buildInfoCard('Preferences', [
            _infoRow(Icons.location_on_outlined, 'State', profile.state),
            _infoRow(
              Icons.translate_rounded,
              'Language',
              _langDisplayName(profile.language),
            ),
          ]),
          const SizedBox(height: 16),

          // Account Info
          _buildInfoCard('Account', [
            _infoRow(
              Icons.calendar_today_outlined,
              'Member Since',
              '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
            ),
            _infoRow(
                Icons.fingerprint, 'UID', profile.uid.substring(0, 12) + '...'),
          ]),
          const SizedBox(height: 24),

          _buildSignOutButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEditMode(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KrishiTheme.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: KrishiTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note_rounded,
                    color: KrishiTheme.primaryGreen, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Edit Profile',
                  style: KrishiTheme.labelStyle.copyWith(
                    color: KrishiTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Name
          _editLabel('Display Name'),
          const SizedBox(height: 8),
          _editField(_nameController, Icons.person_outline_rounded),
          const SizedBox(height: 20),

          // Phone
          _editLabel('Phone'),
          const SizedBox(height: 8),
          _editField(_phoneController, Icons.phone_outlined,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 20),

          // Company (only show if company)
          if (profile.accountType == 'company') ...[
            _editLabel('Company Name'),
            const SizedBox(height: 8),
            _editField(_companyController, Icons.business_outlined),
            const SizedBox(height: 20),
          ],

          // State dropdown
          _editLabel('State'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: KrishiTheme.primaryGreen.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _editState,
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
                  if (v != null) setState(() => _editState = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Language picker
          _editLabel('Language'),
          const SizedBox(height: 8),
          _langPickerButton(),
          const SizedBox(height: 32),

          // Save / Cancel buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KrishiTheme.monsoonSky,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveProfile(profile),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KrishiTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Save Changes'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────

  Widget _buildAvatar(String name, String? photoUrl) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
      ),
      child: photoUrl != null
          ? ClipOval(
              child: Image.network(photoUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                return Center(
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                );
              }),
            )
          : Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: KrishiTheme.labelStyle.copyWith(
              color: KrishiTheme.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Divider(height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KrishiTheme.monsoonSky),
          const SizedBox(width: 12),
          Text(label,
              style: KrishiTheme.bodySmall
                  .copyWith(color: KrishiTheme.monsoonSky)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: KrishiTheme.bodyMedium.copyWith(
                color: KrishiTheme.deepSoil,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editLabel(String text) {
    return Text(
      text,
      style: KrishiTheme.bodyMedium.copyWith(
        color: KrishiTheme.deepSoil,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _editField(TextEditingController controller, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: KrishiTheme.bodyLarge.copyWith(color: KrishiTheme.deepSoil),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: KrishiTheme.primaryGreen, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: KrishiTheme.primaryGreen.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: KrishiTheme.primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _langPickerButton() {
    final lang = _findLang(_editLanguage);
    return GestureDetector(
      onTap: () => _showLangPicker(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                lang != null ? KrishiTheme.primaryGreen : Colors.grey.shade300,
            width: lang != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.translate_rounded,
                color: KrishiTheme.primaryGreen, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: lang == null
                  ? Text('Select language',
                      style: KrishiTheme.bodyMedium
                          .copyWith(color: Colors.grey.shade500))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.name,
                            style: KrishiTheme.bodyMedium.copyWith(
                                color: KrishiTheme.deepSoil,
                                fontWeight: FontWeight.w700)),
                        Text(lang.native,
                            style: KrishiTheme.bodySmall
                                .copyWith(color: KrishiTheme.monsoonSky)),
                      ],
                    ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Future<void> _showLangPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LangPickerSheet(selected: _editLanguage),
    );
    if (picked != null) setState(() => _editLanguage = picked);
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: KrishiTheme.alertRed,
          side: BorderSide(color: KrishiTheme.alertRed.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Language picker bottom sheet ─────────────────────────────────────────────

class _LangPickerSheet extends StatefulWidget {
  final String? selected;
  const _LangPickerSheet({this.selected});

  @override
  State<_LangPickerSheet> createState() => _LangPickerSheetState();
}

class _LangPickerSheetState extends State<_LangPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Build flat list when searching
  List<_IndianLang> get _searchResults {
    final q = _query.toLowerCase();
    return _allLangs
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.native.toLowerCase().contains(q) ||
            l.code.toLowerCase().contains(q))
        .toList();
  }

  // Unique codes already shown (to avoid duplicates in grouped view)
  final _shown = <String>{};

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  const Icon(Icons.translate_rounded,
                      color: KrishiTheme.primaryGreen, size: 22),
                  const SizedBox(width: 10),
                  Text('Select Language',
                      style: KrishiTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KrishiTheme.deepSoil)),
                  const Spacer(),
                  Text('${_allLangs.length} languages',
                      style: KrishiTheme.bodySmall
                          .copyWith(color: KrishiTheme.monsoonSky)),
                ]),
              ),
              const SizedBox(height: 12),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search language...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            })
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // List
              Expanded(
                child: _query.isNotEmpty
                    ? _buildFlatList(scrollCtrl)
                    : _buildGroupedList(scrollCtrl),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlatList(ScrollController ctrl) {
    final results = _searchResults;
    if (results.isEmpty) {
      return Center(
        child: Text('No language found',
            style: KrishiTheme.bodyMedium.copyWith(color: Colors.grey)),
      );
    }
    return ListView.builder(
      controller: ctrl,
      itemCount: results.length,
      itemBuilder: (_, i) => _langTile(results[i]),
    );
  }

  Widget _buildGroupedList(ScrollController ctrl) {
    // Build a flat list of [header, lang, lang, …, header, …]
    final items = <_PickerItem>[];
    final seenCodes = <String>{}; // track to avoid duplicates across states

    for (final entry in _stateLangs.entries) {
      final langs =
          entry.value.map(_findLang).whereType<_IndianLang>().toList();
      if (langs.isEmpty) continue;
      items.add(_PickerItem.header(entry.key));
      for (final l in langs) {
        items.add(_PickerItem.lang(l));
        seenCodes.add(l.code);
      }
    }

    // "Other / All Scheduled" — langs not shown in any state
    final remaining =
        _allLangs.where((l) => !seenCodes.contains(l.code)).toList();
    if (remaining.isNotEmpty) {
      items.add(_PickerItem.header('Other Scheduled Languages'));
      for (final l in remaining) {
        items.add(_PickerItem.lang(l));
      }
    }

    return ListView.builder(
      controller: ctrl,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return item.isHeader
            ? _stateHeader(item.label!)
            : _langTile(item.lang!);
      },
    );
  }

  Widget _stateHeader(String state) {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        state,
        style: KrishiTheme.bodySmall.copyWith(
          color: KrishiTheme.primaryGreen,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _langTile(_IndianLang lang) {
    final isSelected = widget.selected == lang.code;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      tileColor: isSelected ? KrishiTheme.primaryGreen.withOpacity(0.08) : null,
      leading: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: KrishiTheme.primaryGreen, size: 22)
          : CircleAvatar(
              radius: 11,
              backgroundColor: Colors.grey[200],
              child: Text(
                lang.code.substring(0, 2).toUpperCase(),
                style:
                    const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
      title: Text(lang.name,
          style: KrishiTheme.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? KrishiTheme.primaryGreen : KrishiTheme.deepSoil,
          )),
      subtitle: Text(lang.native,
          style: KrishiTheme.bodySmall.copyWith(color: KrishiTheme.monsoonSky)),
      onTap: () => Navigator.of(context).pop(lang.code),
    );
  }
}

class _PickerItem {
  final String? label; // non-null = section header
  final _IndianLang? lang; // non-null = language tile
  bool get isHeader => label != null;

  const _PickerItem.header(this.label) : lang = null;
  const _PickerItem.lang(this.lang) : label = null;
}
