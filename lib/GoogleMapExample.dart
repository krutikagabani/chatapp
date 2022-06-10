
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapExample extends StatefulWidget {
  @override
  State<GoogleMapExample> createState() => _GoogleMapExampleState();
}

class _GoogleMapExampleState extends State<GoogleMapExample> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  LatLng _center = LatLng(9.669111, 80.014007);


  GoogleMapController _controller;
  Location currentLocation = Location();
  Set<Marker> _markers = {};

  Timer timer;
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  BitmapDescriptor customIcon;

  void getLocation() async {

// make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'Img/ChatLogo1.png')
        .then((d) {
      customIcon = d;
    });

    timer = Timer.periodic(Duration(seconds: 10), (Timer t)async {
      await FirebaseFirestore.instance.collection("Employee").doc("dupXNwxKLSKDSiptEj0J").get().then((document){
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId('Home'),icon: customIcon,
              position: LatLng(double.parse(document["lattitude"].toString()),double.parse(document["longtitude"].toString()))
          ));
        });
    });

    });
    // var location = await currentLocation.getLocation();
    // currentLocation.onLocationChanged.listen((LocationData loc) {
    //   _controller
    //       ?.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
    //     target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
    //     zoom: 12.0,
    //   )));
    //   print(loc.latitude);
    //   print(loc.longitude);
    //   setState(() {
    //     _markers.add(Marker(
    //         markerId: MarkerId('Home'),
    //         position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
    //   });
    // });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Google Map example"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(
              target: LatLng(20.5937, 78.9629),
              zoom: 9,
            ),
            // markers: markers.values.toSet(),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
              // final marker = Marker(
              //   markerId: MarkerId('Adajan'),
              //   position: LatLng(21.1959, 72.7933),
              //   infoWindow: InfoWindow(
              //     title: 'title',
              //     snippet: 'address',
              //   ),
              //
              // );
              // setState(() {
              //   markers[MarkerId('Adajan')] = marker;
              //   mapController = controller;
              // });
              //
              // final marker1 = Marker(
              //   markerId: MarkerId('Adajan'),
              //   position: LatLng(21.1959, 72.7933),
              //   infoWindow: InfoWindow(
              //     title: 'title',
              //     snippet: 'address',
              //   ),
              // );
              // setState(() {
              //   markers[MarkerId('Adajan')] = marker1;
              // });
              //
              // final marker2 = Marker(
              //   markerId: MarkerId('Katargam'),
              //   position: LatLng(21.2266, 72.8312),
              //   infoWindow: InfoWindow(
              //     title: 'title',
              //     snippet: 'address',
              //   ),
              // );
              // setState(() {
              //   markers[MarkerId('Katargam')] = marker2;
              // });
              //
              // final marker3 = Marker(
              //   markerId: MarkerId('Vesu'),
              //   position: LatLng(21.1418, 72.7933),
              //   infoWindow: InfoWindow(
              //     title: 'title',
              //     snippet: 'address',
              //   ),
              // );
              // setState(() {
              //   markers[MarkerId('Vesu')] = marker3;
              // });
            },
            markers: _markers,
            // zoomGesturesEnabled: true,
            // myLocationEnabled: true,
            // compassEnabled: true,
            // myLocationButtonEnabled: false,
          ),
        ),
      ),
    );
  }
}
