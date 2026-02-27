class SubsidyModel {
  final String id;
  final String title;
  final String description;
  final int subsidyPercentage;
  final String eligibility;
  final List<String> documentsRequired;
  final bool isActive;
  final String ministry; // Ministry providing the subsidy
  final String deadline; // Application deadline
  final String category; // Category: Equipment, Training, Certification, etc.
  final String contactInfo; // Contact details
  final String officialLink; // Official government website
  final String benefitsDescription; // Detailed benefits
  final List<String> applicableStates; // States where applicable

  SubsidyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subsidyPercentage,
    required this.eligibility,
    required this.documentsRequired,
    required this.isActive,
    required this.ministry,
    required this.deadline,
    required this.category,
    required this.contactInfo,
    required this.officialLink,
    required this.benefitsDescription,
    required this.applicableStates,
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
      ministry: json['ministry'] ?? '',
      deadline: json['deadline'] ?? '',
      category: json['category'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      officialLink: json['officialLink'] ?? '',
      benefitsDescription: json['benefitsDescription'] ?? '',
      applicableStates: List<String>.from(json['applicableStates'] ?? []),
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
      'ministry': ministry,
      'deadline': deadline,
      'category': category,
      'contactInfo': contactInfo,
      'officialLink': officialLink,
      'benefitsDescription': benefitsDescription,
      'applicableStates': applicableStates,
    };
  }
}
