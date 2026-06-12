class SteamTrapSizingRequest {
  //cliente
  final int? customerId;
  final String? customerRuc;

  final int? pvId;
  final String? pvDescription;
  final String? pvCode;

  final String process;
  final String trapType;
  final String calculationMethod;

  final double workingPressurePsig;
  final double returnPressurePsig;
  final double pressureDifferentialPsig;

  final String? fluid;
  final double? volumeM3;
  final double? densityKgM3;
  final double? cpKjKgC;
  final double? initialTemperatureC;
  final double? finalTemperatureC;
  final double? heatingTimeMin;
  final double? requiredHeatKj;
  final double? hfgKjKg;

  final double? knownLoadKgH;
  final double? boilerBhp;

  final double estimatedLoadKg;
  final double safetyFactor;
  final double loadWithSafetyFactorKg;

  const SteamTrapSizingRequest({
    required this.customerId,
    required this.customerRuc,
    required this.pvId,
    required this.pvDescription,
    required this.pvCode,
    required this.process,
    required this.trapType,
    required this.calculationMethod,
    required this.workingPressurePsig,
    required this.returnPressurePsig,
    required this.pressureDifferentialPsig,
    this.fluid,
    this.volumeM3,
    this.densityKgM3,
    this.cpKjKgC,
    this.initialTemperatureC,
    this.finalTemperatureC,
    this.heatingTimeMin,
    this.requiredHeatKj,
    this.hfgKjKg,
    this.knownLoadKgH,
    this.boilerBhp,
    required this.estimatedLoadKg,
    required this.safetyFactor,
    required this.loadWithSafetyFactorKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_ruc': customerRuc,

      'pvId'  : pvId,
      'pvDescription': pvDescription,
      'pvCode': pvCode,

      'process': process,
      'trapType': trapType,
      'calculationMethod': calculationMethod,

      'workingPressurePsig': workingPressurePsig,
      'returnPressurePsig': returnPressurePsig,
      'pressureDifferentialPsig': pressureDifferentialPsig,

      'fluid': fluid,
      'volumeM3': volumeM3,
      'densityKgM3': densityKgM3,
      'cpKjKgC': cpKjKgC,
      'initialTemperatureC': initialTemperatureC,
      'finalTemperatureC': finalTemperatureC,
      'heatingTimeMin': heatingTimeMin,
      'requiredHeatKj': requiredHeatKj,
      'hfgKjKg': hfgKjKg,

      'knownLoadKgH': knownLoadKgH,
      'boilerBhp': boilerBhp,

      'estimatedLoadKg': estimatedLoadKg,
      'safetyFactor': safetyFactor,
      'loadWithSafetyFactorKg': loadWithSafetyFactorKg,

      'spParams': {
        'workingPressurePsig': workingPressurePsig,
        'returnPressurePsig': returnPressurePsig,
        'estimatedLoadKg': estimatedLoadKg,
        'safetyFactor': safetyFactor,
      },
    };
  }
}
