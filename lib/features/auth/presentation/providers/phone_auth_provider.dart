import 'package:firebase_auth/firebase_auth.dart';
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
      verificationCompleted: (cred) async {
        try {
          await repo.signInWithCredentials(cred);

          state = state.copyWith(isLoading: false);
        } on FirebaseAuthException catch (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.message);
        }
      },
      verificationFailed: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
      codeSent: (verificationId, resendToken) {
        state = state.copyWith(
          verificationId: verificationId,
          resendToken: resendToken,
          isLoading: false,
          isCodeSent: true,
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        state = state.copyWith(verificationId: verificationId);
      },
    );
  }

  Future<void> verifyOtp(String otp) async {
    final verfId = state.verificationId;

    if (verfId == null) {
      state = state.copyWith(errorMessage: "Verification session expired!");
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verfId,
        smsCode: otp,
      );
      await ref.read(authRepositoryProvider).signInWithCredentials(cred);

      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    }
  }

  Future<void> resendOtp() async {
    final phno = state.phoneNumber;

    if (phno == null) {
      return;
    }

    final repo = ref.read(authRepositoryProvider);

    await repo.verifyPhoneNumber(
      phoneNumber: phno,
      verificationCompleted: (cred) async {
        try {
          await repo.signInWithCredentials(cred);
        } catch (_) {}
      },
      verificationFailed: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
      codeSent: (verificationId, resendToken) {
        state = state.copyWith(
          verificationId: verificationId,
          resendToken: resendToken,
          isLoading: false,
          isCodeSent: true,
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        state = state.copyWith(verificationId: verificationId);
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const PhoneAuthState();
  }
}
