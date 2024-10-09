import 'package:flutter/material.dart';
import 'package:tokyo_mania/screen/lib/feature.dart';

/// 検索条件の状態を管理するクラス
class DetailInfoModel extends ChangeNotifier {
  Feature? _feature;

  // Getters
  Feature? get feature => _feature;

  // Setters
  void setSelectedFeature(Feature? feature) {
    _feature = feature;
    notifyListeners();
  }
}