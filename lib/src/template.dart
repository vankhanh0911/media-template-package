import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import './adsinfo.dart';

class Template extends StatefulWidget {
  const Template({Key? key, required this.ad, this.onRouteChange})
      : super(key: key);

  final AdInfo ad;
  final AdCallbackChangRoute<String>? onRouteChange;

  @override
  _MediaTemplateState createState() => _MediaTemplateState();
}

class _MediaTemplateState extends State<Template> {
  double heightContainer = 1;
  String templateType = '';
  Future<bool>? loaded;
  Widget? child;
  bool show = true;
  String zoneType = '';
  bool trigger = false;
  bool hasAds = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleMessageFromWebView(MessageWebview message) async {
    var type = message.type;
    var data = message.data;

    switch (type) {
      case 'antsomi-cdp-campaign-size':
        setState(() {
          heightContainer = data['height'].toDouble();
        });
        break;
      case 'antsomi-cdp-webview-closed':
        if (['pop_up', 'full_screen', 'floating_bar', 'gamified']
            .contains(widget.ad.template)) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }

        setState(() {
          show = false;
        });
        break;
      case 'antsomi-cdp-campaign-change-route':
        var route = data['route'];

        if (widget.onRouteChange != null) {
          widget.onRouteChange!(route);
        } else {
          await launchUrl(Uri.parse(route));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.ad.jsCode != '' && show
        ? SizedBox(
            height: heightContainer,
            width: MediaQuery.of(context).size.width,
            child: MediaTemplateWebview(
                key: widget.key,
                zoneCode: widget.ad.zoneCode,
                js: widget.ad.jsCode,
                ad: widget.ad,
                callback: (MessageWebview message) {
                  handleMessageFromWebView(message);
                }),
          )
        : Container(height: 0);
  }
}

class MessageWebview {
  final String type;
  final dynamic data;

  const MessageWebview({required this.type, required this.data});

  factory MessageWebview.fromJson(Map<String, dynamic> json) {
    return MessageWebview(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }
}

class MediaTemplateWebview extends StatefulWidget {
  final String js;
  final AdInfo? ad;
  final String? zoneCode;
  final Function(MessageWebview) callback;

  const MediaTemplateWebview(
      {Key? key,
      required this.js,
      required this.callback,
      this.ad,
      this.zoneCode})
      : super(key: key);

  @override
  _MediaTemplateWebviewState createState() => _MediaTemplateWebviewState();
}

class _MediaTemplateWebviewState extends State<MediaTemplateWebview> {
  bool isLoading = true;
  late WebViewController _controller;
  final key = UniqueKey();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleMessage(String message) {
    var messageWebview = MessageWebview.fromJson(json.decode(message));

    widget.callback(messageWebview);
  }

  @override
  Widget build(BuildContext context) {
    var portalId = widget.ad?.portalId;
    var propsId = widget.ad?.propsId;
    var template = widget.ad?.template;
    var userId = widget.ad?.userId;
    var items = widget.ad?.items;

    return WebView(
      key: key,
      zoomEnabled: false,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        webViewController.loadUrl(Uri.encodeFull(
            'https://st-media-template.antsomi.com/html/index.html?verion=221325&portalId=${portalId}&propsId=${propsId}&zoneCode=${template}&userId=${userId}&items=${items}&v=1'));
        _controller = webViewController;
      },
      onPageFinished: (String url) async {
        await _controller.runJavascript(widget.js);
      },
      javascriptChannels: <JavascriptChannel>{
        JavascriptChannel(
          name: 'messageHandler',
          onMessageReceived: (JavascriptMessage message) {
            handleMessage(message.message);
          },
        )
      },
    );
  }
}
