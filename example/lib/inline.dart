import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediatemplate/mediatemplate.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';

class Inline extends StatefulWidget {
  const Inline({Key? key}) : super(key: key);

  @override
  State<Inline> createState() => _InlineState();
}

class _InlineState extends State<Inline> {
  late AdInfo _ad;
  bool loaded = false;
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      deviceId = '123123123';
    });
  }

  @override
  void didUpdateWidget(covariant Inline oldWidget) {
    print("change");

    Ads.load(
        portalId: 561236459,
        propsId: 564990801,
        ec: '',
        ea: '',
        zoneCode: 'inline',
        templateType: 'inline',
        userId: deviceId,
        onAdFailedToLoad: (String error) {
          print(error);
        },
        onAdLoaded: (AdInfo ad) {
          setState(() {
            _ad = ad;
            loaded = true;
          });
        });

    super.didUpdateWidget(oldWidget);
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
      ),
      // floatingActionButton: loaded ? Template(ad: _ad) : null,
    );
  }
}
