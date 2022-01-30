import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/CommonComponents/color.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/CommonComponents/CommonImage.dart';

// Noted :  You just have to replace your database key with my content like
// I have write Enter your collection name so you have to write your collection name
// like if you have created collection "user" so can replace code with
// Example : Firestore.instance
//           .collection('users') // youe collection name
//           .document(currentUserId)
//           .updateData({'chattingWith Key': pId});

// Enter your collection userid key , In this you have to replace id with whatever you have create filed
// Example , my user table fields like this
// chattingWith : "ABC"
// so where i used word chattingWithkey = chattingWith

class Chat extends StatelessWidget {
  final String pId;
  final String pName;
  final String pImage;

  Chat({Key key, @required this.pId, @required this.pName, @required this.pImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          pName,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(chat_bg),
              fit: BoxFit.cover,
            ),
          ),
          child: ChatScreen(
            pId: pId,
            pImage: pImage,
          )),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String pId;
  final String pImage;

  ChatScreen({Key key, @required this.pId, @required this.pImage}) : super(key: key);

  @override
  State createState() => new ChatScreenState(pId: pId, pImage: pImage);
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ChatScreenState({Key key, @required this.pId, @required this.pImage});

  String pId;
  String pImage;
  String id;

  var message;
  String groupId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl, peerNo;

  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  final BorderRadius borderRadius = new BorderRadius.only(
      topRight: Radius.circular(20.0), topLeft: Radius.circular(20.0), bottomLeft: Radius.circular(20.0));

  final BorderRadius leftborderRadius = new BorderRadius.only(
      topRight: Radius.circular(20.0), bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0));

  @override
  void initState() {
    super.initState();
    groupId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
    print(pId);
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= pId.hashCode) {
      groupId = '$id-$pId';
    } else {
      groupId = '$pId-$id';
    }
    Firestore.instance
        .collection(
            'Enter your collection name') // Your collection name will be whatever you have given in firestore database
        .document(id)
        .updateData({'Enter your chattingWith Key': pId});
    setState(() {});
  }

// GET IMAGE FROM GALLARY
  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Image is Not Valid');
    });
  }

  // SEND MESSAGE CLICK

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupId)
          .collection(groupId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': pId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0
                    // Text
                    ? Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              document['content'],
                              style: TextStyle(color: colors, fontSize: 14.0),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(12.0),
                        width: 220.0,
                        decoration: BoxDecoration(color: bgcolors, borderRadius: borderRadius),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 10.0 : 10.0, right: 10.0),
                      )
                    : Container(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: TextButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(colors),
                                  ),
                                  width: 220.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: colors,
                                    borderRadius: borderRadius,
                                  ),
                                ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: borderRadius,
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      )
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            // STORE TIME ZONE FOR BACKAND DATABASE
            isLastMessageRight(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                      style: TextStyle(color: bgcolors, fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
        margin: EdgeInsets.only(bottom: 2.0),
      );
    } else {
      // RECEIVER MESSAGE
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                // isLastMessageLeft(index)
                //     ? Material(
                //         child: CachedNetworkImage(
                //           placeholder: (context, url) => Container(
                //             child: CircularProgressIndicator(
                //               strokeWidth: 1.0,
                //               valueColor:
                //                   AlwaysStoppedAnimation<Color>(themeColor),
                //             ),
                //             width: 35.0,
                //             height: 35.0,
                //             padding: EdgeInsets.all(10.0),
                //           ),
                //           imageUrl: pImage,
                //           width: 35.0,
                //           height: 35.0,
                //           fit: BoxFit.cover,
                //         ),
                //         borderRadius: leftborderRadius,
                //         clipBehavior: Clip.hardEdge,
                //       )
                //     : Container(width: 35.0),

                // MESSAGE BOX FOR TEXT
                document['type'] == 0
                    ? Container(
                        child: Text(
                          document['content'],
                          style: TextStyle(color: bgcolors, fontSize: 14.0),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 220.0,
                        decoration: BoxDecoration(color: greyColor, borderRadius: leftborderRadius),
                        margin: EdgeInsets.only(left: 2.0),
                      )

                    // MESSAGE BOX FOR IMAGE
                    : Container(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: TextButton(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: bgcolors,
                                    borderRadius: leftborderRadius,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: leftborderRadius,
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      )
              ],
            ),

            // STORE TIME ZONE FOR BACKAND DATABASE
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))),
                      style: TextStyle(color: bgcolors, fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  // CHECK IF IT IS RECEIVER SIDE OR NOT
  bool isLastMessageLeft(int index) {
    if ((index > 0 && message != null && message[index - 1]['idFrom'] == id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // CHECK IF IT IS SENDER SIDE OR NOT
  bool isLastMessageRight(int index) {
    if ((index > 0 && message != null && message[index - 1]['idFrom'] != id) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // ON BACKPRESS
  Future<bool> onBackPress() {
    Firestore.instance
        .collection(
            'Enter your collection name') // Your collection name will be whatever you have given in firestore database
        .document(id)
        .updateData({'Enter your chattingWith Key': null});
    Navigator.pop(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildmessageBox(),
              // Sticker
              Container(),
              // Input content
              buildInputBox(),
            ],
          ),

          // Loading
          buildLoader()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

// LOADER IS LOADER TILL MESSAGES NOT LOAD
  Widget buildLoader() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

// BOTTOM ENTER MESSAGEBOX UI
  Widget buildInputBox() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter your message',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: bgcolors,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

// BUILD MESSAGEBOX
  Widget buildmessageBox() {
    return Flexible(
      child: groupId == ''
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupId)
                  .collection(groupId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  message = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
