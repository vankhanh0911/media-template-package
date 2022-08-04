import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import './ads.dart';

class Template extends StatefulWidget {
  const Template(
      {Key? key,
      required this.portalId,
      required this.propsId,
      required this.zoneId,
      this.userId,
      this.items})
      : super(key: key);

  final num portalId;
  final num propsId;
  final num zoneId;
  final String? userId;
  final String? items;

  @override
  _MediaTemplateState createState() => _MediaTemplateState();
}

class _MediaTemplateState extends State<Template> {
  String jsCode = '';
  double heightContainer = 0;
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

    Ads.getAds(widget.portalId, widget.propsId, widget.zoneId, widget.userId,
        widget.items, (String response) {
      processAds(response);
    });
  }

  void handleMessageFromWebView(MessageWebview message) {
    var type = message.type;
    var data = message.data;

    switch (type) {
      case 'antsomi-cdp-campaign-height':
        setState(() {
          heightContainer = widget.zoneId == 531008
              ? data['height'].toDouble() + 20
              : data['height'].toDouble();
        });
        break;
      case 'antsomi-cdp-webview-closed':
        if (zoneType == 'POPUP') {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
        setState(() {
          show = false;
        });
        break;
    }
  }

  void processAds(String response) {
    var parse = jsonDecode(response);
    var webContents = parse['webContents'] as Map<String, dynamic>;

    webContents.forEach((k, v) => {
          if (v['javascript'] != '' && v['zoneId'] == widget.zoneId)
            {
              setState(() {
                jsCode = v['javascript'];
                zoneType = 'POPUP';
                hasAds = true;
              })
            }
        });

    if (!hasAds) {
      setState(() {
        show = false;
        if (zoneType == 'POPUP') {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (zoneType) {
      case 'POPUP':
      case 'FLOATING_BAR':
      case 'INLINE':
      default:
        return jsCode != '' && show
            ? Container(
                height: heightContainer,
                width: MediaQuery.of(context).size.width,
                child: MediaTemplateWebview(
                    key: widget.key,
                    zoneId: widget.zoneId.toString(),
                    js: jsCode,
                    callback: (MessageWebview message) {
                      handleMessageFromWebView(message);
                    }),
              )
            : Container(height: 0);
    }
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
          'https://sandbox-template.ants.vn/khanhhv/mobile/index.html?v=12'),
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
