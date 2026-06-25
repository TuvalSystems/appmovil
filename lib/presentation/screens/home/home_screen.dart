import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/infrastructure/services/app_update_service.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/content_body.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';
import 'package:tuvalapp/presentation/shared/widgets/tuval_app_bar.dart';
import 'package:tuvalapp/presentation/widgets/app_update_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppUpdateService _appUpdateService = AppUpdateService();

  bool _checkingUpdate = false;
  bool _updateDialogShown = false;
  bool _pointSalesRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPointSales();
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    if (_checkingUpdate || _updateDialogShown) return;

    _checkingUpdate = true;

    try {
      final result = await _appUpdateService.checkForUpdate();

      if (!mounted || result == null) return;

      if (result.hasUpdate) {
        _updateDialogShown = true;

        await showDialog(
          context: context,
          barrierDismissible: !result.isRequired,
          builder: (_) => AppUpdateDialog(result: result),
        );
      }
    } catch (e) {
      debugPrint('No se pudo validar actualización: $e');
    } finally {
      _checkingUpdate = false;
    }
  }

  Future<void> _loadPointSales() async {
    if (_pointSalesRequested) return;
    _pointSalesRequested = true;

    try {
      final pointSalesProvider = context.read<PointSalesProvider>();
      await pointSalesProvider.loadPointSales();
      if (!mounted) return;
      if (pointSalesProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(pointSalesProvider.errorMessage!),
          ),
        );
      }
    } catch (e) {
      debugPrint('No se pudo cargar puntos de venta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: TuvalAppBar(),
      drawer: const SideMenu(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ContentBody(user: user),
    );
  }
}
