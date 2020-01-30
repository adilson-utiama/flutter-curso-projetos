import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minha_loja_virtual_admin/validators/login_validators.dart';
import 'package:rxdart/rxdart.dart';

enum LoginState { IDLE, LOADING, SUCCESS, FAIL }

class LoginBloc extends BlocBase with LoginValidators{

  //login: admin@lojavirtual.com:12345678

  final _emailController = BehaviorSubject<String>();
  final _senhaController = BehaviorSubject<String>();
  final _stateController = BehaviorSubject<LoginState>();

  Stream<String> get outEmail => _emailController.stream.transform(validateEmail);
  Stream<String> get outSenha => _senhaController.stream.transform(validateSenha);
  Stream<LoginState> get outState => _stateController.stream;

  Stream<bool> get outSubmitValid => Rx.combineLatest2(
    outEmail, outSenha, (a, b) =>  true
  );

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeSenha => _senhaController.sink.add;

  StreamSubscription _streamSubscription;

  LoginBloc(){
    _streamSubscription = FirebaseAuth.instance.onAuthStateChanged.listen(
        (user) async {
          if(user != null){
            if(await verifyPrivileges(user)){
              _stateController.add(LoginState.SUCCESS);
            }else{
              _stateController.add(LoginState.FAIL);
              FirebaseAuth.instance.signOut();
            }
          } else{
            _stateController.add(LoginState.IDLE);
          }
        }
    );
  }

  Future<bool> verifyPrivileges(FirebaseUser user) async {
    return await Firestore.instance.collection("loja_virtual_admins")
        .document(user.uid)
        .get()
        .then((doc){
          print(doc.data);
          if(doc.data != null){
            return true;
          }else{
            return false;
          }
    }).catchError((err) => false);
  }

  void submit(){
    final email = _emailController.value;
    final senha = _senhaController.value;

    _stateController.add(LoginState.LOADING);

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(email: email, password: senha)
        .catchError((err){
          print(err.toString());
       _stateController.add(LoginState.FAIL);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.close();
    _senhaController.close();
    _stateController.close();
    _streamSubscription.cancel();
  }
}