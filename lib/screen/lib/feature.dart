import 'package:json_annotation/json_annotation.dart';
import 'package:tokyo_mania/screen/lib/explanation.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

part 'feature.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class Feature {
  final int id;
  final int attractionId;
  final int viewingOrder;
  final String featureNameJp;
  final String featureNameEng;
  final String? googleMapsUrl;
  final String? googleMapsPlaceId;
  final double latMain;
  final double lngMain;
  final double latGuide;
  final double lngGuide;
  final int guideWithinMeters;
  List<Explanation>? _explanations;

  Feature({
    required this.id,
    required this.attractionId,
    required this.viewingOrder,
    required this.featureNameJp,
    required this.featureNameEng,
    this.googleMapsUrl,
    this.googleMapsPlaceId,
    required this.latMain,
    required this.lngMain,
    required this.latGuide,
    required this.lngGuide,
    required this.guideWithinMeters,
  });


  // Getter
  Future<List<Explanation>> get explanations async{
    _explanations ??= await Explanation.getByFeatureId(id);
    return _explanations!;
  }

  factory Feature.fromJson(Map<String, dynamic> json) =>
      _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);

  static Future<List<Feature>> getByAttractionId(int attractionId) async {
    final List<Feature> ret = [];
    final datas = await SupabaseUtil.client
        .from('features')
        .select()
        .eq('attraction_id', attractionId)
        .order('attraction_id', ascending: true)
        .order('viewing_order', ascending: true);
    
    for (final data in datas) {
      ret.add(Feature.fromJson(data));
    }

    return ret;
  }
}
