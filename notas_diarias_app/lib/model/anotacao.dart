import 'package:notas_diarias_app/helper/anotacao_helper.dart';

class Anotacao{
  int id;
  String titulo;
  String anotacao;
  String data;

  Anotacao(this.titulo, this.anotacao, this.data);

  Anotacao.fromMap(Map map){
    this.id = map[AnotacaoHelper.idColuna];
    this.titulo = map[AnotacaoHelper.tituloColuna];
    this.anotacao = map[AnotacaoHelper.anotacaoColuna];
    this.data = map[AnotacaoHelper.dataColuna];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      AnotacaoHelper.tituloColuna : this.titulo,
      AnotacaoHelper.anotacaoColuna : this.anotacao,
      AnotacaoHelper.dataColuna : this.data
    };

    if(this.id != null){
      map[AnotacaoHelper.idColuna] = this.id;
    }

    return map;
  }
}