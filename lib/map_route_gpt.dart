import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreenGPT extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenGPT> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getRoute();  // ルートを取得して描画する
  }

  Future<void> _getRoute() async {
    const origin = '35.66998,139.70225';  // 出発点
    const destination = '35.66998,139.7022';  // 終点
    const waypoints = '35.67402,139.69963|35.67587,139.69941|35.67509,139.70182';  // ウェイポイント

    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin&destination=$destination&mode=walking&waypoints=$waypoints&key=${String.fromEnvironment('googleMapApiKey')}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      final decodedPoints = _decodePolyline(points);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: decodedPoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final latLng = LatLng(lat / 1E5, lng / 1E5);
      poly.add(latLng);
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Route Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(35.66998, 139.70225),  // 出発点の緯度経度
          zoom: 15.0,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        polylines: _polylines,
      ),
    );
  }
}
