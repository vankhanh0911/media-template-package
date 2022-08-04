import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './adsinfo.dart';

class Template extends StatefulWidget {
  const Template({Key? key, required this.ad}) : super(key: key);

  final AdInfo ad;

  @override
  _MediaTemplateState createState() => _MediaTemplateState();
}

class _MediaTemplateState extends State<Template> {
  double heightContainer = 0;
  double widthContainer = 0;
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

  void handleMessageFromWebView(MessageWebview message) {
    var type = message.type;
    var data = message.data;

    switch (type) {
      case 'antsomi-cdp-campaign-size':
        setState(() {
          heightContainer = data['height'].toDouble();
          widthContainer = data['width'].toDouble();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.ad.jsCode != '' && show
        ? SizedBox(
            height: heightContainer,
            width: widget.ad.template == 'slide_in'
                ? widthContainer == 0
                    ? MediaQuery.of(context).size.width
                    : widthContainer
                : MediaQuery.of(context).size.width,
            child: MediaTemplateWebview(
                key: widget.key,
                zoneId: widget.ad.zoneCode,
                js: widget.ad.jsCode,
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
  final String? zoneId;
  final Function(MessageWebview) callback;

  const MediaTemplateWebview(
      {Key? key, required this.js, required this.callback, this.zoneId})
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
    return WebView(
      key: key,
      zoomEnabled: false,
      initialUrl: Uri.encodeFull(
          'https://sandbox-template.ants.vn/khanhhv/mobile/index.html?v=14'),
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
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
