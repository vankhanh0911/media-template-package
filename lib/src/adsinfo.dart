typedef AdCallbackLoaded<Ad> = void Function(Ad ad);
typedef AdCallbackFailed<String> = void Function(String);
typedef AdCallbackChangRoute<String> = void Function(String route);

class AdsLoadCallback {
  /// Construct a [InterstitialAdLoadCallback].
  const AdsLoadCallback({
    required AdCallbackLoaded<AdInfo> onAdLoaded,
    required AdCallbackFailed<String> onAdFailedToLoad,
  });
}

class AdInfo {
  static String zoneSelectorInit = '#at-mobile-app';

  final num portalId;
  final num propsId;
  final String zoneCode;
  final String? userId;
  final String? items;
  final String template;
  final String jsCode;
  final String? cssSelector;
  final dynamic? destinationFrequencyCapping;
  final dynamic? zoneFrequencyCapping;

  const AdInfo(
      {required this.portalId,
      required this.propsId,
      required this.zoneCode,
      this.userId,
      this.items,
      required this.template,
      required this.jsCode,
      this.cssSelector,
      this.destinationFrequencyCapping,
      this.zoneFrequencyCapping});

  factory AdInfo.fromJson(num portalId, num propsId, String zoneCode,
      String? userId, String? items, Map<String, dynamic> json) {
    var jsCode = json['javascript'] as String;
    if (zoneCode == 'inline' && json['cssSelector'] != '') {
      jsCode = jsCode.replaceAll(json['cssSelector'], zoneSelectorInit);
    }

    return AdInfo(
        portalId: portalId,
        propsId: propsId,
        zoneCode: zoneCode,
        userId: userId,
        items: items,
        template: json['template'] as String,
        jsCode: jsCode,
        cssSelector: json['cssSelector'] as String?,
        destinationFrequencyCapping: json['zoneFrequencyCapping'],
        zoneFrequencyCapping: json['zoneFrequencyCapping']);
  }
}
