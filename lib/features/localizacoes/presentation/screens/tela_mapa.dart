import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/cache_mapa.dart';
import '../widgets/item_localizacao.dart';
import '../widgets/mapa_localizacoes.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final _repositorio = RepositorioLocalizacoes();
  final _controlador = MapController();

  List<Localizacao> _itens = [];
  CachedTileProvider? _provedor;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final provedor = _provedor ?? await CacheMapa.criarProvedor();
      final itens = await _repositorio.ultimas();
      if (!mounted) return;
      setState(() {
        _provedor = provedor;
        _itens = itens;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os registros.';
        _carregando = false;
      });
    }
  }

  void _enquadrar() {
    if (_itens.isEmpty) return;
    _controlador.fitCamera(MapaLocalizacoes.enquadramento(_itens));
  }

  void _mostrarDetalhes(Localizacao l) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(child: ItemLocalizacao(localizacao: l)),
    );
  }

  Widget _corpo() {
    if (_carregando) return const Center(child: CircularProgressIndicator());
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erro!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _carregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_itens.isEmpty) {
      return const Center(child: Text('Nenhuma localização para exibir.'));
    }
    return MapaLocalizacoes(
      localizacoes: _itens,
      controlador: _controlador,
      provedorTiles: _provedor!,
      aoTocar: _mostrarDetalhes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa (últimas 100)'),
        actions: [
          IconButton(
            tooltip: 'Enquadrar todos os pontos',
            onPressed: _enquadrar,
            icon: const Icon(Icons.fit_screen),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _corpo(),
    );
  }
}