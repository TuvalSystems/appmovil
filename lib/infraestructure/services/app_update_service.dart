import 'package:package_info_plus/package_info_plus.dart';
import 'package:tuvalapp/domain/entities/app_version_info.dart';
import 'package:tuvalapp/infraestructure/datasources/app_version_datasource.dart';

class AppUpdateResult {
  final bool hasUpdate;
  final bool isRequired;
  final int currentBuild;
  final String currentVersion;
  final AppVersionInfo latest;

  AppUpdateResult({
    required this.hasUpdate,
    required this.isRequired,
    required this.currentBuild,
    required this.currentVersion,
    required this.latest,
  });
}

class AppUpdateService {
  final AppVersionDatasource datasource = AppVersionDatasource();

  Future<AppUpdateResult> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
    final currentVersion = packageInfo.version;

    final latest = await datasource.getLatestVersion(platform: 'android');

    final hasUpdate = currentBuild < latest.latestBuild;
    final isRequired = currentBuild < latest.minimumRequiredBuild;

    return AppUpdateResult(
      hasUpdate: hasUpdate,
      isRequired: isRequired,
      currentBuild: currentBuild,
      currentVersion: currentVersion,
      latest: latest,
    );
  }
}