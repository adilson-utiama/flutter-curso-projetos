import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class ProductBloc extends BlocBase {

  final _dataController = BehaviorSubject<Map>();
  final _loadingController = BehaviorSubject<bool>();
  final _createdController = BehaviorSubject<bool>();

  Stream<Map> get outData => _dataController.stream;
  Stream<bool> get outLoading => _loadingController.stream;
  Stream<bool> get outCreated => _createdController.stream;

  String categoryId;
  DocumentSnapshot product;

  Map<String, dynamic> unsaveData;

  ProductBloc({this.categoryId, this.product}){
    if(product != null){
      unsaveData = Map.of(product.data);
      unsaveData["images"] = List.of(product.data["images"]);
      unsaveData["sizes"] = List.of(product.data["sizes"]);

      _createdController.add(true);
    }else{
      unsaveData = {
        "title": null,
        "description": null,
        "price": null,
        "images": [],
        "sizes": []
      };
      _createdController.add(false);
    }

    _dataController.add(unsaveData);
  }

  void saveTitle(String title){
    unsaveData["title"] = title;
  }

  void saveDescription(String description){
    unsaveData["description"] = description;
  }

  void savePrice(String price){
    unsaveData["price"] = double.parse(price);
  }

  void saveImages(List images){
    unsaveData["images"] = images;
  }

  void saveSizes(List sizes){
    unsaveData["sizes"] = sizes;
  }

  Future<bool> saveProduct() async {
    _loadingController.add(true);

    try{
      if(product != null){
        await _uploadImages(product.documentID);
        await product.reference.updateData(unsaveData);
      }else{
        DocumentReference ref = await Firestore.instance.collection("loja_virtual_products")
            .document(categoryId)
            .collection("items")
            .add(Map.from(unsaveData)..remove("images"));

        await _uploadImages(ref.documentID);
        await ref.updateData(unsaveData);
      }
      _createdController.add(true);
      _loadingController.add(false);
      return true;
    }catch(e){
      _loadingController.add(false);
      return false;
    }
//
//    _loadingController.add(false);
//    return true;
  }

  Future _uploadImages(String productId) async {

    List<String> files = [];

    for(int i = 0; i < unsaveData["images"].length; i++){
      if(unsaveData["images"][i] is String) continue;

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      files.add(fileName);
      StorageUploadTask uploadTask = FirebaseStorage.instance.ref()
          .child("loja_virtual")
          .child("produtos")
          .child(categoryId)
          .child(productId)
          .child(fileName)
          .putFile(unsaveData["images"][i]);
      
      StorageTaskSnapshot snap = await uploadTask.onComplete;
      String downloadUrl = await snap.ref.getDownloadURL();
      
      unsaveData["images"][i] = downloadUrl;
    }

    Firestore.instance.collection("loja_virtual_products")
        .document(categoryId)
        .collection("items")
        .document(productId)
        .setData({
            "files": files
        });

  }



  @override
  void dispose() {
    _dataController.close();
    _loadingController.close();
    _createdController.close();
    super.dispose();
  }

  void deleteProduct() async {
    print(product.documentID);
    print(product.data);
    print(product.reference.documentID);
    await product.reference.delete();
    await _deleteImages(product.documentID);
  }

  Future _deleteImages(String productId) async {
    for(int i = 0; i < product.data["files"].length; i++){
      await FirebaseStorage.instance.ref()
          .child("loja_virtual")
          .child("produtos")
          .child(categoryId)
          .child(productId)
          .child(product.data["files"][i])
          .delete();
    }
  }
}