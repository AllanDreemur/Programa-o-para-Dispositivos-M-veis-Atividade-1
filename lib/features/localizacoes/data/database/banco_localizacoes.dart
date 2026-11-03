import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BancoLocalizacoes {
  BancoLocalizacoes._();
  static final BancoLocalizacoes instancia = BancoLocalizacoes._();

  static const nomeTabela = 'localizacoes';
  Future<Database>? _conexao;

  Future<Database> obter() async {
    try {
      return await (_conexao ??= _abrir());
    } catch (_) {
      _conexao = null; // permite nova tentativa
      rethrow;
    }
  }

  Future<Database> _abrir() async {
    final pasta = await getDatabasesPath();
    return openDatabase(
      join(pasta, 'localizacoes.db'),
      version: 1,
      onCreate: (db, versao) => db.execute('''
        CREATE TABLE $nomeTabela (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          precisao REAL NOT NULL,
          instante TEXT NOT NULL
        )
      '''),
    );
  }
}