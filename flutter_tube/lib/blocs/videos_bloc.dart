import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter_tube/api.dart';
import 'package:flutter_tube/models/video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideosBloc extends BlocBase {
  Api api;
  List<Video> videos;

  VideosBloc() {
    api = Api();
    _searchController.stream.listen(_search);
  }

  final StreamController<List<Video>> _videosController =
      StreamController<List<Video>>();
  Stream get outVideos => _videosController.stream;

  final StreamController<String> _searchController = StreamController<String>();
  Sink get inSearch => _searchController.sink;

  void _search(String search) async {
    if (search != null) {
      _videosController.sink.add([]);
      videos = await api.search(search);
      SharedPreferences.getInstance().then(
          (prefs){
            prefs.setString("last_search", search);
          }
      );
    } else {
      videos += await api.nextPage();
    }
    _videosController.sink.add(videos);
  }

  @override
  void dispose() {
    _videosController.close();
    _searchController.close();
    super.dispose();
  }
}
