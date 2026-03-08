import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Handles Firebase Authentication and user profile creation in Firestore.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null && displayName != null && displayName.isNotEmpty) {
      await cred.user!.updateDisplayName(displayName);
    }
    await _createUserProfile(cred.user!);
    await sendEmailVerification();
  }

  Future<void> _createUserProfile(User user) async {
    final profile = UserProfile(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      createdAt: DateTime.now(),
    );
    await _firestore.collection(_usersCollection).doc(user.uid).set(profile.toMap());
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}
