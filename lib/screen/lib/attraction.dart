import 'dart:ffi';

import 'package:tokyo_mania/data/google_maps_places_detail_data.dart';
import 'package:tokyo_mania/screen/lib/feature.dart';
import 'package:tokyo_mania/screen/lib/google_places_detail_data.dart';
import 'package:tokyo_mania/screen/lib/tag.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

class Attraction {
  int attractionID;
  int categoryID;
  String attractionNameJP;
  String googleMapsURL;
  String googleMapsPlaceID;
  String explanationJP;
  String explanationENG;
  List<Tag>? _tags;
  List<Feature>? _features;
  GooglePlacesDetailData? _googlePlacesDetailData;

  // Constructor
  Attraction({
    required this.attractionID,
    required this.categoryID,
    required this.attractionNameJP,
    required this.googleMapsURL,
    required this.googleMapsPlaceID,
    required this.explanationJP,
    required this.explanationENG,
  });

  // Getter
  List<Tag> get tags {
    return _tags!;
  }

  // Getter
  Future<List<Feature>> get features async {
    _features ??= await Feature.getByAttractionId(attractionID);
    return _features!;
  }

  GooglePlacesDetailData get googlePlacesDetailData {
    _googlePlacesDetailData ??= GooglePlacesDetailData.fromJson(
        googlePlacesDetailDataJson
            .firstWhere((element) => element['id'] == googleMapsPlaceID));

    return _googlePlacesDetailData!;
  }

  static fromJson(Map<String, dynamic> json) {
    return Attraction(
      attractionID: json['id'],
      categoryID: json['category_id'],
      attractionNameJP: json['attraction_name_jp'],
      googleMapsURL: json['google_maps_url'],
      googleMapsPlaceID: json['google_maps_place_id'],
      explanationJP: json['explanation_jp'],
      explanationENG: json['explanation_eng'],
    );
  }

  static Future<List<Attraction>> getAll() async {
    final datas =
        await SupabaseUtil.client.from('attractions').select('*, tags(*)').order('id', ascending: true);

    return _fromJsonDatas(datas);
  }

  static Future<List<Attraction>> getWhere(
      int? categoryID, List<Tag>? tags) async {
    final datas =
        await SupabaseUtil.client.rpc('get_attractions_with_cond', params: {
      'in_category_id': categoryID,
      'in_tag_ids': (tags == null || tags.isEmpty)
          ? null
          : tags.map((tag) => tag.tagID).toList(),
    }).select('*, tags(*)')
    .order('id', ascending: true);

    return _fromJsonDatas(datas);
  }

  static List<Attraction> _fromJsonDatas(List<Map<String, dynamic>> datas) {
    List<Attraction> ret = [];

    for (final json in datas) {
      Attraction attraction = Attraction.fromJson(json);
      if (json['tags'] is List) {
        attraction._tags = (json['tags'] as List)
            .map((jsonTag) => Tag.fromJson(jsonTag))
            .toList();
      }
      ret.add(attraction);
    }

    return ret;
  }

  @override
  bool operator ==(Object other) {
    // 型とフィールドの値を比較する
    if (identical(this, other)) return true;

    return other is Attraction && other.attractionID == attractionID;
  }

  @override
  int get hashCode => attractionID.hashCode;
}
