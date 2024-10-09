// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explanation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Explanation _$ExplanationFromJson(Map<String, dynamic> json) => Explanation(
      id: (json['id'] as num).toInt(),
      featureId: (json['feature_id'] as num).toInt(),
      explanationOrder: (json['explanation_order'] as num).toInt(),
      selfGuide: (json['self_guide'] as num).toInt(),
      guidedTour: (json['guided_tour'] as num).toInt(),
      explanationType: json['explanation_type'] as String,
      explanationJp: json['explanation_jp'] as String,
      explanationEng: json['explanation_eng'] as String,
      isGuidanceRequired: (json['is_guidance_required'] as num).toInt(),
    );

Map<String, dynamic> _$ExplanationToJson(Explanation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'feature_id': instance.featureId,
      'explanation_order': instance.explanationOrder,
      'self_guide': instance.selfGuide,
      'guided_tour': instance.guidedTour,
      'explanation_type': instance.explanationType,
      'explanation_jp': instance.explanationJp,
      'explanation_eng': instance.explanationEng,
      'is_guidance_required': instance.isGuidanceRequired,
    };
