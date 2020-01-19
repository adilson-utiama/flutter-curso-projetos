import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:minha_loja_virtual/datas/cart_product.dart';
import 'package:minha_loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {
  UserModel user;

  List<CartProduct> products = [];

  String couponCode;
  int discountPercent = 0;

  CartModel(this.user) {
    if (user.isLoggedIn()) {
      _loadCartItens();
    }
  }

  bool isLoading = false;

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void addCartItem(CartProduct cartProduct) {
    products.add(cartProduct);
    Firestore.instance
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .add(cartProduct.toMap())
        .then((doc) {
      cartProduct.cartId = doc.documentID;
    });
    notifyListeners();
  }

  void removeCartItem(CartProduct cartProduct) {
    Firestore.instance
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cartId)
        .delete();
    products.remove(cartProduct);
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    cartProduct.quantity--;
    Firestore.instance
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cartId)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    cartProduct.quantity++;
    Firestore.instance
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cartId)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void setCoupon(String couponCode, int discountPercent) {
    this.couponCode = couponCode;
    this.discountPercent = discountPercent;
  }

  double getProductsPrice() {
    double price = 0.0;
    for (CartProduct c in products) {
      if (c.productData != null) {
        price += c.quantity * c.productData.price;
      }
    }
    return price;
  }

  double getShipPrice() {
    //Retornando um valor fixo, pois a funcao de frete ainda noa existe
    return 9.99;
  }

  double getDiscount() {
    return getProductsPrice() * discountPercent / 100;
  }

  void updatePrices() {
    notifyListeners();
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double productsPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    var db = Firestore.instance;

    DocumentReference refOrder =
        await db.collection("loja_virtual_orders").add({
      "clientId": user.firebaseUser.uid,
      "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
      "shipPrice": shipPrice,
      "productsPrice": productsPrice,
      "discount": discount,
      "totalPrice": productsPrice + shipPrice - discount,
      "status": 1
    });
    await db
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("orders")
        .document(refOrder.documentID)
        .setData({"ordeId": refOrder.documentID});

    QuerySnapshot query = await db
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();

    for(DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }
    products.clear();
    couponCode = null;
    discountPercent = 0;

    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }

  void _loadCartItens() async {
    QuerySnapshot query = await Firestore.instance
        .collection("loja_virtual_users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();
    products = query.documents
        .map((document) => CartProduct.fromDocument(document))
        .toList();
    notifyListeners();
  }
}
