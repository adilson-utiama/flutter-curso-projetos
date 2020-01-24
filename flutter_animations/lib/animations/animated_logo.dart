import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedLogo extends AnimatedWidget {

  AnimatedLogo(Animation<double> animation) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {

    final Animation<double> animation = listenable;

    return Center(
      child: Container(
        width: animation.value,
        height: animation.value,
        child: FlutterLogo(),
      ),
    );
  }

}