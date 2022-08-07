import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'adsinfo.dart';
import 'template.dart';

class Ads {
  static String ec = 'webview_screen';
  static String ea = 'load';

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
        'https://delivery.cdp.asia/interaction/v2?portal_id=$portalId&ec=$ec&ea=$ea&prop_id=$propsId&zoneCode=[$zoneCode]&uid=$userId&items=$items&format=json';

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

    if (ads.isEmpty) {
      onAdFailedToLoad('Empty ads');
    } else {
      onAdLoaded(ads.first);
    }
  }

  static void show(AdInfo ad, context, scaffoldKey,
      [AdCallbackChangRoute<String>? callbackRoute]) {
    String templateType = ad.template;

    switch (templateType) {
      case 'pop_up':
        showDialog(
          context: context,
          useSafeArea: false,
          builder: (BuildContext context) {
            return Dialog(
                insetPadding: EdgeInsets.zero,
                child: Template(ad: ad, onRouteChange: callbackRoute));
          },
        );
        break;
      case 'full_screen':
      case 'gamified': //gamified
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Template(ad: ad);
          },
        );
        break;
      case 'floating_bar':
      case 'slide_in':
        scaffoldKey.currentState.showBottomSheet((context) => Template(ad: ad));
        break;
      case 'inline':
        break;
    }
  }
}
