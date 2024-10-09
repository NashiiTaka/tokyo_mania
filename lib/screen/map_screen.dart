import 'dart:io' show Platform;
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tokyo_mania/data/language_infos.dart';
import 'package:tokyo_mania/data/routes.dart';
import 'package:tokyo_mania/main.dart';
import 'package:tokyo_mania/screen/wigdet/markdown_with_yt.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';
import 'package:tokyo_mania/screen/lib/feature.dart';
import 'package:tokyo_mania/screen/lib/tag.dart';
import 'package:tokyo_mania/screen/provider/detail_info_model.dart';
import 'package:tokyo_mania/screen/provider/map_view_mode_model.dart';
import 'package:tokyo_mania/screen/provider/panel_content_model.dart';
import 'package:tokyo_mania/screen/provider/search_view_model.dart';
import 'package:tokyo_mania/screen/provider/selected_attraction_model.dart';
import 'package:tokyo_mania/screen/wigdet/nav_bar.dart';
import 'package:tokyo_mania/screen/wigdet/search_area.dart';
import 'package:tokyo_mania/screen/wigdet/search_result_panels.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

import 'dart:math' show pi, sin, cos, asin, atan2, pow;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PanelController _panelController = PanelController();

  /// GoogleMapsのコントローラー
  GoogleMapController? _mapController;

  /// 地図上に表示するマーカー
  Map<String, Marker> _markers = {};
  BitmapDescriptor? _iconNavCenter;
  Map<String, Feature> _remainGuideFeatures = {};
  final Set<Polyline> _polylines = {};
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 0;
  Language _currentLanguage = Language.JP; // 初期言語
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSoundPlaying = false;
  LatLng? _currentLatLng;
  bool _centerOnLocation = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  final GoogleMapsPlaces _googleMapsPlaces =
      GoogleMapsPlaces(apiKey: const String.fromEnvironment('googleMapApiKey'));

  late ScrollController _scrollController;
  Attraction? _currentAttraction;
  bool _stopListenCameraMoveStarted = true;
  bool movingByGPSPosition = false;
  late SearchViewModel _searchViewModel;
  late MapViewModeModel _mapViewModeModel;
  bool _isListenerAdded = false;
  late SelectedAttractionModel _selectedAttractionModel;
  double _currentHeading = 0;
  StreamSubscription<CompassEvent>? _compassStreamSubscription;
  bool _shouldShowNavCenter = false;
  bool _panelIsOpen = false;

  String _navBarDuration = '';
  String _navBarDistance = '';
  String _navBarTime = '';
  String _detailInfoText = '';

  CameraPosition _lastKnownCameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    tilt: 0,
    bearing: 0,
    zoom: 11,
  );

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _createCustomMarkerIcon();
    // final datas = Attraction.getAll();

    // _testFunction();

    // 再生開始時のハンドラー
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSoundPlaying = true;
      });
    });

    // 再生完了時のハンドラー
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSoundPlaying = false;
      });
    });

    // エラー時のハンドラー
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSoundPlaying = false;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(content: Text('Error: $msg')));
    });

    print('end initState();');
  }

  void _testFunction() async {
    // final datas = await Attraction.getAll();

    final datas = await Tag.getByAttractionID(3);

    // final datas =
    //     await SupabaseUtil.client.rpc('get_attractions_with_cond', params: {
    //   'in_category_id': 2,
    //   'in_tag_ids': [32, 13],
    // });

    print(datas);
  }

  Future<void> _createCustomMarkerIcon() async {
    final double width = 70;
    final double height = 60;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint ellipsePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    final Paint arrowPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // 半透明の白い楕円を描画
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(width / 2, height / 2),
            width: width,
            height: height),
        ellipsePaint);

    // 青い矢印を描画
    final Path path = Path();
    path.moveTo(width / 2, height / 4);
    path.lineTo(width * 3 / 4, height * 3 / 4);
    path.lineTo(width / 2, height * 5 / 8);
    path.lineTo(width / 4, height * 3 / 4);
    path.close();
    canvas.drawPath(path, arrowPaint);

    final img = await pictureRecorder
        .endRecording()
        .toImage(width.toInt(), height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    if (data != null) {
      setState(() {
        _iconNavCenter = BitmapDescriptor.bytes(data.buffer.asUint8List());
      });
    }
  }

  // Future<Position> _initilizaPosition() async {
  //   return await Geolocator.getCurrentPosition();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _searchViewModel = Provider.of<SearchViewModel>(context);
    _selectedAttractionModel = Provider.of<SelectedAttractionModel>(context);
    _mapViewModeModel = Provider.of<MapViewModeModel>(context);

    if (!_isListenerAdded) {
      _searchViewModel.panelControllerModel.addListener(_handlePanelChange);
      _searchViewModel.searchModel.addListener(_handleSearchChanged);
      _selectedAttractionModel.addListener(_handleSelectedAttractionChanged);
      _mapViewModeModel.addListener(_handleMapViewModeChanged);
      _isListenerAdded = true;
    }

    print('end didChangeDependencies();');
  }

  void _replaceNavCenterMarker(LatLng position) {
    if (_iconNavCenter != null) {
      setState(() {
        _markers['navigationMarker'] = Marker(
          markerId: MarkerId('navigationMarker'),
          position: position,
          icon: _iconNavCenter!,
          // マーカーの回転は不要になりました（アイコンに矢印が含まれているため）
        );
      });
    }
  }

  void _handleMapViewModeChanged() {
    if (_mapViewModeModel.currentMapViewMode == MapViewMode.navigating) {
      setState(() {
        _centerOnLocation = true;
        _shouldShowNavCenter = true;
      });

      _updateCenterLatLng(_currentLatLng!,
          stopListenCameraMoveStarted: true, tilt: 60, zoom: 18);
      _startListeningToCompass();
      print('_startListeningToCompass();');
    } else {
      _compassStreamSubscription?.cancel();
      _compassStreamSubscription = null;

      setState(() {
        _shouldShowNavCenter = false;
        _markers.remove('navigationMarker');
        _currentHeading = 0;
      });

      _updateCenterLatLng(_currentLatLng!,
          stopListenCameraMoveStarted: true, tilt: 0, zoom: 11);

      print('_compassStreamSubscription?.cancel();');
    }
  }

  void _handleSelectedAttractionChanged() async {
    if (_selectedAttractionModel.attraction != null) {
      _updateCenterLatLng(
          LatLng(
            _selectedAttractionModel
                .attraction!.googlePlacesDetailData.location.latitude,
            _selectedAttractionModel
                .attraction!.googlePlacesDetailData.location.longitude,
          ),
          zoom: 15);

      _addMarkersFromFeatureInfos(_selectedAttractionModel.attraction!);
    } else {
      LatLng? cunnrentCenter = await _getMapCenterLocation();
      if (cunnrentCenter != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: cunnrentCenter, // 現在の中心座標
              zoom: 11,
            ),
          ),
        );
      }

      _handleSearchChanged();
    }
  }

  Future<LatLng?> _getMapCenterLocation() async {
    if (_mapController == null) return null;

    LatLngBounds bounds = await _mapController!.getVisibleRegion();
    LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    return center;
  }

  void _handlePanelChange() {
    if (_searchViewModel.panelControllerModel.currentContent !=
        PanelContent.none) {
      _panelController.animatePanelToPosition(1);
    }
    // 他の条件も必要に応じて追加
  }

  void _handleSearchChanged() {
    _addMarkersFromSearchedAttractions();
    // 他の条件も必要に応じて追加
  }

  @override
  void dispose() {
    debugPrint('Dispose method called for ${widget.runtimeType}');
    _searchViewModel.panelControllerModel.removeListener(_handlePanelChange);
    _searchViewModel.searchModel.removeListener(_handleSearchChanged);
    _selectedAttractionModel.removeListener(_handleSelectedAttractionChanged);

    _isListenerAdded = false;

    // TODO: 要、Dispose時の破棄、Logout時にDispose&再ログイン時にエラーが出ているため、コメントアウトしている。
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    // _positionStreamSubscription?.cancel();
    // _compassStreamSubscription?.cancel();
    super.dispose();
  }

  void _startListeningToLocationChanges() {
    print('_startListeningToLocationChanges');

    // https://chatgpt.com/share/f3a83b58-3d9c-4c50-afee-c0125baee1d8
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(_updatePosition);
  }

  void _startListeningToCompass() {
    _compassStreamSubscription ??=
        FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        _currentHeading = event.heading!;
        if (_centerOnLocation) {
          _updateCenterLatLng(_currentLatLng!,
              stopListenCameraMoveStarted: true);
        }
      }
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastKnownCameraPosition = position;
  }

  double _calculateDistanceBasedOnZoom(double zoom, double offsetRatio) {
    // ズームレベルに基づいて適切な距離を計算
    // この計算は近似値であり、必要に応じて調整が必要です
    double baseDistance = 120; // 基準距離（メートル）
    double zoomFactor = pow(2, 20 - zoom) as double; // 20はベースズームレベル
    return baseDistance * zoomFactor * offsetRatio;
  }

  void _updatePosition(Position position) {
    print('_updatePosition: ${position.latitude}, ${position.longitude}');
    _currentLatLng = LatLng(position.latitude, position.longitude);
    // _currentLatLng = LatLng(35.600794, 139.702250);

    // センターをユーザー位置に合わせて更新する場合のみ、センターの変更を実行する。
    if (_centerOnLocation) {
      _updateCenterLatLng(_currentLatLng!, stopListenCameraMoveStarted: true);
      print('_updatePosition: _updateCenterLatLng(_currentLatLng!);');
    }

    // TODO: 距離チェックは一旦停止
    // 各マーカーとの距離をチェック
    if (_remainGuideFeatures.isNotEmpty) {
      final nextFeature = _remainGuideFeatures.values.toList()[0];

      double distanceInMeters = Geolocator.distanceBetween(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
        nextFeature.latGuide,
        nextFeature.lngGuide,
      );

      // print('Distance to ${feature['featureNameJP']}: $distanceInMeters M');

      if (distanceInMeters <= nextFeature.guideWithinMeters) {
        // マーカーのonTapイベントを呼び出す
        // _remainGuideFeaturesからの削除処理は、タップイベント内で実施
        _markers[nextFeature.id.toString()]!.onTap?.call();
      }

      // ナビゲーション中は、次の目的地までの距離等の情報を計算する。
      if (_mapViewModeModel.currentMapViewMode == MapViewMode.navigating) {
        setState(() {
          if (distanceInMeters >= 1000) {
            _navBarDistance =
                (distanceInMeters / 1000).toStringAsFixed(2) + 'km';
          } else {
            _navBarDistance = '$distanceInMeters km';
          }
        });
      }
    }
  }

  LatLng _calculateTargetPosition(
      LatLng currentPosition, double bearing, double zoom, double offsetRatio) {
    double distanceInMeters = _calculateDistanceBasedOnZoom(zoom, offsetRatio);

    // 緯度経度を度からラジアンに変換
    double lat1 = currentPosition.latitude * (pi / 180);
    double lon1 = currentPosition.longitude * (pi / 180);
    double bearingRad = bearing * (pi / 180);

    // 地球の半径（メートル）
    const double R = 6378137;

    // 新しい緯度を計算
    double lat2 = asin(sin(lat1) * cos(distanceInMeters / R) +
        cos(lat1) * sin(distanceInMeters / R) * cos(bearingRad));

    // 新しい経度を計算
    double lon2 = lon1 +
        atan2(sin(bearingRad) * sin(distanceInMeters / R) * cos(lat1),
            cos(distanceInMeters / R) - sin(lat1) * sin(lat2));

    // ラジアンから度に戻す
    return LatLng(lat2 * (180 / pi), lon2 * (180 / pi));
  }

  void _updateCenterLatLng(LatLng latLng,
      {double? zoom, bool stopListenCameraMoveStarted = false, double? tilt}) {
    // _currentHeading = 270;
    if (_mapController != null) {
      LatLng targetPosition = latLng;
      if (_mapViewModeModel.currentMapViewMode == MapViewMode.navigating) {
        targetPosition = _calculateTargetPosition(latLng, _currentHeading,
            zoom ?? _lastKnownCameraPosition.zoom, 1 / 3);
      }

      final newPosition = CameraPosition(
        target: targetPosition,
        zoom: zoom ?? _lastKnownCameraPosition.zoom,
        tilt: tilt ?? _lastKnownCameraPosition.tilt,
        bearing: _currentHeading,
      );

      final newCameraPosition = CameraUpdate.newCameraPosition(newPosition);

      _lastKnownCameraPosition = newPosition;

      if (_shouldShowNavCenter) {
        _replaceNavCenterMarker(_currentLatLng!);
      }

      if (stopListenCameraMoveStarted) {
        _stopListenCameraMoveStarted = true;
        print('_updateCenterLatLng: _stopListenCameraMoveStarted = true;');
        _mapController!.animateCamera(newCameraPosition);
      } else {
        _mapController!.animateCamera(newCameraPosition);
        print('_updateCenterLatLng: 制御なし');
      }
    }
  }

  void _onCameraMoveStarted() {
    if (_stopListenCameraMoveStarted) {
      print('_onCameraMoveStarted: _stopListenCameraMoveStarted');
      return;
    }
    // If the map is moved manually, stop centering on location
    _centerOnLocation = false;

    print('_onCameraMoveStarted: _centerOnLocation = false;');
  }

  void _onReturnToCurrentLocation() {
    if (_currentLatLng != null) {
      print('_onReturnToCurrentLocation: _centerOnLocation = true;');
      _centerOnLocation = true;
      _updateCenterLatLng(_currentLatLng!, stopListenCameraMoveStarted: true);
    }
  }

  void _onCameraIdle() {
    _stopListenCameraMoveStarted = false;
    print('_onCameraIdle: _stopListenCameraMoveStarted = false;');
  }

  void _onMapCreated(GoogleMapController controller) async {
    print('_onMapCreated');
    _mapController = controller;
    _startListeningToLocationChanges();
  }

  /// 検索結果が更新されたら、該当するマーカーを更新する非同期メソッド
  Future<void> _addMarkersFromSearchedAttractions() async {
    List<Attraction> attractions =
        _searchViewModel.searchModel.searchedAttractions;
    Map<String, Marker> newMarkers = {};

    for (final attraction in attractions) {
      final gdata = attraction.googlePlacesDetailData;

      final marker = Marker(
        markerId: MarkerId(
          gdata.id,
        ), // Place IDをMarker IDとして設定
        position: LatLng(
          gdata.location.latitude, // 緯度を設定
          gdata.location.longitude, // 経度を設定
        ),
        // infoWindowは表示させない
        // infoWindow: InfoWindow(
        //   title: feature['FeatureName-JP'], // マーカーのタイトルを場所の名前に設定
        // ),
        icon: attraction == _currentAttraction
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        // マーカーがタップされた時の処理
        onTap: () {
          // setState(() {
          //   final tappedMarker = _markers[featureId];
          //   if (tappedMarker != null && tappedMarker.icon != customIconAft) {
          //     _markers[featureId] = tappedMarker.copyWith(
          //       iconParam: customIconAft,
          //     );
          //     // 案内予定のマーカーをリストから削除
          //     _remainGuideFeatures.remove(featureId);
          //   }
          // });

          // // 詳細情報の選択情報を更新する
          // Provider.of<DetailInfoModel>(context, listen: false)
          //     .setSelectedFeatureID(feature['featureID']);
        },
      );

      newMarkers[gdata.id] = marker;
    }

    // setStateでマーカーリスト更新
    setState(() {
      _markers = newMarkers;
    });
  }

  // アトラクション特定後、その中のフィーチャーマーカーを生成するする非同期メソッド
  Future<void> _addMarkersFromFeatureInfos(Attraction attraction) async {
    var numOfGuidance = 0;
    _markers.clear();
    _remainGuideFeatures.clear();

    final newMarkers = <String, Marker>{};
    final newRemainGuideFeatures = <String, Feature>{};

    final featuresByAttractionId =
        await Feature.getByAttractionId(attraction.attractionID);

    for (var i = 0; i < featuresByAttractionId.length; i++) {
      final feature = featuresByAttractionId[i];
      final containsGuidanceRequired =
          (await feature.explanations).any((e) => e.isGuidanceRequired == 1);

      double? lat;
      double? lng;
      BitmapDescriptor? customIconPre;
      BitmapDescriptor? customIconAft;

      if (!containsGuidanceRequired) {
        customIconPre =
            await _createIcon('assets/images/markers/information.png');
        customIconAft = customIconPre;
      } else {
        numOfGuidance++;
        customIconPre = await _createIcon(
            'assets/images/markers/red${numOfGuidance.toString().padLeft(2, '0')}.png');
        customIconAft = await _createIcon(
            'assets/images/markers/gray${numOfGuidance.toString().padLeft(2, '0')}.png');
      }

      final featureIdString = feature.id.toString();

      // マーカーを作成し、取得した場所の緯度・経度を設定
      final marker = Marker(
        markerId: MarkerId(
          featureIdString,
        ), // Place IDをMarker IDとして設定
        position: LatLng(
          feature.latMain, // 緯度を設定
          feature.lngMain, // 経度を設定
        ),
        // infoWindowは表示させない
        // infoWindow: InfoWindow(
        //   title: feature['FeatureName-JP'], // マーカーのタイトルを場所の名前に設定
        // ),
        icon: customIconPre,
        // マーカーがタップされた時の処理
        onTap: () {
          setState(() {
            final tappedMarker = _markers[featureIdString];
            if (tappedMarker != null && tappedMarker.icon != customIconAft) {
              _markers[featureIdString] = tappedMarker.copyWith(
                iconParam: customIconAft,
              );
              // 案内予定のマーカーをリストから削除
              _remainGuideFeatures.remove(featureIdString);
            }
          });

          // 詳細情報の選択情報を更新する
          Provider.of<DetailInfoModel>(context, listen: false)
              .setSelectedFeature(feature);

          _generateText(feature);
        },
      );

      newMarkers[featureIdString] = marker;
      newRemainGuideFeatures[featureIdString] = feature;
    }

    setState(() {
      _markers = newMarkers;
      _remainGuideFeatures = newRemainGuideFeatures;
      _createPolylines();
    });
  }

  Future<AssetMapBitmap> _createIcon(String path) {
    return BitmapDescriptor.asset(
      const ImageConfiguration(
        size: Size(28, 28),
      ),
      path,
    );
  }

  void _createPolylines() {
    setState(() {
      final List<LatLng> points = [];

      for (var element in routes) {
        points.add(LatLng(element['lat'], element['lng']));
      }

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: googleMapsLightBlue,
          width: 8,
          points: points,
          patterns: Platform.isIOS
              ? [
                  PatternItem.dash(10), // iOSでは小さなダッシュを使用
                  PatternItem.gap(10),
                ]
              : [
                  PatternItem.dot, // Androidではドットを使用
                  PatternItem.gap(5),
                ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // https://chatgpt.com/share/f5a1368e-6390-47d9-b625-27e81b8067e6

    // パネルの高さを画面の高さを設定
    switch (Provider.of<SearchViewModel>(context)
        .panelControllerModel
        .currentContent) {
      case PanelContent.searchResults:
        _panelHeightOpen = MediaQuery.of(context).size.height * 0.5;
        break;
      case PanelContent.detailInfo:
        _panelHeightOpen = MediaQuery.of(context).size.height * 0.8;
        break;
      case PanelContent.navigatingInfo:
        _panelHeightOpen = MediaQuery.of(context).size.height * 0.2;
        break;
      case PanelContent.none:
        _panelHeightOpen = MediaQuery.of(context).size.height * 0.0;
        break;
    }

    // _panelHeightOpen = MediaQuery.of(context).size.height * 0.7;

    return FutureBuilder(
      future: futureInitilizePosition,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final pos = snapshot.data as Position;
          _currentLatLng = LatLng(pos.latitude, pos.longitude);

          return Scaffold(
            // マテリアルデザインのスタイルを適用するためのウィジェットを提供します https://chatgpt.com/share/f811d628-0eb4-4b76-b551-3332dd996065
            body: Stack(
              // ウィジェットを重ねて配置する https://chatgpt.com/share/2ce55e74-f823-4c9f-9413-fd9c1e113b11
              alignment:
                  Alignment.topCenter, // 子ウィジェットをStackの上端中央に配置することを意味します。
              children: <Widget>[
                // SlidingUpPanelウィジェットを表示
                SlidingUpPanel(
                  controller: _panelController,
                  maxHeight: _panelHeightOpen, // パネルの最大高さを設定
                  minHeight: _panelHeightClosed, // パネルの最小高さを設定
                  parallaxEnabled:
                      true, // パララックス効果を有効にする + パララックス効果とは、異なるオブジェクトが異なる速度で移動することで、深さや距離感を生み出す視覚的効果です。通常、背景と前景の要素が異なる速度で動くことで、より立体的な感じを演出します。
                  parallaxOffset: .5, // パララックス効果のオフセットを設定
                  body: _body(), // パネルの下部に表示するコンテンツ
                  panelBuilder: (sc) => _panel(sc), // パネルのビルダー関数
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0), // パネルの左上の角を丸める
                    topRight: Radius.circular(18.0), // パネルの右上の角を丸める
                  ),
                  onPanelClosed: () {
                    print('onPanelClosed');
                    setState(() {
                      _panelIsOpen = false;
                    });
                  },
                  onPanelOpened: () {
                    print('onPanelOpened');
                    setState(() {
                      _panelIsOpen = true;
                    });
                  },
                ),
                // トップの検索画面は、ナビゲーションモードの場合は表示しない
                if (_mapViewModeModel.currentMapViewMode !=
                    MapViewMode.navigating)
                  SafeArea(
                    child: SearchArea(),
                  ),
                // パネル内容があり、パネルが閉じられている場合は、サブインフォウィンドウを下に表示する。
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 0,
                  right: 0,
                  bottom: !_panelIsOpen &&
                          _searchViewModel
                                  .panelControllerModel.currentContent ==
                              PanelContent.searchResults
                      ? 0
                      : -50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      _panelController.open();
                    },
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        'リスト表示',
                        style: TextStyle(color: googleMapsBlue, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // パネル裏のマップを表示するWidget
  Widget _body() {
    return Scaffold(
      // アプリの基本的な構造を提供するためのウィジェットです。
      // appBar: AppBar(
      //   title: Text('Google Maps Example'),
      // ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLatLng ??
                  const LatLng(35.6585, 139.7010), // Shibuya Station
              zoom: 11.0,
            ),
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            myLocationEnabled:
                Provider.of<MapViewModeModel>(context).currentMapViewMode !=
                    MapViewMode.navigating, //現在位置をマップ上に表示
            myLocationButtonEnabled: false,
            onCameraIdle: _onCameraIdle,
            onCameraMoveStarted: _onCameraMoveStarted,
            onCameraMove: _onCameraMove,
            buildingsEnabled:
                Provider.of<MapViewModeModel>(context).currentMapViewMode ==
                    MapViewMode.nomal, // 建物を表示しない
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'moveToCurrentLocationButton',
              onPressed: _onReturnToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: 'logoutButton',
              child: const Icon(Icons.logout),
              onPressed: () async {
                await SupabaseUtil.client.auth.signOut();
                // Navigator.pushNamed(context, '/');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController? sc) {
    return Consumer<SearchViewModel>(
      builder: (context, searchViewModel, child) {
        switch (searchViewModel.panelControllerModel.currentContent) {
          case PanelContent.searchResults:
            return SearchResultPanels(
              scrollController: sc!,
              onFocusedAttractionChanged: (Attraction attraction) {
                _updateCenterLatLng(
                  LatLng(
                    attraction.googlePlacesDetailData.location.latitude,
                    attraction.googlePlacesDetailData.location.longitude,
                  ),
                );

                setState(() {
                  if (_currentAttraction != null &&
                      _markers[_currentAttraction!.googlePlacesDetailData.id] !=
                          null) {
                    _markers[_currentAttraction!.googlePlacesDetailData.id] =
                        _markers[_currentAttraction!.googlePlacesDetailData.id]!
                            .copyWith(
                      iconParam: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                    );
                    print(
                        '${_currentAttraction!.attractionNameJP} のアイコンをデフォルトに');
                  }

                  if (_markers[attraction.googlePlacesDetailData.id] != null) {
                    _markers[attraction.googlePlacesDetailData.id] =
                        _markers[attraction.googlePlacesDetailData.id]!
                            .copyWith(
                      iconParam: BitmapDescriptor.defaultMarker,
                    );
                    print('${attraction.attractionNameJP} のアイコンをカスタムに');
                  }

                  _currentAttraction = attraction;
                });
              },
            );
          case PanelContent.detailInfo:
            return CustomScrollView(
              // controller: sc,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: DynamicSliverPersistentHeaderDelegate(
                    // child: Container(
                    //   color: Colors.lightBlue,
                    child: _buildButtonArea(_detailInfoText),
                    // ),
                  ),
                ),
                // SliverToBoxAdapter(
                //   child: _buildButtonArea(txt),
                // ),
                SliverFillRemaining(
                  child: CustomMarkdownWidget(
                      data: _detailInfoText, controller: sc),
                ),
              ],
            );
          case PanelContent.navigatingInfo:
            return NavBar(
                // duration: _navBarDuration,
                // distance: _navBarDistance,
                // time: _navBarTime,
                duration: '2分',
                distance: _navBarDistance,
                time: '11:03',
                onEndNavigation: () {
                  _mapViewModeModel.setMapViewMode(MapViewMode.nomal);
                  _searchViewModel.panelControllerModel
                      .setContent(PanelContent.searchResults);
                });
          case PanelContent.none:
            return const Text('none');
          default:
            throw Exception('Invalid PanelContent');
        }
      },
    );
  }

  void _generateText(Feature? feature) async {
    String txt = '';
    if (feature == null) {
      setState(() {
        _detailInfoText = '';
      });
      return;
    }

    // 詳細情報の表題を取得
    final String caption = _currentLanguage == Language.JP
        ? feature.featureNameJp
        : feature.featureNameEng;

    // 1つのFeatureに対して複数の詳細情報が存在するため、連結
    // TODO: 本来はページングで実装したい
    (await feature.explanations)
        .where((e) => e.featureId == feature.id)
        .forEach((e) {
      txt +=
          '${_currentLanguage == Language.JP ? e.explanationJp : e.explanationEng}  　  　\n\n';
    });

    setState(() {
      _detailInfoText = '# $caption  \n${txt.replaceAll('\n', '　  　  \n')}';
    });
  }

  Widget _buildButtonArea(String txt) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      // constraints: BoxConstraints(minHeight: 100), // 最小高さを設定
      child: Column(
        // mainAxisSize: MainAxisSize.min, // これを追加
        children: [
          const SizedBox(height: 8),
          // Container(
          //   height: 5,
          //   width: 100,
          //   margin: EdgeInsets.only(top: 10),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[400],
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          // ),
          // SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageButton(Language.JP),
              const SizedBox(width: 10),
              _buildLanguageButton(Language.English),
              const SizedBox(width: 10),
              _buildSpeakButton(txt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(Language language) {
    return ElevatedButton(
      onPressed: () => _handleLanguageChange(language),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _currentLanguage == language ? Colors.blue : Colors.grey,
      ),
      child: Text(
        languageInfos[language]!.display,
        style: TextStyle(
          color: _currentLanguage == language ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSpeakButton(String txt) {
    return ElevatedButton(
      onPressed: () {
        _isSoundPlaying ? _stopSpeak() : _startSpeak(txt);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: Text(
        _isSoundPlaying ? 'Stop' : 'Speak',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Future _startSpeak(String value) async {
    if (_isSoundPlaying) {
      await _stopSpeak();
    }

    value = value.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');

    await _flutterTts
        .setLanguage(languageInfos[_currentLanguage]!.languageCode); // 英語の設定
    await _flutterTts.setSpeechRate(0.5); // 速度調整
    await _flutterTts.setPitch(1.00); // 音程
    await _flutterTts.speak(value); // 読み上げるテキスト
  }

  Future _stopSpeak() async {
    await _flutterTts.stop(); // 再生を中止
    setState(() {
      _isSoundPlaying = false; // 中止した場合も再生状態を false に更新
    });
  }

  void _handleLanguageChange(Language language) {
    setState(() {
      _currentLanguage = language;
    });
    // 言語変更の処理をここに記述
    print('選択された言語: ${languageInfos[language]!.display}');
    // ここで必要な処理を追加
  }
}

class DynamicSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  double _height = 60; // 初期高さ
  VoidCallback? _triggerRebuild;

  DynamicSliverPersistentHeaderDelegate({required this.child});

  void updateHeight(Size size) {
    if (_height != size.height) {
      _height = size.height;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerRebuild?.call();
      });
    }
  }

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _triggerRebuild = () {
          if (constraints.biggest.height != _height) {
            (context as Element).markNeedsBuild();
          }
        };
        return SizeReportingWidget(
          onSizeChange: updateHeight,
          child: child,
        );
      },
    );
  }

  @override
  bool shouldRebuild(
      covariant DynamicSliverPersistentHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || _height != oldDelegate._height;
  }
}

class SizeReportingWidget extends SingleChildRenderObjectWidget {
  final void Function(Size size) onSizeChange;

  const SizeReportingWidget({
    super.key,
    required this.onSizeChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SizeReportingRenderObject(onSizeChange);
  }
}

class SizeReportingRenderObject extends RenderProxyBox {
  final void Function(Size size) onSizeChange;
  Size? _oldSize;

  SizeReportingRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child!.size;
    if (_oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSizeChange(newSize);
      });
    }
  }
}
