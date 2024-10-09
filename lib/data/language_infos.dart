enum Language{
  JP,
  English
}

final Map<Language, LanguageInfo> languageInfos = {
  Language.JP: LanguageInfo(display: '日本語', sufix: 'JP', languageCode: 'ja-JP'),
  Language.English: LanguageInfo(display: 'English', sufix: 'ENG', languageCode: 'en-US'),
};

class LanguageInfo{
  final String display;
  final String sufix;
  final String languageCode;

  LanguageInfo({
    required this.display,
    required this.sufix,
    required this.languageCode,
  });
}