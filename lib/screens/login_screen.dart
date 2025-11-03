import 'package:flutter/material.dart';
import 'package:freeradius_app/providers/auth_provider.dart';
import 'package:freeradius_app/theme/app_theme.dart';
import 'package:freeradius_app/widgets/forms/app_input_field.dart';
import 'package:heroicons/heroicons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final success = await AuthController.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
      _error = success ? null : AuthController.state.value.errorMessage;
    });

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme, colors),
                    const SizedBox(height: 18),
                    Text(
                      'Inicia sesión',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    AppInputField(
                      label: 'Usuario',
                      hintText: 'Ingresa tu usuario',
                      controller: _usernameController,
                      prefixIcon: const HeroIcon(HeroIcons.user),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa tu usuario';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AppInputField(
                      label: 'Contraseña',
                      hintText: 'Ingresa tu contraseña',
                      controller: _passwordController,
                      prefixIcon: const HeroIcon(HeroIcons.lockClosed),
                      suffixIcon: IconButton(
                        tooltip: _showPassword
                            ? 'Ocultar contraseña'
                            : 'Mostrar contraseña',
                        icon: HeroIcon(
                          _showPassword
                              ? HeroIcons.eyeSlash
                              : HeroIcons.eye,
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSubmit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _submitting ? null : _handleSubmit,
                        child: _submitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(colors.onPrimary),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Validando...'),
                                ],
                              )
                            : const Text('Iniciar sesión'),
                      ),
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

  Widget _buildHeader(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HeroIcon(
              HeroIcons.wifi,
              size: 36,
              color: colors.onPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'infRadius',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sistema de gestión FreeRADIUS',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

}
