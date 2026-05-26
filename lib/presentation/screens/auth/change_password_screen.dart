import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _newPasswordController = TextEditingController();

  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.changePassword(
      password: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'No se pudo actualizar la contraseña',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      size: 72,
                      color: Color(0xFFEA580C),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Actualizar contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Por seguridad debes actualizar tus credenciales antes de continuar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La nueva contraseña es obligatoria';
                        }

                        if (value.trim().length < 8) {
                            return 'La contraseña debe tener al menos 8 caracteres';
                        }

                        

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: authProvider.isPosting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: authProvider.isPosting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Actualizar contraseña',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),

                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: authProvider.isPosting
                          ? null
                          : () => authProvider.logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
