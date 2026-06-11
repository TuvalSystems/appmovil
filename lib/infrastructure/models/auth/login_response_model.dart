import 'package:tuvalapp/domain/entities/user.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';
import 'package:tuvalapp/infrastructure/models/user_model.dart';

class LoginResponseModel {
  final User user;
  final String token;
  final AppMenu appMenu;

  LoginResponseModel({
    required this.user,
    required this.token,
    required this.appMenu,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userModel = UserModel.fromJson(json);

    final data = json['data'];
    final menuJson = data is Map<String, dynamic>
        ? data['menu'] as Map<String, dynamic>?
        : null;

    return LoginResponseModel(
      user: userModel.toEntity(),
      token: userModel.token,
      appMenu: AppMenu.fromJson(menuJson),
    );
  }
}
