import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

class RepositorioLocalizacoes {
  RepositorioLocalizacoes({BancoLocalizacoes? banco})
      : _banco = banco ?? BancoLocalizacoes.instancia;

  final BancoLocalizacoes _banco;

  Future<int> inserir(Localizacao localizacao) async {
    final db = await _banco.obter();
    final mapa = localizacao.toMap()..remove('id');
    return db.insert(BancoLocalizacoes.nomeTabela, mapa);
  }

  /// O limite vale só para a consulta. Nada é apagado automaticamente.
  Future<List<Localizacao>> ultimas({int limite = 100}) async {
    final db = await _banco.obter();
    final linhas = await db.query(
      BancoLocalizacoes.nomeTabela,
      orderBy: 'instante DESC, id DESC',
      limit: limite,
    );
    return linhas.map(Localizacao.fromMap).toList();
  }

  Future<int> excluirTodas() async {
    final db = await _banco.obter();
    return db.delete(BancoLocalizacoes.nomeTabela);
  }
}