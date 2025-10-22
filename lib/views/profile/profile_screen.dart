import 'package:community/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/profile/profile_viewmodel.dart';
import 'widgets/default_cover_photo.dart';
import 'widgets/profile_action_button.dart';
import 'widgets/editable_unit_number.dart';
import 'widgets/editable_bio.dart';
import 'user_permissions_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentAppUserProvider);

    return Scaffold(
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Cover Photo and App Bar
                  SliverAppBar(
                    expandedHeight: 140,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cover Photo
                          user.coverPhotoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: user.coverPhotoUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => const DefaultCoverPhoto(),
                                )
                              : const DefaultCoverPhoto(),
                          // Gradient overlay (non-interactive)
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          // Tap detector layer on top
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showCoverPhotoOptions(context, ref, user.id),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          ref.read(authViewModelProvider.notifier).signOut();
                        },
                      ),
                    ],
                  ),

                  // Profile Content with padding for profile photo
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            user.name,
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Unit Number
                        EditableUnitNumber(
                          unitNumber: user.unitNumber,
                          onSave: (unitNumber) =>
                              ref.read(profileViewModelProvider.notifier).updateUnitNumber(user.id, unitNumber),
                        ),

                        // Bio
                        EditableBio(
                          bio: user.bio,
                          onSave: (bio) => ref.read(profileViewModelProvider.notifier).updateBio(user.id, bio),
                        ),

                        // Settings Cards
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: AppColors.surface,
                          child: ListTile(
                            title: const Text('Notification Settings'),
                            trailing: const Icon(Icons.notifications_outlined),
                            onTap: () => Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (context) => const UserPermissionsScreen())),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
              // Profile Photo - positioned absolutely on top
              Positioned(
                top: 148,
                right: 20,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showProfilePhotoOptions(context, ref, user.id),
                      customBorder: const CircleBorder(),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null
                                  ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showProfilePhotoOptions(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ref.read(profileViewModelProvider.notifier).updateProfilePhoto(userId, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ref.read(profileViewModelProvider.notifier).updateProfilePhoto(userId, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCoverPhotoOptions(BuildContext context, WidgetRef ref, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ref.read(profileViewModelProvider.notifier).updateCoverPhoto(userId, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ref.read(profileViewModelProvider.notifier).updateCoverPhoto(userId, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
