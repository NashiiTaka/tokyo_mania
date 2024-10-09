import 'package:flutter/material.dart';
import 'package:tokyo_mania/screen/provider/detail_info_model.dart';
import 'package:tokyo_mania/screen/provider/panel_content_model.dart';
import 'package:tokyo_mania/screen/provider/search_model.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchModel searchModel;
  final DetailInfoModel infoModel;
  final PanelContentModel panelControllerModel;

  SearchViewModel(this.searchModel, this.infoModel, this.panelControllerModel) {
    searchModel.addListener(_onSearchModelChanged);
    infoModel.addListener(_onInfoModelChanged);
  }

  void _onSearchModelChanged() {
    // 検索結果が更新されたらパネルを開く処理
    panelControllerModel.setContent(PanelContent.searchResults);
  }

  void _onInfoModelChanged() {
    // 他の情報が更新されたらパネルを開く処理
    panelControllerModel.setContent(PanelContent.detailInfo);
  }

  @override
  void dispose() {
    searchModel.removeListener(_onSearchModelChanged);
    infoModel.removeListener(_onInfoModelChanged);
    super.dispose();
  }
}