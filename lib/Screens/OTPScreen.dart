import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chatapp/Screens/Drawer.dart';

import '../CommonComponents/otp_input.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  OTPScreen({
    Key key,
    @required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  var _otp = TextEditingController();

  var otp_contain = "OTP has been sent to you on your mobile number please enter it below.";

  bool isCodeSent = false;
  String _verificationId;

  TextStyle style = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  PinDecoration _pinDecoration =
      UnderlineDecoration(enteredColor: Colors.black, hintText: '000000', color: Colors.black);

  @override
  void initState() {
    super.initState();
    _onVerifyCode();
  }

  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);

// DISSMISS KEYBOARD

  void dismisskeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _homeNavigation(userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', userid);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Drawerpage(currentUserId: userid)));
  }

  @override
  Widget build(BuildContext context) {
    // EMAIL INPUT LAYOUT
    final emailField = PinInputTextField(
      pinLength: 6,
      decoration: _pinDecoration,
      controller: _otp,
      autoFocus: true,
      textInputAction: TextInputAction.done,
      onSubmit: (pin) {
        if (pin.length == 6) {
          _onFormSubmitted();
        } else {
          showToast("Invalid OTP", Colors.red);
        }
      },
    );

    // LOGIN BUTTON LAYOUT

    final button = Material(
      borderRadius: BorderRadius.circular(30.0),
      color: bgcolors,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width - 120,
        padding: edgeInsets,
        onPressed: () {
          if (_otp.text.length == 6) {
            _onFormSubmitted();
          } else {
            showToast("Invalid OTP", Colors.red);
          }
        },
        child: Text("DONE",
            textAlign: TextAlign.center, style: TextStyle(color: colors, fontSize: 18.0, fontWeight: FontWeight.w400)),
      ),
    );

//  MAIN CONTAIN

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
                    "Verify mobile Number",
                    style: TextStyle(
                      fontSize: 18,
                      color: bgcolors,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    otp_contain,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
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

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _onVerifyCode() {
    setState(() {
      isCodeSent = true;
    });

    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential).then((AuthResult value) {
        if (value.user != null) {
          // Handle loogged in state
          _homeNavigation(value.user.uid);
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((error) {
        showToast("Try again in sometime", Colors.red);
      });
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      showToast(authException.message, Colors.red);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
      print(verificationId);
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      print(verificationId);

      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    //   Change country code

    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    AuthCredential _authCredential =
        PhoneAuthProvider.getCredential(verificationId: _verificationId, smsCode: _otp.text);

    _firebaseAuth.signInWithCredential(_authCredential).then((AuthResult value) {
      if (value.user != null) {
        _homeNavigation(value.user.uid);
      } else {
        showToast("Error validating OTP, try again", Colors.red);
      }
    }).catchError((error) {
      showToast("Something went wrong", Colors.red);
    });
  }
}
