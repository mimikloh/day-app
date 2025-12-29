import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;

  // Отправка SMS
  Future<void> sendCode({
    required String phoneNumber,
    required Function(String error) onError,
    required Function() onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Автовход (Android)
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Ошибка');
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  //Подтверждение SMS-кода
  Future<User?> verifyCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('verificationId is null');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    final userCredential =
    await _auth.signInWithCredential(credential);

    return userCredential.user;
  }
}
