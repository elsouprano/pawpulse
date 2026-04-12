// ─────────────────────────────────────────────────────────
// PawPulse — Test UI
// ⚠️ Test screen only — not production UI.
// Replace with your own designed widgets when ready.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({Key? key}) : super(key: key);

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider(AuthService());
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Auth')),
      body: ValueListenableBuilder<AuthState>(
        valueListenable: _authProvider,
        builder: (context, state, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isLoading) const CircularProgressIndicator(),
                if (state.error != null) Text(state.error!, style: const TextStyle(color: Colors.red)),
                Text('Current User: ${state.currentUser?.uid ?? "Not logged in"}'),
                Text('Email: ${state.currentUser?.email ?? ""}'),
                const SizedBox(height: 20),
                TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Password')),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name (for Registration)')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _authProvider.register(_emailCtrl.text, _passwordCtrl.text),
                  child: const Text('Register'),
                ),
                ElevatedButton(
                  onPressed: () => _authProvider.login(_emailCtrl.text, _passwordCtrl.text),
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () => _authProvider.logout(),
                  child: const Text('Logout'),
                ),
                ElevatedButton(
                  onPressed: () => _authProvider.resetPassword(_emailCtrl.text),
                  child: const Text('Reset Password'),
                ),
                ElevatedButton(
                  onPressed: () => AuthService().deleteAccount(),
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
