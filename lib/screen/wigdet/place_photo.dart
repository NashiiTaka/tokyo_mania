import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlacePhoto extends StatefulWidget {
  final String placeId;

  const PlacePhoto({required this.placeId});

  @override
  _PlacePhotoState createState() => _PlacePhotoState();
}

class _PlacePhotoState extends State<PlacePhoto> {
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    final apiKey = String.fromEnvironment('googleMapApiKey');
    final placeId = widget.placeId;

    // Place Details APIのエンドポイント
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey');

    // Place Detailsを取得
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final result = jsonResponse['result'];

      if (result != null && result['photos'] != null && result['photos'].isNotEmpty) {
        // photo_referenceを取得
        final photoReference = result['photos'][0]['photo_reference'];

        // Google Places Photos APIのURLを構築
        setState(() {
          photoUrl =
              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=$apiKey';
        });
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Photo'),
      ),
      body: Center(
        child: photoUrl != null
            ? Image.network(photoUrl!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
