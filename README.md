# Media Template

Show template on mobile

Its supports template:
- POP_UP
- FLOATING_BAR
- FULL_SCREEN
- INLINE
- SLIDE_IN
- GAMIFIED

## Intstall
```sh
flutter pub add mediatemplate
```

## Example
```dart
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
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Inline'),
      ),
      body: Center(
        child: loaded ? Template(ad: _ad) : null,
        
      ),
    );
  }
}
```

## Usage
- Open example to get more information;