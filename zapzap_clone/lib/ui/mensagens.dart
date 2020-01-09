import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zapzap_clone/model/conversa.dart';
import 'package:zapzap_clone/model/mensagem.dart';
import 'package:zapzap_clone/model/usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;
  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  Usuario _usuarioLogado;
  bool _subindoImagem = false;
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;

  Firestore _db = Firestore.instance;

  TextEditingController _controllerMensagem = TextEditingController();

  final _controller  = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  void _enviarMensagem() {
    String textMensagem = _controllerMensagem.text;
    if (textMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      //Salva mensagem para remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      //SAlva mensagem para destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      //Salva Conversa
     _salvarConversa(mensagem);

      _controllerMensagem.clear();
    }
  }

  _salvarConversa(Mensagem msg) async {
    //Salva conversa remetente
    Conversa cRemetente = Conversa.empty();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlAvatar;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salva conversa destinatario
    Conversa cDestinatario = Conversa.empty();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
//    cDestinatario.nome = widget.contato.nome;
//    cDestinatario.caminhoFoto = widget.contato.urlAvatar;
    cDestinatario.nome = _usuarioLogado.nome;
    cDestinatario.caminhoFoto = _usuarioLogado.urlAvatar;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();

  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem mensagem) async {

    String time = DateTime.now().millisecondsSinceEpoch.toString();

    await _db
        .collection("zapzap_mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .document(time)
        .setData(mensagem.toMap());
    //Limpa texto
    _controllerMensagem.clear();

  }

  void _enviarFoto() async {
    File imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("zapzap_mensagens")
        .child(_idUsuarioLogado)
        .child("$nomeImagem.jpg");

    StorageUploadTask task = arquivo.putFile(imagemSelecionada);
    task.events.listen((StorageTaskEvent event) {
      if (event.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (event.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";

    //Salva mensagem para remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    //SAlva mensagem para destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

    //Salva Conversa
    _salvarConversa(mensagem);
  }

  Future _recuperaDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    DocumentSnapshot usuario =  await _db.collection("zapzap_usuarios").document(_idUsuarioLogado).get();
    print(usuario.data);
    _usuarioLogado = Usuario();
    _usuarioLogado.urlAvatar = usuario.data["urlAvatar"];
    _usuarioLogado.nome = usuario.data["nome"];

    _idUsuarioDestinatario = widget.contato.idUsuario;

    _adicionarListenerMensagens();
  }

  //Listener para detectar mudanca na base de dados e atualizar a tela no StreamBuilder
  Stream<QuerySnapshot> _adicionarListenerMensagens(){
    final stream = _db.collection("zapzap_mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .snapshots();
    stream.listen((dados){
      _controller.add(dados);
      //Pula para o ultimo item da lista dpois de 1 segundo, apos atualizar lista
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperaDadosUsuario();

  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Color(0xff075E54),
                            ),
                            onPressed: _enviarFoto,
                          )),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando Mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;
            if (snapshot.hasError) {
              return Text("Erro ao carregar dados.");
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, index) {
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[index];

                      //Largura com 80% da largura total da tela
                      var larguraContainerMsg =
                          MediaQuery.of(context).size.width * 0.8;

                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffD2FFA5);
                      if (_idUsuarioLogado != item["idUsuario"]) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                              width: larguraContainerMsg,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: item["tipo"] == "texto"
                                  ? Text(
                                      item["mensagem"],
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Image.network(item["urlImagem"])),
                        ),
                      );
                    }),
              );
            }
            break;
          default:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando Mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
        }
      },
    );

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              CircleAvatar(
                  maxRadius: 20,
                  backgroundColor: Colors.grey,
                  backgroundImage: widget.contato.urlAvatar != null
                      ? NetworkImage(widget.contato.urlAvatar)
                      : null),
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(widget.contato.nome),
              )
            ],
          ),
        ),
        body: Container(
          //No MediaQuery informa a largura da tela
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  stream,
                  caixaMensagem,
                ],
              ),
            ),
          ),
        ));
  }
}
