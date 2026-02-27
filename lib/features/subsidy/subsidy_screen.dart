import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import 'subsidy_controller.dart';
import 'subsidy_model.dart';

class SubsidyScreen extends ConsumerStatefulWidget {
  const SubsidyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubsidyScreen> createState() => _SubsidyScreenState();
}

class _SubsidyScreenState extends ConsumerState<SubsidyScreen> {
  String? selectedState = 'All States';
  String selectedCategory = 'All';
  String searchQuery = '';
  double investmentAmount = 0.0;
  String? selectedSchemeForCalculator;

  final List<String> indianStates = [
    'All States',
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
  ];

  @override
  Widget build(BuildContext context) {
    final subsidiesAsync = ref.watch(subsidyStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.lotusWhite,
      body: CustomScrollView(
        slivers: [
          // Royal Header
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.royalPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Government Subsidies',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.royalPurple, AppTheme.royalMaroon],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.royalGold.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.currency_rupee,
                                color: AppTheme.royalGold, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Save up to 80% on Your Hydroponics Setup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Explore government schemes for farmers',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search subsidies...',
                      prefixIcon:
                          const Icon(Icons.search, color: AppTheme.royalPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: AppTheme.royalGold.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: AppTheme.royalPurple, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value.toLowerCase());
                    },
                  ),
                  const SizedBox(height: 16),
                  // State selector
                  Text(
                    'Select State',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.royalPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedState ?? 'All States',
                    items: indianStates
                        .map((state) => DropdownMenuItem(
                              value: state,
                              child: Text(state),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedState = value);
                    },
                    underline: Container(
                      height: 2,
                      color: AppTheme.royalGold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category filter
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.royalPurple,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All'),
                        _buildCategoryChip('Equipment'),
                        _buildCategoryChip('Training'),
                        _buildCategoryChip('Technology'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Subsidy Calculator Section
          SliverToBoxAdapter(
            child: _buildSubsidyCalculator(),
          ),
          // Content
          subsidiesAsync.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.royalPurple,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $err'),
                ),
              ),
            ),
            data: (subsidies) {
              if (subsidies.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No subsidy data available',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              }

              // Filter subsidies
              var filtered = subsidies.where((subsidy) {
                // Search filter
                bool matchesSearch = searchQuery.isEmpty ||
                    subsidy.title.toLowerCase().contains(searchQuery) ||
                    subsidy.description.toLowerCase().contains(searchQuery);

                // State filter
                bool matchesState = true;
                if (selectedState != null && selectedState != 'All States') {
                  matchesState = subsidy.applicableStates.any((state) =>
                      state
                          .toLowerCase()
                          .contains(selectedState!.toLowerCase()) ||
                      state.toLowerCase().contains('all states'));
                }

                // Category filter
                bool matchesCategory = selectedCategory == 'All' ||
                    subsidy.category
                        .toLowerCase()
                        .contains(selectedCategory.toLowerCase());

                return matchesSearch && matchesState && matchesCategory;
              }).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No subsidies found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSubsidyCard(filtered[index]),
                  childCount: filtered.length,
                ),
              );
            },
          ),
          // Footer spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsidyCalculator() {
    final subsidiesAsync = ref.watch(subsidyStreamProvider);

    return subsidiesAsync.when(
      data: (subsidies) {
        if (subsidies.isEmpty) return const SizedBox.shrink();

        double calculatedSubsidy = 0.0;
        double netCost = investmentAmount;

        if (selectedSchemeForCalculator != null && investmentAmount > 0) {
          try {
            final selectedScheme = subsidies
                .firstWhere((s) => s.id == selectedSchemeForCalculator);
            calculatedSubsidy =
                (investmentAmount * selectedScheme.subsidyPercentage) / 100;
            netCost = investmentAmount - calculatedSubsidy;
          } catch (e) {
            // Scheme not found
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.royalGold.withOpacity(0.15), Colors.white],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.royalGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.royalPurple.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.royalPurple.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calculate,
                          color: AppTheme.royalPurple, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Subsidy Calculator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.royalPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Investment Amount Input
                Text(
                  'Your Investment Amount (₹)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.currency_rupee),
                    hintText: 'Enter investment amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      investmentAmount = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Scheme Selection
                Text(
                  'Select Subsidy Scheme',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSchemeForCalculator,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Choose a scheme...'),
                    ),
                    ...subsidies.map((scheme) => DropdownMenuItem(
                          value: scheme.id,
                          child: Text(
                            '${scheme.title} (${scheme.subsidyPercentage}%)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() => selectedSchemeForCalculator = value);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Results
                if (investmentAmount > 0 && selectedSchemeForCalculator != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green[300]!, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Investment:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '₹${investmentAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Government Subsidy:',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '💰 ₹${calculatedSubsidy.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 12, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Cost (After Subsidy):',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${netCost.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '👉 You Save: ₹${calculatedSubsidy.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.orange[900],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (investmentAmount == 0)
                  Center(
                    child: Text(
                      'Enter investment amount to see subsidy calculation',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      'Select a scheme to calculate subsidy',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.all(16),
        child: CircularProgressIndicator(color: Colors.green[700]),
      ),
      error: (err, stack) => Container(
        margin: const EdgeInsets.all(16),
        child: Text('Error loading calculator: $err'),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => selectedCategory = category);
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.royalPurple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.royalPurple,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: isSelected
              ? AppTheme.royalPurple
              : AppTheme.royalGold.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSubsidyCard(SubsidyModel subsidy) {
    final isDeadlineSoon = _isDeadlineSoon(subsidy.deadline);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: AppTheme.royalPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.royalGold.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header with ministry badge
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.royalPurple, AppTheme.royalMaroon],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subsidy.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildBadge(
                            subsidy.ministry.split(' ').sublist(0, 2).join(' '),
                            Colors.white.withOpacity(0.2),
                            Colors.white,
                            Icons.account_balance,
                          ),
                          if (isDeadlineSoon)
                            _buildBadge(
                              '⏰ Deadline Soon',
                              Colors.red.withOpacity(0.3),
                              Colors.white,
                              Icons.warning,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Subsidy percentage highlight
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${subsidy.subsidyPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Subsidy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  subsidy.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Benefits
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    subsidy.benefitsDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Deadline and Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📅 Deadline: ${subsidy.deadline}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDeadlineSoon ? Colors.red : Colors.grey[600],
                          fontWeight: isDeadlineSoon
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        subsidy.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Eligibility
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eligibility',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subsidy.eligibility,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Required Documents
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Documents (${subsidy.documentsRequired.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ...subsidy.documentsRequired.take(3).map((doc) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doc,
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[700]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (subsidy.documentsRequired.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '+${subsidy.documentsRequired.length - 3} more',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Applicable States
                Wrap(
                  spacing: 6,
                  children: [
                    Text(
                      '📍 States:',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ...subsidy.applicableStates
                        .take(3)
                        .map((state) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                state,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                    if (subsidy.applicableStates.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          '+${subsidy.applicableStates.length - 3} more',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(subsidy.officialLink),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Official Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.royalPurple,
                      side: const BorderSide(color: AppTheme.royalPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApplyBottomSheet(subsidy),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Apply Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.royalPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    String label,
    Color backgroundColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isDeadlineSoon(String deadline) {
    try {
      final deadlineDate = DateTime.parse(deadline.replaceAll('-', '-'));
      final daysUntilDeadline = deadlineDate.difference(DateTime.now()).inDays;
      return daysUntilDeadline <= 90 && daysUntilDeadline > 0;
    } catch (e) {
      return false;
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _showApplyBottomSheet(SubsidyModel subsidy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.royalGold.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Apply for ${subsidy.title}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalPurple,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.royalPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.royalPurple.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.royalGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.phone,
                              color: AppTheme.royalGold, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.royalPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subsidy.contactInfo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _launchUrl(subsidy.officialLink),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppTheme.royalPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Visit Official Portal'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Checklist
              Row(
                children: [
                  const Icon(Icons.task_alt, color: AppTheme.royalGold),
                  const SizedBox(width: 8),
                  Text(
                    'Before applying, ensure you have:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.royalPurple,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...subsidy.documentsRequired.map((doc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 18, color: AppTheme.royalGold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            doc,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Application process started for ${subsidy.title}'),
                      backgroundColor: AppTheme.royalPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppTheme.royalGold,
                  foregroundColor: AppTheme.royalPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Proceed to Apply',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
