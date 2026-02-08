import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ViewModel for Firebase Authentication.
class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser;

  AuthViewModel() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter email and password';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Login failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Create account with email and password
  Future<bool> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter email and password';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Sign up failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> logout() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Please enter your email address';
      notifyListeners();
      return false;
    }

    if (!_isValidEmail(email)) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to send reset email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Delete user account and all associated data
  Future<bool> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      _errorMessage = 'No user is logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete user from Firebase Auth
      await user.delete();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'requires-recent-login') {
        _errorMessage = 'Please log out and log back in before deleting your account';
      } else {
        _errorMessage = _getErrorMessage(e.code);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete account: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed: $code';
    }
  }

  /// Validates email format using regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }
}
