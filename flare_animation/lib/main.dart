import 'package:flare_animation/gear_animation.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 6)).then((_){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GearAnimation()
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            "Flutter + Flare",
            style: TextStyle(fontSize: 30.0, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          Container(
            width: 150,
            height: 150,
            child: FlareActor(
              "assets/HeartBeat.flr",
              animation: "heartbeat",
            ),
          )
        ],
      ),
    );
  }
}
