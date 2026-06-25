class AppEnvironment {
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static String get apiBaseUrl {
    switch (env) {
      case 'prod':
        return 'https://api.tuvalsa.com/api';
      case 'qa':
        return 'http://tuvalapi.cosenco.ec/api';
      case 'dev':
      default:
        return 'http://172.16.1.110:8000/api';
    }
  }

  static bool get isProduction => env == 'prod';
  static bool get isDevelopment => env == 'dev';
  static bool get isQa => env == 'qa';

  static bool get enableHttpLogs => !isProduction;
}
