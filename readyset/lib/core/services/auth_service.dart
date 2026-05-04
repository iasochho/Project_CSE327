// lib/core/services/auth_service.dart
// STRATEGY PATTERN: AuthService selects the correct sign-in / sign-out strategy.

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Password Reset ─────────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
