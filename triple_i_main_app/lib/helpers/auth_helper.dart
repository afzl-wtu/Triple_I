import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthClass {
  FirebaseAuth auth = FirebaseAuth.instance;

  //Create Account
  Future<String> createAccount(SignupData data) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: data.name!, password: data.password!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return "Error occurred";
    }
    return "Account created";
  }

  //Sign in user
  Future<String> signIn(LoginData data) async {
    try {
      await auth.signInWithEmailAndPassword(
          email: data.name, password: data.password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return "Welcome";
  }

  //Reset Password
  Future<String> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(
        email: email,
      );
      return "Email sent";
    } catch (e) {
      return "Error occurred";
    }
  }

  //SignOut
  void signOut() {
    auth.signOut();
  }

  //Google Auth
  Future<String?>? signWithGoogle() async {
    final GoogleSignInAccount googleUser =
        (await GoogleSignIn(scopes: <String>["email"]).signIn())!;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      return 'Error occured';
    }
  }

//Facebook
  Future<String?>? signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken!.token);

    try {
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      return 'Error Ocured';
    }
  }
}
