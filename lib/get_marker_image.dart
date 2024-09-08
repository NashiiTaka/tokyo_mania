import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetMarkerImage extends StatefulWidget {
  const GetMarkerImage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GetMarkerImage();
  }
}

class _GetMarkerImage extends State<GetMarkerImage> {
  var urls = [];
  final API_KEY = "AIzaSyAX69oZWYzbY_ZRyMwHkcKseEZvw3Jiz-M";
  final KEY_WORD = "〒505-0041 岐阜県美濃加茂市太田町２６８９ 30 コミュニティ&コワーキングスペース co・ya^ne";

  Future<void> fetchPhoto() async {
    final searchRes = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$KEY_WORD&language=ja&key=$API_KEY'));

    final Map<String, dynamic> body = jsonDecode(searchRes.body);
    final place_id = body['results'][0]['place_id'];

    final placeRes = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$place_id&key=$API_KEY'));

    final Map<String, dynamic> placeData = jsonDecode(placeRes.body);

    final List photos = placeData['result']["photos"];

    for (var photo in photos) {
      final photo_reference = photo['photo_reference'];
      final url =
          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photo_reference&key=$API_KEY";
      urls.add(url);
      print(url);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
                onPressed: () async {
                  await fetchPhoto();
                },
                child: const Text('done')),
          ),
          Expanded(
            child: urls.isEmpty
                ? Container()
                : GridView.builder(
                    itemCount: urls.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final image = urls[index];

                      return _photoItem(image);
                    }),
          )
        ],
      )),
    );
  }

  Widget _photoItem(String image) {
    return Image.network(
      image,
      fit: BoxFit.cover,
    );
  }
}
