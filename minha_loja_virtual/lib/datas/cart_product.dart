import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minha_loja_virtual/datas/product_data.dart';

class CartProduct {

  String cartId;

  String category;
  String prodId;

  int quantity;
  String size;

  ProductData productData;

  CartProduct();

  CartProduct.fromDocument(DocumentSnapshot document){
    cartId = document.documentID;
    category = document.data["category"];
    prodId = document.data["prodId"];
    quantity = document.data["quantity"];
    size = document.data["size"];
  }

  Map<String, dynamic> toMap(){
    return {
      "category": category,
      "prodId": prodId,
      "quantity": quantity,
      "size": size,
      "product": productData.toResumedMap()
    };
  }
}