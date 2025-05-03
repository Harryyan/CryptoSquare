import 'package:cryptosquare/l10n/l18n_keywords.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:get/get.dart';

import '../../util/event_bus.dart';

GlobalKey<_CountdownButtonState> cdButtonKey = GlobalKey();

class CountdownButton extends StatefulWidget {
  final VoidCallback? onPressed;
  CountdownButton({super.key, this.onPressed});
  @override
  _CountdownButtonState createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  int _countdownTime = 60;
  Timer? _timer;
  bool _isCountingDown = false;
  final VoidCallback? onPressedCallback;

  _CountdownButtonState({this.onPressedCallback});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    eventBus.on('isUserNameValid', (arg) {
      if (arg != null) {
        if (arg == 'true') {
          _startCountdown();
        }
      }
    });
  }

  void _startCountdown() {
    if (mounted) {
      setState(() {
        _isCountingDown = true;
      });
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownTime > 0) {
            _countdownTime--;
          } else {
            _timer?.cancel();
            _resetCountdown();
          }
        });
      }
    });
  }

  void reset() {
    _resetCountdown();
  }

  void _resetCountdown() {
    _timer?.cancel();
    setState(() {
      _countdownTime = 60;
      _isCountingDown = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          _isCountingDown
              ? null
              : () {
                if (widget.onPressed != null) {
                  widget.onPressed!();
                }

                // if (widget.isValid) {
                //   _startCountdown();
                // }
              },
      child: Text(
        _isCountingDown ? '$_countdownTime s' : I18nKeyword.sendCode.tr,
      ),
    );
  }
}
