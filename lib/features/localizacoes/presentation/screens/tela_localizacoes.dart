import 'package:flutter/material.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../widgets/item_localizacao.dart';

class TelaLocalizacoes extends StatefulWidget {
  const TelaLocalizacoes({super.key, required this.coletaAtiva});

  final bool coletaAtiva;

  @override
  State<TelaLocalizacoes> createState() => _TelaLocalizacoesState();
}

class _TelaLocalizacoesState extends State<TelaLocalizacoes> {
  final _repositorio = RepositorioLocalizacoes();
  List<Localizacao> _itens = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final resultado = await _repositorio.ultimas();
      if (!mounted) return;
      setState(() {
        _itens = resultado;
        _erro = null;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível ler o histórico.';
        _carregando = false;
      });
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _limpar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: Text(
          'Todos os registros serão apagados permanentemente.'
          '${widget.coletaAtiva ? '\n\nA coleta está ativa: novos registros continuarão sendo salvos.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar histórico'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      await _repositorio.excluirTodas();
      if (!mounted) return;
      await _carregar();
      if (!mounted) return;
      _mensagem('Histórico apagado com sucesso.');
    } catch (_) {
      if (!mounted) return;
      _mensagem('Erro ao apagar o histórico.');
    }
  }

  Widget _conteudo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    // ListView em todos os casos, para o "puxar para atualizar" funcionar.
    if (_erro != null || _itens.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(_erro ?? 'Nenhuma localização registrada.')),
        ],
      );
    }
    return ListView.separated(
      itemCount: _itens.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => ItemLocalizacao(localizacao: _itens[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico (últimas 100)'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Limpar histórico',
            onPressed: _limpar,
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _carregar, child: _conteudo()),
    );
  }
}