import 'package:flutter/material.dart';
import 'package:flutter_animations/animations/grow_opacity_transition.dart';
import 'package:flutter_animations/widgets/logo_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animatons',
      debugShowCheckedModeBanner: false,
      home: LogoApp(),
    );
  }
}

class LogoApp extends StatefulWidget {
  @override
  _LogoAppState createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  AnimationController animController;

  Animation<double> animation;

  @override
  void initState() {
    animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    //Utilizado no GrowTransition
    //animation = Tween<double>(begin: 0, end: 250).animate(animController);

    //Utilizado em GrowOpacityTransition
    animation =
        CurvedAnimation(parent: animController, curve: Curves.elasticOut);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animController.forward();
      }
    });

    animController.forward();

    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return AnimatedLogo(animation);
    return GrowOpacityTransition(
      child: LogoWidget(),
      animation: animation,
    );
  }
}
