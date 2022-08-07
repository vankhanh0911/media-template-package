import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediatemplate/mediatemplate.dart';
import 'package:flutter/scheduler.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({Key? key}) : super(key: key);

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  late AdInfo _ad;
  bool loaded = false;

  void initState() {
    Ads.load(
        portalId: 561236459,
        propsId: 564990801,
        userId: '123-23992-23991-2132',
        zoneCode: 'full_screen',
        onAdFailedToLoad: (String error) {
          print(error);
        },
        onAdLoaded: (AdInfo ad) {
          setState(() {
            _ad = ad;
            loaded = true;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    if (loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Ads.show(_ad, context, scaffoldKey);
      });
    }

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('FullScreen'),
        ),
        body: Center(
          child: ElevatedButton(
            child: const Text('Home'),
            onPressed: () {
              // Navigate to home route when tapped.
              Navigator.pop(context);
            },
          ),
        ));
  }
}
