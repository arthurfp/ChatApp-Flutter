import 'package:flutter/material.dart';
import 'package:chatapp/Constants/Constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  RegistrationScreenState createState() => new RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  bool _emailValidate = false;
  bool _passwordValidation = false;
  bool _confirmpasswordValidation = false;
  bool _nameValidation = false;
  bool _passEye = true;
  bool _confirmpassEye = true;
  var _name = TextEditingController();
  var _text = TextEditingController();
  var _passtext = TextEditingController();
  var _confirmpasstext = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _passworsFocus = FocusNode();
  final FocusNode _confirmpassworsFocus = FocusNode();

  var auth = FirebaseAuth.instance;

  var _emailError = 'Please Enter Email ID';
  var _passwordError = 'Please Enter Password ';
  var _confirmpasswordError = 'Please Enter Confirm Password ';

  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  TextStyle style = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);

// CHECK VALIDATION

  void _checkValidation() async {
    RegExp regex = new RegExp(pattern);
    if (_name.text.isEmpty) {
      _nameValidation = true;
      _emailValidate = false;
      _passwordValidation = false;
      _confirmpasswordValidation = false;
    } else if (_text.text.isEmpty) {
      _emailValidate = true;
      _nameValidation = false;
      _passwordValidation = false;
      _confirmpasswordValidation = false;
    } else if (!regex.hasMatch(_text.text)) {
      _emailValidate = true;
      _nameValidation = false;
      _passwordValidation = false;
      _confirmpasswordValidation = false;
      _emailError = 'Please Enter Valid Email ID';
    } else if (_passtext.text.isEmpty) {
      _emailValidate = false;
      _nameValidation = false;
      _passwordValidation = true;
      _confirmpasswordValidation = false;
    } else if (_passtext.text.length < 8) {
      _emailValidate = false;
      _nameValidation = false;
      _passwordValidation = true;
      _confirmpasswordValidation = false;
      _passwordError = "Password must be longer than 8 characters";
    } else if (_confirmpasstext.text.isEmpty) {
      _emailValidate = false;
      _nameValidation = false;
      _passwordValidation = false;
      _confirmpasswordValidation = true;
    } else if (_confirmpasstext.text.toString() != _passtext.text.toString()) {
      _emailValidate = false;
      _nameValidation = false;
      _passwordValidation = false;
      _confirmpasswordValidation = true;
      _confirmpasswordError = "confirm Password is not matched with password";
    } else {
      dismisskeyboard();
      _emailValidate = false;
      _nameValidation = false;
      _passwordValidation = false;
      _confirmpasswordValidation = false;
      signUp(_text.text, _passtext.text);
    }
  }

  // CALL REGISRATION IN FIREBASE

// EYE TOGGLE

  void _toggle(val) {
    setState(() {
      _passEye = !_passEye;
    });
  }

  void _confirmtoggle(val) {
    setState(() {
      _confirmpassEye = !_confirmpassEye;
    });
  }

// DISSMISS KEYBOARD

  void dismisskeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // MOVE TO NEXT FOCUS FIELD

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  // CLEAR TEXT

  _cleartext() {
    _text.text = "";
    _passtext.text = "";
    _name.text = "";
    _confirmpasstext.text = "";
  }

  @override
  Widget build(BuildContext context) {
    // NAME INPUT LAYOUT
    final nameField = TextFormField(
      controller: _name,
      obscureText: false,
      style: style,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      focusNode: _nameFocus,
      onFieldSubmitted: (value) {
        _fieldFocusChange(context, _nameFocus, _emailFocus);
      },
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: bgcolors,
        ),
        hintText: "",
        labelText: "Name",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        errorText: _nameValidation ? 'Please Enter Name' : null,
      ),
    );

    // EMAIL INPUT LAYOUT
    final emailField = TextFormField(
      controller: _text,
      obscureText: false,
      style: style,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocus,
      onFieldSubmitted: (value) {
        _fieldFocusChange(context, _emailFocus, _passworsFocus);
      },
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: bgcolors,
        ),
        hintText: "",
        labelText: "Email address",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        errorText: _emailValidate ? _emailError : null,
      ),
    );

// PASSWORD INPUT LAYOUT
    var passwordField = TextFormField(
      controller: _passtext,
      obscureText: _passEye,
      focusNode: _passworsFocus,
      textInputAction: TextInputAction.next,
      style: style,
      onFieldSubmitted: (value) {
        _fieldFocusChange(context, _passworsFocus, _confirmpassworsFocus);
      },
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: bgcolors,
        ),
        hintText: "",
        labelText: "Password",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        suffixIcon: IconButton(
          iconSize: 20.0,
          onPressed: () => _toggle(_passEye),
          icon: Icon(Icons.remove_red_eye),
        ),
        errorText: _passwordValidation ? _passwordError : null,
      ),
    );

    // CONFIRM PASSWORD INPUT LAYOUT
    var confirmpasswordField = TextFormField(
      controller: _confirmpasstext,
      obscureText: _confirmpassEye,
      focusNode: _confirmpassworsFocus,
      textInputAction: TextInputAction.done,
      style: style,
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: bgcolors,
        ),
        hintText: "",
        labelText: "Confirm Password",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        suffixIcon: IconButton(
          iconSize: 20.0,
          onPressed: () => _confirmtoggle(_confirmpassEye),
          icon: Icon(Icons.remove_red_eye),
        ),
        errorText: _confirmpasswordValidation ? _confirmpasswordError : null,
      ),
    );

    // LOGIN BUTTON LAYOUT

    final loginButton = Material(
      borderRadius: BorderRadius.circular(30.0),
      color: bgcolors,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width - 120,
        padding: edgeInsets,
        onPressed: () {
          setState(() {
            _checkValidation();
          });
        },
        child: Text("Sign Up",
            textAlign: TextAlign.center, style: TextStyle(color: colors, fontSize: 18.0, fontWeight: FontWeight.w400)),
      ),
    );

    // BOTTOM TEXT

    final bottomText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Already have an Account",
          style: TextStyle(
            color: bgcolors,
          ),
        ),
        MaterialButton(
          padding: EdgeInsets.only(left: 5),
          minWidth: 0,
          onPressed: () {
            Navigator.of(context).pushNamed(LOGIN_SCREEN);
          },
          child: Text(
            "Sign In",
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
              color: bgcolors,
            ),
          ),
        )
      ],
    );

//  MAIN CONTAIN
    return Container(
      child: Scaffold(
        backgroundColor: colors,
        body: Column(children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  back,
                  height: 20,
                  width: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.all(36.0),
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
                      height: 5.0,
                    ),
                    Text("Let's Get Started !",
                        style: TextStyle(fontSize: 16.0, color: bgcolors, fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 16.0,
                    ),
                    nameField,
                    SizedBox(
                      height: 16.0,
                    ),
                    emailField,
                    SizedBox(
                      height: 16.0,
                    ),
                    passwordField,
                    SizedBox(
                      height: 16.0,
                    ),
                    confirmpasswordField,
                    SizedBox(
                      height: 20.0,
                    ),
                    loginButton,
                    bottomText
                  ],
                ),
              ),
            )
          ])))
        ]),
      ),
    );
  }

// SIGN UP IN FIREBASE
  Future<FirebaseUser> signUp(email, password) async {
    try {
      var user = await auth.createUserWithEmailAndPassword(email: email, password: password);
      assert(user != null);
      assert(await user.user.getIdToken() != null);
      _cleartext();
      Navigator.of(context).pushNamed(LOGIN_SCREEN);
      return user.user;
    } catch (e) {
      return null;
    }
  }
}
