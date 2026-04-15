import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/club.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

class ClubSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;
  const ClubSetupScreen({super.key, required this.onSetupComplete});

  @override
  State<ClubSetupScreen> createState() => _ClubSetupScreenState();
}

class _ClubSetupScreenState extends State<ClubSetupScreen> {
  int _flujo = 0; // 0=Director, 1=Unirse, 2=Necesito código

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryGreenDark, AppTheme.primaryGreen],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Boton regresar (solo si hay algo a donde regresar)
              if (Navigator.of(context).canPop())
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Volver al login',
                  ),
                )
              else
                const SizedBox(height: 16),
              const Icon(Icons.shield, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              const Text(AppConfig.appName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),

              // Selector de flujo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTab(0, 'Soy Director'),
                    const SizedBox(width: 8),
                    _buildTab(1, 'Unirme'),
                    const SizedBox(width: 8),
                    _buildTab(2, 'Info'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _flujo == 0
                        ? _FlujoDirector(onComplete: widget.onSetupComplete)
                        : _flujo == 1
                            ? const _FlujoUnirse()
                            : const _FlujoInfo(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final selected = _flujo == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _flujo = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppTheme.primaryGreen : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  FLUJO A: Director con código de acceso
// ═══════════════════════════════════════════
class _FlujoDirector extends StatefulWidget {
  final VoidCallback onComplete;
  const _FlujoDirector({required this.onComplete});

  @override
  State<_FlujoDirector> createState() => _FlujoDirectorState();
}

class _FlujoDirectorState extends State<_FlujoDirector> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtl = TextEditingController();
  final _nombreCtl = TextEditingController();
  final _apellidoCtl = TextEditingController();
  final _usuarioCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  Map<String, dynamic>? _clubData;
  String? _ministerio;
  bool _isLoading = false;
  bool _obscure = true;
  int _step = 0; // 0=código, 1=ministerio, 2=datos

  Future<void> _verificarCodigo() async {
    final codigo = _codigoCtl.text.trim().toUpperCase();
    if (codigo.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().verificarCodigo(codigo);
      if (data == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código inválido'), backgroundColor: AppTheme.errorRed));
      } else {
        _clubData = data;
        final ministerios = (data['ministerios'] as String? ?? 'gm').split(',').map((e) => e.trim()).toList();
        if (ministerios.length == 1) {
          _ministerio = ministerios.first;
          setState(() => _step = 2);
        } else {
          setState(() => _step = 1);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService().onboarding(
        codigoAcceso: _codigoCtl.text.trim().toUpperCase(),
        ministerio: _ministerio!,
        nombre: _nombreCtl.text.trim(),
        apellido: _apellidoCtl.text.trim(),
        usuario: _usuarioCtl.text.trim(),
        password: _passwordCtl.text,
      );

      final auth = AuthService();
      final clubInfo = result['club'] as Map<String, dynamic>;
      clubInfo['codigo_acceso'] = _codigoCtl.text.trim().toUpperCase();
      final club = Club.fromMap(clubInfo);
      await auth.setClub(club);

      // Crear usuario local
      await auth.crearAdminInicial(
        nombre: _nombreCtl.text.trim(),
        apellido: _apellidoCtl.text.trim(),
        usuario: _usuarioCtl.text.trim(),
        password: _passwordCtl.text,
      );

      if (mounted) widget.onComplete();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Código de Acceso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Ingresa el código que te proporcionó el administrador.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          TextField(
            controller: _codigoCtl,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Código', prefixIcon: Icon(Icons.vpn_key), hintText: 'Ej: DOULOS2026'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _verificarCodigo,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: _isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Verificar Código', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      );
    }

    if (_step == 1) {
      final ministerios = (_clubData!['ministerios'] as String).split(',').map((e) => e.trim()).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Club: ${_clubData!['nombre']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${_clubData!['iglesia']} · ${_clubData!['ciudad']}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          const Text('Selecciona tu ministerio:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...ministerios.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() { _ministerio = m; _step = 2; }),
                icon: Icon(m == 'gm' ? Icons.shield : m == 'conq' ? Icons.explore : Icons.child_care),
                label: Text(AppConfig.ministeriosNombres[m] ?? m),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          )),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: () => setState(() => _step = 0), icon: const Icon(Icons.arrow_back), label: const Text('Atrás')),
        ],
      );
    }

    // Step 2: Datos personales
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Club: ${_clubData!['nombre']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Ministerio: ${AppConfig.ministeriosNombres[_ministerio] ?? _ministerio}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 20),
          TextFormField(controller: _nombreCtl, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _apellidoCtl, decoration: const InputDecoration(labelText: 'Apellido', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _usuarioCtl, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.alternate_email)), validator: (v) => v != null && v.trim().length >= 3 ? null : 'Mínimo 3 caracteres'),
          const SizedBox(height: 12),
          TextFormField(controller: _passwordCtl, decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))), obscureText: _obscure, validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres'),
          const SizedBox(height: 12),
          TextFormField(controller: _confirmCtl, decoration: const InputDecoration(labelText: 'Confirmar contraseña', prefixIcon: Icon(Icons.lock_outline)), obscureText: true, validator: (v) => v == _passwordCtl.text ? null : 'No coinciden'),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton.icon(onPressed: () => setState(() => _step = _step > 1 ? 1 : 0), icon: const Icon(Icons.arrow_back), label: const Text('Atrás')),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: _isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Crear Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codigoCtl.dispose(); _nombreCtl.dispose(); _apellidoCtl.dispose();
    _usuarioCtl.dispose(); _passwordCtl.dispose(); _confirmCtl.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════
//  FLUJO B: Unirse a un club existente
// ═══════════════════════════════════════════
class _FlujoUnirse extends StatefulWidget {
  const _FlujoUnirse();

  @override
  State<_FlujoUnirse> createState() => _FlujoUnirseState();
}

class _FlujoUnirseState extends State<_FlujoUnirse> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtl = TextEditingController();
  final _nombreCtl = TextEditingController();
  final _apellidoCtl = TextEditingController();
  final _usuarioCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  Map<String, dynamic>? _clubData;
  String? _ministerio;
  String _rolSolicitado = 'miembro';
  String? _claseMinisterio;
  bool _isLoading = false;
  bool _enviado = false;
  int _step = 0;

  Future<void> _verificar() async {
    if (_codigoCtl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService().verificarCodigo(_codigoCtl.text.trim().toUpperCase());
      if (data == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código no encontrado'), backgroundColor: AppTheme.errorRed));
      } else {
        _clubData = data;
        final mins = (data['ministerios'] as String).split(',').map((e) => e.trim()).toList();
        if (mins.length == 1) _ministerio = mins.first;
        setState(() => _step = 1);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate() || _ministerio == null) return;
    setState(() => _isLoading = true);
    try {
      await ApiService().unirse(
        clubId: _clubData!['id'] as String,
        ministerio: _ministerio!,
        nombre: _nombreCtl.text.trim(),
        apellido: _apellidoCtl.text.trim(),
        usuario: _usuarioCtl.text.trim(),
        password: _passwordCtl.text,
        rolSolicitado: _rolSolicitado,
        claseMinisterio: _claseMinisterio,
      );
      setState(() => _enviado = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_enviado) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.hourglass_top, size: 64, color: AppTheme.warningOrange.withValues(alpha: 0.7)),
          const SizedBox(height: 20),
          const Text('Solicitud Enviada', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('El Director de tu club debe aprobar tu solicitud.\nUna vez aprobado, podrás iniciar sesión.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        ],
      );
    }

    if (_step == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unirse a un Club', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Ingresa el código de tu club para solicitar unirte.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 20),
          TextField(controller: _codigoCtl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Código del club', prefixIcon: Icon(Icons.vpn_key))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _verificar,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: _isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Buscar Club'),
            ),
          ),
        ],
      );
    }

    // Step 1: Formulario completo
    final ministerios = (_clubData!['ministerios'] as String).split(',').map((e) => e.trim()).toList();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Club: ${_clubData!['nombre']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (ministerios.length > 1) ...[
            DropdownButtonFormField<String>(
              value: _ministerio,
              decoration: const InputDecoration(labelText: 'Ministerio'),
              items: ministerios.map((m) => DropdownMenuItem(value: m, child: Text(AppConfig.ministeriosNombres[m] ?? m))).toList(),
              onChanged: (v) => setState(() { _ministerio = v; _claseMinisterio = null; }),
              validator: (v) => v == null ? 'Selecciona ministerio' : null,
            ),
            const SizedBox(height: 12),
          ],
          DropdownButtonFormField<String>(
            value: _rolSolicitado,
            decoration: const InputDecoration(labelText: 'Quiero unirme como'),
            items: const [
              DropdownMenuItem(value: 'miembro', child: Text('Miembro')),
              DropdownMenuItem(value: 'consejero', child: Text('Consejero')),
            ],
            onChanged: (v) => setState(() => _rolSolicitado = v ?? 'miembro'),
          ),
          const SizedBox(height: 12),
          if (_ministerio == 'conq') ...[
            DropdownButtonFormField<String>(
              value: _claseMinisterio,
              decoration: const InputDecoration(labelText: 'Clase actual'),
              items: [...AppConfig.clasesConquistadores['regulares']!, ...AppConfig.clasesConquistadores['avanzadas']!].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _claseMinisterio = v),
            ),
            const SizedBox(height: 12),
          ],
          if (_ministerio == 'av') ...[
            DropdownButtonFormField<String>(
              value: _claseMinisterio,
              decoration: const InputDecoration(labelText: 'Clase actual'),
              items: AppConfig.clasesAventureros.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _claseMinisterio = v),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(controller: _nombreCtl, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _apellidoCtl, decoration: const InputDecoration(labelText: 'Apellido', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words, validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _usuarioCtl, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.alternate_email)), validator: (v) => v != null && v.trim().length >= 3 ? null : 'Mínimo 3 caracteres'),
          const SizedBox(height: 12),
          TextFormField(controller: _passwordCtl, decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)), obscureText: true, validator: (v) => v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres'),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton.icon(onPressed: () => setState(() => _step = 0), icon: const Icon(Icons.arrow_back), label: const Text('Atrás')),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _enviarSolicitud,
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    child: _isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Enviar Solicitud'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codigoCtl.dispose(); _nombreCtl.dispose(); _apellidoCtl.dispose();
    _usuarioCtl.dispose(); _passwordCtl.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════
//  FLUJO C: Necesito código
// ═══════════════════════════════════════════
class _FlujoInfo extends StatelessWidget {
  const _FlujoInfo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Necesitas un código?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'Para usar GMU Doulos necesitas un código de acceso de tu club.\n\n'
          'Si tu club ya usa la app, pide el código a tu Director.\n\n'
          'Si tu club aún no está registrado, el Director del ministerio juvenil de tu iglesia debe solicitar un código.',
          style: TextStyle(color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoBlue.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.info_outline, color: AppTheme.infoBlue, size: 18),
                const SizedBox(width: 8),
                Text('Pasos', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.infoBlue)),
              ]),
              const SizedBox(height: 8),
              Text('1. Tu Director solicita el código\n2. El Director se registra primero\n3. Te comparte el código del club\n4. Tú te unes desde "Unirme"', style: TextStyle(color: Colors.grey[700], height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }
}
