import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class GearAnimation extends StatefulWidget {
  @override
  _GearAnimationState createState() => _GearAnimationState();
}

class _GearAnimationState extends State<GearAnimation> {

  String _anim = "spin1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: (){
                setState(() {
                  if(_anim == "spin1"){
                    _anim = "spin2";
                  }else{
                    _anim = "spin1";
                  }
                });
              },
              child: Container(
                width: 150,
                height: 150,
                child: FlareActor("assets/Gears.flr", animation: _anim,),
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Text(
              "Clique na animação para alterar rotação",
              style: TextStyle(color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}
