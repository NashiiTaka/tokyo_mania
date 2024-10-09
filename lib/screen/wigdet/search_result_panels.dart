import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tokyo_mania/data/google_maps_places_detail_data.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';
import 'package:tokyo_mania/screen/lib/google_places_detail_data.dart';
import 'package:tokyo_mania/screen/provider/map_view_mode_model.dart';
import 'package:tokyo_mania/screen/provider/panel_content_model.dart';
import 'package:tokyo_mania/screen/provider/search_model.dart';
import 'package:tokyo_mania/screen/provider/selected_attraction_model.dart';
import 'package:tokyo_mania/screen/wigdet/search_area.dart';
import 'package:tokyo_mania/screen/wigdet/selective_tap_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io';

// Google Mapsの青色により近いカスタムカラーを定義
const Color googleMapsBlue = Color.fromARGB(255, 11, 83, 198);
const Color googleMapsLightBlue = Color.fromARGB(255, 23, 106, 239);

class SearchResultPanels extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(Attraction) onFocusedAttractionChanged;

  const SearchResultPanels({
    super.key,
    required this.scrollController,
    required this.onFocusedAttractionChanged,
  });

  @override
  _SearchResultPanelsState createState() => _SearchResultPanelsState();
}

class _SearchResultPanelsState extends State<SearchResultPanels> {
  final _panelKey = GlobalKey();
  late List<GlobalKey> _attractionKeys;
  late List<Attraction> _attractions;
  int? _preFocusedIndex;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('【initState】WidgetsBinding.instance.addPostFrameCallback');
      _onScroll(); // 初期位置での実行
      print('scrollToTop');
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    // widget.scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // パネルの上部の位置を取得
    final RenderBox? panelRenderBox =
        _panelKey.currentContext?.findRenderObject() as RenderBox?;
    if (panelRenderBox == null) return;

    final panelTopOffset = panelRenderBox.localToGlobal(Offset.zero).dy;

    for (int i = 0; i < _attractionKeys.length; i++) {
      final RenderBox? renderBox =
          _attractionKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        // カードの位置を取得
        final position = renderBox.localToGlobal(Offset.zero).dy;

        // パネルの上部に対する位置を判断
        if (position >= panelTopOffset &&
            position <= panelTopOffset + 30 &&
            _preFocusedIndex != i) {
          HapticFeedback.lightImpact();
          _centerMapOnAttraction(i);
          _preFocusedIndex = i;
          break;
        }
      }
    }
  }

  void _centerMapOnAttraction(int index) {
    print('focused attraction index $index');
    widget.onFocusedAttractionChanged(_attractions[index]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preFocusedIndex = null;

    // 描画が完了した後に一度だけ実行したい処理
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('WidgetsBinding.instance.addPostFrameCallback');
        _onScroll(); // 初期位置での実行
        print('scrollToTop');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _attractions = Provider.of<SearchModel>(context).searchedAttractions;
    _attractionKeys =
        List.generate(_attractions.length, (_) => GlobalKey()); // キーを初期化
    const apiKey = String.fromEnvironment('googleMapApiKey');

    return Consumer<SearchModel>(
      builder: (context, provider, child) {
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (widget.scrollController.hasClients) {
        //     widget.scrollController.animateTo(
        //       0,
        //       duration: Duration(milliseconds: 300),
        //       curve: Curves.easeOut,
        //     );
        //     print('scrollToTop');
        //     ;
        //   }
        // });
        print('build SearchResultPanels');

        return Scaffold(
          key: _panelKey,
          backgroundColor: Colors.white,
          body: CustomScrollView(
            controller: widget.scrollController, // ScrollControllerを渡す
            slivers: [
              // スワイプ可能を表すハンドル
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: 80,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // final attraction = _attractions[index];
                    final data = _attractions[index].googlePlacesDetailData;
                    return Column(
                      children: [
                        AttractionCard(
                          key: _attractionKeys[index],
                          name: data.displayName.text,
                          rating: data.rating,
                          reviews: data.userRatingCount,
                          // distance: '${290 + index * 50} m',
                          type: data.primaryTypeDisplayName.text,
                          // price: 'お手頃',
                          // accessibility: '♿',
                          // status: '営業時間外',
                          // openingTime: '営業開始: 18:00',
                          summary: data.editorialSummary?.text,
                          images: List.generate(
                              data.photos.length,
                              // 1, // TODO: API費用節約のため、1枚だけ表示
                              (i) =>
                                  'https://places.googleapis.com/v1/${data.photos[i].name}/media?key=$apiKey&maxHeightPx=150&maxWidthPx=150&skipHttpRedirect=false'
                              // 'https://via.placeholder.com/150?text=${index + 1}-${i + 1}',
                              ),
                          attraction: _attractions[index],
                        ),
                        if (index == _attractions.length - 1 &&
                            _attractions.length > 1)
                          SizedBox(
                              height:
                                  300), // 最終要素の後に余白を追加、パネル上端に達した時のイベントを発動させるため
                      ],
                    );
                  },
                  childCount: _attractions.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AttractionCard extends StatelessWidget {
  final String name;
  final double? rating;
  final int reviews;
  // final String distance;
  final String type;
  // final String price;
  // final String accessibility;
  // final String status;
  // final String openingTime;
  final String? summary;
  final List<String> images;
  final Attraction attraction;

  const AttractionCard({
    Key? key,
    required this.name,
    required this.rating,
    required this.reviews,
    // required this.distance,
    required this.type,
    // required this.price,
    // required this.accessibility,
    // required this.status,
    // required this.openingTime,
    required this.summary,
    required this.images,
    required this.attraction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationButtonKey = GlobalKey();
    final directionButtonKey = GlobalKey();
    final telButtonKey = GlobalKey();

    return SelectiveTapCard(
      ignoreKeys: [navigationButtonKey, directionButtonKey, telButtonKey],
      margin: EdgeInsets.all(8),
      onCardTap: () {
        print('onCardTap: $name');
        Provider.of<SelectedAttractionModel>(context, listen: false)
            .setSelectedAttraction(attraction);
      },
      myChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 8 : 0, right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text('${rating ?? '評価なし'} ',
                        style: TextStyle(color: Colors.grey.shade800)),
                    ...List.generate(rating == null ? 0 : 5, (index) {
                      final currentRating = index + 1;
                      final tgt = rating! - currentRating;
                      if (-0.25 <= tgt) {
                        return Icon(Icons.star, color: Colors.amber, size: 16);
                      } else if (-0.75 <= rating! - currentRating &&
                          rating! - currentRating < -0.25) {
                        return Icon(Icons.star_half,
                            color: Colors.amber, size: 16);
                      } else {
                        return Icon(Icons.star_border,
                            color: Colors.amber, size: 16);
                      }
                    }),
                    SizedBox(width: 4),
                    // Text('$rating ($reviews) · $distance',
                    //     style: TextStyle(color: Colors.grey)),
                    Text(
                      rating != null
                          ? ' (${NumberFormat('#,###').format(reviews)})'
                          : '',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
                // Text('$type · $price · $accessibility'),
                Text('$type'),
                // Text('$status · $openingTime',
                //     style: TextStyle(color: Colors.red)),
                SizedBox(height: 4),
                Text('$summary'),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildActionButton(
                          navigationButtonKey, Icons.navigation, '開始',
                          hanten: true, onPressed: () {
                        Provider.of<MapViewModeModel>(context, listen: false)
                            .setMapViewMode(MapViewMode.navigating);
                        Provider.of<PanelContentModel>(context, listen: false)
                            .setContent(PanelContent.navigatingInfo);
                      }),
                      SizedBox(width: 8),
                      _buildActionButton(
                          directionButtonKey, Icons.directions, '経路',
                          onPressed: () =>
                              launchGoogleMapsDirectionsWithPlaceId(
                                  attraction.googlePlacesDetailData)),
                      SizedBox(width: 8),
                      _buildActionButton(
                        telButtonKey,
                        Icons.phone,
                        '電話',
                        onPressed: () {
                          if (attraction.googlePlacesDetailData
                                  .internationalPhoneNumber !=
                              null)
                            makePhoneCall(attraction.googlePlacesDetailData
                                .internationalPhoneNumber!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Key? key, IconData icon, String label,
      {Function()? onPressed, bool hanten = false}) {
    final foreColor = hanten ? Colors.white : googleMapsBlue;
    final backColor = hanten ? googleMapsBlue : googleMapsBlue.withOpacity(0.1);

    return ElevatedButton.icon(
      key: key,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: foreColor,
        size: 20,
        weight: 700,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: foreColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: foreColor,
        backgroundColor: backColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<void> launchGoogleMapsWithPlaceId(String placeId) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=Google&query_place_id=$placeId';

    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl);
    } else {
      throw 'Google Mapsを開けませんでした';
    }
  }

  Future<void> launchGoogleMapsDirectionsWithPlaceId(
      GooglePlacesDetailData placeData) async {
    final String destination = Uri.encodeComponent(placeData.displayName.text);
    final String placeId = placeData.id;

    Uri? mapsUrl;

    if (Platform.isAndroid) {
      mapsUrl = Uri.parse(
          'google.navigation:q=$destination&mode=d&destination_place_id=$placeId');
    } else if (Platform.isIOS) {
      mapsUrl = Uri.parse(
          'comgooglemaps://?daddr=$destination&destination_place_id=$placeId&directionsmode=transit');
    }

    if (mapsUrl != null && await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // フォールバック: ウェブブラウザでGoogleマップを開く
      final Uri fallbackUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$destination&destination_place_id=$placeId&travelmode=driving');
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      } else {
        throw 'Google Mapsを開けませんでした';
      }
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
