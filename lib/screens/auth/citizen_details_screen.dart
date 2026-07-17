import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../features/profile/presentation/pages/profile_dashboard_gate.dart';

class CitizenDetailsScreen extends StatefulWidget {
  const CitizenDetailsScreen({super.key});

  @override
  State<CitizenDetailsScreen> createState() =>
      _CitizenDetailsScreenState();
}

class _CitizenDetailsScreenState
    extends State<CitizenDetailsScreen> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController =
      TextEditingController();

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
    final picked =
        await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) return;
    setState(() =>
        _profileImage = File(picked.path));
  }

  Future<String?> _askOtpCode() async {
    final controller =
        TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text("Enter OTP",
        style:
          TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType:
              TextInputType.number,
        style: TextStyle(
          color: AppColors.textPrimary),
        decoration: InputDecoration(
            hintText: "6-digit code",
        hintStyle: TextStyle(
          color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
        child: Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton
                .styleFrom(
              backgroundColor:
            AppColors.primaryGold,
              foregroundColor:
            AppColors.onGold,
            ),
            onPressed: () =>
                Navigator.pop(
                    context,
                    controller.text
                        .trim()),
            child:
                const Text("Verify"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
        context.read<UserProvider>();

    try {
      final phone =
          _phoneController.text.trim();
      final digitsOnly = phone
        .replaceAll(RegExp(r'\D'), '');
      final normalized =
        digitsOnly.startsWith('91') &&
            digitsOnly.length > 10
          ? '+$digitsOnly'
          : '+91$digitsOnly';

      final verificationId =
          await provider
              .sendCitizenOtp(
                  normalized);

      final otp =
          await _askOtpCode();

      if (otp == null ||
          otp.isEmpty) {
        return;
      }

      await provider
          .completeCitizenOnboarding(
        name:
            _nameController.text.trim(),
        phone: normalized,
        email: _emailController
                .text
                .trim()
                .isEmpty
            ? null
            : _emailController.text
                .trim(),
        city:
            _cityController.text.trim(),
        state:
            _stateController.text
                .trim(),
        profileImageFile:
            _profileImage,
        verificationId:
            verificationId,
        otpCode: otp,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) =>
                const ProfileDashboardGate()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  /// ✅ GOLD BORDER FIELD
  Widget _goldField({
    required IconData icon,
    required String hint,
    required TextEditingController
        controller,
    bool obscure = false,
    TextInputType keyboard =
        TextInputType.text,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),
      padding:
          const EdgeInsets.symmetric(
              horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: AppColors.primaryGold),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              obscureText: obscure,
              style: TextStyle(
                  color: AppColors.textPrimary),
              validator: (v) {
                if (hint ==
                    "Email (Optional)") {
                  return null;
                }
                if (v == null ||
                    v.isEmpty) {
                  return "Required";
                }
                if (hint ==
                        "Phone Number" &&
                    v.length < 10) {
                  return "Invalid phone";
                }
                if (hint ==
                        "Password" &&
                    v.length < 6) {
                  return "Min 6 chars";
                }
                return null;
              },
              decoration:
                  InputDecoration(
                hintText: hint,
                hintStyle:
                  TextStyle(
                    color: AppColors.textMuted),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding:
                  const EdgeInsets.symmetric(
                    vertical: 16),
                border:
                    InputBorder.none,
                enabledBorder:
                  InputBorder.none,
                focusedBorder:
                  InputBorder.none,
                disabledBorder:
                  InputBorder.none,
                errorBorder:
                  InputBorder.none,
                focusedErrorBorder:
                  InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        context.watch<UserProvider>()
            .isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Citizen Verification",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 6),

                Text(
                  "Please provide your official details",
                  style: TextStyle(
                    color: AppColors.textMuted),
                ),

                const SizedBox(
                    height: 30),

                /// ✅ Gold Circular Border Profile
                Center(
                  child:
                      GestureDetector(
                    onTap:
                        _pickImage,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .all(3),
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape
                            .circle,
                        border:
                            Border.fromBorderSide(
                          BorderSide(
                              color: Color(
                                  0xFFD4AF37),
                              width: 2),
                        ),
                      ),
                      child:
                          CircleAvatar(
                        radius: 46,
                        backgroundColor:
                          AppColors.surface,
                        backgroundImage:
                            _profileImage ==
                                    null
                                ? null
                                : FileImage(
                                    _profileImage!),
                        child:
                          _profileImage == null
                            ? Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryGold,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 30),

                _goldField(
                    icon: Icons
                        .person_outline,
                    hint: "Full Name",
                    controller:
                        _nameController),

                _goldField(
                    icon: Icons
                        .phone_outlined,
                    hint:
                        "Phone Number",
                    controller:
                        _phoneController,
                    keyboard:
                        TextInputType
                            .phone),

                _goldField(
                    icon:
                        Icons.email_outlined,
                    hint:
                        "Email (Optional)",
                    controller:
                        _emailController),

                _goldField(
                    icon: Icons
                        .location_city,
                    hint: "City",
                    controller:
                        _cityController),

                _goldField(
                    icon:
                        Icons.map_outlined,
                    hint: "State",
                    controller:
                        _stateController),

                _goldField(
                    icon:
                        Icons.lock_outline,
                    hint: "Password",
                    controller:
                        _passwordController,
                    obscure: true),

                const SizedBox(
                    height: 30),

                /// ✅ Gold Button
                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton(
                    onPressed:
                        loading
                            ? null
                            : _submit,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          AppColors.primaryGold,
                      foregroundColor:
                          AppColors.onGold,
                      padding:
                          const EdgeInsets
                              .symmetric(
                                  vertical:
                                      18),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                                    22),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                          color: AppColors.onGold)
                        : const Text(
                            "Submit for Verification",
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                Center(
                  child: Text(
                    "Your information is secure and encrypted",
                    style: TextStyle(
                        color: AppColors.textMuted),
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