import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatapp/Screens/OTPScreen.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';

class MobilePhone extends StatefulWidget {
  @override
  MobilePhoneState createState() => new MobilePhoneState();
}

class MobilePhoneState extends State<MobilePhone> {
  bool _mobileNumber = false;
  var _phone = TextEditingController();
  final FocusNode _phoneFocus = FocusNode();

  TextStyle style = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);

  // CHECK VALIDATION

  void _checkValidation() async {
    if (_phone.text.isEmpty) {
      _mobileNumber = true;
    } else {
      dismisskeyboard();
      _mobileNumber = false;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              mobileNumber: _phone.text,
            ),
          ));
    }
  }

//   DISSMISS KEYBOARD

  void dismisskeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    //   EMAIL INPUT LAYOUT
    final emailField = TextFormField(
      controller: _phone,
      obscureText: false,
      style: style,
      keyboardType: TextInputType.phone,
      focusNode: _phoneFocus,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        hintText: "",
        labelText: "Mobile Number",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        errorText: _mobileNumber ? 'Please Enter Mobile Number' : null,
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
        child: Text("Next",
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
                    height: 20.0,
                  ),
                  Text(
                    "Let's enter your mobile number will send you OTP for confirm your number",
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
