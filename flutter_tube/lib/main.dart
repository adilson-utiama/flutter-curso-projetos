import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tube/api.dart';
import 'package:flutter_tube/blocs/favorite_bloc.dart';
import 'package:flutter_tube/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/videos_bloc.dart';

void main(){



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SharedPreferences.getInstance().then(
            (prefs){
          if(!prefs.containsKey("last_search")){
            prefs.setString("last_search", "youtube");
          }
        }
    );

    return BlocProvider(
      blocs: [
        Bloc((i) => VideosBloc()),
        Bloc((i) => FavoriteBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Tube',
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

