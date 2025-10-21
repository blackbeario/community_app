import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Screen for creating a new Firebase community project
/// Collects the required fields for the create-community.sh script
class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _communityNameController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _iosBundleIdController = TextEditingController();
  final _androidPackageController = TextEditingController();
  final _adminEmailController = TextEditingController();

  // Auto-generate fields option
  bool _autoGenerateIds = true;

  // Loading state
  bool _isCreating = false;

  @override
  void dispose() {
    _communityNameController.dispose();
    _projectIdController.dispose();
    _iosBundleIdController.dispose();
    _androidPackageController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Community'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 24, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firebase Project Creation',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This will run the create-community.sh script to set up a new Firebase project with iOS/Android apps, Firestore rules, Cloud Functions, and initial groups.',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Community Name (required)
              Text(
                'Community Name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _communityNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Champion Hills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Community name is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_autoGenerateIds) {
                    _updateGeneratedIds(value);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Auto-generate toggle
              Row(
                children: [
                  Checkbox(
                    value: _autoGenerateIds,
                    onChanged: (value) {
                      setState(() {
                        _autoGenerateIds = value ?? true;
                        if (_autoGenerateIds) {
                          _updateGeneratedIds(_communityNameController.text);
                        }
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Auto-generate IDs from community name',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Project ID
              Text(
                'Firebase Project ID',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _projectIdController,
                enabled: !_autoGenerateIds,
                decoration: InputDecoration(
                  hintText: 'e.g., community-champion-hills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: _autoGenerateIds ? AppColors.greyLight : AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project ID is required';
                  }
                  if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                    return 'Only lowercase letters, numbers, and hyphens allowed';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // iOS Bundle ID
              Text(
                'iOS Bundle ID',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _iosBundleIdController,
                enabled: !_autoGenerateIds,
                decoration: InputDecoration(
                  hintText: 'e.g., io.vibesoftware.community.championhills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: _autoGenerateIds ? AppColors.greyLight : AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'iOS Bundle ID is required';
                  }
                  if (!RegExp(r'^[a-z0-9.]+$').hasMatch(value)) {
                    return 'Only lowercase letters, numbers, and periods allowed';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Android Package Name
              Text(
                'Android Package Name',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _androidPackageController,
                enabled: !_autoGenerateIds,
                decoration: InputDecoration(
                  hintText: 'e.g., io.vibesoftware.community.championhills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: _autoGenerateIds ? AppColors.greyLight : AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Android Package Name is required';
                  }
                  if (!RegExp(r'^[a-z0-9.]+$').hasMatch(value)) {
                    return 'Only lowercase letters, numbers, and periods allowed';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Admin Email (optional)
              Text(
                'Admin Email (Optional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'The user must sign up first, then run create-admin.sh',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _adminEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'admin@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Warning card
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber, size: 24, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual Steps Required',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1. You must manually create the Firebase project in the Firebase Console first\n'
                              '2. Enable Blaze (pay-as-you-go) billing plan\n'
                              '3. Then run the script to configure apps and deploy',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          'Create Community',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Script info
              Center(
                child: Text(
                  'This will execute: ./scripts/create-community.sh',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateGeneratedIds(String communityName) {
    if (communityName.isEmpty) {
      _projectIdController.clear();
      _iosBundleIdController.clear();
      _androidPackageController.clear();
      return;
    }

    // Convert to lowercase, replace spaces with hyphens, remove special chars
    final slug = communityName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');

    setState(() {
      _projectIdController.text = 'community-$slug';
      _iosBundleIdController.text = 'io.vibesoftware.community.${slug.replaceAll('-', '')}';
      _androidPackageController.text = 'io.vibesoftware.community.${slug.replaceAll('-', '')}';
    });
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement actual script execution
      // This would need to call the create-community.sh script
      // For now, show the parameters that would be passed

      final params = {
        'communityName': _communityNameController.text.trim(),
        'projectId': _projectIdController.text.trim(),
        'iosBundleId': _iosBundleIdController.text.trim(),
        'androidPackage': _androidPackageController.text.trim(),
        'adminEmail': _adminEmailController.text.trim(),
      };

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create Community'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Script Parameters:'),
              const SizedBox(height: 12),
              ...params.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${e.key}: ${e.value}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              )),
              const SizedBox(height: 16),
              Text(
                'This will run:\n./scripts/create-community.sh "${params['communityName']}"',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: Script execution from Flutter app is not yet implemented. '
                'You can run this command manually in the terminal.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
