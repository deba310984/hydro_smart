import '../crop_recommendation/data/models/crop.dart';

// ── Growth Stage ─────────────────────────────────────────────────────────────

enum GrowthStage { seedling, vegetative, development, maturation, harvestReady }

extension GrowthStageExt on GrowthStage {
  String get label {
    switch (this) {
      case GrowthStage.seedling:
        return 'Seedling';
      case GrowthStage.vegetative:
        return 'Vegetative Growth';
      case GrowthStage.development:
        return 'Development';
      case GrowthStage.maturation:
        return 'Maturation';
      case GrowthStage.harvestReady:
        return 'Harvest Ready';
    }
  }

  String get emoji {
    switch (this) {
      case GrowthStage.seedling:
        return '🌱';
      case GrowthStage.vegetative:
        return '🌿';
      case GrowthStage.development:
        return '🌾';
      case GrowthStage.maturation:
        return '🌻';
      case GrowthStage.harvestReady:
        return '🎉';
    }
  }

  String get description {
    switch (this) {
      case GrowthStage.seedling:
        return 'Seeds germinating. Keep pH stable and EC low.';
      case GrowthStage.vegetative:
        return 'Active leaf growth. Gradually increase nutrient concentration.';
      case GrowthStage.development:
        return 'Structure forming. Maintain optimal light and airflow.';
      case GrowthStage.maturation:
        return 'Nearing harvest. Reduce feeding frequency gradually.';
      case GrowthStage.harvestReady:
        return 'Ready to harvest! Check size, colour and physical signs.';
    }
  }

  double get startPercent {
    switch (this) {
      case GrowthStage.seedling:
        return 0;
      case GrowthStage.vegetative:
        return 15;
      case GrowthStage.development:
        return 45;
      case GrowthStage.maturation:
        return 70;
      case GrowthStage.harvestReady:
        return 90;
    }
  }

  double get endPercent {
    switch (this) {
      case GrowthStage.seedling:
        return 15;
      case GrowthStage.vegetative:
        return 45;
      case GrowthStage.development:
        return 70;
      case GrowthStage.maturation:
        return 90;
      case GrowthStage.harvestReady:
        return 100;
    }
  }
}

// ── Sensor Reading ────────────────────────────────────────────────────────────

class SensorReading {
  final String name;
  final String unit;
  final double? value; // null = sensor not yet connected
  final double targetMin;
  final double targetMax;
  final String icon;

  const SensorReading({
    required this.name,
    required this.unit,
    this.value,
    required this.targetMin,
    required this.targetMax,
    required this.icon,
  });

  bool get isConnected => value != null;

  bool get isOptimal =>
      value != null && value! >= targetMin && value! <= targetMax;

  String get statusLabel {
    if (!isConnected) return 'No Sensor';
    if (isOptimal) return 'Optimal';
    if (value! < targetMin) return 'Too Low';
    return 'Too High';
  }

  String get targetRange =>
      '${targetMin.toStringAsFixed(1)} – ${targetMax.toStringAsFixed(1)} $unit';

  SensorReading copyWithValue(double newValue) => SensorReading(
        name: name,
        unit: unit,
        value: newValue,
        targetMin: targetMin,
        targetMax: targetMax,
        icon: icon,
      );
}

// ── Nutrient Tip ─────────────────────────────────────────────────────────────

class NutrientTip {
  final String title;
  final String detail;
  final String icon;

  const NutrientTip(
      {required this.title, required this.detail, required this.icon});
}

// ── Active Growth Session ─────────────────────────────────────────────────────

class ActiveGrowthSession {
  final Crop crop;
  final DateTime plantedDate;

  // Sensor readings — values are null until physical sensors are connected.
  final SensorReading phLevel;
  final SensorReading ecLevel;
  final SensorReading waterTemp;
  final SensorReading ambientTemp;
  final SensorReading humidity;
  final SensorReading lightHours;

  const ActiveGrowthSession({
    required this.crop,
    required this.plantedDate,
    required this.phLevel,
    required this.ecLevel,
    required this.waterTemp,
    required this.ambientTemp,
    required this.humidity,
    required this.lightHours,
  });

  // ── Computed ─────────────────────────────────────────────────

  int get daysSincePlanting =>
      DateTime.now().difference(plantedDate).inDays.clamp(0, 9999);

  int get daysRemaining {
    final r = crop.seedToHarvestDays - daysSincePlanting;
    return r < 0 ? 0 : r;
  }

  double get progressPercent =>
      (daysSincePlanting / crop.seedToHarvestDays * 100).clamp(0.0, 100.0);

  GrowthStage get currentStage {
    final pct = progressPercent;
    if (pct >= 90) return GrowthStage.harvestReady;
    if (pct >= 70) return GrowthStage.maturation;
    if (pct >= 45) return GrowthStage.development;
    if (pct >= 15) return GrowthStage.vegetative;
    return GrowthStage.seedling;
  }

  bool get isOverdue => daysSincePlanting > crop.seedToHarvestDays;

  DateTime get expectedHarvestDate =>
      plantedDate.add(Duration(days: crop.seedToHarvestDays));

  List<SensorReading> get allSensors =>
      [phLevel, ecLevel, waterTemp, ambientTemp, humidity, lightHours];

  int get connectedSensorCount => allSensors.where((s) => s.isConnected).length;

  // ── Nutrient tips per stage ───────────────────────────────────

  List<NutrientTip> get currentTips {
    switch (currentStage) {
      case GrowthStage.seedling:
        return [
          const NutrientTip(
              icon: '💧',
              title: 'Low EC Start',
              detail: 'Keep EC at 0.8–1.2 mS/cm to avoid nutrient burn.'),
          const NutrientTip(
              icon: '🌡️',
              title: 'Warm Water',
              detail: 'Water temp 20–22 °C encourages root development.'),
          const NutrientTip(
              icon: '🔆',
              title: '18 hr Light',
              detail: 'Provide 18 h of light per day to speed up germination.'),
        ];
      case GrowthStage.vegetative:
        return [
          const NutrientTip(
              icon: '⚡',
              title: 'Increase EC',
              detail: 'Raise EC to 1.5–2.0 mS/cm for leaf growth.'),
          const NutrientTip(
              icon: '🫧',
              title: 'Aeration',
              detail: 'Ensure dissolved oxygen > 6 mg/L for healthy roots.'),
          const NutrientTip(
              icon: '🌿',
              title: 'Prune Lower Leaves',
              detail: 'Remove yellowing lower leaves to improve airflow.'),
        ];
      case GrowthStage.development:
        return [
          const NutrientTip(
              icon: '🧪',
              title: 'Stable pH',
              detail: 'Keep pH within ±0.2 of optimal for best uptake.'),
          const NutrientTip(
              icon: '☀️',
              title: 'Consistent Light',
              detail: 'Maintain scheduled photoperiod without interruption.'),
          const NutrientTip(
              icon: '🌬️',
              title: 'Airflow',
              detail: 'Good circulation prevents fungal issues at this stage.'),
        ];
      case GrowthStage.maturation:
        return [
          const NutrientTip(
              icon: '📉',
              title: 'Reduce EC',
              detail: 'Taper EC below 1.5 mS/cm to flush residual salts.'),
          const NutrientTip(
              icon: '🚿',
              title: 'Final Flush',
              detail:
                  'Flush with plain pH-adjusted water 5–7 days before harvest.'),
          const NutrientTip(
              icon: '👁️',
              title: 'Inspect Daily',
              detail: 'Check for pests and signs of early harvest readiness.'),
        ];
      case GrowthStage.harvestReady:
        return [
          const NutrientTip(
              icon: '✂️',
              title: 'Time to Harvest',
              detail:
                  'Harvest in the morning for best flavour and shelf life.'),
          const NutrientTip(
              icon: '❄️',
              title: 'Cold Storage',
              detail: 'Refrigerate immediately after harvest at 2–4 °C.'),
          const NutrientTip(
              icon: '🔄',
              title: 'Replant Soon',
              detail: 'Clean the system and start the next crop within 48 h.'),
        ];
    }
  }

  // ── Factory ───────────────────────────────────────────────────

  /// Build a session with no sensor values — placeholder ranges come from
  /// the crop's own growing-condition data.
  factory ActiveGrowthSession.fromCrop(Crop crop, DateTime plantedDate) {
    final phMin = (crop.phRange['min'] as num?)?.toDouble() ?? 5.5;
    final phMax = (crop.phRange['max'] as num?)?.toDouble() ?? 7.0;
    final tempMin = (crop.temperatureRange['min'] as num?)?.toDouble() ?? 18.0;
    final tempMax = (crop.temperatureRange['max'] as num?)?.toDouble() ?? 28.0;
    final lightH =
        (crop.lightRequirement['daily_hours'] as num?)?.toDouble() ?? 14.0;

    return ActiveGrowthSession(
      crop: crop,
      plantedDate: plantedDate,
      phLevel: SensorReading(
          name: 'pH Level',
          unit: 'pH',
          targetMin: phMin,
          targetMax: phMax,
          icon: '💧'),
      ecLevel: SensorReading(
          name: 'EC Level',
          unit: 'mS/cm',
          targetMin: 1.2,
          targetMax: 2.0,
          icon: '⚡'),
      waterTemp: SensorReading(
          name: 'Water Temp',
          unit: '°C',
          targetMin: tempMin - 2,
          targetMax: tempMax - 2,
          icon: '🌡️'),
      ambientTemp: SensorReading(
          name: 'Air Temp',
          unit: '°C',
          targetMin: tempMin,
          targetMax: tempMax,
          icon: '🌤️'),
      humidity: SensorReading(
          name: 'Humidity',
          unit: '%',
          targetMin: 60,
          targetMax: 80,
          icon: '💦'),
      lightHours: SensorReading(
          name: 'Light Hours',
          unit: 'hrs/day',
          targetMin: lightH - 1,
          targetMax: lightH + 1,
          icon: '☀️'),
    );
  }

  // ── CopyWith for sensor updates ───────────────────────────────

  ActiveGrowthSession copyWithSensors({
    SensorReading? phLevel,
    SensorReading? ecLevel,
    SensorReading? waterTemp,
    SensorReading? ambientTemp,
    SensorReading? humidity,
    SensorReading? lightHours,
  }) =>
      ActiveGrowthSession(
        crop: crop,
        plantedDate: plantedDate,
        phLevel: phLevel ?? this.phLevel,
        ecLevel: ecLevel ?? this.ecLevel,
        waterTemp: waterTemp ?? this.waterTemp,
        ambientTemp: ambientTemp ?? this.ambientTemp,
        humidity: humidity ?? this.humidity,
        lightHours: lightHours ?? this.lightHours,
      );
}

// ── Legacy compat ─────────────────────────────────────────────────────────────

class GrowthData {
  final String cropName;
  final int daysSincePlantation;
  final int totalGrowthDays;
  final DateTime expectedHarvestDate;

  double get progressPercentage =>
      (daysSincePlantation / totalGrowthDays) * 100;

  int get daysRemaining => totalGrowthDays - daysSincePlantation;

  GrowthData({
    required this.cropName,
    required this.daysSincePlantation,
    required this.totalGrowthDays,
    required this.expectedHarvestDate,
  });
}
