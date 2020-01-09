import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zapzap_clone/model/conversa.dart';
import 'package:zapzap_clone/model/usuario.dart';
import 'package:zapzap_clone/route/route_generator.dart';

class TabConversas extends StatefulWidget {
  @override
  _TabConversasState createState() => _TabConversasState();
}

class _TabConversasState extends State<TabConversas> {

  Firestore _db = Firestore.instance;
  String _idUsuarioLogado;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Stream<QuerySnapshot> _adicionarListenerConversas() {
    final stream = _db
        .collection("zapzap_conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future _inicializarDados() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _adicionarListenerConversas();
  }

  @override
  void initState() {
    _inicializarDados();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Erro ao carregar dados.");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, index) {
                    List<DocumentSnapshot> conversas =
                    querySnapshot.documents.toList();
                    DocumentSnapshot item = conversas[index];

                    String urlImagem = item["caminhoFoto"];
                    String tipo = item["tipoMensagem"];
                    String mensagem = item["mensagem"];
                    String nome = item["nome"];
                    String idDestinatario = item["idDestinatario"];

                    Usuario usuario = Usuario();
                    usuario.nome = nome;
                    usuario.urlAvatar = urlImagem;
                    usuario.idUsuario = idDestinatario;

                    return ListTile(
                      onTap: (){
                        Navigator.pushNamed(context, RouteGenerator.ROTA_MENSAGENS, arguments: usuario);
                      },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                            maxRadius: 30,
                            backgroundColor: Colors.grey,
                            backgroundImage: urlImagem != null
                                ? NetworkImage(urlImagem)
                                : null),
                        title: Text(
                          nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: tipo == "texto" ? Text(mensagem) : Text(
                          "Imagem enviada...",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    );
                  });
            }
            break;
          default:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando conversas"),
                  CircularProgressIndicator()
                ],
              ),
            );
        }
      },
    );
  }
}
