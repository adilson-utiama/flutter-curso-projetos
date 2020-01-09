import 'package:flutter/material.dart';
import 'package:zapzap_clone/route/route_generator.dart';
import 'package:zapzap_clone/ui/cadastro.dart';
import 'package:zapzap_clone/ui/home.dart';
import 'package:zapzap_clone/ui/login.dart';

void main() => runApp(MaterialApp(
      home: Login(),
      theme: ThemeData(
        primaryColor: Color(0xff075E54),
        accentColor: Color(0xff25D366)
      ),
      initialRoute: "/",
      //Outra Forma de usar rotas nomeadas, declarando diretamente
/*      routes: {
        "/" : (context) => Login(),
        "/login": (context) => Login(),
        "/cadastro": (context) => Cadastro(),
        "/home": (context) => Home()
      },*/
      //Rotas determinadas em RouteGenerator
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    ));
