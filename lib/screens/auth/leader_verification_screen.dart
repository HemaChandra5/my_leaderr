import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../leader/leader_profile_screen.dart';

class LeaderVerificationScreen extends StatefulWidget {
  const LeaderVerificationScreen({super.key});

  @override
  State<LeaderVerificationScreen> createState() =>
      _LeaderVerificationScreenState();
}

class _LeaderVerificationScreenState extends State<LeaderVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'designation': TextEditingController(),
    'party': TextEditingController(),
    'constituency': TextEditingController(),
    'officeAddress': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'bio': TextEditingController(),
    'yearsInService': TextEditingController(),
    'password': TextEditingController(),
  };

  bool _confirmed = false;
  File? _governmentId;
  File? _profilePhoto;
  File? _coverImage;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile(ValueSetter<File> setter) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return;
    }
    setter(File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_governmentId == null ||
        _profilePhoto == null ||
        _coverImage == null ||
        !_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All images and confirmation are required'),
        ),
      );
      return;
    }

    final provider = context.read<UserProvider>();
    try {
      await provider.completeLeaderOnboarding(
        fullName: _controllers['name']!.text.trim(),
        designation: _controllers['designation']!.text.trim(),
        party: _controllers['party']!.text.trim(),
        constituency: _controllers['constituency']!.text.trim(),
        governmentIdPath: _governmentId!.path,
        officeAddress: _controllers['officeAddress']!.text.trim(),
        officialEmail: _controllers['email']!.text.trim(),
        officialPhone: _controllers['phone']!.text.trim(),
        shortBio: _controllers['bio']!.text.trim(),
        yearsInService: _controllers['yearsInService']!.text.trim(),
        password: _controllers['password']!.text,
        profilePhoto: _profilePhoto!,
        coverImage: _coverImage!,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Success',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Profile submitted for verification',
            style: TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LeaderProfileScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth failed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.primaryGold),
      floatingLabelStyle: TextStyle(color: AppColors.primaryGold),
      hintStyle: TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryGold, width: 1.2),
      ),
    );
  }

  Widget _requiredField(String key, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: _controllers[key],
        maxLines: maxLines,
        obscureText: key == 'password',
        style: TextStyle(color: AppColors.textPrimary),
        cursorColor: AppColors.primaryGold,
        decoration: _decor(label),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _pickerTile(String title, File? file, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.surface,
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(
        file == null ? 'Tap to upload (required)' : file.path.split('\\').last,
        style: TextStyle(color: AppColors.textMuted),
      ),
      trailing: Icon(Icons.upload_file_rounded, color: AppColors.primaryGold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Leader Verification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _requiredField('name', 'Full Name'),
              _requiredField('designation', 'Official Designation'),
              _requiredField('party', 'Political Party'),
              _requiredField('constituency', 'Constituency'),
              _requiredField('officeAddress', 'Office Address', maxLines: 2),
              _requiredField('email', 'Official Email'),
              _requiredField('phone', 'Official Phone'),
              _requiredField('bio', 'Short Bio', maxLines: 3),
              _requiredField('yearsInService', 'Years in Service'),
              _requiredField('password', 'Password'),
              _pickerTile(
                'Government ID Upload',
                _governmentId,
                () => _pickFile((f) => setState(() => _governmentId = f)),
              ),
              const SizedBox(height: 8),
              _pickerTile(
                'Profile Photo',
                _profilePhoto,
                () => _pickFile((f) => setState(() => _profilePhoto = f)),
              ),
              const SizedBox(height: 8),
              _pickerTile(
                'Cover Image',
                _coverImage,
                () => _pickFile((f) => setState(() => _coverImage = f)),
              ),
              CheckboxListTile(
                value: _confirmed,
                onChanged: (v) => setState(() => _confirmed = v ?? false),
                title: Text(
                  'I confirm details are accurate',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                activeColor: AppColors.primaryGold,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
