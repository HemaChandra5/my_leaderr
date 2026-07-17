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
  State<LeaderVerificationScreen> createState() {
    return _LeaderVerificationScreenState();
  }
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
  void initState() {
    super.initState();
    _prefillSampleDetails();
  }

  void _prefillSampleDetails() {
    final sampleDetails = <String, String>{
      'name': 'Aarav Sharma',
      'designation': 'State Youth President',
      'party': 'National Progressive Party',
      'constituency': 'North District Constituency',
      'officeAddress': '12, Gulmohar Lane, New Town, Delhi',
      'email': 'aarav.sharma@leaderr.in',
      'phone': '+91 98765 43210',
      'bio':
          'Community organizer, youth mentor, and civic policy advocate focused on education and public service.',
      'yearsInService': '12',
      'password': 'Sample@1234',
    };

    for (final entry in sampleDetails.entries) {
      _controllers[entry.key]?.text = entry.value;
    }

    _confirmed = true;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile(ValueSetter<File> setter) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setter(File(picked.path));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please confirm the details are accurate"),
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
        governmentIdPath: _governmentId?.path ?? '',
        officeAddress: _controllers['officeAddress']!.text.trim(),
        officialEmail: _controllers['email']!.text.trim(),
        officialPhone: _controllers['phone']!.text.trim(),
        shortBio: _controllers['bio']!.text.trim(),
        yearsInService: _controllers['yearsInService']!.text.trim(),
        password: _controllers['password']!.text,
        profilePhoto: _profilePhoto,
        coverImage: _coverImage,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LeaderProfileScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Auth failed')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  /// ✅ GOLD FIELD
  Widget _goldField(
    String key,
    String hint, {
    int maxLines = 1,
    IconData icon = Icons.person,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _controllers[key],
              maxLines: maxLines,
              obscureText: key == 'password',
              style: TextStyle(color: AppColors.textPrimary),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? "Required" : null,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.textMuted),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ GOLD FILE PICKER
  Widget _goldPicker(String title, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGold, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(Icons.upload_file, color: AppColors.primaryGold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file == null
                    ? "$title (Tap to upload)"
                    : file.path.split('/').last,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<UserProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leader Verification",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Please provide your official details",
                  style: TextStyle(color: AppColors.textMuted),
                ),

                const SizedBox(height: 30),

                _goldField('name', 'Full Name', icon: Icons.person_outline),
                _goldField(
                  'designation',
                  'Official Designation',
                  icon: Icons.work_outline,
                ),
                _goldField(
                  'party',
                  'Political Party',
                  icon: Icons.flag_outlined,
                ),
                _goldField(
                  'constituency',
                  'Constituency',
                  icon: Icons.location_on_outlined,
                ),
                _goldField(
                  'officeAddress',
                  'Office Address',
                  maxLines: 2,
                  icon: Icons.home_work_outlined,
                ),
                _goldField(
                  'email',
                  'Official Email',
                  icon: Icons.email_outlined,
                ),
                _goldField(
                  'phone',
                  'Official Phone',
                  icon: Icons.phone_outlined,
                ),
                _goldField(
                  'bio',
                  'Short Bio',
                  maxLines: 3,
                  icon: Icons.description_outlined,
                ),
                _goldField(
                  'yearsInService',
                  'Years in Service',
                  icon: Icons.calendar_today_outlined,
                ),
                _goldField('password', 'Password', icon: Icons.lock_outline),

                _goldPicker(
                  "Government ID Upload",
                  _governmentId,
                  () => _pickFile((f) => setState(() => _governmentId = f)),
                ),

                _goldPicker(
                  "Profile Photo",
                  _profilePhoto,
                  () => _pickFile((f) => setState(() => _profilePhoto = f)),
                ),

                _goldPicker(
                  "Cover Image",
                  _coverImage,
                  () => _pickFile((f) => setState(() => _coverImage = f)),
                ),

                Row(
                  children: [
                    Checkbox(
                      value: _confirmed,
                      activeColor: AppColors.primaryGold,
                      onChanged: (v) => setState(() => _confirmed = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        "I confirm details are accurate",
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.onGold,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: loading
                        ? CircularProgressIndicator(color: AppColors.onGold)
                        : const Text(
                            "Submit for Verification",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
