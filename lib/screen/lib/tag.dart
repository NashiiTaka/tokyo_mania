import 'package:tokyo_mania/util/supabase_util.dart';

class Tag {
  int tagID;
  String tagNameJP;
  String tagNameENG;

  // Constructor
  Tag({
    required this.tagID,
    required this.tagNameJP,
    required this.tagNameENG,
  });

  static Tag fromJson(Map<String, dynamic> json) {
    return Tag(
      tagID: json['id'],
      tagNameJP: json['tag_name_jp'],
      tagNameENG: json['tag_name_eng'],
    );
  }

  static Future<List<Tag>> getByAttractionID(int attractionID) async {
    List<Tag> ret = [];

    final datas = await SupabaseUtil.client
        .from('attractions_tags')
        .select('tags(*)')
        .eq('attraction_id', attractionID);

    for(final data in datas){
      if(data['tags'] is Map<String, dynamic>){
        ret.add(Tag.fromJson(data['tags']));
      }
    }

    return ret;
  }

  @override
  bool operator ==(Object other) {
    // 型とフィールドの値を比較する
    if (identical(this, other)) return true;

    return other is Tag && other.tagID == tagID;
  }

  @override
  int get hashCode => tagID.hashCode;
}
