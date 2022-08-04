import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'adsinfo.dart';
import 'template.dart';

class Ads {
  static String ec = 'load';
  static String ea = 'webview_screen';

  static Future<void> load({
    required num portalId,
    required num propsId,
    required String zoneCode,
    String? userId,
    String? items,
    required AdCallbackFailed<String> onAdFailedToLoad,
    required AdCallbackLoaded<AdInfo> onAdLoaded,
  }) async {
    var ec = Ads.ec;
    var ea = Ads.ea;
    var url =
        'https://sandbox-delivery.cdp.asia/interaction/v2?portal_id=$portalId&ec=$ec&ea=$ea&prop_id=$propsId&zoneId=[$zoneCode]&uid=$userId&items=$items&format=json';

    var uri = Uri.parse(url);

    var response = await http.get(uri);
    var parse = jsonDecode(response.body);

    var webContents = parse['webContents'] as Map<String, dynamic>;

    List<AdInfo> ads = [];

    webContents.forEach((k, v) => {
          if (v['javascript'] != '' && v['template'] == zoneCode)
            {
              ads.add(AdInfo.fromJson(portalId, propsId, zoneCode, userId,
                  items, v as Map<String, dynamic>))
            }
        });

    print(ads.first.jsCode);

    if (ads.isEmpty) {
      onAdFailedToLoad('Empty ads');
    } else {
      onAdLoaded(ads.first);
    }
  }

  static void show(AdInfo ad, context, scaffoldKey) {
    String templateType = ad.template;

    print(templateType);

    switch (templateType.toUpperCase()) {
      case 'POPUP':
      case 'FULLSCREEN':
      case 'GAMIFIED': //gamified
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Template(ad: ad);
          },
        );
        break;
      case 'FLOATING_BAR':
        scaffoldKey.currentState.showBottomSheet((context) => Template(ad: ad));
        break;
      case 'INLINE':
        break;
      case 'WEBVIEW':
        break;
    }
  }
}
