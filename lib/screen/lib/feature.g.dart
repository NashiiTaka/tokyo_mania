// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
      id: (json['id'] as num).toInt(),
      attractionId: (json['attraction_id'] as num).toInt(),
      viewingOrder: (json['viewing_order'] as num).toInt(),
      featureNameJp: json['feature_name_jp'] as String,
      featureNameEng: json['feature_name_eng'] as String,
      googleMapsUrl: json['google_maps_url'] as String?,
      googleMapsPlaceId: json['google_maps_place_id'] as String?,
      latMain: (json['lat_main'] as num).toDouble(),
      lngMain: (json['lng_main'] as num).toDouble(),
      latGuide: (json['lat_guide'] as num).toDouble(),
      lngGuide: (json['lng_guide'] as num).toDouble(),
      guideWithinMeters: (json['guide_within_meters'] as num).toInt(),
    );

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'id': instance.id,
      'attraction_id': instance.attractionId,
      'viewing_order': instance.viewingOrder,
      'feature_name_jp': instance.featureNameJp,
      'feature_name_eng': instance.featureNameEng,
      'google_maps_url': instance.googleMapsUrl,
      'google_maps_place_id': instance.googleMapsPlaceId,
      'lat_main': instance.latMain,
      'lng_main': instance.lngMain,
      'lat_guide': instance.latGuide,
      'lng_guide': instance.lngGuide,
      'guide_within_meters': instance.guideWithinMeters,
    };
