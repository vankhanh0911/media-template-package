import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediatemplate/mediatemplate.dart';
import 'package:flutter/scheduler.dart';

class Gamified extends StatefulWidget {
  const Gamified({Key? key}) : super(key: key);

  @override
  State<Gamified> createState() => _GamifiedState();
}

class _GamifiedState extends State<Gamified> {
  late AdInfo _ad;
  bool loaded = false;

  void initState() {
    Ads.load(
        portalId: 561236459,
        propsId: 564990801,
        userId: '123-23992-23991-2132',
        zoneCode: 'gamified',
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
          title: const Text('Gamified'),
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
