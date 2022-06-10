import 'package:chatapp/MyChatScreen.dart';
import 'package:chatapp/SplashScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var name = "";
  var email = "";
  var photo = "";
  var googleid = "";
  GoogleSignIn googleSignIn = GoogleSignIn();

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name");
      email = prefs.getString("email");
      photo = prefs.getString("photo");
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
      appBar: AppBar(
        title: Text("ChatApp"),
        actions: [
          IconButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove("islogin");

                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.signOut();

                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SplashScreen()));
              },
              icon: Icon(
                Icons.logout,
                size: 30.0,
              )),
        ],
      ),

      body: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection("Users").where("email",isNotEqualTo: email).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.size <= 0) {
                return Center(
                  child: Text("No Data Found"),
                );
              } else {
                return ListView(
                  children: snapshot.data.docs.map((document) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(document["photo"]),
                        radius: 30,
                      ),
                      title: Text(
                        document["name"],
                        style:
                            TextStyle(color: Color(0xFF004d40), fontSize: 18),
                      ),
                      subtitle: Text(
                        document["email"],
                        style: TextStyle(color: Colors.teal),
                      ),
                      onTap: () {
                        var docid = document.id.toString();

                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyChatScreen(receiverid: docid,name: document["name"].toString(),email: document["email"].toString(),photo: document["photo"].toString(),)));
                      },
                    );
                  }).toList(),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),

      // body: SingleChildScrollView(
      //   child: Padding(
      //     padding: EdgeInsets.all(10),
      //
      //       child: Column(
      //         children: [
      //           ListTile(
      //             contentPadding: EdgeInsets.all(0),
      //             leading: CircleAvatar(
      //              child: Text(photo),
      //               radius: 28,
      //             ),
      //             title: Text(name, style: TextStyle(color:  Color(0xFF004d40), fontSize: 18),),
      //             subtitle: Text(email, style: TextStyle(color: Colors.teal),),
      //             onTap: (){
      //               Navigator.of(context).pop();
      //               Navigator.of(context).push(MaterialPageRoute(
      //                   builder: (context) => ChatScreen()));
      //             },
      //           ),
      //
      //           Divider(
      //             height: 20,
      //             thickness: 2,
      //             color:  Color(0xFFe0f2f1 ),
      //           ),
      //
      //           SizedBox(
      //             height: 70,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
    );
  }
}
