import 'package:flutter/material.dart';

// 表示するコンテンツのタイプを定義
enum MapViewMode { nomal, navigating }

class MapViewModeModel extends ChangeNotifier {
  MapViewMode _currentMapViewMode = MapViewMode.nomal;
  MapViewMode get currentMapViewMode => _currentMapViewMode;

  // パネルに表示するコンテンツを変更する
  void setMapViewMode(MapViewMode newMapViewMode) {
    _currentMapViewMode = newMapViewMode;
    notifyListeners();
  }
}
