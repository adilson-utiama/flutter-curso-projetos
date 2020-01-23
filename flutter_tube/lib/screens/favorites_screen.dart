import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tube/blocs/favorite_bloc.dart';
import 'package:flutter_tube/models/video.dart';
import 'package:flutter_youtube/flutter_youtube.dart';

import '../api.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final FavoriteBloc bloc = BlocProvider.getBloc<FavoriteBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black87,
      body: StreamBuilder<Map<String, Video>>(
        stream: bloc.outFav,
        initialData: {},
        builder: (context, snapshot){
          return ListView(
            children: snapshot.data.values.map(
                (video){
                  return InkWell(
                    onTap: (){
                      FlutterYoutube.playYoutubeVideoById(
                          apiKey: API_KEY,
                          videoId: video.id
                      );
                    },
                    onLongPress: (){
                      bloc.toggleFavorite(video);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 80,
                          child: Image.network(video.thumb, fit: BoxFit.cover,),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  video.title,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  video.channel,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
            ).toList(),
          );
        },
      )
    );
  }
}
