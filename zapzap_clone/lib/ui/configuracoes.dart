import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const String CAMERA = "CAMERA";
const String GALERIA = "GALERIA";

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {

  TextEditingController _controllerNome = TextEditingController();
  File _imagemAvatar;
  String _idUsuario;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  Future _recuperarImagem(String imageSource) async {
    File imagemSelecionada;
    switch(imageSource){
      case CAMERA:
        print("Selecionado: $imageSource");
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case GALERIA:
        print("Selecionado: $imageSource");
        imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _imagemAvatar = imagemSelecionada;
      if(_imagemAvatar != null){
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child("zapzap_perfil").child("$_idUsuario.jpg");

    StorageUploadTask task = arquivo.putFile(_imagemAvatar);
    task.events.listen((StorageTaskEvent event){
      if(event.type == StorageTaskEventType.progress){
        setState(() {
          _subindoImagem = true;
        });
      }else if(event.type == StorageTaskEventType.success){
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarUrlImagemFirestore(String url){
    Firestore db = Firestore.instance;

    Map<String, dynamic> dados = {
      "urlAvatar": url
    };

    db.collection("zapzap_usuarios").document(_idUsuario).updateData(dados);
  }

  _atualizarNomeFirestore(){
    Firestore db = Firestore.instance;

    Map<String, dynamic> dados = {
      "nome": _controllerNome.text
    };

    db.collection("zapzap_usuarios").document(_idUsuario).updateData(dados);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuario = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("zapzap_usuarios").document(_idUsuario).get();
    Map<String, dynamic> dadosUsuario = snapshot.data;
    _controllerNome.text = dadosUsuario["nome"];
    if(dadosUsuario["urlAvatar"] != null){
      setState(() {
        _urlImagemRecuperada = dadosUsuario["urlAvatar"];
      });
    }
  }

  @override
  void initState() {
    _recuperarDadosUsuario();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada != null
                      ? NetworkImage(_urlImagemRecuperada)
                      : null
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Camera", style: TextStyle(color: Colors.blueAccent),),
                      onPressed: (){
                        _recuperarImagem(CAMERA);
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria", style: TextStyle(color: Colors.blueAccent)),
                      onPressed: (){
                        _recuperarImagem(GALERIA);
                      },
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                        _atualizarNomeFirestore();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
