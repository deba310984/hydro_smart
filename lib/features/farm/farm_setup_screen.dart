import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydro_smart/core/constants/app_constants.dart';
import 'package:hydro_smart/core/utils/validators.dart';
import 'package:hydro_smart/core/services/error_handler.dart';
import 'package:hydro_smart/data/models/farm_model.dart';
import 'package:hydro_smart/features/auth/auth_controller.dart';
import 'package:hydro_smart/features/farm/farm_controller.dart';

class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  late List<String> _cropTypes;

  @override
  void initState() {
    super.initState();
    _cropTypes = [
      'Lettuce',
      'Tomato',
      'Cucumber',
      'Spinach',
      'Basil',
      'Peppers',
      'Strawberry',
      'Mint',
    ];
    _initializeController();
  }

  /// Initialize farm controller for current user
  void _initializeController() {
    final authState = ref.read(authStateProvider);
    authState.whenData((user) {
      if (user != null) {
        final controller = ref.read(farmControllerProvider(user.uid).notifier);
        controller.loadFarms();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return authState.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Farm Setup')),
            body: const Center(child: Text('Please log in to manage farms')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Farm Management'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: _buildFarmContent(context, user.uid, isMobile),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFarmDialog(context, user.uid),
            icon: const Icon(Icons.add),
            label: const Text('New Farm'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Farm Setup')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Farm Setup')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  /// Build main content area
  Widget _buildFarmContent(BuildContext context, String userId, bool isMobile) {
    final farmState = ref.watch(farmControllerProvider(userId));

    if (farmState.isLoading && farmState.farms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (farmState.error != null && farmState.farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading farms',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              farmState.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (farmState.farms.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, farmState.farms.length),
          const SizedBox(height: 24),
          isMobile
              ? _buildMobileList(context, farmState.farms, userId)
              : _buildDesktopGrid(context, farmState.farms, userId),
        ],
      ),
    );
  }

  /// Build header with farm count
  Widget _buildHeader(BuildContext context, int farmCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('🌾', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Farms',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$farmCount farm${farmCount != 1 ? 's' : ''} active',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build mobile list layout
  Widget _buildMobileList(
    BuildContext context,
    List<FarmModel> farms,
    String userId,
  ) {
    return Column(
      spacing: 12,
      children:
          farms.map((farm) => _buildFarmCard(context, farm, userId)).toList(),
    );
  }

  /// Build desktop grid layout
  Widget _buildDesktopGrid(
    BuildContext context,
    List<FarmModel> farms,
    String userId,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: farms.length,
      itemBuilder: (context, index) {
        return _buildFarmCard(context, farms[index], userId);
      },
    );
  }

  /// Build individual farm card
  Widget _buildFarmCard(BuildContext context, FarmModel farm, String userId) {
    return Material(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.withOpacity(0.1),
              Colors.green.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: name + menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    farm.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showFarmDialog(context, userId, farm: farm);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, farm, userId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details
            _buildDetailRow(context, Icons.location_on, farm.location),
            const SizedBox(height: 8),
            _buildDetailRow(context, Icons.grass, farm.cropType),
            const SizedBox(height: 8),
            _buildDetailRow(context, Icons.straighten, '${farm.area} m²'),
            const SizedBox(height: 12),

            // Device ID badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Device: ${farm.deviceId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row for farm card
  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Farms Yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first farm to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final authState = ref.read(authStateProvider);
              authState.whenData((user) {
                if (user != null) {
                  _showFarmDialog(context, user.uid);
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Farm'),
          ),
        ],
      ),
    );
  }

  /// Show farm creation/edit dialog
  void _showFarmDialog(BuildContext context, String userId, {FarmModel? farm}) {
    showDialog(
      context: context,
      builder: (context) =>
          _FarmFormDialog(userId: userId, farm: farm, cropTypes: _cropTypes),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(
    BuildContext context,
    FarmModel farm,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Farm?'),
        content: Text(
          'Are you sure you want to delete "${farm.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteFarm(farm.id, userId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete farm with error handling
  void _deleteFarm(String farmId, String userId) async {
    try {
      final controller = ref.read(farmControllerProvider(userId).notifier);
      await controller.deleteFarm(farmId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
    }
  }
}

/// Farm form dialog for create/edit
class _FarmFormDialog extends ConsumerStatefulWidget {
  final String userId;
  final FarmModel? farm;
  final List<String> cropTypes;

  const _FarmFormDialog({
    required this.userId,
    this.farm,
    required this.cropTypes,
  });

  @override
  ConsumerState<_FarmFormDialog> createState() => _FarmFormDialogState();
}

class _FarmFormDialogState extends ConsumerState<_FarmFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _deviceIdController;
  late TextEditingController _areaController;
  late String _selectedCropType;
  late GlobalKey<FormState> _formKey;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.farm?.name ?? '');
    _locationController = TextEditingController(
      text: widget.farm?.location ?? '',
    );
    _deviceIdController = TextEditingController(
      text: widget.farm?.deviceId ?? 'device1',
    );
    _areaController = TextEditingController(
      text: widget.farm?.area.toString() ?? '',
    );
    _selectedCropType = widget.farm?.cropType ?? 'Lettuce';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _deviceIdController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.farm != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Farm' : 'Create New Farm'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Farm name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Farm Name',
                  hintText: 'e.g., North Greenhouse',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Farm name is required';
                  }
                  if (value!.length < 2) {
                    return 'Farm name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Building A, Room 101',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Crop type dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCropType,
                decoration: InputDecoration(
                  labelText: 'Crop Type',
                  prefixIcon: const Icon(Icons.grass),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: widget.cropTypes
                    .map(
                      (crop) =>
                          DropdownMenuItem(value: crop, child: Text(crop)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCropType = value ?? 'Lettuce');
                },
              ),
              const SizedBox(height: 16),

              // Area
              TextFormField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Area (m²)',
                  hintText: 'e.g., 50',
                  prefixIcon: const Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Area is required';
                  }
                  final area = double.tryParse(value!);
                  if (area == null || area <= 0) {
                    return 'Enter a valid area greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Device ID
              TextFormField(
                controller: _deviceIdController,
                decoration: InputDecoration(
                  labelText: 'Device ID',
                  hintText: 'e.g., device1',
                  prefixIcon: const Icon(Icons.devices),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Device ID is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  /// Submit form
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(
        farmControllerProvider(widget.userId).notifier,
      );
      final area = double.parse(_areaController.text);

      if (widget.farm != null) {
        // Update existing farm
        await controller.updateFarm(
          farmId: widget.farm!.id,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          deviceId: _deviceIdController.text.trim(),
          area: area,
          cropType: _selectedCropType,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Create new farm
        await controller.createFarm(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
          deviceId: _deviceIdController.text.trim(),
          area: area,
          cropType: _selectedCropType,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackbar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
