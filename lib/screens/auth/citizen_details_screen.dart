import 'dart:io';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
        backgroundColor:
            const Color(0xFF111111),
        title: const Text("Enter OTP",
            style:
                TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType:
              TextInputType.number,
          style: const TextStyle(
              color: Colors.white),
          decoration: const InputDecoration(
            hintText: "6-digit code",
            hintStyle: TextStyle(
                color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton
                .styleFrom(
              backgroundColor:
                  const Color(0xFFF5A623),
              foregroundColor:
                  Colors.black,
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
        .validate()) return;

    final provider =
        context.read<UserProvider>();

    try {
      final phone =
          _phoneController.text.trim();
      final normalized =
          phone.startsWith('+')
              ? phone
              : '+91$phone';

      final verificationId =
          await provider
              .sendCitizenOtp(
                  normalized);

      final otp =
          await _askOtpCode();

      if (otp == null ||
          otp.isEmpty) return;

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
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFD4AF37),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color:
                  const Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboard,
              obscureText: obscure,
              style: const TextStyle(
                  color: Colors.white),
              validator: (v) {
                if (hint ==
                    "Email (Optional)")
                  return null;
                if (v == null ||
                    v.isEmpty)
                  return "Required";
                if (hint ==
                        "Phone Number" &&
                    v.length < 10)
                  return "Invalid phone";
                if (hint ==
                        "Password" &&
                    v.length < 6)
                  return "Min 6 chars";
                return null;
              },
              decoration:
                  InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(
                        color: Colors
                            .white38),
                border:
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
      backgroundColor: Colors.black,
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

                const Text(
                  "Citizen Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 6),

                const Text(
                  "Please provide your official details",
                  style: TextStyle(
                      color:
                          Colors.white54),
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
                            Colors.black,
                        backgroundImage:
                            _profileImage ==
                                    null
                                ? null
                                : FileImage(
                                    _profileImage!),
                        child:
                            _profileImage ==
                                    null
                                ? const Icon(
                                    Icons
                                        .camera_alt,
                                    color: Color(
                                        0xFFD4AF37),
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
                          const Color(
                              0xFFD4AF37),
                      foregroundColor:
                          Colors.black,
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
                            color: Colors
                                .black)
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

                const Center(
                  child: Text(
                    "Your information is secure and encrypted",
                    style: TextStyle(
                        color: Colors
                            .white38),
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