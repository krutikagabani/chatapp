import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';

class LoginScreen extends StatefulWidget {

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  checklogin() async
  {
    // GoogleSignIn googleSignIn = GoogleSignIn();
    // if(await googleSignIn.isSignedIn())
    // {
    //   Navigator.of(context).pop();
    //   Navigator.of(context).push(
    //       MaterialPageRoute(builder: (context) => HomePage())
    //   );
    // }
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
    if(prefs.containsKey("islogin"))
    {
      Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePage())
      );
    }

  }

  var version="";
  getversion()async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checklogin();
    getversion();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login screen",),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset("Img/logo.png",height: 150,),
                  Container(
                    width: MediaQuery.of(context).size.width/1.2,
                    height: 80,
                    padding: EdgeInsets.all(15),
                    child: ElevatedButton(
                      onPressed: ()async{
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
                        if (googleSignInAccount != null) {
                          final GoogleSignInAuthentication googleSignInAuthentication =
                          await googleSignInAccount.authentication;
                          final AuthCredential authCredential = GoogleAuthProvider
                              .credential(
                              idToken: googleSignInAuthentication.idToken,
                              accessToken: googleSignInAuthentication.accessToken);

                          // Getting users credential
                          UserCredential result = await auth.signInWithCredential(
                              authCredential);
                          User user = result.user;

                          var name  = user.displayName.toString();
                          var email = user.email.toString();
                          var photo = user.photoURL.toString();
                          var googleid = user.uid.toString();

                          print("name : "+name);
                          print("email : "+email);
                          print("photo : "+photo);
                          print("googleid : "+googleid);

                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          prefs.setString("name", name);
                          prefs.setString("email", email);
                          prefs.setString("photo", photo);
                          prefs.setString("googleid", googleid);
                          prefs.setString("islogin", "yes");

                          await FirebaseFirestore.instance.collection("Users")
                              .where("email",isEqualTo: email).get().then((data) async{
                             if(data.size<=0)
                               {
                                 await FirebaseFirestore.instance.collection("Users").add({
                                   "name":name,
                                   "email":email,
                                   "photo":photo,
                                   "googleid":googleid
                                 }).then((document){

                                   prefs.setString("senderid",document.id.toString());

                                   Navigator.of(context).pop();
                                   Navigator.of(context).push(
                                       MaterialPageRoute(builder: (context) => HomePage())
                                   );
                                 });
                               }
                             else
                               {
                                 prefs.setString("senderid",data.docs.first.id.toString());

                                 Navigator.of(context).pop();
                                 Navigator.of(context).push(
                                     MaterialPageRoute(builder: (context) => HomePage())
                                 );
                               }
                          });
                        }
                      },
                      //icon data for elevated button
                      child:Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('Img/GoogleIcon.jpg'),
                          ),
                          // Image.asset("",height: 20,),
                          SizedBox(width: 30,),
                          Text("Login With Google",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      //label text

                    ),
                  ),

                Text("Version : "+version,style: TextStyle(fontSize: 20),),
                ],
              ),
        ),
      ),
    );
  }
}
