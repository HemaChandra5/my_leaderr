import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../models/app_user.dart';
import '../../../../providers/user_provider.dart';
import '../../../../theme.dart';
import '../widgets/bottom_nav_bar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const String _homeRoute = '/home';
  static const String _eventsRoute = '/events';
  static const String _trackRoute = '/track';
  static const String _communityRoute = '/community';

  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _bio = TextEditingController();

  final _designation = TextEditingController();
  final _party = TextEditingController();
  final _constituency = TextEditingController();
  final _officeAddress = TextEditingController();
  final _yearsInService = TextEditingController();

  final _city = TextEditingController();
  final _state = TextEditingController();

  File? _pickedProfileImage;
  File? _pickedCoverImage;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _bio.dispose();
    _designation.dispose();
    _party.dispose();
    _constituency.dispose();
    _officeAddress.dispose();
    _yearsInService.dispose();
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  void _onBottomTabTap(int index) {
    if (index == 4) {
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(_homeRoute);
      return;
    }

    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(_trackRoute);
      return;
    }

    if (index == 2) {
      Navigator.of(context).pushReplacementNamed(_communityRoute);
      return;
    }

    if (index == 3) {
      Navigator.of(context).pushReplacementNamed(_eventsRoute);
    }
  }

  void _prefill(AppUser user) {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _name.text = user.name;
    _phone.text = user.phone ?? '';
    _email.text = user.email ?? '';
    _bio.text = user.bio ?? '';

    _designation.text = user.designation ?? '';
    _party.text = user.party ?? '';
    _constituency.text = user.constituency ?? '';
    _officeAddress.text = user.officeAddress ?? '';
    _yearsInService.text = user.yearsInService ?? '';

    _city.text = user.city ?? '';
    _state.text = user.state ?? '';
  }

  Future<void> _pickImage({required bool isCover}) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() {
      if (isCover) {
        _pickedCoverImage = File(picked.path);
      } else {
        _pickedProfileImage = File(picked.path);
      }
    });
  }

  Future<void> _save(AppUser user) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final fields = <String, String>{
      'name': _name.text,
      'phone': _phone.text,
      'email': _email.text,
      'bio': _bio.text,
    };

    if (user.isLeader) {
      fields.addAll({
        'designation': _designation.text,
        'party': _party.text,
        'constituency': _constituency.text,
        'officeAddress': _officeAddress.text,
        'yearsInService': _yearsInService.text,
      });
    } else {
      fields.addAll({'city': _city.text, 'state': _state.text});
    }

    try {
      await context.read<UserProvider>().updateCurrentUserProfile(
        fields: fields,
        profileImageFile: _pickedProfileImage,
        coverImageFile: user.isLeader ? _pickedCoverImage : null,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppTheme.textPrimary),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.gold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final user = provider.appUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
      );
    }

    _prefill(user);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ImagePickerCard(
              title: 'Profile Photo',
              imagePath: _pickedProfileImage?.path,
              networkImage: user.profileImage,
              fallbackAsset: 'assets/images/avatar1.png',
              onTap: () => _pickImage(isCover: false),
            ),
            if (user.isLeader) ...[
              const SizedBox(height: 12),
              _ImagePickerCard(
                title: 'Cover Image',
                imagePath: _pickedCoverImage?.path,
                networkImage: user.coverImage,
                fallbackAsset: 'assets/images/cover.jpg',
                onTap: () => _pickImage(isCover: true),
                height: 130,
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Basic Details',
              style: TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            _field('Full Name', _name, required: true),
            _field('Phone', _phone, keyboardType: TextInputType.phone),
            _field('Email', _email, keyboardType: TextInputType.emailAddress),
            _field('Bio', _bio, maxLines: 3),
            const SizedBox(height: 6),
            Text(
              user.isLeader ? 'Leader Details' : 'Citizen Details',
              style: const TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            if (user.isLeader) ...[
              _field('Designation', _designation, required: true),
              _field('Party', _party, required: true),
              _field('Constituency', _constituency, required: true),
              _field('Office Address', _officeAddress, maxLines: 2),
              _field(
                'Years in Service',
                _yearsInService,
                keyboardType: TextInputType.number,
              ),
            ] else ...[
              _field('City', _city),
              _field('State', _state),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : () => _save(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBarWidget(onTabTap: _onBottomTabTap),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.title,
    required this.onTap,
    required this.fallbackAsset,
    this.imagePath,
    this.networkImage,
    this.height = 80,
  });

  final String title;
  final VoidCallback onTap;
  final String fallbackAsset;
  final String? imagePath;
  final String? networkImage;
  final double height;

  @override
  Widget build(BuildContext context) {
    ImageProvider image;
    if ((imagePath ?? '').isNotEmpty) {
      image = FileImage(File(imagePath!));
    } else if ((networkImage ?? '').isNotEmpty) {
      image = NetworkImage(networkImage!);
    } else {
      image = AssetImage(fallbackAsset);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            height: height,
            width: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap to change image',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.edit_rounded, color: AppTheme.gold),
          ),
        ],
      ),
    );
  }
}
