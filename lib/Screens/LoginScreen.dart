import 'package:flutter/material.dart';
import 'package:chatapp/Constants/Constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Screens/Drawer.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _emailValidate = false;
  bool _passwordValidation = false;
  bool _passEye = true;
  var _text = TextEditingController();
  var _passtext = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passworsFocus = FocusNode();

  var loggedIn = false;
  var firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin();

  SharedPreferences prefs;
  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;
  var user_id = '';

  TextStyle style = TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );

  _homeNavigation(userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id', userid);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Drawerpage(currentUserId: userid)));
  }

  var _emailError = 'Please Enter Email ID';
  var _passwordError = 'Please Enter Password ';

  EdgeInsets edgeInsets = EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0);
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

// CHECK VALIDATION

  void _checkValidation() async {
    isLoading = true;
    RegExp regex = new RegExp(pattern);
    if (_text.text.isEmpty) {
      _emailValidate = true;
      _passwordValidation = false;
      showToast(_emailError);
    } else if (!regex.hasMatch(_text.text)) {
      _emailValidate = true;
      _passwordValidation = false;
      _emailError = 'Please Enter Valid Email ID';
      showToast(_emailError);
    } else if (_passtext.text.isEmpty) {
      _emailValidate = false;
      _passwordValidation = true;
      showToast(_passwordError);
    } else if (_passtext.text.length < 8) {
      _emailValidate = false;
      _passwordValidation = true;
      _passwordError = "Password must be longer than 8 characters";
      showToast(_passwordError);
    } else {
      dismisskeyboard();
      _emailValidate = false;
      _passwordValidation = false;
      signIn(_text.text, _passtext.text);
    }
  }

  showToast(error) {
    Fluttertoast.showToast(msg: error);
  }

// CLEAR TEXT
  _cleartext() {
    _text.text = "";
    _passtext.text = "";
  }

// EYE TOGGLE

  void _toggle() {
    setState(() {
      _passEye = !_passEye;
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

  @override
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('id') ?? '';
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user == null) {
        print("null");
      } else {
        _homeNavigation(user_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          color: Colors.black,
        ),
        hintText: "",
        labelText: "Email Address",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        labelStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        errorText: _emailValidate ? _emailError : null,
      ),
    );

// PASSWORD INPUT LAYOUT
    var passwordField = TextFormField(
      controller: _passtext,
      obscureText: _passEye,
      focusNode: _passworsFocus,
      textInputAction: TextInputAction.done,
      style: style,
      decoration: InputDecoration(
        contentPadding: edgeInsets,
        hintStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        hintText: "",
        labelText: "Password",
        border: new UnderlineInputBorder(borderSide: new BorderSide(color: colors)),
        labelStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        suffixIcon: IconButton(
          iconSize: 20.0,
          onPressed: () => _toggle(),
          icon: Icon(Icons.remove_red_eye),
        ),
        errorText: _passwordValidation ? _passwordError : null,
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
          _checkValidation();
        },
        child: Text("Sign In",
            textAlign: TextAlign.center, style: TextStyle(color: colors, fontSize: 18.0, fontWeight: FontWeight.w400)),
      ),
    );

    // SOCIAL MEDIA LAYOUT

    final socialLogin = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(5.0),
          child: InkWell(
              onTap: () {
                loginWithFB();
              },
              child: new Image.asset(
                facebook,
                height: 48.0,
                width: 48.0,
              )),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: InkWell(
              onTap: () {
                initiateSignIn("G");
              },
              child: new Image.asset(
                gmail,
                height: 45.0,
                width: 45.0,
              )),
        ),
        Padding(
          padding: EdgeInsets.all(0),
          child: IconButton(
            iconSize: 44.0,
            onPressed: () => _signInAnonymously(),
            icon: Icon(Icons.account_circle, color: bgcolors),
          ),
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(PHONENUMBER);
                },
                hoverColor: bgcolors,
                child: new Image.asset(
                  phone,
                  height: 42.0,
                  width: 42.0,
                ))),
      ],
    );

    // FORGOT PASSWORD

    final forgotPasword = MaterialButton(
      onPressed: () {
        Navigator.of(context).pushNamed(RESETPASSWORD);
      },
      child: Text(
        "Forgot Password",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: bgcolors,
        ),
      ),
    );

    // BOTTOM LAYOUT

    final bottomText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Don't have an account ",
          style: TextStyle(
            color: bgcolors,
          ),
        ),
        MaterialButton(
          padding: EdgeInsets.only(left: 5),
          minWidth: 0,
          onPressed: () {
            Navigator.of(context).pushNamed(REGISTRATION_SCREEN);
          },
          child: Text(
            "Sign Up",
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
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: colors),
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Container(
              decoration: BoxDecoration(color: colors),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  isLoading == false
                      ? Column(
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
                              Text("Welcome Back !!",
                                  style: TextStyle(fontSize: 16.0, color: bgcolors, fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: 20.0,
                              ),
                              emailField,
                              SizedBox(
                                height: 20.0,
                              ),
                              passwordField,
                              SizedBox(
                                height: 20.0,
                              ),
                              loginButton,
                              forgotPasword,
                              bottomText,
                              SizedBox(
                                height: 10.0,
                              ),
                              Text("--------- or ---------",
                                  style: TextStyle(fontSize: 16.0, color: bgcolors, fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: 10.0,
                              ),
                              socialLogin,
                            ])
                      : buildLoader()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoader() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(bgcolors)),
              ),
              color: colors.withOpacity(0.8),
            )
          : Container(),
    );
  }

  // SIGN IN WITH GOOGLE
  void initiateSignIn(String type) {
    isLoading = true;
    _handleSignIn(type).then((result) {
      if (result == 1) {
        setState(() {
          loggedIn = true;
        });
      } else {}
    });
  }

  Future<int> _handleSignIn(String type) async {
    switch (type) {
      case "G":
        try {
          GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
          final googleAuthCred =
              GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          FirebaseUser user = (await firebaseAuth.signInWithCredential(googleAuthCred)).user;
          isLoading = false;
          _homeNavigation(user.uid);
          print(user);
          return 1;
        } catch (error) {
          isLoading = false;
          return 0;
        }
    }
    return 0;
  }

  // SIGN IN WITH ANONYMOUS

  Future<void> _signInAnonymously() async {
    isLoading = true;
    try {
      await FirebaseAuth.instance.signInAnonymously();
      FirebaseAuth.instance.onAuthStateChanged.listen((firebaseUser) {
        isLoading = false;
        _homeNavigation(firebaseUser.uid);
      });
    } catch (e) {
      print(e);
    }
  }

  loginWithFB() async {
    isLoading = false;
    final result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken: token);
        final user = (await firebaseAuth.signInWithCredential(facebookAuthCred)).user;
        _homeNavigation(user.uid);
        print(user);
        break;

      case FacebookLoginStatus.cancelledByUser:
        print(FacebookLoginStatus);
        break;
      case FacebookLoginStatus.error:
        print(FacebookLoginStatus);
        break;
    }
  }

  // SIGN IN WITH EMAIL

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      var user = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      assert(user != null);
      assert(await user.user.getIdToken() != null);
      final FirebaseUser currentUser = await firebaseAuth.currentUser();
      assert(user.user.uid == currentUser.uid);
      isLoading = false;
      _cleartext();
      _homeNavigation(user.user.uid);
      return user.user;
    } catch (e) {
      isLoading = false;
      showToast("Invalid Cradential");
    }
  }
}
