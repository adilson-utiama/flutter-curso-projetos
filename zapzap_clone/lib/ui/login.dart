import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zapzap_clone/model/usuario.dart';
import 'package:zapzap_clone/route/route_generator.dart';
import 'package:zapzap_clone/ui/cadastro.dart';
import 'package:zapzap_clone/ui/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController(text: "adilson@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(text: "1234567");
  String _mensagemErro = "";

  _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty) {
      if (senha.isNotEmpty) {
        setState(() {
          _mensagemErro = "";
        });
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = "Preencha o campo senha.";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o campo email.";
      });
    }
  }

  void _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
        email: usuario.email, password: usuario.senha).then((firebaseUser) {

          Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
//        Navigator.pushReplacement(context, MaterialPageRoute(
//          builder: (context) => Home()
//        ));

    }).catchError((erro){
      print(erro);
      setState(() {
        _mensagemErro = "Erro ao autenticar Usuario, verifique os dados e tente novamente";
      });
    });
  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    if(usuarioLogado != null){

      //Utilizando rotas nomeadas
      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
//      Navigator.pushReplacement(context, MaterialPageRoute(
//        builder: (context) => Home()
//      ));
    }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: Image.asset(
                    "images/logo_zapzap.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                TextField(
                  controller: _controllerSenha,
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                    onPressed: () {
                      _validarCampos();
                    },
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? Cadastre-se.",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, RouteGenerator.ROTA_CADASTRO);
//                      Navigator.push(context,
//                          MaterialPageRoute(builder: (context) => Cadastro()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    _mensagemErro,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 18),
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
