import 'package:flutter/material.dart';

class ThankYouPage extends StatefulWidget {
  @override
  State<ThankYouPage> createState() => _ThankYouPageState();
}

class _ThankYouPageState extends State<ThankYouPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thankyou page"),
      ),
      body: Center(
        child: Image.asset("Img/Payment-Received.jpg"),
      ),
    );
  }
}
