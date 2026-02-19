class SubsidyModel {
  final String id;
  final String title;
  final String description;
  final int subsidyPercentage;
  final String eligibility;
  final List<String> documentsRequired;
  final bool isActive;

  SubsidyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subsidyPercentage,
    required this.eligibility,
    required this.documentsRequired,
    required this.isActive,
  });

  factory SubsidyModel.fromJson(Map<String, dynamic> json, String id) {
    return SubsidyModel(
      id: id,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subsidyPercentage: json['subsidyPercentage'] ?? 0,
      eligibility: json['eligibility'] ?? '',
      documentsRequired: List<String>.from(json['documentsRequired'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subsidyPercentage': subsidyPercentage,
      'eligibility': eligibility,
      'documentsRequired': documentsRequired,
      'isActive': isActive,
    };
  }
}
