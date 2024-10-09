import 'package:flutter/material.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';
import 'package:tokyo_mania/screen/lib/tag.dart';

/// 検索条件の状態を管理するクラス
class SearchModel extends ChangeNotifier {
  String? _categoryID;
  final List<Tag> _tags = [];
  List<Attraction> _searchedAttractions = [];

  // Getters
  String? get categoryID => _categoryID;
  List<Tag> get tags => _tags;
  List<Attraction> get searchedAttractions => _searchedAttractions;

  // Setters
  Future<void> setSelectedCategoryID(String? categoryID) async {
    // カテゴリが変更された場合は、タグの選択状態もリセットする。
    if(_categoryID != categoryID){
      _tags.clear();
    }

    // 後続処理もこの条件のみで良さそうだが、再表示すると開発が楽なので、同カテゴリであっても更新処理を実行する。
    _categoryID = categoryID;
    await updateSearchResults();
    notifyListeners();
    print('notify from setSelectedCategoryID');
  }

  Future<void> addTag(Tag tag) async {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
      await updateSearchResults();
      notifyListeners();
      print('notify from addTag');
    }
  }

  Future<void> removeTag(Tag tag) async {
    if (_tags.remove(tag)) {
      await updateSearchResults();
      notifyListeners();
      print('notify from removeTag');
    }
  }

  Future<void> updateSearchResults() async {
    if (_categoryID == null) {
      if (_searchedAttractions.isNotEmpty) {
        _searchedAttractions.clear();
      }
    } else {
      _searchedAttractions = await Attraction.getWhere(
          categoryID == null ? null : int.tryParse(categoryID!), _tags);
    }

    print('_searchedAttractions.length: ${_searchedAttractions.length}');
  }
}