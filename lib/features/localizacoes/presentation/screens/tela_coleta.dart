import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/repositorio_localizacoes.dart';
import '../../models/localizacao.dart';
import '../../services/servico_localizacao.dart';
import 'tela_localizacoes.dart';
import 'tela_mapa.dart';

class TelaColeta extends StatefulWidget {
  const TelaColeta({super.key});

  @override
  State<TelaColeta> createState() => _TelaColetaState();
}

class _TelaColetaState extends State<TelaColeta> {
  final _servico = ServicoLocalizacao();
  final _repositorio = RepositorioLocalizacoes();

  StreamSubscription<Position>? _assinatura;
  Future<void> _filaGravacao = Future.value();
  bool _iniciando = false;
  int _gravadas = 0;

  bool get _coletando => _assinatura != null;

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _iniciar() async {
    if (_coletando || _iniciando) return;
    setState(() => _iniciando = true);

    final resultado = await _servico.garantirPermissao();
    if (!mounted) return;

    if (resultado != ResultadoPermissao.concedida) {
      setState(() => _iniciando = false);
      await _orientarUsuario(resultado);
      return;
    }

    _assinatura = _servico.posicoes().listen(_aoReceber, onError: _aoErro);
    setState(() => _iniciando = false);
  }

  void _aoReceber(Position p) {
    final localizacao = Localizacao(
      latitude: p.latitude,
      longitude: p.longitude,
      precisao: p.accuracy,
      instante: p.timestamp.toUtc(),
    );
    // Encadeia: cada gravação só começa quando a anterior termina.
    _filaGravacao = _filaGravacao.then((_) async {
      try {
        await _repositorio.inserir(localizacao);
        if (mounted) setState(() => _gravadas++);
      } catch (_) {
        if (mounted) _mensagem('Erro ao gravar a localização no banco.');
      }
    });
  }

  Future<void> _aoErro(Object erro) async {
    await _parar();
    if (!mounted) return;
    _mensagem(erro is LocationServiceDisabledException
        ? 'O GPS foi desativado. Coleta interrompida.'
        : 'Erro na coleta de localização. Coleta interrompida.');
  }

  Future<void> _parar() async {
    final assinatura = _assinatura;
    if (assinatura == null) return;
    setState(() => _assinatura = null);
    await assinatura.cancel();
  }

  Future<void> _orientarUsuario(ResultadoPermissao resultado) async {
    final (String texto, String? acao, Future<bool> Function()? abrir) =
        switch (resultado) {
      ResultadoPermissao.servicoDesativado => (
          'O serviço de localização (GPS) está desativado.',
          'Abrir configurações de localização',
          _servico.abrirConfiguracoesLocalizacao,
        ),
      ResultadoPermissao.negadaPermanentemente => (
          'A permissão de localização foi negada. Habilite-a nas configurações do aplicativo.',
          'Abrir configurações do app',
          _servico.abrirConfiguracoesApp,
        ),
      _ => (
          'A permissão de localização é necessária para a coleta.',
          null,
          null,
        ),
    };

    final abrirConfig = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Localização'),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Fechar'),
          ),
          if (acao != null)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(acao),
            ),
        ],
      ),
    );
    if (abrirConfig == true && abrir != null) await abrir();
  }

  void _abrirTela(Widget tela) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coleta de localização')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _coletando
                  ? 'Coleta ativa • $_gravadas posições gravadas nesta sessão'
                  : 'Coleta parada',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: (_coletando || _iniciando) ? null : _iniciar,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar coleta'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: (_coletando && !_iniciando) ? _parar : null,
              icon: const Icon(Icons.stop),
              label: const Text('Parar coleta'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  _abrirTela(TelaLocalizacoes(coletaAtiva: _coletando)),
              icon: const Icon(Icons.history),
              label: const Text('Consultar histórico'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _abrirTela(const TelaMapa()),
              icon: const Icon(Icons.map),
              label: const Text('Ver mapa'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _servico.abrirConfiguracoesApp,
              icon: const Icon(Icons.settings),
              label: const Text('Configurações de permissão'),
            ),
          ],
        ),
      ),
    );
  }
}