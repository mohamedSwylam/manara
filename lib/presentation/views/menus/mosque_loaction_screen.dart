import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../constants/images.dart';

class MosqueLocationScreen extends StatefulWidget {
  const MosqueLocationScreen({super.key});

  @override
  State<MosqueLocationScreen> createState() => _MosqueLocationScreenState();
}

class _MosqueLocationScreenState extends State<MosqueLocationScreen> {

  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGoogleplex = CameraPosition(
      target: LatLng(21.4241, 39.8173),
      zoom: 12
  );

  List<Marker> _marker = [];

  Uint8List? markerImage;

  Future<Uint8List> getBytesFromAssets(String path, int width) async{
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  final String? mapApiKey = dotenv.env['map_Api_Key'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_marker.addAll(_list);
    //location();

    //Getting user current location
    getUserCurrentLocation().then((value) async {
      print("My current location");
      print(value.latitude.toString());
      print(value.longitude.toString());

      //Add marker in my current location
      _marker.add(
          Marker(
              markerId: const MarkerId('3'),
              position: LatLng(value.latitude, value.longitude),
              infoWindow: const InfoWindow(
                  title: "My current location"
              )
          )
      );

      //Animating to my current location
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 12,
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      getMosque(value.latitude.toString(), value.longitude.toString());

      setState(() {

      });

    });
  }


  //Get user current location
  Future<Position> getUserCurrentLocation() async{
    await Geolocator.requestPermission().then((value){

    }).onError((error, stackTrace) {
      print("error" + error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }


  Future<void> getMosque(String lat, String lon) async {
    try {
      // Check if API key is properly configured
      if (mapApiKey == null || 
          mapApiKey!.isEmpty || 
          mapApiKey!.contains('YOUR GOOGLE MAP API KEY HERE')) {
        print("Google Maps API key not configured. Skipping mosque search.");
        return;
      }

      String s =
          "https://maps.googleapis.com/maps/api/place/nearbysearch" +
              "/json?location=" +
              lat +
              "," +
              lon +
              "&radius=5000&types=mosque&name=mosque" +
              "&key=$mapApiKey";

      var response = await http.get(Uri.parse(s));

      print('----------------');
      printFullResponse(response);
      print('----------------');
      updateMapMarkers(response);
    } catch (e) {
      print("Error fetching mosque data: $e");
    }
  }

  Future<void> updateMapMarkers(http.Response response) async {
    final decodedResponse = json.decode(response.body);
    if (decodedResponse.containsKey('results')) {
      List<dynamic> results = decodedResponse['results'];

      final Uint8List markerIcon = await getBytesFromAssets(AssetsPath.mosqueLocation, 100);

      setState(() {
        //_marker.clear();

        for (var result in results) {
          var location = result['geometry']['location'];
          var lat = location['lat'];
          var lon = location['lng'];
          _marker.add(
            Marker(
              markerId: MarkerId(result['place_id']),
              position: LatLng(lat, lon),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: InfoWindow(title: result['name']),
            ),
          );
        }
      });
    }
  }

  Future<void> printFullResponse(http.Response response) async {
    final int maxChunkSize = 1024; // Set your preferred chunk size

    for (var i = 0; i < response.body.length; i += maxChunkSize) {
      print(response.body.substring(i, i + maxChunkSize));
    }

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(23.8041, 90.4152),
          zoom: 12,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _kGoogleplex,
        mapType: MapType.normal,
        myLocationEnabled: true,
        compassEnabled: true,
        markers: Set<Marker>.of(_marker),
        onMapCreated: (GoogleMapController controller){
          _controller.complete(controller);
        },
      ),

    );
  }
}
