// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_places_detail_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GooglePlacesDetailData _$GooglePlacesDetailDataFromJson(
        Map<String, dynamic> json) =>
    GooglePlacesDetailData(
      name: json['name'] as String,
      id: json['id'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      nationalPhoneNumber: json['nationalPhoneNumber'] as String?,
      internationalPhoneNumber: json['internationalPhoneNumber'] as String?,
      formattedAddress: json['formattedAddress'] as String,
      addressComponents: (json['addressComponents'] as List<dynamic>)
          .map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
          .toList(),
      plusCode: PlusCode.fromJson(json['plusCode'] as Map<String, dynamic>),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      viewport: Viewport.fromJson(json['viewport'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toDouble(),
      googleMapsUri: json['googleMapsUri'] as String,
      websiteUri: json['websiteUri'] as String?,
      utcOffsetMinutes: (json['utcOffsetMinutes'] as num).toInt(),
      adrFormatAddress: json['adrFormatAddress'] as String,
      businessStatus: json['businessStatus'] as String,
      userRatingCount: (json['userRatingCount'] as num).toInt(),
      iconMaskBaseUri: json['iconMaskBaseUri'] as String,
      iconBackgroundColor: json['iconBackgroundColor'] as String,
      displayName:
          LocalizedText.fromJson(json['displayName'] as Map<String, dynamic>),
      primaryTypeDisplayName: LocalizedText.fromJson(
          json['primaryTypeDisplayName'] as Map<String, dynamic>),
      primaryType: json['primaryType'] as String,
      shortFormattedAddress: json['shortFormattedAddress'] as String,
      editorialSummary: json['editorialSummary'] == null
          ? null
          : EditorialSummary.fromJson(
              json['editorialSummary'] as Map<String, dynamic>),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>)
          .map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      goodForChildren: json['goodForChildren'] as bool?,
      restroom: json['restroom'] as bool?,
    );

Map<String, dynamic> _$GooglePlacesDetailDataToJson(
        GooglePlacesDetailData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'types': instance.types,
      'nationalPhoneNumber': instance.nationalPhoneNumber,
      'internationalPhoneNumber': instance.internationalPhoneNumber,
      'formattedAddress': instance.formattedAddress,
      'addressComponents': instance.addressComponents,
      'plusCode': instance.plusCode,
      'location': instance.location,
      'viewport': instance.viewport,
      'rating': instance.rating,
      'googleMapsUri': instance.googleMapsUri,
      'websiteUri': instance.websiteUri,
      'utcOffsetMinutes': instance.utcOffsetMinutes,
      'adrFormatAddress': instance.adrFormatAddress,
      'businessStatus': instance.businessStatus,
      'userRatingCount': instance.userRatingCount,
      'iconMaskBaseUri': instance.iconMaskBaseUri,
      'iconBackgroundColor': instance.iconBackgroundColor,
      'displayName': instance.displayName,
      'primaryTypeDisplayName': instance.primaryTypeDisplayName,
      'primaryType': instance.primaryType,
      'shortFormattedAddress': instance.shortFormattedAddress,
      'editorialSummary': instance.editorialSummary,
      'reviews': instance.reviews,
      'photos': instance.photos,
      'goodForChildren': instance.goodForChildren,
      'restroom': instance.restroom,
    };

AddressComponent _$AddressComponentFromJson(Map<String, dynamic> json) =>
    AddressComponent(
      longText: json['longText'] as String,
      shortText: json['shortText'] as String,
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      languageCode: json['languageCode'] as String,
    );

Map<String, dynamic> _$AddressComponentToJson(AddressComponent instance) =>
    <String, dynamic>{
      'longText': instance.longText,
      'shortText': instance.shortText,
      'types': instance.types,
      'languageCode': instance.languageCode,
    };

PlusCode _$PlusCodeFromJson(Map<String, dynamic> json) => PlusCode(
      globalCode: json['globalCode'] as String,
      compoundCode: json['compoundCode'] as String,
    );

Map<String, dynamic> _$PlusCodeToJson(PlusCode instance) => <String, dynamic>{
      'globalCode': instance.globalCode,
      'compoundCode': instance.compoundCode,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Viewport _$ViewportFromJson(Map<String, dynamic> json) => Viewport(
      low: Location.fromJson(json['low'] as Map<String, dynamic>),
      high: Location.fromJson(json['high'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ViewportToJson(Viewport instance) => <String, dynamic>{
      'low': instance.low,
      'high': instance.high,
    };

LocalizedText _$LocalizedTextFromJson(Map<String, dynamic> json) =>
    LocalizedText(
      text: json['text'] as String,
      languageCode: json['languageCode'] as String,
    );

Map<String, dynamic> _$LocalizedTextToJson(LocalizedText instance) =>
    <String, dynamic>{
      'text': instance.text,
      'languageCode': instance.languageCode,
    };

EditorialSummary _$EditorialSummaryFromJson(Map<String, dynamic> json) =>
    EditorialSummary(
      text: json['text'] as String,
      languageCode: json['languageCode'] as String,
    );

Map<String, dynamic> _$EditorialSummaryToJson(EditorialSummary instance) =>
    <String, dynamic>{
      'text': instance.text,
      'languageCode': instance.languageCode,
    };

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      name: json['name'] as String,
      relativePublishTimeDescription:
          json['relativePublishTimeDescription'] as String,
      rating: (json['rating'] as num).toInt(),
      text: LocalizedText.fromJson(json['text'] as Map<String, dynamic>),
      originalText:
          LocalizedText.fromJson(json['originalText'] as Map<String, dynamic>),
      authorAttribution: AuthorAttribution.fromJson(
          json['authorAttribution'] as Map<String, dynamic>),
      publishTime: json['publishTime'] as String,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'name': instance.name,
      'relativePublishTimeDescription': instance.relativePublishTimeDescription,
      'rating': instance.rating,
      'text': instance.text,
      'originalText': instance.originalText,
      'authorAttribution': instance.authorAttribution,
      'publishTime': instance.publishTime,
    };

AuthorAttribution _$AuthorAttributionFromJson(Map<String, dynamic> json) =>
    AuthorAttribution(
      displayName: json['displayName'] as String,
      uri: json['uri'] as String,
      photoUri: json['photoUri'] as String,
    );

Map<String, dynamic> _$AuthorAttributionToJson(AuthorAttribution instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'uri': instance.uri,
      'photoUri': instance.photoUri,
    };

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      name: json['name'] as String,
      widthPx: (json['widthPx'] as num).toInt(),
      heightPx: (json['heightPx'] as num).toInt(),
      authorAttributions: (json['authorAttributions'] as List<dynamic>)
          .map((e) => AuthorAttribution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'name': instance.name,
      'widthPx': instance.widthPx,
      'heightPx': instance.heightPx,
      'authorAttributions': instance.authorAttributions,
    };
