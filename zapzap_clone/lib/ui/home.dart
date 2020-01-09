import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zapzap_clone/route/route_generator.dart';
import 'package:zapzap_clone/tabs/TabContatos.dart';
import 'package:zapzap_clone/tabs/TabConversas.dart';
import 'package:zapzap_clone/ui/login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  TabController _tabController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _emailUsuario = "";

  List<String> itensMenuOption = [
    "Configurações", "Deslogar"
  ];

  @override
  void initState() {
    super.initState();

    _verificaUsuarioLogado();
    _recuperaDadosUsuario();
    _tabController = TabController(
      length: 2,
      vsync: this
    );
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado == null){
      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
    }
  }


  Future _recuperaDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    setState(() {
      _emailUsuario = usuarioLogado.email;
    });
  }

  _escolhaMenuItem(String itemSelecionado){
    switch(itemSelecionado) {
      case "Configurações":
        Navigator.pushNamed(context, RouteGenerator.ROTA_CONFIGURACOES);
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deslogar Do App?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Deslogar"),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
                  /*Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => Login()
                  ));*/
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text("ZapZap Clone"),
        backgroundColor: Colors.green,
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(text: "Conversas",),
            Tab(text: "Contatos",)
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
              return itensMenuOption.map((String item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TabConversas(),
          TabContatos()
        ],
      ),
    );
  }
}
