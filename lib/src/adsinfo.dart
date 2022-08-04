typedef AdCallbackLoaded<Ad> = void Function(Ad ad);
typedef AdCallbackFailed<String> = void Function(String);

class AdsLoadCallback {
  /// Construct a [InterstitialAdLoadCallback].
  const AdsLoadCallback({
    required AdCallbackLoaded<AdInfo> onAdLoaded,
    required AdCallbackFailed<String> onAdFailedToLoad,
  });
}

class AdInfo {
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
  final bool loaded;

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
      this.zoneFrequencyCapping,
      this.loaded = false});

  factory AdInfo.fromJson(num portalId, num propsId, String zoneCode,
      String? userId, String? items, Map<String, dynamic> json) {
    return AdInfo(
        portalId: portalId,
        propsId: propsId,
        zoneCode: zoneCode,
        userId: userId,
        items: items,
        template: json['template'] as String,
        jsCode: json['javascript'] as String,
        cssSelector: json['cssSelector'] as String?,
        destinationFrequencyCapping: json['zoneFrequencyCapping'],
        zoneFrequencyCapping: json['zoneFrequencyCapping'],
        loaded: true);
  }
}
