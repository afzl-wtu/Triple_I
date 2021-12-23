import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:main/helpers/auth_helper.dart';
import 'package:main/screens/main_screen.dart';
import 'package:main/widgets/backgroundGrad.dart';

class AuthScreen extends StatelessWidget {
  final AuthClass _auth = AuthClass();

  Duration get loginTime => Duration(milliseconds: 2250);

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(
          accentColor: Color.fromRGBO(65, 190, 186, 1),
          titleStyle: GoogleFonts.notoSerif(color: Colors.white)),
      background: BackgroundImage(),
      title: 'Triple I',
      logo: 'assets/images/LOGO Darmon app.png',
      onLogin: _auth.signIn,
      onSignup: _auth.createAccount,
      loginProviders: <LoginProvider>[
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Google',
          callback: _auth.signWithGoogle,
        ),
        LoginProvider(
          icon: FontAwesomeIcons.facebookF,
          label: 'Facebook',
          callback: _auth.signInWithFacebook,
        ),
      ],
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScreen(),
        ));
      },
      onRecoverPassword: _auth.resetPassword,
    );
  }
}
