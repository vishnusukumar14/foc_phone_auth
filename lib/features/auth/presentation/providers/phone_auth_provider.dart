import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foc_phone_auth/features/auth/presentation/providers/auth_provider.dart';

final phoneAuthProvider = NotifierProvider<PhoneAuthNotifier, PhoneAuthState>(
  PhoneAuthNotifier.new,
);

class PhoneAuthState {
  const PhoneAuthState({
    this.phoneNumber,
    this.verificationId,
    this.resendToken,
    this.isLoading = false,
    this.isCodeSent = false,
    this.errorMessage,
  });

  final String? phoneNumber;
  final String? verificationId;
  final int? resendToken;

  final bool isLoading;
  final bool isCodeSent;

  final String? errorMessage;

  PhoneAuthState copyWith({
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    bool? isLoading,
    bool? isCodeSent,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PhoneAuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PhoneAuthNotifier extends Notifier<PhoneAuthState> {
  @override
  PhoneAuthState build() {
    return const PhoneAuthState();
  }

  Future<void> sentOtp({required String phoneNumber}) async {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      isLoading: true,
      isCodeSent: false,
      clearError: false,
    );

    final repo = ref.read(authRepositoryProvider);

    await repo.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (cred) async {},
      verificationFailed: (error) {},
      codeSent: (verificationId, resendToken) {},
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }
}
