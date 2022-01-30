import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Constants/Constant.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassword extends StatefulWidget {
  @override
  ResetPasswordState createState() => new ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  bool _textvalidate = false;
  var _text = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  TextStyle style = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  var firebaseAuth = FirebaseAuth.instance;
  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);

  // CHECK VALIDATION
  void _checkValidation() async {
    if (_text.text.isEmpty) {
      _textvalidate = true;
    } else {
      dismisskeyboard();
      _textvalidate = false;
      await sendPasswordResetEmail(_text.text.toString());
      Fluttertoast.showToast(msg: "Reset password has been sent you in email ID");
      Navigator.of(context).pushNamed(LOGIN_SCREEN); // Navigation of login screen
    }
  }

  // PASSWORD RESET PROCESS
  Future sendPasswordResetEmail(String email) async {
    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

// FOR DISSMISS KEYBOARD
  void dismisskeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    //   EMAIL INPUT LAYOUT
    final emailField = TextFormField(
      controller: _text,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.emailAddress,
      focusNode: _textFocus,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        hintText: "",
        labelText: "Email Id",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        errorText: _textvalidate ? 'Please Enter Email Id' : null,
      ),
    );

    //   LOGIN BUTTON LAYOUT
    final button = Material(
      borderRadius: BorderRadius.circular(30.0),
      color: bgcolors,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width - 120,
        padding: edgeInsets,
        onPressed: () {
          _checkValidation();
        },
        child: Text("Done",
            textAlign: TextAlign.center, style: TextStyle(color: colors, fontSize: 18.0, fontWeight: FontWeight.w400)),
      ),
    );

//    MAIN CONTAIN
    return Container(
      child: Scaffold(
        backgroundColor: colors,
        resizeToAvoidBottomInset: false,
        body: Column(children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  back,
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(36.0),
            child: Container(
              decoration: BoxDecoration(color: colors),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    logo,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Reset Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: bgcolors,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "You can reset your password with you email Id.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: bgcolors,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  emailField,
                  SizedBox(
                    height: 30.0,
                  ),
                  button,
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
