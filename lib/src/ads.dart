import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'adsinfo.dart';
import 'template.dart';
import 'frequency.dart';

class Ads {
  static Future<void> load({
    required num portalId,
    required num propsId,
    required String zoneCode,
    required String templateType,
    required String ec,
    required String ea,
    String? userId,
    String? items,
    String? dims,
    String? extra,
    required AdCallbackFailed<String> onAdFailedToLoad,
    required AdCallbackLoaded<AdInfo> onAdLoaded,
  }) async {
    var url =
        'https://delivery.cdp.asia/interaction/v2?portal_id=$portalId&ec=$ec&ea=$ea&prop_id=$propsId&jrequest_zones=["$zoneCode"]&uid=$userId&items=$items&dims=$dims&extra=$extra&format=json';

    var uri = Uri.parse(url);

    var response = await http.get(uri);
    var parse = jsonDecode(response.body);

    var webContents = parse['webContents'] as Map<String, dynamic>;

    List<AdInfo> ads = [];
    List<AdInfo> adsRender = [];

    Map<String, dynamic> freq = await Frequency.getFrequency();

    webContents.forEach((k, v) => {
          if (v['javascript'] != '' && v['template'] == templateType)
            {
              ads.add(AdInfo.fromJson(portalId, propsId, templateType, userId,
                  items, dims, extra, v as Map<String, dynamic>))
            }
        });

    if (ads.isNotEmpty) {
      for (final ad in ads) {
        bool flagStory = true;
        bool flagZone = true;
        bool flagDestination = true;

        if (ad.frequencyCapping != null) {
          String event = ad.frequencyCapping!['event'];
          int value = ad.frequencyCapping!['value'];

          Map<String, dynamic> cachedFreq =
              freq['story'] as Map<String, dynamic>;

          if (cachedFreq.containsKey(ad.storyId.toString())) {
            Map<String, dynamic> storyCached =
                cachedFreq[ad.storyId.toString()] as Map<String, dynamic>;

            if (storyCached.containsKey(event) && value <= storyCached[event]) {
              flagStory = false;
            }
          }
        }

        if (ad.zoneFrequencyCapping != null) {
          String event = ad.zoneFrequencyCapping!['event'];
          int value = ad.zoneFrequencyCapping!['value'];

          Map<String, dynamic> cachedFreq =
              freq['zone'] as Map<String, dynamic>;

          if (cachedFreq.containsKey(ad.zoneId.toString())) {
            Map<String, dynamic> zoneCached =
                cachedFreq[ad.zoneId.toString()] as Map<String, dynamic>;

            if (zoneCached.containsKey(event) && value <= zoneCached[event]) {
              flagZone = false;
            }
          }
        }

        if (ad.destinationFrequencyCapping != null) {
          String event = ad.destinationFrequencyCapping!['event'];
          int value = ad.destinationFrequencyCapping!['value'];

          Map<String, dynamic> cachedFreq =
              freq['destination'] as Map<String, dynamic>;

          if (cachedFreq.containsKey(ad.destinationId.toString())) {
            Map<String, dynamic> destinationCached =
                cachedFreq[ad.destinationId.toString()] as Map<String, dynamic>;

            if (destinationCached.containsKey(event) &&
                value <= destinationCached[event]) {
              flagDestination = false;
            }
          }
        }

        if (flagStory && flagZone && flagDestination) {
          adsRender.add(ad);
        }
      }
    }

    if (adsRender.isEmpty) {
      onAdFailedToLoad('Empty ads');
    } else {
      onAdLoaded(adsRender.first);
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
