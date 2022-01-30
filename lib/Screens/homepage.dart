import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatapp/Screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/CommonComponents/BottomBar/bootom_navigation_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Noted :  You just have to replace your database key with my content like
// I have write Enter your collection name so you have to write your collection name
// like if you have created collection "user" so can replace code with
// Example : Firestore.instance
//           .collection('users') // youe collection name
//           .document(currentUserId)
//           .updateData({'collection pushTokekey': token});

// Enter your collection userid key , In this you have to replace id with whatever you have create filed
// Example , my user table fields like this
// id : "ABC"
// image : "abc.jpg"
// name : "abc"
// pushToken : "fgdsfyjdgkjdfgdsjfgdsjhfdsgfhj"
// so where i used word useridkey = id , imagekey = image and namekey = name

class Homepage extends StatefulWidget {
  final String currentUserId;
  Homepage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => _MainScreenState(currentUserId: currentUserId);
}

class _MainScreenState extends State<Homepage> {
  _MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser currentUser;
  bool isHomePageSelected = true;
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
// call setState to rebuild the view
        this.currentUser = user;
      });
    });
    _fetch();
    configLocalNotification();
    registerNotification();
  }

// NOTIFICATION REGISTRATION

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      _showNotificationWithDefaultSound();
      print('onMessage: $message');
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance.collection('Enter Your collection name ').document(currentUserId)
          // Enter your collection pushToken key
          .updateData({'Enter you pushToken key': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  Future _showNotificationWithDefaultSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

// LOCAL CONFIGRATION OF NOTIFICATION

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

// SHOW NOTIFICATION STUCTURE

// BOTTOM TABLAYOUT ICON CLICKED

  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      setState(() {
        isHomePageSelected = true;
      });
    } else {
      setState(() {
        isHomePageSelected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// LOGIN BUTTON LAYOUT
    return Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
            child: Stack(fit: StackFit.expand, children: <Widget>[
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 50,
              decoration: BoxDecoration(color: colors),
              child: StreamBuilder(
                stream: Firestore.instance
                    // Enter your collection name
                    .collection('Enter your collection name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => loadUser(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: BottomNavigation(
                onIconPresed: onBottomIconPressed,
              )),
        ])));
  }

// LOAD USERDATA LIST
  Widget loadUser(BuildContext context, DocumentSnapshot document) {
    // Enter your collection userid key from there you can check ids
    if (document['Enter you userid key'] == currentUserId) {
      return Container();
    } else {
      return Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: document['Enter you image key'] != null
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: document['Enter you image key'],
                          width: 40.0,
                          height: 40.0,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 50.0,
                          color: greyColor,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            document['Enter you name key'],
                            style: TextStyle(color: bgcolors, fontSize: 16),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chat(
                            pId: document.documentID,
                            pName: document['Enter you name key'],
                            pImage: document['Enter you image key'],
                          )));
            },
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Future<FirebaseUser> _fetch() async {
    String groupChatId = "";
    String lastSeen = "";
    // Enter your collection name from there you can get userId
    final result = await Firestore.instance.collection('Enter you collection name here').getDocuments();
    result.documents.forEach((doc) async {
      String id = doc.data['id'];
      if (id.hashCode <= currentUserId.hashCode) {
        groupChatId = '$id-$currentUserId';
      } else {
        groupChatId = '$currentUserId-$id';
      }
      final m = await Firestore.instance.collection(
          // type your collection name in which you want to fetch groupChatId
          'Enter your collection name here').document(groupChatId).collection(groupChatId).getDocuments();
      if (m.documents.length > 0) {
        lastSeen = m.documents.first.data['content'];
      }
    });
  }
}
