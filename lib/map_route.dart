import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as directions;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RouteMapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<RouteMapScreen> {
  GoogleMapController? mapController;
  directions.GoogleMapsDirections? directionsService;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  final List<LatLng> waypoints = [
    LatLng(35.66998, 139.70225),
    LatLng(35.67402, 139.69963),
    LatLng(35.67587, 139.69941),
    LatLng(35.67509, 139.70182),
    LatLng(35.66998, 139.70225),
  ];

  @override
  void initState() {
    super.initState();
    String apiKey = String.fromEnvironment('googleMapApiKey'); // APIキーを設定
    if (apiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      print('警告: APIキーが設定されていません。有効なAPIキーを設定してください。');
    }
    directionsService = directions.GoogleMapsDirections(apiKey: apiKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Walking Route in Shibuya')),
      body: GoogleMap(
        onMapCreated: (controller) {
          setState(() {
            mapController = controller;
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(35.67298, 139.70083),
          zoom: 15,
        ),
        markers: markers,
        polylines: polylines,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createRoute(),
        child: Icon(Icons.directions_walk),
      ),
    );
  }

  void _createRoute() async {
    List<LatLng> routePoints = [];
    Set<Marker> newMarkers = {};

    for (int i = 0; i < waypoints.length - 1; i++) {
      try {
        print('Requesting directions from ${waypoints[i]} to ${waypoints[i + 1]}');
        directions.DirectionsResponse response = await directionsService!.directionsWithLocation(
          directions.Location(lat: waypoints[i].latitude, lng: waypoints[i].longitude),
          directions.Location(lat: waypoints[i + 1].latitude, lng: waypoints[i + 1].longitude),
          travelMode: directions.TravelMode.walking,
        );

        if (response.status == 'OK') {
          print('Directions request successful');
          List<PointLatLng> decodedPoints = PolylinePoints().decodePolyline(response.routes[0].overviewPolyline.points);
          print('Decoded ${decodedPoints.length} points');
          routePoints.addAll(decodedPoints.map((point) => LatLng(point.latitude, point.longitude)));

          newMarkers.add(Marker(
            markerId: MarkerId('marker_${i}'),
            position: waypoints[i],
            infoWindow: InfoWindow(title: 'Point ${i + 1}'),
          ));
        } else {
          print('Directions request failed with status: ${response.status}');
        }
      } catch (e) {
        print('Error fetching directions: $e');
      }
    }

    // Add the last waypoint marker
    newMarkers.add(Marker(
      markerId: MarkerId('marker_${waypoints.length - 1}'),
      position: waypoints.last,
      infoWindow: InfoWindow(title: 'Point ${waypoints.length}'),
    ));

    print('Total route points: ${routePoints.length}');

    setState(() {
      markers = newMarkers;
      polylines.clear(); // Clear existing polylines
      if (routePoints.isNotEmpty) {
        polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ));
        print('Polyline added');
      } else {
        print('No route points to draw polyline');
      }
    });

    // Fit the map to the route
    if (routePoints.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(
        southwest: waypoints.reduce((value, element) => LatLng(
          value.latitude < element.latitude ? value.latitude : element.latitude,
          value.longitude < element.longitude ? value.longitude : element.longitude,
        )),
        northeast: waypoints.reduce((value, element) => LatLng(
          value.latitude > element.latitude ? value.latitude : element.latitude,
          value.longitude > element.longitude ? value.longitude : element.longitude,
        )),
      );
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  @override
  void dispose() {
    directionsService?.dispose();
    super.dispose();
  }
}