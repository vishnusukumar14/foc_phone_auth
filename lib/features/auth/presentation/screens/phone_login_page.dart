import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foc_phone_auth/features/auth/presentation/providers/phone_auth_provider.dart';

import 'otp_page.dart';

class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final mobile = _phoneController.text.trim();

    if (mobile.length != 10) {
      _showMessage("Enter a valid 10-digit mobile number");
      return;
    }

    final phoneNumber = "+91$mobile";
    await ref
        .read(phoneAuthProvider.notifier)
        .sentOtp(phoneNumber: phoneNumber);

    if (!mounted) return;
    final state = ref.read(phoneAuthProvider);

    if (state.isCodeSent) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpPage()),
      );
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                "Welcome",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your mobile number to continue ",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  prefixText: "+91",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.isLoading ? null : _sendOtp,
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Send OTP"),
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(state.errorMessage!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
