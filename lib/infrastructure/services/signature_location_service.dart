import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:tuvalapp/infrastructure/models/inventory/signature_location.dart';

class SignatureLocationService {
  Future<SignatureLocation> capture() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Active la ubicación del dispositivo para guardar la firma.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw StateError(
          'Permita el acceso a la ubicación desde los ajustes de la aplicación para guardar la firma.',
        );
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw StateError(
          'Debe permitir el acceso a la ubicación para guardar la firma.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
      return SignatureLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        signedAt: DateTime.now().toUtc(),
      );
    } on TimeoutException {
      throw StateError(
        'No se pudo obtener la ubicación en 30 segundos. Verifique el GPS e intente nuevamente.',
      );
    } on LocationServiceDisabledException {
      throw StateError(
        'Active la ubicación del dispositivo para guardar la firma.',
      );
    } on PermissionDeniedException {
      throw StateError(
        'Debe permitir el acceso a la ubicación para guardar la firma.',
      );
    }
  }
}
