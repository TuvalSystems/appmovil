import 'package:tuvalapp/presentation/screens/equipment/steam_traps/constants/steam_traps_catalogs.dart';

class SteamTrapCalculator {
  const SteamTrapCalculator._();

  static double pressureToPsig(double pressure, String unit) {
    switch (unit.toLowerCase()) {
      case 'psig':
        return pressure;
      case 'barg':
        return (pressure + 1.01325) / 0.0689476 - 14.6959;
      case 'kpag':
        return (pressure / 100 + 1.01325) / 0.0689476 - 14.6959;
      case 'psia':
        return pressure - 14.6959;
      case 'bara':
        return pressure / 0.0689476 - 14.6959;
      case 'kpaa':
        return (pressure / 100) / 0.0689476 - 14.6959;
      default:
        return pressure;
    }
  }

  static double hfgFromPsig(double psig) {
    final table = SteamTrapsCatalogs.steamTablePsig;

    if (table.isEmpty) return 0;

    if (psig <= table.first['psig']!) {
      return table.first['hfg']!;
    }

    if (psig >= table.last['psig']!) {
      return table.last['hfg']!;
    }

    for (int i = 0; i < table.length - 1; i++) {
      final a = table[i];
      final b = table[i + 1];

      final x1 = a['psig']!;
      final x2 = b['psig']!;

      if (psig >= x1 && psig <= x2) {
        final y1 = a['hfg']!;
        final y2 = b['hfg']!;
        final factor = (psig - x1) / (x2 - x1);

        return y1 + ((y2 - y1) * factor);
      }
    }

    return 0;
  }

  static double condensateFromHeating({
    required double volumeM3,
    required double densityKgM3,
    required double cpKjKgC,
    required double tempInicialC,
    required double tempFinalC,
    required double timeMin,
    required double hfgKjKg,
  }) {
    if (volumeM3 <= 0) return 0;
    if (densityKgM3 <= 0) return 0;
    if (cpKjKgC <= 0) return 0;
    if (timeMin <= 0) return 0;
    if (hfgKjKg <= 0) return 0;
    if (tempFinalC <= tempInicialC) return 0;

    final deltaT = tempFinalC - tempInicialC;

    return (60 * densityKgM3 * volumeM3 * cpKjKgC * deltaT) /
        (hfgKjKg * timeMin);
  }

  static double condensateFromBhp({required double bhp}) {
    if (bhp <= 0) return 0;

    return 0.15 * bhp * 15.65;
  }
}
