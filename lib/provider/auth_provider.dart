import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';
import '../service/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userModel;
  bool _isLoading = true;

  UserModel? get userModel => _userModel;
  bool get isLoggedIn => _userModel != null;
  bool get isLoading => _isLoading;

  // Compatibility getter for older screens
  Map<String, dynamic>? get currentUser => _userModel != null ? _userModel!.toMap() : null;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        _firestoreService.streamUser(user.uid).listen((userData) {
          if (userData != null) {
            _userModel = userData;
            _isLoading = false;
            notifyListeners();
          } else {
            // Profile chưa tồn tại trong Firestore, có thể cần tạo mới hoặc chờ
            _isLoading = false;
            notifyListeners();
          }
        });
      } else {
        _userModel = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Compatibility method for LoginScreen
  Future<void> loginWithFirebase(User firebaseUser) async {
    // This method is called from LoginScreen after a successful Firebase Login
    // We ensure the user exists in Firestore
    await _firestoreService.saveUser(UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'User',
      photoUrl: firebaseUser.photoURL ?? '',
      joinedProjects: [],
      createdAt: DateTime.now(),
    ));
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: '',
        joinedProjects: [],
        createdAt: DateTime.now(),
      );
      await _firestoreService.saveUser(newUser);
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential cred = await _auth.signInWithCredential(credential);
    if (cred.user != null) {
      await _firestoreService.saveUser(UserModel(
        uid: cred.user!.uid,
        email: cred.user!.email ?? '',
        displayName: cred.user!.displayName ?? 'User',
        photoUrl: cred.user!.photoURL ?? '',
        joinedProjects: [],
        createdAt: DateTime.now(),
      ));
    }
  }

  // Updated Compatibility methods for ForgotPassword screen
  Future<void> sendOTP(
    String phone, {
    required Function(String) onCodeSent,
    required Function(String) onVerificationFailed,
  }) async {
    if (phone.startsWith('0')) phone = '+84${phone.substring(1)}';
    else if (!phone.startsWith('+')) phone = '+84$phone';
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onVerificationFailed(e.message ?? "Lỗi xác thực");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTP(String otp) async {
    // In a real flow, you'd need the verificationId from sendOTP.
    // Since forgotpass_screen.dart doesn't store it properly yet, 
    // this is a placeholder. 
    // Ideally, the screen should hold the verificationId.
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    }
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePhotoURL(photoUrl);
      await _firestoreService.updateUserField(user.uid, {'photo_url': photoUrl});
      notifyListeners();
    }
  }

  Future<void> updateUserName(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _firestoreService.updateUserField(user.uid, {'display_name': name});
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserPhone(String phone) async {
    if (_userModel != null) {
      // Logic to update phone in Firestore
      print("Updating phone to $phone");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
