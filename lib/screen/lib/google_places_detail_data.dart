import 'package:json_annotation/json_annotation.dart';

part 'google_places_detail_data.g.dart';

@JsonSerializable()
class GooglePlacesDetailData {
  final String name;
  final String id;
  final List<String> types;
  final String? nationalPhoneNumber;
  final String? internationalPhoneNumber;
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final PlusCode plusCode;
  final Location location;
  final Viewport viewport;
  final double? rating;
  final String googleMapsUri;
  final String? websiteUri;
  final int utcOffsetMinutes;
  final String adrFormatAddress;
  final String businessStatus;
  final int userRatingCount;
  final String iconMaskBaseUri;
  final String iconBackgroundColor;
  final LocalizedText displayName;
  final LocalizedText primaryTypeDisplayName;
  final String primaryType;
  final String shortFormattedAddress;
  final EditorialSummary? editorialSummary;
  final List<Review> reviews;
  final List<Photo> photos;
  final bool? goodForChildren;
  final bool? restroom;
  // final AccessibilityOptions accessibilityOptions;

  GooglePlacesDetailData({
    required this.name,
    required this.id,
    required this.types,
    this.nationalPhoneNumber,
    this.internationalPhoneNumber,
    required this.formattedAddress,
    required this.addressComponents,
    required this.plusCode,
    required this.location,
    required this.viewport,
    this.rating,
    required this.googleMapsUri,
    this.websiteUri,
    required this.utcOffsetMinutes,
    required this.adrFormatAddress,
    required this.businessStatus,
    required this.userRatingCount,
    required this.iconMaskBaseUri,
    required this.iconBackgroundColor,
    required this.displayName,
    required this.primaryTypeDisplayName,
    required this.primaryType,
    required this.shortFormattedAddress,
    this.editorialSummary,
    required this.reviews,
    required this.photos,
    required this.goodForChildren,
    required this.restroom,
    // required this.accessibilityOptions,
  });

  factory GooglePlacesDetailData.fromJson(Map<String, dynamic> json) =>
      _$GooglePlacesDetailDataFromJson(json);

  Map<String, dynamic> toJson() => _$GooglePlacesDetailDataToJson(this);
}

@JsonSerializable()
class AddressComponent {
  final String longText;
  final String shortText;
  final List<String> types;
  final String languageCode;

  AddressComponent({
    required this.longText,
    required this.shortText,
    required this.types,
    required this.languageCode,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);

  Map<String, dynamic> toJson() => _$AddressComponentToJson(this);
}

@JsonSerializable()
class PlusCode {
  final String globalCode;
  final String compoundCode;

  PlusCode({required this.globalCode, required this.compoundCode});

  factory PlusCode.fromJson(Map<String, dynamic> json) =>
      _$PlusCodeFromJson(json);

  Map<String, dynamic> toJson() => _$PlusCodeToJson(this);
}

@JsonSerializable()
class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class Viewport {
  final Location low;
  final Location high;

  Viewport({required this.low, required this.high});

  factory Viewport.fromJson(Map<String, dynamic> json) =>
      _$ViewportFromJson(json);

  Map<String, dynamic> toJson() => _$ViewportToJson(this);
}

@JsonSerializable()
class LocalizedText {
  final String text;
  final String languageCode;

  LocalizedText({required this.text, required this.languageCode});

  factory LocalizedText.fromJson(Map<String, dynamic> json) =>
      _$LocalizedTextFromJson(json);

  Map<String, dynamic> toJson() => _$LocalizedTextToJson(this);
}

@JsonSerializable()
class EditorialSummary {
  final String text;
  final String languageCode;

  EditorialSummary({required this.text, required this.languageCode});

  factory EditorialSummary.fromJson(Map<String, dynamic> json) =>
      _$EditorialSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EditorialSummaryToJson(this);
}

@JsonSerializable()
class Review {
  final String name;
  final String relativePublishTimeDescription;
  final int rating;
  final LocalizedText text;
  final LocalizedText originalText;
  final AuthorAttribution authorAttribution;
  final String publishTime;

  Review({
    required this.name,
    required this.relativePublishTimeDescription,
    required this.rating,
    required this.text,
    required this.originalText,
    required this.authorAttribution,
    required this.publishTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class AuthorAttribution {
  final String displayName;
  final String uri;
  final String photoUri;

  AuthorAttribution({
    required this.displayName,
    required this.uri,
    required this.photoUri,
  });

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) =>
      _$AuthorAttributionFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorAttributionToJson(this);
}

@JsonSerializable()
class Photo {
  final String name;
  final int widthPx;
  final int heightPx;
  final List<AuthorAttribution> authorAttributions;

  Photo({
    required this.name,
    required this.widthPx,
    required this.heightPx,
    required this.authorAttributions,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoToJson(this);
}

// @JsonSerializable()
// class AccessibilityOptions {
//   final bool wheelchairAccessibleParking;
//   final bool wheelchairAccessibleEntrance;

//   AccessibilityOptions({
//     required this.wheelchairAccessibleParking,
//     required this.wheelchairAccessibleEntrance,
//   });

//   factory AccessibilityOptions.fromJson(Map<String, dynamic> json) =>
//       _$AccessibilityOptionsFromJson(json);

//   Map<String, dynamic> toJson() => _$AccessibilityOptionsToJson(this);
// }