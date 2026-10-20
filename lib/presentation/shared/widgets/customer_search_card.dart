import 'package:flutter/material.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';
import 'package:tuvalapp/presentation/shared/controllers/customer_search_controller.dart';

class CustomerSearchCard extends StatelessWidget {
  final CustomerSearchController controller;
  final String description;
  const CustomerSearchCard({
    super.key,
    required this.controller,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => _buildContents(context),
  );

  Widget _buildContents(BuildContext context) {
    final provider = controller;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.muted,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: provider.customerSearchController,
            textInputAction: TextInputAction.search,
            onChanged: provider.onCustomerSearchChanged,
            onSubmitted: provider.searchCustomers,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, RUC o nombre corto',
              filled: true,
              fillColor: context.appColors.card,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _SuffixIcon(provider: provider),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: context.appColors.border,
                  width: 0.7,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: context.appColors.border,
                  width: 0.7,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.brand, width: 1.2),
              ),
            ),
          ),

          if (provider.selectedCustomer != null) ...[
            SizedBox(height: 12),
            _SelectedCustomerBox(
              customer: provider.selectedCustomer!,
              onClear: provider.clearSelectedCustomer,
            ),
          ],

          if (provider.customerSearchMessage != null &&
              provider.selectedCustomer == null) ...[
            SizedBox(height: 10),
            Text(
              provider.customerSearchMessage!,
              style: TextStyle(color: context.appColors.muted, fontSize: 12),
            ),
          ],

          if (provider.customerResults.isNotEmpty) ...[
            SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 230),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: provider.customerResults.length,
                separatorBuilder: (_, _) {
                  return Divider(height: 1, color: context.appColors.border);
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
  final CustomerSearchController provider;

  const _SuffixIcon({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isSearchingCustomer) {
      return Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (provider.customerSearchController.text.isNotEmpty) {
      return IconButton(
        onPressed: provider.clearSelectedCustomer,
        icon: Icon(Icons.close),
      );
    }

    return SizedBox.shrink();
  }
}

class _CustomerResultItem extends StatelessWidget {
  final SteamTrapCustomer customer;
  final VoidCallback onTap;

  const _CustomerResultItem({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final location = _buildLocation(customer);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.appColors.pill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_search,
                size: 20,
                color: context.appColors.text,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.razonSocial,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.text,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.appColors.muted),
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

  const _SelectedCustomerBox({required this.customer, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final location = _buildLocation(customer);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.successSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border, width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: context.appColors.success),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente seleccionado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.success,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  customer.razonSocial,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.appColors.text,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.muted,
                  ),
                ),
                if (customer.nombreCorto.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    'Nombre corto: ${customer.nombreCorto}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(onPressed: onClear, icon: Icon(Icons.close)),
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
