import 'package:tuvalapp/infrastructure/services/biometric_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/sanctum_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/steam_trap_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/app_version_datasource.dart';
import 'package:tuvalapp/infrastructure/services/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/environment/app_environment.dart';
import 'package:tuvalapp/config/router/app_router.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/infrastructure/datasources/point_sales_datasource.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/auth/check_auth_screen.dart';
import 'package:tuvalapp/presentation/screens/auth/login_screen.dart';
import 'package:tuvalapp/presentation/screens/auth/change_password_screen.dart';
import 'package:tuvalapp/presentation/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final keyValueStorageService = KeyValueStorageService();
  late AuthProvider authProvider;
  runApp(
    MultiProvider(
      providers: [
        Provider<KeyValueStorageService>.value(value: keyValueStorageService),
        Provider<BiometricAuthService>(create: (_) => BiometricAuthService()),
        Provider<Dio>(
          create: (context) => DioClient.create(
            storage: context.read<KeyValueStorageService>(),
            onUnauthorized: (token) => authProvider.expireSession(token),
          ),
          dispose: (_, dio) => dio.close(),
        ),
        Provider<SanctumDatasource>(
          create: (context) => SanctumDatasource(dio: context.read<Dio>()),
        ),
        Provider<PointSalesDatasource>(
          create: (context) => PointSalesDatasource(dio: context.read<Dio>()),
        ),
        Provider<CustomersDatasource>(
          create: (context) => CustomersDatasource(dio: context.read<Dio>()),
        ),
        Provider<DeliveryNotesDatasource>(
          create: (context) =>
              DeliveryNotesDatasource(dio: context.read<Dio>()),
        ),
        Provider<SteamTrapDatasource>(
          create: (context) => SteamTrapDatasource(dio: context.read<Dio>()),
        ),
        Provider<AppVersionDatasource>(
          create: (context) => AppVersionDatasource(dio: context.read<Dio>()),
        ),
        Provider<AppUpdateService>(
          create: (context) => AppUpdateService(
            datasource: context.read<AppVersionDatasource>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PointSalesProvider(
            pointSalesDatasource: context.read<PointSalesDatasource>(),
            keyValueStorageService: context.read<KeyValueStorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => authProvider = AuthProvider(
            keyValueStorageService: context.read<KeyValueStorageService>(),
            sanctumDatasource: context.read<SanctumDatasource>(),
            biometricAuthService: context.read<BiometricAuthService>(),
            onSessionEnded: () =>
                context.read<PointSalesProvider>().clearPointSales(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthProvider>().authStatus;

    return MaterialApp(
      key: ValueKey(authStatus),
      title: 'TUVAL',
      debugShowCheckedModeBanner: false,
      theme: const AppTheme().theme(),
      darkTheme: const AppTheme().theme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: _buildHome(authStatus),
      routes: AppRouter.getRoutes(),
      builder: (context, child) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),

              if (!AppEnvironment.isProduction)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: Colors.redAccent,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          'AMBIENTE ${AppEnvironment.env.toUpperCase()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHome(AuthStatus authStatus) {
    switch (authStatus) {
      case AuthStatus.checking:
        return const CheckAuthScreen();

      case AuthStatus.mustChangePassword:
        return const ChangePasswordScreen();

      case AuthStatus.authenticated:
        return const HomeScreen();

      case AuthStatus.notAuthenticated:
        return const LoginScreen();
    }
  }
}
