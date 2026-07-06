import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';


class AuthService {
  AuthService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get _rawAuthStateChanges => _auth.userChanges();

  Stream<AppUser?> get appUserChanges =>
      _rawAuthStateChanges.map(_mapFirebaseUser);

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName?.isNotEmpty == true
          ? user.displayName!
          : 'Joueur',
      isAnonymous: user.isAnonymous,
    );
  }

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();
      final refreshedUser = _auth.currentUser!;
      await _createOrUpdateUserDoc(refreshedUser.uid, displayName, email);
      return _mapFirebaseUser(refreshedUser)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapFirebaseUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  
  Future<AppUser> signInAnonymously(String displayName) async {
    try {
      final credential = await _auth.signInAnonymously();
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();
      final refreshedUser = _auth.currentUser!;
      await _createOrUpdateUserDoc(refreshedUser.uid, displayName, null);
      return _mapFirebaseUser(refreshedUser)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _createOrUpdateUserDoc(
    String uid,
    String displayName,
    String? email,
  ) {
    return _firestore.collection('users').doc(uid).set({
      'displayName': displayName,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Pas de connexion réseau. Réessayez.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'operation-not-allowed':
        return 'Cette méthode de connexion n\'est pas activée côté Firebase.';
      default:
        return 'Erreur d\'authentification (${e.code}).';
    }
  }
}