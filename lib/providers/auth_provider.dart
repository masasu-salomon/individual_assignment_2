import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, unauthenticated, unverified, authenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserProfile? _profile;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;
  User? get user => _user;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user == null) {
      _profile = null;
      _status = AuthStatus.unauthenticated;
    } else if (!user.emailVerified) {
      _profile = await _authService.getUserProfile(user.uid);
      _status = AuthStatus.unverified;
    } else {
      _profile = await _authService.getUserProfile(user.uid);
      _status = AuthStatus.authenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _onAuthStateChanged(_authService.currentUser);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authMessage(e.code);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithEmailPassword(email: email, password: password);
      await _onAuthStateChanged(_authService.currentUser);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authMessage(e.code);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkEmailVerified() async {
    await _authService.reloadUser();
    await _onAuthStateChanged(_authService.currentUser);
  }

  Future<void> resendVerificationEmail() async {
    _errorMessage = null;
    try {
      await _authService.sendEmailVerification();
      _errorMessage = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _authMessage(e.code);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static String? _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'internal-error':
        return 'Firebase Auth configuration error. Add your app\'s SHA-1 in Firebase Console → Project settings → Your apps → Android app → Add fingerprint. See README.';
      default:
        if (code.contains('CONFIGURATION_NOT_FOUND') || code.toLowerCase().contains('recaptcha')) {
          return 'Auth not configured for this app. Add your debug SHA-1 in Firebase Console (Project settings → Your apps → Android → Add fingerprint). See README.';
        }
        return code;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
