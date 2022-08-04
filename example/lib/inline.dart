import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediatemplate/mediatemplate.dart';
import 'package:flutter/scheduler.dart';

class Inline extends StatefulWidget {
  const Inline({Key? key}) : super(key: key);

  @override
  State<Inline> createState() => _InlineState();
}

class _InlineState extends State<Inline> {
  late AdInfo _ad;
  bool loaded = false;

  void initState() {
    Ads.load(
        portalId: 33167,
        propsId: 556301499,
        zoneCode: 'inline',
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

    // if (loaded) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Ads.show(_ad, context, scaffoldKey);
    //   });
    // }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Inline'),
      ),
      body: Center(
        child: loaded ? Template(ad: _ad) : null,
        ElevatedButton(
            child: const Text('Home'),
            onPressed: () {
              // Navigate to home route when tapped.
              Navigator.pop(context);
            },
          )
      ),
      // floatingActionButton: loaded ? Template(ad: _ad) : null,
    );
  }
}
