import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tube/blocs/favorite_bloc.dart';
import 'package:flutter_tube/blocs/videos_bloc.dart';
import 'package:flutter_tube/delegates/data_search.dart';
import 'package:flutter_tube/screens/favorites_screen.dart';
import 'package:flutter_tube/tiles/video_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var bloc = BlocProvider.getBloc<VideosBloc>();
    SharedPreferences.getInstance().then(
        (prefs){
          if(prefs.containsKey("last_search")){
            bloc.inSearch.add(prefs.getString("last_search"));
          }else{
            bloc.inSearch.add("youtube");
          }
        }
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Container(
          height: 25,
          child: Image.asset("images/youtube_logo.png"),
        ),
        elevation: 0,
        backgroundColor: Colors.black87,
        actions: <Widget>[
          Align(
            alignment: Alignment.center,
            child: StreamBuilder(
              stream: BlocProvider.getBloc<FavoriteBloc>().outFav,
              //initialData: {},
              builder: (context, snapshot){
                if(snapshot.hasData){
                  return Text("${snapshot.data.length}");
                }else{
                  return Container();
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.star),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen()
                )
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String result = await showSearch(context: context, delegate: DataSearch());
              if(result != null){
                bloc.inSearch.add(result);
              }
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: bloc.outVideos,
        initialData: [],
        builder: (context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data.length + 1,
              itemBuilder: (context, index){
                if(index < snapshot.data.length){
                  return VideoTile(snapshot.data[index]);
                }else if(index > 1){
                  bloc.inSearch.add(null);
                  return Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),),
                  );
                }else{
                  return Container();
                }
              },
            );
          }else{
            return Container();
          }
        },
      ),
    );
  }
}
