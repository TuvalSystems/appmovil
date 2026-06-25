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
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(keyValueStorageService: keyValueStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PointSalesProvider(
            pointSalesDatasource: PointSalesDatasource(),
            keyValueStorageService: keyValueStorageService,
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
      title: 'TUVAL',
      debugShowCheckedModeBanner: !AppEnvironment.isProduction,
      theme: const AppTheme().theme(),
      home: _buildHome(authStatus),
      routes: AppRouter.getRoutes(),
      builder: (context, child) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: child ?? const SizedBox.shrink(),
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
