import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import 'subsidy_model.dart';

/// Full-screen detail page for a subsidy scheme.
/// Shows comprehensive info + step-by-step application process.
class SubsidyDetailPage extends StatefulWidget {
  final SubsidyModel subsidy;

  const SubsidyDetailPage({Key? key, required this.subsidy}) : super(key: key);

  @override
  State<SubsidyDetailPage> createState() => _SubsidyDetailPageState();
}

class _SubsidyDetailPageState extends State<SubsidyDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Track which application steps the user has "completed"
  final Map<int, bool> _completedSteps = {};

  SubsidyModel get s => widget.subsidy;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Application Steps (generated per scheme) ───────────────
  List<_ApplicationStep> get _applicationSteps => [
        _ApplicationStep(
          title: 'Check Eligibility',
          description:
              'Verify that you meet the eligibility criteria:\n${s.eligibility}',
          icon: Icons.fact_check_outlined,
          tip:
              'Contact your local agriculture office if unsure about eligibility.',
        ),
        _ApplicationStep(
          title: 'Gather Required Documents',
          description:
              'Collect all the documents listed below before proceeding:\n${s.documentsRequired.map((d) => '• $d').join('\n')}',
          icon: Icons.folder_open,
          tip:
              'Keep scanned soft copies ready for online upload. Ensure all documents are up-to-date.',
        ),
        _ApplicationStep(
          title: 'Visit Official Portal',
          description:
              'Go to the official scheme website to register or begin your application.\n\nPortal: ${s.officialLink}',
          icon: Icons.language,
          tip:
              'Create an account on the portal using your Aadhaar-linked mobile number.',
        ),
        _ApplicationStep(
          title: 'Fill Application Form',
          description:
              'Complete the online/offline application form with accurate details about your farm, land, and proposed project.',
          icon: Icons.edit_document,
          tip:
              'Double-check all entered data. Mistakes may lead to rejection. Save draft frequently.',
        ),
        _ApplicationStep(
          title: 'Upload Documents',
          description:
              'Upload scanned copies of all required documents in the specified format (PDF/JPEG, usually < 2MB each).',
          icon: Icons.cloud_upload_outlined,
          tip:
              'Use a document scanner app for clear uploads. Name files clearly (e.g., "aadhaar_card.pdf").',
        ),
        _ApplicationStep(
          title: 'Submit & Get Reference Number',
          description:
              'Submit the application and note down your Application Reference Number for tracking.',
          icon: Icons.receipt_long,
          tip:
              'Take a screenshot of the confirmation page. You\'ll need the reference number to track status.',
        ),
        _ApplicationStep(
          title: 'Verification & Inspection',
          description:
              'A field officer from ${s.ministry} may visit your farm/project site for verification.',
          icon: Icons.verified_user_outlined,
          tip:
              'Keep all original documents ready for inspection. Be available during scheduled visit.',
        ),
        _ApplicationStep(
          title: 'Approval & Disbursement',
          description:
              'Once approved, the ${s.subsidyPercentage}% subsidy amount will be transferred directly to your bank account (DBT).',
          icon: Icons.account_balance_wallet,
          tip:
              'Ensure your bank account is linked to Aadhaar for Direct Benefit Transfer (DBT).',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDeadlineSoon = _isDeadlineSoon(s.deadline);

    return Scaffold(
      backgroundColor: AppTheme.lotusWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ─── Hero Header ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.royalPurple,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white70),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white70),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scheme bookmarked!')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.royalPurple,
                      Color(0xFF2D0E42),
                      AppTheme.royalMaroon,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category + Status badges
                        Row(
                          children: [
                            _badge(
                                s.category,
                                AppTheme.royalGold.withOpacity(0.3),
                                AppTheme.royalGold,
                                Icons.category),
                            const SizedBox(width: 8),
                            _badge(
                              s.isActive ? 'Active' : 'Closed',
                              s.isActive
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                              Colors.white,
                              s.isActive ? Icons.check_circle : Icons.cancel,
                            ),
                            if (isDeadlineSoon) ...[
                              const SizedBox(width: 8),
                              _badge(
                                  'Deadline Soon!',
                                  Colors.red.withOpacity(0.4),
                                  Colors.white,
                                  Icons.timer),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          s.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Ministry
                        Row(
                          children: [
                            const Icon(Icons.account_balance,
                                color: AppTheme.royalGold, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.ministry,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Subsidy % + Deadline row
                        Row(
                          children: [
                            _subsidyPercentChip(),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Deadline: ${s.deadline}',
                              style: TextStyle(
                                color: isDeadlineSoon
                                    ? Colors.redAccent[100]
                                    : Colors.white70,
                                fontSize: 12,
                                fontWeight: isDeadlineSoon
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.royalGold,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'How to Apply'),
                Tab(text: 'Details'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildHowToApplyTab(),
            _buildDetailsTab(),
          ],
        ),
      ),
      // Bottom action bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1: Overview
  // ═══════════════════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Description
        _sectionCard(
          icon: Icons.info_outline,
          title: 'About This Scheme',
          child: Text(
            s.description,
            style: const TextStyle(
                fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),

        // Benefits
        _sectionCard(
          icon: Icons.stars,
          title: 'Key Benefits',
          color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${s.subsidyPercentage}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        s.benefitsDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Eligibility
        _sectionCard(
          icon: Icons.person_search,
          title: 'Who Can Apply?',
          color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...s.eligibility.split(',').map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle,
                            size: 18, color: Colors.blue.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.trim(),
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Applicable States
        _sectionCard(
          icon: Icons.map_outlined,
          title: 'Applicable States',
          color: Colors.orange,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: s.applicableStates
                .map((state) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Text(
                        state,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 80), // Space for bottom bar
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2: How to Apply (step-by-step process)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHowToApplyTab() {
    final steps = _applicationSteps;
    final completedCount = _completedSteps.values.where((v) => v).length;
    final progress = steps.isEmpty ? 0.0 : completedCount / steps.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.royalPurple.withOpacity(0.1),
                AppTheme.royalGold.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.royalPurple.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.rocket_launch,
                      color: AppTheme.royalPurple, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Application Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalPurple,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completedCount / ${steps.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.royalPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    progress == 1.0 ? Colors.green : AppTheme.royalGold,
                  ),
                ),
              ),
              if (progress == 1.0)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'All steps completed! You\'re ready to apply.',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Step-by-step timeline
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isCompleted = _completedSteps[index] == true;
          final isLast = index == steps.length - 1;

          return _buildStepTile(
            index: index,
            step: step,
            isCompleted: isCompleted,
            isLast: isLast,
          );
        }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStepTile({
    required int index,
    required _ApplicationStep step,
    required bool isCompleted,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Circle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _completedSteps[index] = !isCompleted;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green
                          : AppTheme.royalPurple.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isCompleted ? Colors.green : AppTheme.royalPurple,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppTheme.royalPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Step content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCompleted
                      ? Colors.green.shade300
                      : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step.icon,
                          size: 20,
                          color: isCompleted
                              ? Colors.green.shade700
                              : AppTheme.royalPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.green.shade800
                                : Colors.black87,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      // Tap checkbox
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _completedSteps[index] = !isCompleted;
                          });
                        },
                        child: Icon(
                          isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color:
                              isCompleted ? Colors.green : Colors.grey.shade400,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Pro tip
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.tip,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber.shade900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 3: Details (Documents, Contact, etc.)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Required Documents
        _sectionCard(
          icon: Icons.description,
          title: 'Required Documents',
          color: Colors.indigo,
          child: Column(
            children: s.documentsRequired.asMap().entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                    Icon(Icons.upload_file,
                        size: 18, color: Colors.indigo.shade300),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Contact Information
        _sectionCard(
          icon: Icons.phone_in_talk,
          title: 'Contact & Helpline',
          color: Colors.teal,
          child: Column(
            children: [
              _contactRow(Icons.phone, 'Helpline', s.contactInfo),
              const SizedBox(height: 12),
              _contactRow(Icons.web, 'Official Website', s.officialLink),
              const SizedBox(height: 12),
              _contactRow(Icons.account_balance, 'Ministry', s.ministry),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick subsidy estimate
        _sectionCard(
          icon: Icons.calculate,
          title: 'Quick Subsidy Estimate',
          color: Colors.deepPurple,
          child: _buildQuickEstimate(),
        ),
        const SizedBox(height: 16),

        // Important Notes
        _sectionCard(
          icon: Icons.warning_amber,
          title: 'Important Notes',
          color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _noteItem('Applications must be submitted before ${s.deadline}'),
              _noteItem('Subsidy is subject to verification and approval'),
              _noteItem(
                  'Amount is disbursed via Direct Benefit Transfer (DBT)'),
              _noteItem('Keep all original documents for field verification'),
              _noteItem(
                  'Processing time varies from 30-90 days after submission'),
              _noteItem(
                  'Contact the helpdesk for any queries regarding your application'),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildQuickEstimate() {
    return Column(
      children: [
        ...[50000, 100000, 200000, 500000].map((amount) {
          final subsidy = (amount * s.subsidyPercentage) / 100;
          final yourCost = amount - subsidy;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${_formatAmount(amount)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '- ₹${_formatAmount(subsidy.toInt())}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Text('= ', style: TextStyle(fontSize: 13)),
                Text(
                  '₹${_formatAmount(yourCost.toInt())}',
                  style: TextStyle(
                    color: Colors.deepPurple.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Investment',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            Text('Govt Subsidy (${s.subsidyPercentage}%)',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            Text('Your Cost',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  // ─── Bottom Bar ─────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Official link button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(s.officialLink),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Portal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.royalPurple,
                  side:
                      const BorderSide(color: AppTheme.royalPurple, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Apply button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Jump to "How to Apply" tab
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: const Text('Start Application',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.royalPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reusable Widgets ───────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Color color = AppTheme.royalPurple,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _subsidyPercentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.royalGold,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.currency_rupee, size: 14, color: Colors.white),
          Text(
            '${s.subsidyPercentage}% Subsidy',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return InkWell(
      onTap: () {
        if (value.startsWith('http')) {
          _launchUrl(value);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.teal.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          TextStyle(fontSize: 10, color: Colors.teal.shade600)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: value.startsWith('http')
                          ? Colors.blue.shade700
                          : Colors.black87,
                      decoration: value.startsWith('http')
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (value.startsWith('http'))
              Icon(Icons.open_in_new, size: 16, color: Colors.teal.shade400),
          ],
        ),
      ),
    );
  }

  Widget _noteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, size: 16, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12, color: Colors.red.shade800, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────

  bool _isDeadlineSoon(String deadline) {
    try {
      final parts = deadline.split('-');
      if (parts.length == 3) {
        final deadlineDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final daysUntil = deadlineDate.difference(DateTime.now()).inDays;
        return daysUntil <= 90 && daysUntil > 0;
      }
    } catch (_) {}
    return false;
  }

  String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  void _launchUrl(String url) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No link available')),
        );
      }
      return;
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}

// ─── Step Data Model ──────────────────────────────────────────
class _ApplicationStep {
  final String title;
  final String description;
  final IconData icon;
  final String tip;

  const _ApplicationStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.tip,
  });
}
