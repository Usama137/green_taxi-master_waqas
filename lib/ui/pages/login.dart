import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:green_taxi/ui/pages/signup.dart';
import 'package:green_taxi/components/constants.dart';
import 'package:green_taxi/components/rounded_button.dart';
import 'package:green_taxi/widgets/sizes_helpers.dart';
import 'package:green_taxi/ui/pages/otp_page.dart';
import 'package:green_taxi/widgets/ProgressDialog.dart';

class Login extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String message) {
    final snackBar = SnackBar(
        content: Text(
      message,
      textAlign: TextAlign.center,
    ));
    scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void login() async {
    
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context)=>ProgressDialog(status: "Logging you in")
    );
    try {

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential != null) {

       // DatabaseReference userRef=FirebaseDatabase.instance.reference().child('drivers/${user.uid}');


        Navigator.pop(context);
        Navigator.pushNamed(context, OtpPage.routeName);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        showSnackBar(e.message);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showSnackBar(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        //physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: displayHeight(context) * 0.15,
              ),
              Image(
                alignment: Alignment.center,
                height: 100,
                width: 100,
                image: AssetImage('assets/images/logobike.PNG'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "E-Bike Service",
                style: TextStyle(
                    color: splashTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 14),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RoundedButton(
                      buttonColor: splashTextColor,
                      textColor: Colors.white,
                      title: 'Login',
                      buttonWidth: displayWidth(context) * 0.80,
                      onPressed: () {
                        login();
                      },
                    )
                  ],
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, Signup.routeName, (route) => true);
                },
                child: Text("Don\'t have an account, sign up here"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
