import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';

class CustomerSearchResponse {
  final List<SteamTrapCustomer> customers;
  const CustomerSearchResponse({this.customers = const []});

  factory CustomerSearchResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CustomerSearchResponse(
      customers: data is List
          ? List.unmodifiable(
              data
                  .whereType<Map>()
                  .map(
                    (item) => SteamTrapCustomer.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .where(
                    (customer) =>
                        customer.id > 0 &&
                        customer.ruc.isNotEmpty &&
                        customer.razonSocial.isNotEmpty,
                  ),
            )
          : const [],
    );
  }
}
