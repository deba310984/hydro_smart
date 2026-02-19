import 'package:equatable/equatable.dart';

class FarmModel extends Equatable {
  final String id;
  final String name;
  final String location;
  final String deviceId;
  final double area; // in square meters
  final String cropType;
  final DateTime createdAt;
  final bool isActive;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.deviceId,
    required this.area,
    required this.cropType,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'deviceId': deviceId,
      'area': area,
      'cropType': cropType,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0,
      cropType: json['cropType'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  FarmModel copyWith({
    String? id,
    String? name,
    String? location,
    String? deviceId,
    double? area,
    String? cropType,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return FarmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      deviceId: deviceId ?? this.deviceId,
      area: area ?? this.area,
      cropType: cropType ?? this.cropType,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    deviceId,
    area,
    cropType,
    createdAt,
    isActive,
  ];

  @override
  String toString() => 'FarmModel(id: $id, name: $name, crop: $cropType)';
}
