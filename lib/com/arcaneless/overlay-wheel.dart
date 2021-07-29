

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';

class SpinWheel {

  bool _created = false;
  OverlayEntry _spinWheelEntry;

  SpinWheel() {
    _spinWheelEntry = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Container(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints.expand(),
            alignment: Alignment.center,
            child: SpinKitWave(
              color: Parameters.themeColor,
              size: 50,
            ),
          ),
        ),
      );
    });
  }

  void overlaySpinWheel(BuildContext context) {
    if (!_created) {
      _created = true;
      return Overlay.of(context).insert(
          _spinWheelEntry
      );
    }
  }

  void overlayRemove(BuildContext context) {
    if (_created) {
      _created = false;
      return _spinWheelEntry.remove();
    }
  }
}