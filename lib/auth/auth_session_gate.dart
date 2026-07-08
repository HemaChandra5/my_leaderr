import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../features/welcome/presentation/pages/welcome_page.dart';
import 'auth_controller.dart';

class AuthSessionGate extends StatefulWidget {
  const AuthSessionGate({super.key});

  @override
  State<AuthSessionGate> createState() => _AuthSessionGateState();
}

class _AuthSessionGateState extends State<AuthSessionGate> {
  late final AuthController _controller;
  late final Future<bool> _restoreSessionFuture;

  @override
  void initState() {
    super.initState();
    _controller = AuthController();
    _restoreSessionFuture = _controller.restoreSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _restoreSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF5A623)),
            ),
          );
        }

        final isAuthenticated = snapshot.data ?? false;
        if (isAuthenticated) {
          return const HomePage();
        }

        return const WelcomePage();
      },
    );
  }
}
