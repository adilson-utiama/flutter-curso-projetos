import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minha_loja_virtual_admin/widgets/tiles/category_tile.dart';

class ProductsTab extends StatefulWidget {
  @override
  _ProductsTabState createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

//    return FutureBuilder<QuerySnapshot>(
//        future:
//        Firestore.instance.collection("loja_virtual_products").getDocuments(),
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection("loja_virtual_products").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        } else {
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return CategoryTile(snapshot.data.documents[index]);
              });
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
