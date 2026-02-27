import 'package:cloud_firestore/cloud_firestore.dart';
import 'subsidy_model.dart';

class SubsidyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock data for real Indian government subsidies
  final List<SubsidyModel> mockSubsidies = [
    SubsidyModel(
      id: '1',
      title: 'PM KUSUM Scheme - Solar Pumps',
      description:
          'Central Sector Scheme for promoting solar powered agriculture',
      subsidyPercentage: 60,
      eligibility:
          'Farmers with 0.5-2 hectares of land, Landless agricultural laborers',
      documentsRequired: [
        'Land ownership proof / lease deed',
        'AADHAR Card',
        'Bank account details',
        'Electricity bill',
      ],
      isActive: true,
      ministry: 'Ministry of New & Renewable Energy',
      deadline: '31-12-2026',
      category: 'Equipment - Solar Pumps',
      contactInfo: '+91-1143082920, helpdesk@mnre.gov.in',
      officialLink: 'https://pmkusum.mnre.gov.in/',
      benefitsDescription:
          '60% subsidy on solar pumps up to 7.5 kW capacity. Additional benefits for grid-connected systems.',
      applicableStates: [
        'Andhra Pradesh',
        'Gujarat',
        'Karnataka',
        'Maharashtra',
        'Punjab',
        'Rajasthan',
        'Tamil Nadu',
        'Telangana',
        'Uttar Pradesh',
        'All States'
      ],
    ),
    SubsidyModel(
      id: '2',
      title: 'PMKSY - Pradhan Mantri Krishi Sinchayee Yojana',
      description:
          'Centrally Sponsored Scheme for irrigation efficiency and crop productivity',
      subsidyPercentage: 55,
      eligibility: 'Small & Marginal Farmers, SC/ST farmers, Women farmers',
      documentsRequired: [
        'Land certificate',
        'Farmer ID',
        'Income certificate',
        'AADHAR/PAN',
        'Feasibility report',
      ],
      isActive: true,
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      deadline: '30-06-2026',
      category: 'Equipment - Drip & Sprinkler Systems',
      contactInfo: '011-2338-8032, pmksy@nic.in',
      officialLink: 'https://pmksy.gov.in/',
      benefitsDescription:
          '50-55% subsidy on micro-irrigation systems. Additional 5% for SC/ST farmers.',
      applicableStates: [
        'Andhra Pradesh',
        'Bihar',
        'Chhattisgarh',
        'Gujarat',
        'Haryana',
        'Karnataka',
        'Maharashtra',
        'Madhya Pradesh',
        'Odisha',
        'Tamil Nadu'
      ],
    ),
    SubsidyModel(
      id: '3',
      title: 'National Horticulture Mission - Hydroponics',
      description:
          'Support for setting up protected cultivation and hydroponics units',
      subsidyPercentage: 50,
      eligibility: 'Self Help Groups, Farmers, Entrepreneurs, Women groups',
      documentsRequired: [
        'Land ownership/lease deed',
        'Bank account statement (6 months)',
        'Business plan',
        'Technical design',
        'AADHAR Card',
      ],
      isActive: true,
      ministry: 'Department of Agriculture & Cooperation',
      deadline: '15-09-2026',
      category: 'Hydroponics Setup',
      contactInfo: 'nhm.gov.in, 011-2339-3847',
      officialLink: 'https://nhm.gov.in/',
      benefitsDescription:
          'Up to 50% subsidy for setting up hydroponics units. Covers infrastructure, equipment & training.',
      applicableStates: ['All States', 'Union Territories'],
    ),
    SubsidyModel(
      id: '4',
      title: 'RKVY-RAFTAAR - Rashtriya Krishi Vikas Yojana',
      description:
          'Scheme for agricultural development with technology promotion',
      subsidyPercentage: 40,
      eligibility: 'Farmers, Cooperative societies, Producer organizations',
      documentsRequired: [
        'Land certificate',
        'Farmer registration number',
        'Project proposal',
        'Bank statement',
        'Technical certification',
      ],
      isActive: true,
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      deadline: '31-03-2027',
      category: 'Technology & Training',
      contactInfo: 'rkvy.raftaar@nic.in, 011-2338-8052',
      officialLink: 'https://rkvy.nic.in/',
      benefitsDescription:
          '40% subsidy on agricultural technology adoption including hydroponics setup.',
      applicableStates: [
        'Andhra Pradesh',
        'Assam',
        'Bihar',
        'Gujarat',
        'Haryana',
        'Himachal Pradesh',
        'Jharkhand',
        'Karnataka',
        'Madhya Pradesh'
      ],
    ),
    SubsidyModel(
      id: '5',
      title: 'Per Drop More Crop Scheme',
      description: 'Micro-irrigation based water conservation scheme',
      subsidyPercentage: 75,
      eligibility: 'Farmers with irrigated land in identified priority areas',
      documentsRequired: [
        'Land record/Title deed',
        'AADHAR Card',
        'Farmer income certificate',
        'Layout plan of field',
        'Quotation of equipment',
      ],
      isActive: true,
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      deadline: '30-11-2026',
      category: 'Water Conservation',
      contactInfo: '+91-11-2338-8178, pradhanmantri@nic.in',
      officialLink: 'https://pmksy.gov.in/pdmc/',
      benefitsDescription:
          'Up to 75% subsidy on drip/sprinkler systems. Focuses on water-scarce regions.',
      applicableStates: [
        'Andhra Pradesh',
        'Gujarat',
        'Haryana',
        'Karnataka',
        'Maharashtra',
        'Rajasthan',
        'Telangana',
        'Uttar Pradesh'
      ],
    ),
    SubsidyModel(
      id: '6',
      title: 'MIDH - Mission for Integrated Development of Horticulture',
      description:
          'Support for value addition and processing of horticultural crops',
      subsidyPercentage: 45,
      eligibility: 'Individual farmers, FPOs, Entrepreneurs, Women SHGs',
      documentsRequired: [
        'Land ownership proof',
        'Proposed project details',
        'Quotations for equipment',
        'AADHAR/PAN',
        'Bank passbook',
      ],
      isActive: true,
      ministry: 'Department of Agriculture & Cooperation',
      deadline: '30-06-2027',
      category: 'Horticulture Development',
      contactInfo: 'midh.nic.in, 011-2338-8373',
      officialLink: 'https://midh.gov.in/',
      benefitsDescription:
          '40-50% subsidy for horticulture development including hydroponics for vegetables.',
      applicableStates: ['All States and Union Territories'],
    ),
    SubsidyModel(
      id: '7',
      title: 'Aatmanirbhar Bharat - Farm Equipment Subsidy',
      description:
          'Scheme supporting agricultural mechanization and equipment purchase',
      subsidyPercentage: 50,
      eligibility: 'All farmers (individual or group), Agricultural clubs',
      documentsRequired: [
        'Land certificate',
        'Farmer ID',
        'Equipment specification',
        'Dealer authorization',
        'Bank evidence',
      ],
      isActive: true,
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      deadline: '31-05-2027',
      category: 'Equipment Purchase',
      contactInfo: 'atmanirbharbharat@nic.in',
      officialLink: 'https://farmequipment.nic.in/',
      benefitsDescription:
          'Up to 50% subsidy on agricultural equipment including pumps and irrigation systems.',
      applicableStates: ['All States and Union Territories'],
    ),
    SubsidyModel(
      id: '8',
      title: 'Horticultural Crops - Vegetables Promotion',
      description: 'State-specific schemes for promoting vegetable cultivation',
      subsidyPercentage: 35,
      eligibility: 'Farmers choosing vegetable farming or hydroponics',
      documentsRequired: [
        'Land records',
        'Farmer registration',
        'Cultivation plan',
        'AADHAR Card',
      ],
      isActive: true,
      ministry: 'Department of Horticulture (State)',
      deadline: 'Varies by State',
      category: 'Vegetable Cultivation',
      contactInfo: 'Contact local agriculture office',
      officialLink: 'https://agriculture.gov.in/',
      benefitsDescription:
          'State-level subsidies (30-40%) for vegetable cultivation including hydroponic farming.',
      applicableStates: ['All States'],
    ),
  ];

  Stream<List<SubsidyModel>> streamSubsidies() {
    // Return mock data directly
    return Stream.value(mockSubsidies.where((s) => s.isActive).toList());
  }

  // Get subsidies filtered by category
  Stream<List<SubsidyModel>> getSubsidiesByCategory(String category) {
    return streamSubsidies().map((schemes) =>
        schemes.where((s) => s.category.contains(category)).toList());
  }

  // Get subsidies filtered by state
  Stream<List<SubsidyModel>> getSubsidiesByState(String state) {
    return streamSubsidies().map((schemes) => schemes
        .where((s) =>
            s.applicableStates.contains(state) ||
            s.applicableStates.contains('All States'))
        .toList());
  }
}
