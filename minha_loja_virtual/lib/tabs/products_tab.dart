import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minha_loja_virtual/tiles/category_tile.dart';

class ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection("loja_virtual_products").getDocuments(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }else{

          var dividedTiles = ListTile.divideTiles(tiles: snapshot.data.documents.map((document){
            return CategoryTile(document);
          }).toList(),
          color: Colors.grey[500]).toList();

          return ListView(
            children: dividedTiles,
          );
        }
      }
    );
  }
}
