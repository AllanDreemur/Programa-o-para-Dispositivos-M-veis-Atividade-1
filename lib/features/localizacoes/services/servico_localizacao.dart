import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

enum ResultadoPermissao {
  concedida,
  servicoDesativado,
  negada,
  negadaPermanentemente,
}

class ServicoLocalizacao {
  Future<ResultadoPermissao> garantirPermissao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return ResultadoPermissao.servicoDesativado;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.deniedForever) {
      return ResultadoPermissao.negadaPermanentemente;
    }
    if (permissao == LocationPermission.denied) {
      return ResultadoPermissao.negada;
    }

    // Android 13+: sem isso a notificação do serviço em primeiro plano fica oculta.
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    return ResultadoPermissao.concedida;
  }

  Stream<Position> posicoes() {
    return Geolocator.getPositionStream(locationSettings: _configuracoes());
  }

  LocationSettings _configuracoes() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 20),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Coleta de localização ativa',
          notificationText: 'Gravando sua posição periodicamente.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.high);
  }

  Future<bool> abrirConfiguracoesApp() => Geolocator.openAppSettings();
  Future<bool> abrirConfiguracoesLocalizacao() =>
      Geolocator.openLocationSettings();
}