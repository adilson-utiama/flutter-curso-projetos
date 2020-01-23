import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          //query -> propriedade da SeachDelegate - texto da pesquisa
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        //transitionAnimation -> propriedade da SeachDelegate
        //triggered when the search pages fades in or out.
        progress: transitionAnimation,
      ),
      onPressed: (){
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    //Fix
    Future.delayed(Duration.zero).then((_) => close(context, query));

    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty){
      return Container();
    }else{
      return FutureBuilder<List>(
        future: suggestions(query),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return Center(child: CircularProgressIndicator(),);
          }else{
            return ListView.builder(
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(snapshot.data[index]),
                    leading: Icon(Icons.play_arrow),
                    onTap: (){
                      close(context, snapshot.data[index]);
                    },
                  );
                },
              itemCount: snapshot.data.length,
            );
          }
        },
      );
    }
  }

  Future<List> suggestions(String search) async {
    http.Response response = await http.get(
        "http://suggestqueries.google.com/complete/search?hl=en&ds=yt&client=youtube&hjson=t&cp=1&q=$search&format=5&alt=json"
    );

    if(response.statusCode == 200){

      return json.decode(response.body)[1].map(
          (value){
            return value[0];
          }
      ).toList();

    }else{
      throw Exception("Failed to load suggestions");
    }
  }

}

/* referenccia do json da sugestao retornada com a pesquisa "banana"
* [
   "banana",
   [
      [
         "banana",
         0
      ],
      [
         "banana pancakes",
         0,
         [
            131
         ]
      ],
      [
         "bananas de pijamas",
         0
      ],
      [
         "banana brain",
         0,
         [
            131
         ]
      ],
      [
         "banana chacha",
         0
      ],
      [
         "banana chips",
         0,
         [
            131
         ]
      ],
      [
         "banana anitta",
         0,
         [
            131
         ]
      ],
      [
         "banana pancakes jack johnson",
         0,
         [
            131
         ]
      ],
      [
         "banana boat song",
         0
      ],
      [
         "banana song",
         0
      ]
   ],
   {
      "k":1,
      "q":"MhEk-OxAXxI_yePJjmXHYq0v6v8"
   }
]*/