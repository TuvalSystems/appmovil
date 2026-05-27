import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';

class CustomerSearchCard extends StatelessWidget {
  const CustomerSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffbfdff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffdce6f2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cliente',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xff07142b),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Busque y seleccione el cliente sobre el cual se aplicará este dimensionamiento.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: provider.customerSearchController,
            textInputAction: TextInputAction.search,
            onChanged: provider.onCustomerSearchChanged,
            onSubmitted: provider.searchCustomers,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, RUC o nombre corto',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _SuffixIcon(provider: provider),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xffdce6f2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xffdce6f2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppColors.brand,
                  width: 1.4,
                ),
              ),
            ),
          ),

          if (provider.selectedCustomer != null) ...[
            const SizedBox(height: 12),
            _SelectedCustomerBox(
              customer: provider.selectedCustomer!,
              onClear: provider.clearSelectedCustomer,
            ),
          ],

          if (provider.customerSearchMessage != null &&
              provider.selectedCustomer == null) ...[
            const SizedBox(height: 10),
            Text(
              provider.customerSearchMessage!,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
          ],

          if (provider.customerResults.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 230,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: provider.customerResults.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    height: 1,
                    color: Color(0xffe6edf5),
                  );
                },
                itemBuilder: (context, index) {
                  final customer = provider.customerResults[index];

                  return _CustomerResultItem(
                    customer: customer,
                    onTap: () {
                      provider.selectCustomer(customer);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuffixIcon extends StatelessWidget {
  final SteamTrapProvider provider;

  const _SuffixIcon({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isSearchingCustomer) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (provider.customerSearchController.text.isNotEmpty) {
      return IconButton(
        onPressed: provider.clearSelectedCustomer,
        icon: const Icon(Icons.close),
      );
    }

    return const SizedBox.shrink();
  }
}

class _CustomerResultItem extends StatelessWidget {
  final SteamTrapCustomer customer;
  final VoidCallback onTap;

  const _CustomerResultItem({
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final location = _buildLocation(customer);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffeef3f9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_search,
                size: 20,
                color: Color(0xff07142b),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.razonSocial,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff07142b),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff344563),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xff344563),
            ),
          ],
        ),
      ),
    );
  }

  String _buildLocation(SteamTrapCustomer customer) {
    final parts = [
      customer.ruc,
      customer.ciudad,
      customer.provincia,
    ].where((item) => item.trim().isNotEmpty).toList();

    return parts.join(' · ');
  }
}

class _SelectedCustomerBox extends StatelessWidget {
  final SteamTrapCustomer customer;
  final VoidCallback onClear;

  const _SelectedCustomerBox({
    required this.customer,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final location = _buildLocation(customer);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffeef7f0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffbfe3c7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xff198754),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cliente seleccionado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff198754),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.razonSocial,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xff07142b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff344563),
                  ),
                ),
                if (customer.nombreCorto.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Nombre corto: ${customer.nombreCorto}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff344563),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  String _buildLocation(SteamTrapCustomer customer) {
    final parts = [
      customer.ruc,
      customer.ciudad,
      customer.provincia,
    ].where((item) => item.trim().isNotEmpty).toList();

    return parts.join(' · ');
  }
}