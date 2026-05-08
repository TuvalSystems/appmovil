class AppVersionInfo {
  final String platform;
  final String latestVersion;
  final int latestBuild;
  final int minimumRequiredBuild;
  final String apkUrl;
  final String? message;
  final String? releaseNotes;
  final String? checksumSha256;
  final int? apkSizeBytes;

  AppVersionInfo({
    required this.platform,
    required this.latestVersion,
    required this.latestBuild,
    required this.minimumRequiredBuild,
    required this.apkUrl,
    this.message,
    this.releaseNotes,
    this.checksumSha256,
    this.apkSizeBytes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      platform: json['platform']?.toString() ?? 'android',
      latestVersion: json['latest_version']?.toString() ?? '',
      latestBuild: int.tryParse(json['latest_build']?.toString() ?? '0') ?? 0,
      minimumRequiredBuild:
          int.tryParse(json['minimum_required_build']?.toString() ?? '0') ?? 0,
      apkUrl: json['apk_url']?.toString() ?? '',
      message: json['message']?.toString(),
      releaseNotes: json['release_notes']?.toString(),
      checksumSha256: json['checksum_sha256']?.toString(),
      apkSizeBytes: int.tryParse(json['apk_size_bytes']?.toString() ?? ''),
    );
  }
}
