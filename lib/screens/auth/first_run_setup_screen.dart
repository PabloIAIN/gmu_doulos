import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

class FirstRunSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const FirstRunSetupScreen({super.key, required this.onSetupComplete});

  @override
  State<FirstRunSetupScreen> createState() => _FirstRunSetupScreenState();
}

class _FirstRunSetupScreenState extends State<FirstRunSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _crearCuenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.crearAdminInicial(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        usuario: _usuarioController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta de Director creada exitosamente'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      widget.onSetupComplete();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreenDark,
              AppTheme.primaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Header
                  const Icon(
                    Icons.shield,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configuracion Inicial',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha:0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Step indicator
                          Row(
                            children: [
                              _buildStepDot(0, 'Datos'),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: _currentStep >= 1
                                      ? AppTheme.primaryGreen
                                      : Colors.grey[300],
                                ),
                              ),
                              _buildStepDot(1, 'Cuenta'),
                            ],
                          ),
                          const SizedBox(height: 24),

                          if (_currentStep == 0) ...[
                            Text(
                              'Datos del Director',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa los datos del director del club para crear la cuenta principal.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _nombreController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Ingresa el nombre'
                                      : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _apellidoController,
                              decoration: const InputDecoration(
                                labelText: 'Apellido',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Ingresa el apellido'
                                      : null,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_nombreController.text.trim().isEmpty ||
                                      _apellidoController.text
                                          .trim()
                                          .isEmpty) {
                                    _formKey.currentState!.validate();
                                    return;
                                  }
                                  setState(() => _currentStep = 1);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Siguiente',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          if (_currentStep == 1) ...[
                            Text(
                              'Crear Cuenta',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Define el usuario y contrasena para iniciar sesion.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _usuarioController,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                prefixIcon: Icon(Icons.alternate_email),
                                hintText: 'Ej: director.juan',
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa un nombre de usuario';
                                }
                                if (v.trim().length < 3) {
                                  return 'Minimo 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Contrasena',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Ingresa una contrasena';
                                }
                                if (v.length < 6) {
                                  return 'Minimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contrasena',
                                prefixIcon:
                                    const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _crearCuenta(),
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return 'Las contrasenas no coinciden';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      setState(() => _currentStep = 0),
                                  icon: const Icon(Icons.arrow_back,
                                      size: 20),
                                  label: const Text('Atras'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _crearCuenta,
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'Crear Cuenta',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.white.withValues(alpha:0.8), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Esta cuenta tendra rol de Director',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGreen : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive && _currentStep > step
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppTheme.primaryGreen : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
