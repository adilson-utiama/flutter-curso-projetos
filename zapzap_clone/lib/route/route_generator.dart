import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zapzap_clone/ui/cadastro.dart';
import 'package:zapzap_clone/ui/configuracoes.dart';
import 'package:zapzap_clone/ui/home.dart';
import 'package:zapzap_clone/ui/login.dart';
import 'package:zapzap_clone/ui/mensagens.dart';

/// Classe responsavel por determinar as rotas
class RouteGenerator {

  static const String ROTA_HOME = "/home";
  static const String ROTA_LOGIN = "/login";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_CONFIGURACOES = "/configuracoes";
  static const String ROTA_MENSAGENS = "/mensagens";

  static Route<dynamic> generateRoute(RouteSettings settings) {

    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(
          builder: (context) => Login()
        );
      case ROTA_LOGIN:
        return MaterialPageRoute(
          builder: (context) => Login()
        );
      case ROTA_CADASTRO:
        return MaterialPageRoute(
            builder: (context) => Cadastro()
        );
      case ROTA_HOME:
        return MaterialPageRoute(
            builder: (context) => Home()
        );
      case ROTA_CONFIGURACOES:
        return MaterialPageRoute(
            builder: (context) => Configuracoes()
        );
      case ROTA_MENSAGENS:
        return MaterialPageRoute(
            builder: (context) => Mensagens(args)
        );
      default:
        return _erroRota();
    }
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(
      builder: (_){
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada"),
          ),
          body: Center(
            child: Text("Tela não encontrada"),
          ),
        );
      }
    );
  }

}