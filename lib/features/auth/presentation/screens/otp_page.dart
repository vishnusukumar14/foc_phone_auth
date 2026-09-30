import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/phone_auth_provider.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showMessage('Enter the 6-digit OTP.');
      return;
    }

    await ref.read(phoneAuthProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    final state = ref.read(phoneAuthProvider);

    if (state.errorMessage != null) {
      _showMessage(state.errorMessage!);
    }
  }

  Future<void> resendOtp() async {
    await ref.read(phoneAuthProvider.notifier).resendOtp();
    if (!mounted) return;

    final state = ref.read(phoneAuthProvider);

    if (state.errorMessage != null) {
      _showMessage(state.errorMessage!);
    } else {
      _showMessage("OTP sent again");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phoneAuthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the 6-digit code sent to '
                '${state.phoneNumber ?? 'your phone'}.',
              ),

              const SizedBox(height: 32),

              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
              ),
              TextButton(
                onPressed: state.isLoading ? null : resendOtp,
                child: const Text('Resend OTP'),
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
