import 'package:notas_diarias_app/model/anotacao.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AnotacaoHelper {
  static final String nomeTabela = "notas";
  static final String idColuna = "id";
  static final String tituloColuna = "titulo";
  static final String anotacaoColuna = "anotacao";
  static final String dataColuna = "data";

  //Singleton
  static final _helper = AnotacaoHelper._internal();

  factory AnotacaoHelper() {
    return _helper;
  }

  AnotacaoHelper._internal();

  //Database
  Database _db;

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicializarDB();
      return _db;
    }
  }

  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "notas_diarias.db");
    Database db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreateDB);
    return db;
  }

  _onCreateDB(Database db, int version) async {
    String sql =
        "CREATE TABLE $nomeTabela ($idColuna INTEGER PRIMARY KEY AUTOINCREMENT, "
        "$tituloColuna VARCHAR, "
        "$anotacaoColuna TEXT, "
        "$dataColuna DATETIME);";
    await db.execute(sql);
  }

  Future<int> salvarAnotacao(Anotacao anotacao) async {
    Database bancoDados = await db;
    return await bancoDados.insert(nomeTabela, anotacao.toMap());
  }

  Future<List> recuperarAnotacoes() async {
    Database bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY $dataColuna DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    Database banco = await db;
    return await banco.update(nomeTabela, anotacao.toMap(),
        where: "id = ?", whereArgs: [anotacao.id]);
  }

  deletarAnotacao(int id) async {
    Database banco = await db;
    await banco.delete(nomeTabela, where: "id = ?", whereArgs: [id]);
  }
}
