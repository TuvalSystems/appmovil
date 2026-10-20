import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/environment/app_environment.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tuvalapp/presentation/shared/widgets/app_action_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/tuval-logo.jpg',
                    width: 260,
                    height: 160,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 12),

                  _LoginForm(),

                  SizedBox(height: 32),

                  _AppVersionLabel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      userController.text.trim(),
      passwordController.text.trim(),
    );

    if (!success && mounted) {
      final errorMsg = authProvider.errorMessage ?? 'Error al iniciar sesión.';
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(errorMsg)),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPosting = context.select<AuthProvider, bool>(
      (provider) => provider.isPosting,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Ingreso',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.appColors.text,
                  ),
                ),
              ),

              SizedBox(height: 6),

              Center(
                child: Text(
                  'Accede con tus credenciales TUVAL',
                  style: TextStyle(
                    color: context.appColors.muted,
                    fontSize: 13,
                  ),
                ),
              ),

              SizedBox(height: 24),

              TextFormField(
                controller: userController,
                enabled: !isPosting,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                autofillHints: [AutofillHints.username],
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ingrese su usuario',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';

                  if (text.isEmpty) {
                    return 'Ingrese su usuario';
                  }

                  return null;
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                enabled: !isPosting,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: [AutofillHints.password],
                onFieldSubmitted: (_) {
                  if (!isPosting) _submit();
                },
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: isPosting
                        ? null
                        : () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  final text = value ?? '';

                  if (text.isEmpty) {
                    return 'Ingrese su contraseña';
                  }

                  return null;
                },
              ),

              SizedBox(height: 26),
              AppActionButton(
                label: 'Ingresar',
                loadingLabel: 'Validando',
                isLoading: isPosting,
                isDisabled: isPosting,
                variant: AppActionButtonType.primary,
                onPressed: isPosting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppVersionLabel extends StatefulWidget {
  const _AppVersionLabel();

  @override
  State<_AppVersionLabel> createState() => _AppVersionLabelState();
}

class _AppVersionLabelState extends State<_AppVersionLabel> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final packageInfo = snapshot.data;
        final envText = AppEnvironment.env.toUpperCase();
        final versionText = packageInfo == null
            ? 'Tuval App - $envText'
            : 'v${packageInfo.version}+${packageInfo.buildNumber} - Tuval App - $envText';

        return Text(
          versionText,
          style: TextStyle(color: context.appColors.muted, fontSize: 12),
        );
      },
    );
  }
}
