import 'package:flutter/material.dart';
import 'package:widget_animation/screens/home/widgets/list_data.dart';

class AnimatedListView extends StatelessWidget {

  final Animation<EdgeInsets> listSlidePosition;

  AnimatedListView({@required this.listSlidePosition});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ListData(
          title: "Estudar Flutter 1",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 7,
        ),
        ListData(
          title: "Estudar Flutter 2",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 6,
        ),
        ListData(
          title: "Estudar Flutter 3",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 5,
        ),
        ListData(
          title: "Estudar Flutter 4",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 4,
        ),
        ListData(
          title: "Estudar Flutter 5",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 3,
        ),
        ListData(
          title: "Estudar Flutter 6",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 2,
        ),
        ListData(
          title: "Estudar Flutter 7",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 1,
        ),
        ListData(
          title: "Estudar Flutter 8",
          subtitle: "Com o curso de Flutter",
          image: AssetImage("images/perfil.jpg"),
          margin: listSlidePosition.value * 0,
        )
      ],
    );
  }
}
