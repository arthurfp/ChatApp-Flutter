import 'package:chatapp/Screens/LoginScreen.dart';
import 'package:chatapp/Screens/Profilepage.dart';
import 'package:chatapp/Screens/homepage.dart';
import 'package:chatapp/Screens/Settings.dart';
import 'package:chatapp/Screens/About.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';
import 'package:flutter/material.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class Drawerpage extends StatefulWidget {
  final String currentUserId;
  Drawerpage({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => DrawerPageState(currentUserId: currentUserId);
}

class DrawerPageState extends State<Drawerpage> {
  DrawerPageState({Key key, @required this.currentUserId});

// DRWER ITEM LIST

  final drawerItems = [
    new DrawerItem("Profile", Icons.account_box),
    new DrawerItem("Chat", Icons.chat),
    new DrawerItem("Settings", Icons.settings),
    new DrawerItem("About", Icons.info),
    new DrawerItem("Logout", Icons.power_settings_new)
  ];

  final String currentUserId;
  int _selectedDrawerIndex = 1;
  FirebaseUser currentUser;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      setState(() {
        this.currentUser = user;
      });
    });
  }

// GET USER NAME
  String _displayname() {
    if (currentUser != null) {
      if (currentUser.displayName != null) {
        return currentUser.displayName;
      } else {
        return "Name Not Found";
      }
    } else {
      return "Name Not Found";
    }
  }

  // GET USER EMAIL
  String _email() {
    if (currentUser != null) {
      if (currentUser.email != null) {
        return currentUser.email;
      } else {
        return "Email Id Not Found";
      }
    } else {
      return "Email Id Not Found";
    }
  }

// GET
  String _profilePic() {
    if (currentUser != null) {
      if (currentUser.photoUrl != null) {
        return currentUser.photoUrl;
      } else {
        return logo1;
      }
    } else {
      return logo1;
    }
  }

  _logOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new Profilepage(
          currentUserId: currentUserId,
        );
      case 1:
        return new Homepage(
          currentUserId: currentUserId,
        );
      case 2:
        return new Settings();
      case 3:
        return new About();
      case 4:
        return _logOut();

      default:
        return new Text("");
    }
  }

  _onSelectItem(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(
          d.icon,
          color: bgcolors,
        ),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        elevation: 0.5,
        leading: new IconButton(icon: new Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState.openDrawer()),
        title: Text("Home"),
        centerTitle: true,
      ),
      drawer: Container(
          width: MediaQuery.of(context).size.width - 100,
          child: Drawer(
            child: ListView(children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Container(
                      color: greyColor2,
                      child: Row(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: ClipOval(
                            child: Image.network(
                              _profilePic(),
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Text(_displayname()),
                              new Text(_email()),
                            ]),
                      ]))),
              new Column(children: drawerOptions),
            ]),
          )),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}
