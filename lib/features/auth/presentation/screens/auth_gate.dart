import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foc_phone_auth/features/auth/presentation/providers/auth_provider.dart';
import 'package:foc_phone_auth/features/auth/presentation/screens/phone_login_page.dart';

import 'home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const PhoneLoginPage();
        }

        return HomePage();
      },
      error: (error, st) {
        return Scaffold(
          body: Center(child: Text("Authentication init failed ${error}")),
        );
      },
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
