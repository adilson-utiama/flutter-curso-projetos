import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:notas_diarias_app/model/anotacao.dart';

import 'helper/anotacao_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _tituloController = TextEditingController();
  final _anotacaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();

  _exibirTelaCadastro({ Anotacao anotacao }) {
    String tituloDialog = "";
    String buttonText = "";
    if(anotacao == null){
      _tituloController.text = "";
      _anotacaoController.text = "";
      tituloDialog = "Salvar Anotação";
      buttonText = "Salvar";
    }else{
      _tituloController.text = anotacao.titulo;
      _anotacaoController.text = anotacao.anotacao;
      tituloDialog = "Editar Anotação";
      buttonText = "Atualizar";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(tituloDialog),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite o Título..."),
                ),
                TextField(
                  controller: _anotacaoController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: "Anotação", hintText: "Escreva a Anotação..."),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  _salvarOuAtualizarAnotacao(editAnotacao: anotacao);
                  Navigator.pop(context);
                },
                child: Text(buttonText),
              )
            ],
          );
        });
  }

  _recuperarAnotacoes() async {
    List<dynamic> all = await _db.recuperarAnotacoes();
    List<Anotacao> tempList = List<Anotacao>();
    all.forEach((item) => tempList.add(Anotacao.fromMap(item)));
    setState(() {
      _anotacoes = tempList;
    });
    tempList = null;
  }

  _salvarOuAtualizarAnotacao({ Anotacao editAnotacao }) async {
    String tituloText = _tituloController.text;
    String anotacaoText = _anotacaoController.text;
    String dataAtual = DateTime.now().toString();

    if( editAnotacao == null ){
      //Salvando
      Anotacao anotacao = Anotacao(tituloText, anotacaoText, dataAtual);
      int id = await _db.salvarAnotacao(anotacao);
    }else{
      //Editando
      editAnotacao.titulo = tituloText;
      editAnotacao.anotacao = anotacaoText;
      editAnotacao.data = dataAtual;
      int id = await _db.atualizarAnotacao(editAnotacao);
    }
    _tituloController.clear();
    _anotacaoController.clear();

    _recuperarAnotacoes();
  }

  _deletarAnotacao(int id){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Deletar Anotação?"),
        elevation: 0.7,
        actions: <Widget>[
          FlatButton(
            child: Text("Cancelar"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("Deletar"),
            onPressed: () async {
               await _db.deletarAnotacao(id);
               _recuperarAnotacoes();
               Navigator.pop(context);
            },
          )
        ],
      );
    });
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR", null);

    //var dateFormat = DateFormat("d/MM/y - H:m");
    var dateFormat = DateFormat.yMMMMd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = dateFormat.format(dataConvertida);

    return dataFormatada;
  }

  @override
  Widget build(BuildContext context) {
    _recuperarAnotacoes();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notas Diárias"),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index) {
                  return _buildListItem(_anotacoes[index]);
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () {
          _exibirTelaCadastro();
        },
      ),
    );
  }

  Widget _buildListItem(Anotacao anotacao) {
    return Card(
      elevation: 6.0,
      margin: EdgeInsets.only(top: 7.0, right: 7.0, left: 7.0),
      child: Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: ListTile(
          title: Text(anotacao.titulo),
          subtitle:
              Text("${_formatarData(anotacao.data)}\n${anotacao.anotacao}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: (){
                    _exibirTelaCadastro(anotacao: anotacao);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.edit, color: Colors.green,),
                ),
              ),
              GestureDetector(
                onTap: (){
                    _deletarAnotacao(anotacao.id);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: Icon(Icons.remove_circle, color: Colors.red,),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
