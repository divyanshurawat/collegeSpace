import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

// If FirebaseAuth and/or GoogleSignIn are not injected into the UserRepository, then we instantiate them internally.
// This allows us to be able to inject mock instances so that we can easily test the UserRepository

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  final FacebookLogin _facebookLogin;
  UserRepository(
      {FirebaseAuth firebaseAuth,
      GoogleSignIn googleSignin,
      FacebookLogin facebookLogin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _facebookLogin = facebookLogin ?? FacebookLogin();

  Future<FirebaseUser> signInWithFacebook() async {
    await _facebookLogin.logOut();
    final result = await _facebookLogin.logIn(['email', 'public_profile']);
    //(result.status);

    if (result.status == FacebookLoginStatus.loggedIn) {
      final token = result.accessToken.token;
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: token,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return await _firebaseAuth.currentUser();
    } else {
      return null;
    }
  }

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();


    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  Future<FirebaseUser> signInWithPhone(
      String smsCode, String verificationCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationCode,
      smsCode: smsCode,
    );

    await _firebaseAuth.signInWithCredential(credential);

    return _firebaseAuth.currentUser();
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> updateAuth({String name, String joined}) async {
    var auth = await _firebaseAuth.currentUser();
    final UserUpdateInfo info = UserUpdateInfo();
    info.displayName = name;
    await auth.updateProfile(info);
    final Firestore _firestore = Firestore.instance;
    final userRef =
        await _firestore.collection("users").document(auth.uid).get();

    await userRef.reference
        .setData({"displayName": name, "joined": joined,"badge":false,"ban":false}, merge: true);
    return auth.reload();
  }

  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return 'success';
    } catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser() != null
        ? true
        : await _firebaseAuth.onAuthStateChanged.first != null ? true : false;
    return currentUser;
  }

  Future<FirebaseUser> getUser() async {
    return (await _firebaseAuth.currentUser());
  }
}
