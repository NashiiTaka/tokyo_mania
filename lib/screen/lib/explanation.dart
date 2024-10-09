import 'package:json_annotation/json_annotation.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

part 'explanation.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class Explanation {
  final int id;
  final int featureId;
  final int explanationOrder;
  final int selfGuide;
  final int guidedTour;
  final String explanationType;
  final String explanationJp;
  final String explanationEng;
  final int isGuidanceRequired;

  Explanation({
    required this.id,
    required this.featureId,
    required this.explanationOrder,
    required this.selfGuide,
    required this.guidedTour,
    required this.explanationType,
    required this.explanationJp,
    required this.explanationEng,
    required this.isGuidanceRequired,
  });

  factory Explanation.fromJson(Map<String, dynamic> json) => _$ExplanationFromJson(json);

  Map<String, dynamic> toJson() => _$ExplanationToJson(this);

  static Future<List<Explanation>> getByFeatureId(int featureId) async {
    final List<Explanation> ret = [];

    final datas = await SupabaseUtil.client.from('explanations').select().eq('feature_id', featureId).order('feature_id, explanation_order');
    for (final data in datas) {
      ret.add(Explanation.fromJson(data));
    }

    return ret;
  }
}