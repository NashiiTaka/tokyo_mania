import 'package:flutter/material.dart';

// 表示するコンテンツのタイプを定義
enum PanelContent { none, searchResults, detailInfo, navigatingInfo }

class PanelContentModel extends ChangeNotifier {
  PanelContent _currentContent = PanelContent.none;
  PanelContent get currentContent => _currentContent;

  // パネルに表示するコンテンツを変更する
  void setContent(PanelContent content) {
    _currentContent = content;
    
    notifyListeners();
  }

  void clearContent() {
    _currentContent = PanelContent.none;
    notifyListeners();
  }
}
