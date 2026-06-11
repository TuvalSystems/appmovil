class AppMenu {
  final List<AppMenuItem> items;
  final AppMenuItem? home;

  AppMenu({
    required this.items,
    this.home,
  });

  factory AppMenu.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppMenu(items: []);
    }

    return AppMenu(
      items: (json['items'] as List? ?? [])
          .map((item) => AppMenuItem.fromJson(item))
          .toList(),
      home: json['home'] != null
          ? AppMenuItem.fromJson(json['home'])
          : null,
    );
  }
}

class AppMenuItem {
  final int id;
  final String key;
  final String label;
  final String? icon;
  final String? route;
  final List<AppMenuItem> children;

  AppMenuItem({
    required this.id,
    required this.key,
    required this.label,
    this.icon,
    this.route,
    this.children = const [],
  });

  factory AppMenuItem.fromJson(Map<String, dynamic> json) {
    return AppMenuItem(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'],
      route: json['route'],
      children: (json['children'] as List? ?? [])
          .map((item) => AppMenuItem.fromJson(item))
          .toList(),
    );
  }
}