import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently authenticated user, or null
  static User? get currentUser => _auth.currentUser;

  /// True if user is logged in
  static bool get isSignedIn => currentUser != null;

  /// Sign in anonymously for instant offline/demo farmer access
  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('FirebaseAuth: anonymous sign in error: $e');
      return null;
    }
  }

  /// Sign in with Email and Password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('FirebaseAuth: email sign in error: $e');
      rethrow;
    }
  }

  /// Register a new Farmer account with Email and Password
  static Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      return cred;
    } catch (e) {
      debugPrint('FirebaseAuth: registration error: $e');
      rethrow;
    }
  }

  /// Send Phone OTP verification code
  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: onVerificationCompleted,
        verificationFailed: onVerificationFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      debugPrint('FirebaseAuth: verifyPhoneNumber error: $e');
      rethrow;
    }
  }

  /// Sign in using Phone OTP SMS code
  static Future<UserCredential?> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('FirebaseAuth: OTP sign in error: $e');
      rethrow;
    }
  }

  /// Sign Out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth: sign out error: $e');
    }
  }
}
