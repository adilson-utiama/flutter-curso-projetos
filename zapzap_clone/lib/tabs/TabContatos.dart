import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zapzap_clone/model/usuario.dart';
import 'package:zapzap_clone/route/route_generator.dart';

class TabContatos extends StatefulWidget {
  @override
  _TabContatosState createState() => _TabContatosState();
}

class _TabContatosState extends State<TabContatos> {
  String _idUsuarioAtual;
  String _emailUsuarioAtual;

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection("zapzap_usuarios").getDocuments();
    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;

      //Verifica se usuario é o usuario logado atual, se for igual ignora e passa para o proximo
      if (dados["email"] == _emailUsuarioAtual) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.nome = dados["nome"];
      usuario.email = dados["email"];
      usuario.urlAvatar = dados["urlAvatar"];
      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioAtual = usuarioLogado.uid;
    _emailUsuarioAtual = usuarioLogado.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      // ignore: missing_return
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando Contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
            break;
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  List<Usuario> listaItens = snapshot.data;
                  Usuario usuario = listaItens[index];
                  return ListTile(
                    onTap: (){
                      //Passando um usuario para a rota seguinte
                      Navigator.pushNamed(context, RouteGenerator.ROTA_MENSAGENS, arguments: usuario);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: usuario.urlAvatar != null
                            ? NetworkImage(usuario.urlAvatar)
                            : null),
                    title: Text(
                      usuario.nome,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
        }
      },
    );
  }
}
