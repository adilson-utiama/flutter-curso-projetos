import 'package:flutter/material.dart';

class GrowOpacityTransition extends StatelessWidget {

  final Widget child;
  final Animation<double> animation;

  final sizeTween = Tween<double>(begin: 0, end: 250);
  final opacityTween = Tween<double>(begin: 0.1, end: 1);

  GrowOpacityTransition({this.child, this.animation});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child){
          return Opacity(
            opacity: opacityTween.evaluate(animation).clamp(0, 1.0),
            child: Container(
              width: sizeTween.evaluate(animation),
              height: sizeTween.evaluate(animation),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
