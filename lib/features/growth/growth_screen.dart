import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'growth_controller.dart';
import 'growth_model.dart';
import '../crop_recommendation/presentation/pages/crop_recommendation_page.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class GrowthTrackerScreen extends ConsumerStatefulWidget {
  const GrowthTrackerScreen({super.key});

  @override
  ConsumerState<GrowthTrackerScreen> createState() =>
      _GrowthTrackerScreenState();
}

class _GrowthTrackerScreenState extends ConsumerState<GrowthTrackerScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh every minute so "days since planting" stays current.
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.read(activeGrowthProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeGrowthProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, session),
      body: session == null
          ? _EmptyGrowthState(
              onGoToCropAdvisory: () => _goToCropAdvisory(context))
          : _ActiveGrowthView(session: session),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ActiveGrowthSession? session) {
    return AppBar(
      title: Text(
        session == null ? 'Growth Tracker' : '${session.crop.cropName} Growth',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: session != null
          ? [
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: 'Stop growing',
                onPressed: () => _confirmStop(context),
              ),
            ]
          : null,
    );
  }

  void _goToCropAdvisory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CropRecommendationPage()),
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Growing?'),
        content: const Text(
            'This will clear the current growth session. Your sensor history is kept in Firebase.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Stop', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(activeGrowthProvider.notifier).stopGrowing();
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyGrowthState extends StatelessWidget {
  final VoidCallback onGoToCropAdvisory;
  const _EmptyGrowthState({required this.onGoToCropAdvisory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Crop Growing Yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Select a crop from the Crop Advisory section to start tracking its growth, monitor sensors and follow the grow plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.eco),
                label: const Text('Go to Crop Advisory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: onGoToCropAdvisory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active view ───────────────────────────────────────────────────────────────

class _ActiveGrowthView extends StatelessWidget {
  final ActiveGrowthSession session;
  const _ActiveGrowthView({required this.session});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(session: session),
          const SizedBox(height: 16),
          _StageTimeline(session: session),
          const SizedBox(height: 16),
          _SensorPanel(session: session),
          const SizedBox(height: 16),
          _HarvestCard(session: session),
          const SizedBox(height: 16),
          _NutrientTipsCard(session: session),
          const SizedBox(height: 16),
          _CropInfoCard(session: session),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Header card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final ActiveGrowthSession session;
  const _HeaderCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final pct = session.progressPercent;
    final stage = session.currentStage;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(stage.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.crop.cropName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          stage.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _CircularProgress(percent: pct),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                    label: 'Day',
                    value: '${session.daysSincePlanting}',
                    sub: 'since planting'),
                _StatChip(
                    label: 'Days Left',
                    value: session.isOverdue
                        ? 'Overdue'
                        : '${session.daysRemaining}',
                    sub: 'to harvest',
                    warn: session.isOverdue),
                _StatChip(
                    label: 'Duration',
                    value: '${session.crop.seedToHarvestDays}',
                    sub: 'total days'),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${pct.toStringAsFixed(1)}% complete',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double percent;
  const _CircularProgress({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Center(
            child: Text(
              '${percent.toInt()}%',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool warn;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.sub,
      this.warn = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: warn ? Colors.orange[200] : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

// ── Stage timeline ────────────────────────────────────────────────────────────

class _StageTimeline extends StatelessWidget {
  final ActiveGrowthSession session;
  const _StageTimeline({required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Growth Stages',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...GrowthStage.values.map((stage) {
              final pct = session.progressPercent;
              final active = stage == session.currentStage;
              final passed = pct >= stage.endPercent;
              final isLast = stage == GrowthStage.harvestReady;

              return _StageRow(
                stage: stage,
                active: active,
                passed: passed,
                isLast: isLast,
                session: session,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final GrowthStage stage;
  final bool active;
  final bool passed;
  final bool isLast;
  final ActiveGrowthSession session;

  const _StageRow({
    required this.stage,
    required this.active,
    required this.passed,
    required this.isLast,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Colors.green[700]!
        : passed
            ? Colors.green[400]!
            : Colors.grey[300]!;

    // Day range for this stage
    final startDay =
        (stage.startPercent / 100 * session.crop.seedToHarvestDays).round();
    final endDay =
        (stage.endPercent / 100 * session.crop.seedToHarvestDays).round();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.green[700]
                        : passed
                            ? Colors.green[400]
                            : Colors.grey[200],
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: passed || active
                        ? Icon(passed && !active ? Icons.check : Icons.circle,
                            size: 14,
                            color: active ? Colors.white : Colors.white)
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: passed ? Colors.green[400] : Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(stage.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stage.label,
                          style: TextStyle(
                            fontWeight:
                                active ? FontWeight.bold : FontWeight.normal,
                            color: active
                                ? Colors.green[800]
                                : passed
                                    ? Colors.grey[700]
                                    : Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text('Day $startDay–$endDay',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                  if (active) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        stage.description,
                        style:
                            TextStyle(fontSize: 12, color: Colors.green[800]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sensor panel ──────────────────────────────────────────────────────────────

class _SensorPanel extends StatelessWidget {
  final ActiveGrowthSession session;
  const _SensorPanel({required this.session});

  @override
  Widget build(BuildContext context) {
    final connected = session.connectedSensorCount;
    final total = session.allSensors.length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Sensor Readings',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        connected == 0 ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: connected == 0
                            ? Colors.orange[300]!
                            : Colors.green[300]!),
                  ),
                  child: Text(
                    '$connected/$total Connected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: connected == 0
                          ? Colors.orange[700]
                          : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            if (connected == 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sensors, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Physical sensors not yet connected. Target ranges are shown below. Sensor integration is ready — connect your pH, EC, temperature and light sensors to see live readings.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: session.allSensors
                  .map((s) => _SensorTile(reading: s))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final SensorReading reading;
  const _SensorTile({required this.reading});

  Color get _statusColor {
    if (!reading.isConnected) return Colors.grey[200]!;
    if (reading.isOptimal) return Colors.green[50]!;
    return Colors.orange[50]!;
  }

  Color get _borderColor {
    if (!reading.isConnected) return Colors.grey[300]!;
    if (reading.isOptimal) return Colors.green[300]!;
    return Colors.orange[300]!;
  }

  Color get _labelColor {
    if (!reading.isConnected) return Colors.grey[500]!;
    if (reading.isOptimal) return Colors.green[700]!;
    return Colors.orange[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(reading.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(reading.name,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reading.isConnected
                    ? '${reading.value!.toStringAsFixed(1)} ${reading.unit}'
                    : '— —',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: reading.isConnected ? Colors.black87 : Colors.grey,
                ),
              ),
              Text(
                reading.isConnected
                    ? reading.statusLabel
                    : 'Target: ${reading.targetRange}',
                style: TextStyle(fontSize: 10, color: _labelColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Harvest card ─────────────────────────────────────────────────────────────

class _HarvestCard extends StatelessWidget {
  final ActiveGrowthSession session;
  const _HarvestCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM yyyy');
    final isReady = session.currentStage == GrowthStage.harvestReady;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isReady ? Colors.green[700] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isReady ? Colors.green[700]! : Colors.green[200]!),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.celebration : Icons.calendar_month,
            color: isReady ? Colors.white : Colors.green[700],
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReady ? '🎉 Ready to Harvest!' : 'Expected Harvest',
                  style: TextStyle(
                    color: isReady ? Colors.white : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fmt.format(session.expectedHarvestDate),
                  style: TextStyle(
                    color: isReady ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isReady)
                  Text(
                    '${session.daysRemaining} days remaining',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nutrient tips card ────────────────────────────────────────────────────────

class _NutrientTipsCard extends StatelessWidget {
  final ActiveGrowthSession session;
  const _NutrientTipsCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final tips = session.currentTips;
    final stage = session.currentStage;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${stage.emoji} ', style: const TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(
                    'Care Tips – ${stage.label}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => _TipRow(tip: tip)),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final NutrientTip tip;
  const _TipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(tip.detail,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Crop info card ────────────────────────────────────────────────────────────

class _CropInfoCard extends StatelessWidget {
  final ActiveGrowthSession session;
  const _CropInfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final crop = session.crop;
    final optimalPh =
        (crop.phRange['optimal'] as num?)?.toStringAsFixed(1) ?? '6.5';
    final optimalTemp =
        (crop.temperatureRange['optimal'] as num?)?.toString() ?? '22';
    final techniques = crop.getCompatibleTechniques().take(3).join(', ');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop Details',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: 'Optimal pH', value: optimalPh),
                _InfoChip(label: 'Temp', value: '$optimalTemp °C'),
                _InfoChip(
                    label: 'Yield',
                    value: '${crop.yieldPerSqm.toStringAsFixed(1)} kg/m²'),
                _InfoChip(
                    label: 'Profit',
                    value: '${crop.profitMargin.toStringAsFixed(0)}%'),
                _InfoChip(label: 'Difficulty', value: crop.difficultyLevel),
                if (techniques.isNotEmpty)
                  _InfoChip(label: 'Techniques', value: techniques),
              ],
            ),
            if (crop.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                crop.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green[800])),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
