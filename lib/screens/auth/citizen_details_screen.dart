import 'dart:io';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../features/profile/presentation/pages/profile_dashboard_gate.dart';

class CitizenDetailsScreen extends StatefulWidget {
  const CitizenDetailsScreen({super.key});

  @override
  State<CitizenDetailsScreen> createState() => _CitizenDetailsScreenState();
}

class _CitizenDetailsScreenState extends State<CitizenDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _profileImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return;
    }
    setState(() => _profileImage = File(picked.path));
  }

  Future<String?> _askOtpCode() async {
    final TextEditingController otpController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Enter OTP',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          style: TextStyle(color: AppColors.textPrimary),
          cursorColor: AppColors.primaryGold,
          decoration: InputDecoration(
            hintText: '6-digit code',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(otpController.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<UserProvider>();
    try {
      final String normalizedPhone = _normalizeIndianPhone(
        _phoneController.text,
      );
      final String verificationId = await provider.sendCitizenOtp(
        normalizedPhone,
      );
      if (!mounted) return;
      final String? otp = await _askOtpCode();
      if (!mounted || otp == null || otp.isEmpty) {
        return;
      }

      await provider.completeCitizenOnboarding(
        name: _nameController.text.trim(),
        phone: normalizedPhone,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        profileImageFile: _profileImage,
        verificationId: verificationId,
        otpCode: otp,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const ProfileDashboardGate()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication error')),
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Request timed out')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  String _normalizeIndianPhone(String rawInput) {
    final String compact = rawInput.replaceAll(RegExp(r'\s+|-'), '');
    if (compact.startsWith('+')) {
      return compact;
    }
    String digitsOnly = compact.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    }
    if (digitsOnly.startsWith('91') && digitsOnly.length > 10) {
      return '+$digitsOnly';
    }
    return '+91$digitsOnly';
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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final loading = userProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Citizen Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.surface,
                  backgroundImage: _profileImage == null
                      ? null
                      : FileImage(_profileImage!),
                  child: _profileImage == null
                      ? Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primaryGold,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('Full Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().length < 10
                    ? 'Enter valid phone'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('Email (Optional)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('City'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stateController,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('State'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: AppColors.textPrimary),
                cursorColor: AppColors.primaryGold,
                decoration: _decor('Password'),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 20),
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
              if (loading) ...[
                const SizedBox(height: 10),
                Text(
                  userProvider.loadingMessage.isEmpty
                      ? 'Please wait...'
                      : userProvider.loadingMessage,
                  style: TextStyle(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
