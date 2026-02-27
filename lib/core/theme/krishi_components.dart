import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'krishi_theme.dart';
import 'warli_painter.dart';

// ═══════════════════════════════════════════════════════════════════════════
// KRISHI CARD - Premium elevated card with green-tinted shadow
// ═══════════════════════════════════════════════════════════════════════════

class KrishiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final WarliPattern? warliPattern;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double borderRadius;

  const KrishiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.warliPattern,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = KrishiTheme.radiusLarge,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    if (warliPattern != null) {
      content = WarliBackground(
        pattern: warliPattern!,
        opacity: 0.03,
        child: content,
      );
    }

    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            KrishiTheme.lightHaptic();
            onTap!();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GLASSMORPHISM CARD - Modern frosted glass effect
// ═══════════════════════════════════════════════════════════════════════════

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? tintColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.tintColor,
    this.borderRadius = KrishiTheme.radiusLarge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (tintColor ?? Colors.white).withOpacity(0.25),
                (tintColor ?? Colors.white).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          KrishiTheme.lightHaptic();
          onTap!();
        },
        child: content,
      );
    }

    return content;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOIL HEALTH CARD - Glassmorphism soil metrics display
// ═══════════════════════════════════════════════════════════════════════════

class SoilHealthCard extends StatelessWidget {
  final double ph;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double moisture;
  final String? lastUpdated;

  const SoilHealthCard({
    super.key,
    this.ph = 6.5,
    this.nitrogen = 75,
    this.phosphorus = 60,
    this.potassium = 80,
    this.moisture = 45,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrishiTheme.primaryGreen.withOpacity(0.9),
            KrishiTheme.primaryGreen.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
        boxShadow: KrishiTheme.elevatedShadow,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: WarliPainter(
                pattern: WarliPattern.crops,
                opacity: 0.08,
                color: Colors.white,
              ),
            ),
          ),
          // Glass overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: KrishiTheme.glassGradient,
                  borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.grass_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Soil Health Card',
                                style: KrishiTheme.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (lastUpdated != null)
                                Text(
                                  'Updated: $lastUpdated',
                                  style: KrishiTheme.bodySmall.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Health score badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: KrishiTheme.goldenWheat,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _calculateHealthScore(),
                            style: KrishiTheme.labelStyle.copyWith(
                              color: KrishiTheme.deepSoil,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Metrics grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetric(
                              'pH Level', ph.toString(), _getPhColor()),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetric('Moisture',
                              '${moisture.toInt()}%', _getMoistureColor()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // NPK values
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNPKIndicator(
                              'N', nitrogen, KrishiTheme.freshLime),
                          _buildNPKIndicator(
                              'P', phosphorus, KrishiTheme.terracotta),
                          _buildNPKIndicator(
                              'K', potassium, KrishiTheme.goldenWheat),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateHealthScore() {
    final avgNPK = (nitrogen + phosphorus + potassium) / 3;
    final phScore = (1 - (ph - 6.5).abs() / 2) * 100;
    final score = (avgNPK * 0.6 + phScore * 0.3 + moisture * 0.1);

    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  Color _getPhColor() {
    if (ph >= 6.0 && ph <= 7.5) return KrishiTheme.freshLime;
    if (ph >= 5.5 && ph <= 8.0) return KrishiTheme.goldenWheat;
    return KrishiTheme.alertRed;
  }

  Color _getMoistureColor() {
    if (moisture >= 40 && moisture <= 60) return KrishiTheme.freshLime;
    if (moisture >= 30 && moisture <= 70) return KrishiTheme.goldenWheat;
    return KrishiTheme.terracotta;
  }

  Widget _buildMetric(String label, String value, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: KrishiTheme.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: KrishiTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNPKIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: KrishiTheme.labelStyle.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 4,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              '${value.toInt()}',
              style: KrishiTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LIVE MANDI TRACKER - Horizontal scrolling price marquee
// ═══════════════════════════════════════════════════════════════════════════

class MandiTracker extends StatefulWidget {
  final List<MandiPrice> prices;
  final double height;

  const MandiTracker({
    super.key,
    required this.prices,
    this.height = 50,
  });

  @override
  State<MandiTracker> createState() => _MandiTrackerState();
}

class _MandiTrackerState extends State<MandiTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _controller.addListener(_animateScroll);
  }

  void _animateScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final targetScroll = maxScroll * _controller.value;
      _scrollController.jumpTo(targetScroll);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_animateScroll);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            KrishiTheme.earthBrown,
            KrishiTheme.earthBrown.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(KrishiTheme.radiusSmall),
      ),
      child: Row(
        children: [
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KrishiTheme.alertRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MANDI',
                  style: KrishiTheme.labelStyle.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Scrolling prices
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.prices.length * 3, // Repeat for seamless scroll
              itemBuilder: (context, index) {
                final price = widget.prices[index % widget.prices.length];
                return _buildPriceItem(price);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(MandiPrice price) {
    final isPositive = price.change >= 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            price.crop,
            style: KrishiTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${price.price}',
            style: KrishiTheme.bodyMedium.copyWith(
              color: KrishiTheme.goldenWheat,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: isPositive ? KrishiTheme.freshLime : KrishiTheme.alertRed,
            size: 20,
          ),
          Text(
            '${isPositive ? '+' : ''}${price.change.toStringAsFixed(1)}%',
            style: KrishiTheme.bodySmall.copyWith(
              color: isPositive ? KrishiTheme.freshLime : KrishiTheme.alertRed,
            ),
          ),
        ],
      ),
    );
  }
}

class MandiPrice {
  final String crop;
  final double price;
  final double change;

  const MandiPrice({
    required this.crop,
    required this.price,
    required this.change,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// FARMER PROFILE HEADER - With Kisan ID badge & language toggle
// ═══════════════════════════════════════════════════════════════════════════

class FarmerProfileHeader extends StatelessWidget {
  final String name;
  final String? kisanId;
  final String? profileImageUrl;
  final String currentLanguage;
  final VoidCallback? onLanguageToggle;
  final VoidCallback? onNotificationTap;

  const FarmerProfileHeader({
    super.key,
    required this.name,
    this.kisanId,
    this.profileImageUrl,
    this.currentLanguage = 'EN',
    this.onLanguageToggle,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile avatar with badge
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: KrishiTheme.goldenWheat,
                    width: 2,
                  ),
                ),
                child: profileImageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),
              // Verified badge
              if (kisanId != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: KrishiTheme.freshLime,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: KrishiTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and Kisan ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: KrishiTheme.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (kisanId != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KrishiTheme.goldenWheat.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: KrishiTheme.goldenWheat.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: KrishiTheme.goldenWheat,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kisan ID: $kisanId',
                          style: KrishiTheme.bodySmall.copyWith(
                            color: KrishiTheme.goldenWheat,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Language toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                KrishiTheme.selectionHaptic();
                onLanguageToggle?.call();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.translate,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currentLanguage == 'EN' ? 'EN' : 'हिं',
                      style: KrishiTheme.labelStyle.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification bell
          IconButton(
            onPressed: () {
              KrishiTheme.lightHaptic();
              onNotificationTap?.call();
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: KrishiTheme.goldenWheat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 28,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// KRISHI FEATURE CARD - Premium feature cards with Hero support
// ═══════════════════════════════════════════════════════════════════════════

class KrishiFeatureCard extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final WarliPattern? warliPattern;
  final String? emoji;

  const KrishiFeatureCard({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.warliPattern,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            KrishiTheme.lightHaptic();
            onTap();
          },
          borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: KrishiTheme.primaryGreen.withOpacity(0.03),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Warli decoration
                if (warliPattern != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: WarliPainter(
                        pattern: warliPattern!,
                        opacity: 0.025,
                        color: accentColor,
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with emoji or accent background
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withOpacity(0.15),
                            accentColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: emoji != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji!,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 6),
                                Icon(icon,
                                    color: accentColor.withOpacity(0.6),
                                    size: 18),
                              ],
                            )
                          : Icon(icon, color: accentColor, size: 26),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      title,
                      style: KrishiTheme.titleMedium.copyWith(
                        color: KrishiTheme.deepSoil,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      subtitle,
                      style: KrishiTheme.bodySmall.copyWith(
                        color: KrishiTheme.monsoonSky,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// KRISHI BUTTON - Premium button with haptic feedback
// ═══════════════════════════════════════════════════════════════════════════

class KrishiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const KrishiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? KrishiTheme.primaryGreen;
    final fgColor = foregroundColor ?? Colors.white;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? bgColor : fgColor,
            ),
          ),
        ),
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: () {
          KrishiTheme.lightHaptic();
          onPressed();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: bgColor,
          side: BorderSide(color: bgColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const StadiumBorder(),
        ),
        child: _buildContent(bgColor),
      );
    }

    return ElevatedButton(
      onPressed: () {
        KrishiTheme.mediumHaptic();
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: const StadiumBorder(),
      ),
      child: _buildContent(fgColor),
    );
  }

  Widget _buildContent(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: KrishiTheme.labelStyle.copyWith(color: color),
          ),
        ],
      );
    }

    return Text(
      label,
      style: KrishiTheme.labelStyle.copyWith(color: color),
    );
  }
}
