import 'package:flutter/material.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';

/// 現在選択されているアトラクションを管理するクラス
class SelectedAttractionModel extends ChangeNotifier {
  Attraction? _attraction;

  // Getters
  Attraction? get attraction => _attraction;

  // Setters
  void setSelectedAttraction(Attraction? newAttraction) {
    _attraction = newAttraction;
    notifyListeners();
  }
}