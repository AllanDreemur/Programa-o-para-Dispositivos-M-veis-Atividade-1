import 'dart:io';

import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path_provider/path_provider.dart';

class CacheMapa {
  /// Cria a pasta privada do app antes de o mapa carregar as imagens.
  static Future<CachedTileProvider> criarProvedor() async {
    final base = await getApplicationCacheDirectory();
    final pasta = Directory('${base.path}${Platform.pathSeparator}mapa_tiles');
    await pasta.create(recursive: true);

    return CachedTileProvider(
      store: FileCacheStore(pasta.path),
      maxStale: const Duration(days: 30),
    );
  }
}