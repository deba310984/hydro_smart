import 'package:equatable/equatable.dart';

class SensorModel extends Equatable {
  final String id;
  final String name;
  final String type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final bool isActive;

  const SensorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.isActive = true,
  });

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Create from Realtime Database snapshot
  factory SensorModel.fromRtdb(String id, Map<dynamic, dynamic> data) {
    return SensorModel(
      id: id,
      name: data['name'] as String? ?? 'Unknown',
      type: data['type'] as String? ?? 'Unknown',
      value: (data['value'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? '',
      timestamp: DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Copy with method for immutability
  SensorModel copyWith({
    String? id,
    String? name,
    String? type,
    double? value,
    String? unit,
    DateTime? timestamp,
    bool? isActive,
  }) {
    return SensorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, type, value, unit, timestamp, isActive];

  @override
  String toString() =>
      'SensorModel(id: $id, name: $name, type: $type, value: $value$unit)';
}
