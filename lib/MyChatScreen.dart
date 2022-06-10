import 'dart:io';
import 'package:chatapp/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MyChatScreen extends StatefulWidget {
  var receiverid;
  var name;
  var email;
  var photo;

  MyChatScreen({this.receiverid, this.name, this.email, this.photo});

  @override
  State<MyChatScreen> createState() => _MyChatScreenState();
}

class _MyChatScreenState extends State<MyChatScreen> {
  var name = "";
  var email = "";
  var photo = "";
  var googleid = "";
  var senderid = "";

  bool emojiShowing = false;

  _onEmojiSelected(Emoji emoji) {
    _msg
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msg.text.length));
  }

  _onBackspacePressed() {
    _msg
      ..text = _msg.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _msg.text.length));
  }

  ImagePicker _picker = ImagePicker();
  File file;

  TextEditingController _msg = TextEditingController();
  final ScrollController _scrollcontroller = ScrollController();

  void _scrollDown() {
    _scrollcontroller.jumpTo(_scrollcontroller.position.minScrollExtent);
  }

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name");
      email = prefs.getString("email");
      photo = prefs.getString("photo");
      senderid = prefs.getString("senderid");
      googleid = prefs.getString("googleid");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(63.0),
        child: AppBar(
          backgroundColor: Colors.teal,
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),

          titleSpacing: 0,
          title: ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
              // child: Image.asset("img/flowergarden4.jpg"),
              backgroundImage: NetworkImage(widget.photo),
              radius: 28,
            ),
            title: Text(
              widget.name,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            subtitle: Text(
              widget.email,
              style: TextStyle(color: Colors.white),
            ),
          ),
          // title: Text("Stack Example"),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
            bottom: 10.0,
            left: 10.0,
            right: 70.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              height: 50.0,
              child: TextField(
                controller: _msg,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  prefixIcon:IconButton(
                    icon: Icon(
                      Icons.tag_faces_outlined,
                      color: Colors.black45,
                    ),
                    onPressed: (){
                      setState(() {
                        emojiShowing = !emojiShowing;
                      });
                    },
                  ),
                  hintText: "Message",
                  hintStyle: TextStyle(fontSize: 18),
                  suffixIcon: Container(
                    width: 150,
                    child: Row(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.attach_file_outlined,
                              color: Colors.black45,
                            ),
                            onPressed: () {}),
                        IconButton(
                            icon: Icon(
                              Icons.image,
                              color: Colors.black45,
                            ),
                            onPressed: () async {
                              // ImagePicker _picker = ImagePicker();
                              // XFile image = await _picker.pickImage(
                              //     source: ImageSource.gallery);
                              // XFile img = await _picker.pickVideo(
                              //     source: ImageSource.gallery);
                              XFile pickedimage = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              file = File(pickedimage.path);

                              var uuid = Uuid();
                              var filename = uuid.v4().toString() + ".jpg";

                              await FirebaseStorage.instance
                                  .ref(filename)
                                  .putFile(file)
                                  .whenComplete(() {})
                                  .then((filedata) async {
                                await filedata.ref
                                    .getDownloadURL()
                                    .then((fileurl) async {
                                  var timestamp =
                                      DateTime.now().millisecondsSinceEpoch;

                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(senderid)
                                      .collection("Chats")
                                      .doc(widget.receiverid)
                                      .collection("messages")
                                      .add({
                                    "senderid": senderid,
                                    "receiverid": widget.receiverid,
                                    "msg": fileurl,
                                    "timestamp": timestamp,
                                    "messagetype": "image"
                                  }).then((value) async {
                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(widget.receiverid)
                                        .collection("Chats")
                                        .doc(senderid)
                                        .collection("messages")
                                        .add({
                                      "senderid": senderid,
                                      "receiverid": widget.receiverid,
                                      "msg": fileurl,
                                      "timestamp": timestamp,
                                      "messagetype": "image"
                                    }).then((value) {
                                      _msg.text = "";
                                    });
                                  });
                                });
                              });
                            }),
                        IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Colors.black45,
                            ),
                            onPressed: () async {
                              print("Senderid :"+senderid);
                              print("receiverid :"+widget.receiverid);
                              // XFile photo = await _picker.pickImage(
                              //     source: ImageSource.camera);
                              // XFile video = await _picker.pickVideo(
                              //     source: ImageSource.camera);
                              XFile pickedimage = await _picker.pickImage(
                                  source: ImageSource.camera);
                              file = File(pickedimage.path);

                              var uuid = Uuid();
                              var filename = uuid.v4().toString() + ".jpg";

                              await FirebaseStorage.instance
                                  .ref(filename)
                                  .putFile(file)
                                  .whenComplete((){})
                                  .then((filedata) async {
                                await filedata.ref
                                    .getDownloadURL()
                                    .then((fileurl) async {
                                  var timestamp =
                                      DateTime.now().millisecondsSinceEpoch;

                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(senderid)
                                      .collection("Chats")
                                      .doc(widget.receiverid)
                                      .collection("messages")
                                      .add({
                                    "senderid": senderid,
                                    "receiverid": widget.receiverid,
                                    "msg": fileurl,
                                    "timestamp": timestamp,
                                    "messagetype": "image"
                                  }).then((value) async {
                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(widget.receiverid)
                                        .collection("Chats")
                                        .doc(senderid)
                                        .collection("messages")
                                        .add({
                                      "senderid": senderid,
                                      "receiverid": widget.receiverid,
                                      "msg": fileurl,
                                      "timestamp": timestamp,
                                      "messagetype": "image"
                                    }).then((value) {
                                      _msg.text = "";
                                    });
                                  });
                                });
                              });
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(50),
              ),
              width: 50.0,
              height: 50.0,
              child: IconButton(
                icon: Icon(
                  Icons.send_sharp,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () async {

                  // print("receiverid :"+widget.receiverid.toString());
                  // print("senderid :"+senderid);


                  var message = _msg.text.toString();
                  var timestamp =
                      DateTime.now().millisecondsSinceEpoch;
                  if(message.length!=0)
                    {
                      await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(senderid)
                          .collection("Chats")
                          .doc(widget.receiverid)
                          .collection("messages")
                          .add({
                        "senderid": senderid,
                        "receiverid": widget.receiverid,
                        "msg": message,
                        "timestamp": timestamp,
                        "messagetype": "text"
                      }).then((value) async {
                        await FirebaseFirestore.instance
                            .collection("Users")
                            .doc(widget.receiverid)
                            .collection("Chats")
                            .doc(senderid)
                            .collection("messages")
                            .add({
                          "senderid": senderid,
                          "receiverid": widget.receiverid,
                          "msg": message,
                          "timestamp": timestamp,
                          "messagetype": "text"
                        }).then((value) {
                          _msg.text = "";

                          _scrollDown();
                        });
                      });
                    }
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 70,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(senderid)
                      .collection("Chats")
                      .doc(widget.receiverid)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.size <= 0) {
                        return Center(child: Text("No message"));
                      }
                      else
                      {
                        return ListView(
                          controller: _scrollcontroller,
                          reverse: true,
                          children: snapshot.data.docs.map((document) {
                            if (document["senderid"] == senderid)
                            {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(10),
                                  child: (document["messagetype"] == "image")
                                      ? Image.network(
                                          document["msg"],
                                          width: 200,
                                        )
                                      : Text(
                                          document["msg"],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                  decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(20)),
                                ),
                              );
                            } else {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(10),
                                  child: (document["messagetype"] == "image")
                                      ? Image.network(
                                          document["msg"],
                                          width: 200,
                                        )
                                      : Text(
                                          document["msg"],
                                          style: TextStyle(color: Colors.black),
                                        ),
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          }).toList(),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
          ),
          Offstage(
            offstage: !emojiShowing,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                  onEmojiSelected: (Category category, Emoji emoji) {
                    _onEmojiSelected(emoji);
                  },
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                      columns: 7,
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFFF2F2F2),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      progressIndicatorColor: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      showRecentsTab: true,
                      recentsLimit: 28,
                      noRecentsText: 'No Recents',
                      noRecentsStyle: const TextStyle(
                          fontSize: 20, color: Colors.black26),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL)),
            ),
          ),
        ],
      ),
    );
  }
}
