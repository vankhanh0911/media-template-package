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
  final String? dims;
  final String? extra;
  final String template;
  final String jsCode;
  final String? cssSelector;
  final num? zoneId;
  final num? destinationId;
  final num? storyId;
  final Map<String, dynamic>? destinationFrequencyCapping;
  final Map<String, dynamic>? zoneFrequencyCapping;
  final Map<String, dynamic>? frequencyCapping;

  const AdInfo(
      {required this.portalId,
      required this.propsId,
      required this.zoneCode,
      this.userId,
      this.items,
      this.dims,
      this.extra,
      required this.template,
      required this.jsCode,
      this.cssSelector,
      this.zoneId,
      this.destinationId,
      this.storyId,
      this.destinationFrequencyCapping,
      this.frequencyCapping,
      this.zoneFrequencyCapping});

  factory AdInfo.fromJson(
      num portalId,
      num propsId,
      String zoneCode,
      String? userId,
      String? items,
      String? dims,
      String? extra,
      Map<String, dynamic> json) {
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
        dims: dims,
        extra: extra,
        template: json['template'] as String,
        jsCode: jsCode,
        cssSelector: json['cssSelector'] as String?,
        zoneId: json['zoneId'] as num,
        destinationId: json['destinationId'] as num,
        storyId: json['storyId'] as num,
        destinationFrequencyCapping:
            json['zoneFrequencyCapping'] as Map<String, dynamic>,
        frequencyCapping: json['frequencyCapping'] as Map<String, dynamic>,
        zoneFrequencyCapping:
            json['zoneFrequencyCapping'] as Map<String, dynamic>);
  }
}
