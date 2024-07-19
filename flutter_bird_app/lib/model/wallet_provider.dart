class WalletProvider {
  final String id;
  final String name;
  final String imageId;
  final ImageUrls imageUrl;
  final String? description;
  final String? homepage;
  final List<String> chains;
  final List<String> versions;
  final List<String> sdks;
  final AppUrls appUrls;
  final MobileInfo mobile;
  final DesktopInfo desktop;

  WalletProvider({
    required this.id,
    required this.name,
    required this.imageId,
    required this.imageUrl,
    this.description,
    this.homepage,
    required this.chains,
    required this.versions,
    required this.sdks,
    required this.appUrls,
    required this.mobile,
    required this.desktop,
  });

  factory WalletProvider.fromJson(Map<String, dynamic> json) {
    return WalletProvider(
      id: json['id'],
      name: json['name'],
      imageId: json['image_id'],
      imageUrl: ImageUrls.fromJson(json['image_url']),
      description: json['description'],
      homepage: json['homepage'],
      chains: List<String>.from(json['chains'] ?? []),
      versions: List<String>.from(json['versions'] ?? []),
      sdks: List<String>.from(json['sdks'] ?? []),
      appUrls: AppUrls.fromJson(json['app'] ?? {}),
      mobile: MobileInfo.fromJson(json['mobile'] ?? {}),
      desktop: DesktopInfo.fromJson(json['desktop'] ?? {}),
    );
  }
}

class MobileInfo {
  final String? native;
  final String? universal;

  MobileInfo({this.native, this.universal});

  factory MobileInfo.fromJson(Map<String, dynamic> json) {
    return MobileInfo(
      native: json['native'],
      universal: json['universal'],
    );
  }
}

class DesktopInfo {
  final String? native;
  final String? universal;

  DesktopInfo({this.native, this.universal});

  factory DesktopInfo.fromJson(Map<String, dynamic> json) {
    return DesktopInfo(
      native: json['native'],
      universal: json['universal'],
    );
  }
}

class ImageUrls {
  final String sm;
  final String md;
  final String lg;

  ImageUrls({required this.sm, required this.md, required this.lg});

  factory ImageUrls.fromJson(Map<String, dynamic> json) {
    return ImageUrls(
      sm: json['sm'] ?? '',
      md: json['md'] ?? '',
      lg: json['lg'] ?? '',
    );
  }
}

class AppUrls {
  final String? browser;
  final String? ios;
  final String? android;
  final String? mac;
  final String? windows;
  final String? linux;

  AppUrls({
    this.browser,
    this.ios,
    this.android,
    this.mac,
    this.windows,
    this.linux,
  });

  factory AppUrls.fromJson(Map<String, dynamic> json) {
    return AppUrls(
      browser: json['browser'],
      ios: json['ios'],
      android: json['android'],
      mac: json['mac'],
      windows: json['windows'],
      linux: json['linux'],
    );
  }
}
