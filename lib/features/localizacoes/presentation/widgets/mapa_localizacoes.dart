import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';

import '../../models/localizacao.dart';

class MapaLocalizacoes extends StatelessWidget {
  const MapaLocalizacoes({
    super.key,
    required this.localizacoes, // índice 0 = mais recente
    required this.controlador,
    required this.provedorTiles,
    required this.aoTocar,
  });

  final List<Localizacao> localizacoes;
  final MapController controlador;
  final CachedTileProvider provedorTiles;
  final void Function(Localizacao) aoTocar;

  static CameraFit enquadramento(List<Localizacao> itens) => CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(
          itens.map((l) => LatLng(l.latitude, l.longitude)).toList(),
        ),
        padding: const EdgeInsets.all(48),
        maxZoom: 17,
      );

  @override
  Widget build(BuildContext context) {
    // Desenha do mais antigo para o mais recente, para o vermelho ficar por cima.
    final marcadores = <Marker>[
      for (var i = localizacoes.length - 1; i >= 0; i--)
        Marker(
          point: LatLng(localizacoes[i].latitude, localizacoes[i].longitude),
          width: 40,
          height: 40,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => aoTocar(localizacoes[i]),
            child: Icon(
              Icons.location_on,
              size: i == 0 ? 44 : 32,
              color: i == 0 ? Colors.red : Colors.blue,
            ),
          ),
        ),
    ];

    return FlutterMap(
      mapController: controlador,
      options: MapOptions(initialCameraFit: enquadramento(localizacoes)),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'br.fatec.app_localizacoes',
          tileProvider: provedorTiles,
        ),
        MarkerLayer(markers: marcadores),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
        ),
      ],
    );
  }
}