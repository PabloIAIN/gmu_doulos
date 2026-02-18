import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pantallas
import 'screens/home_screen.dart';
import 'screens/miembros/miembros_screen.dart';
import 'screens/especialidades/especialidades_screen.dart';
import 'screens/calendario/calendario_screen.dart';
import 'screens/mapas/mapas_screen.dart';
import 'screens/evidencias/evidencias_screen.dart';
import 'screens/asistencia/asistencia_screen.dart';
import 'screens/herramientas/herramientas_screen.dart';
import 'screens/manual/manual_screen.dart';
import 'screens/ajustes/ajustes_screen.dart';
import 'screens/notificaciones/notificaciones_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/first_run_setup_screen.dart';
import 'screens/unidades/unidades_screen.dart';
import 'screens/unidades/consejero_unidad_screen.dart';
import 'screens/carpeta/carpeta_screen.dart';
import 'screens/carpeta/carpeta_review_screen.dart';
import 'screens/carpeta/carpeta_approve_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/gestion_cuentas_screen.dart';

// Servicios
import 'services/notification_service.dart';
import 'services/auth_service.dart';

// Tema
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService().init();
  runApp(const GMUDoulosApp());
}

class GMUDoulosApp extends StatefulWidget {
  const GMUDoulosApp({super.key});

  @override
  State<GMUDoulosApp> createState() => _GMUDoulosAppState();
}

class _GMUDoulosAppState extends State<GMUDoulosApp> {
  bool _darkMode = false;

  void toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMU Doulos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthGate(
        darkMode: _darkMode,
        onDarkModeChanged: toggleDarkMode,
      ),
    );
  }
}

// ── Auth Gate ──
class AuthGate extends StatefulWidget {
  final bool darkMode;
  final Function(bool) onDarkModeChanged;

  const AuthGate({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _auth = AuthService();
  bool _isChecking = true;
  bool _isFirstRun = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final firstRun = await _auth.isFirstRun();
      if (firstRun) {
        setState(() {
          _isFirstRun = true;
          _isChecking = false;
        });
        return;
      }
      final restored = await _auth.tryRestoreSession();
      setState(() {
        _isLoggedIn = restored;
        _isChecking = false;
      });
    } catch (e) {
      setState(() => _isChecking = false);
    }
  }

  void _onSetupComplete() {
    setState(() {
      _isFirstRun = false;
      _isLoggedIn = true;
    });
  }

  void _onLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _onLogout() async {
    await _auth.logout();
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, size: 64, color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text('GMU Doulos',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen)),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (_isFirstRun) {
      return FirstRunSetupScreen(onSetupComplete: _onSetupComplete);
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    return MainNavigation(
      darkMode: widget.darkMode,
      onDarkModeChanged: widget.onDarkModeChanged,
      onLogout: _onLogout,
    );
  }
}

// ── Navegacion principal con roles ──
class MainNavigation extends StatefulWidget {
  final bool darkMode;
  final Function(bool) onDarkModeChanged;
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
    required this.onLogout,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final AuthService _auth = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  // ── Tabs por rol ──
  List<Widget> _getScreens() {
    if (_auth.isAdmin) {
      return [
        HomeScreen(
          onNavigateToTab: (i) => setState(() => _currentIndex = i),
          onOpenDrawer: _openDrawer,
        ),
        MiembrosScreen(onOpenDrawer: _openDrawer),
        CalendarioScreen(onOpenDrawer: _openDrawer),
        AdminPanelScreen(onOpenDrawer: _openDrawer),
      ];
    } else if (_auth.isConsejero) {
      return [
        HomeScreen(
          onNavigateToTab: (i) => setState(() => _currentIndex = i),
          onOpenDrawer: _openDrawer,
        ),
        ConsejeroUnidadScreen(onOpenDrawer: _openDrawer),
        CalendarioScreen(onOpenDrawer: _openDrawer),
        HerramientasScreen(onOpenDrawer: _openDrawer),
      ];
    } else {
      // Aspirante
      return [
        HomeScreen(
          onNavigateToTab: (i) => setState(() => _currentIndex = i),
          onOpenDrawer: _openDrawer,
        ),
        CarpetaScreen(onOpenDrawer: _openDrawer),
        CalendarioScreen(onOpenDrawer: _openDrawer),
        HerramientasScreen(onOpenDrawer: _openDrawer),
      ];
    }
  }

  List<NavigationDestination> _getDestinations() {
    if (_auth.isAdmin) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Miembros',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendario',
        ),
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      ];
    } else if (_auth.isConsejero) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: 'Mi Unidad',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendario',
        ),
        NavigationDestination(
          icon: Icon(Icons.handyman_outlined),
          selectedIcon: Icon(Icons.handyman),
          label: 'Herramientas',
        ),
      ];
    } else {
      return const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Mi Carpeta',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendario',
        ),
        NavigationDestination(
          icon: Icon(Icons.handyman_outlined),
          selectedIcon: Icon(Icons.handyman),
          label: 'Herramientas',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();

    return Scaffold(
      key: _scaffoldKey,
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _getDestinations(),
      ),
      drawer: _buildDrawer(context),
    );
  }

  // ── Drawer por rol ──
  Widget _buildDrawer(BuildContext context) {
    final user = _auth.currentUser;
    final nombre = user?.nombreCompleto ?? 'Usuario';
    final rol = user?.rol ?? '';

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.iniciales ?? 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(rol,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Comunes: Inicio ──
                _drawerItem(Icons.home, 'Inicio', () => _goTab(0)),

                // ── Admin ──
                if (_auth.isAdmin) ...[
                  _drawerItem(Icons.people, 'Miembros', () => _goTab(1)),
                  _drawerItem(Icons.group_work, 'Unidades',
                      () => _pushScreen(const UnidadesScreen())),
                  _drawerItem(
                      Icons.calendar_month, 'Calendario', () => _goTab(2)),
                  _drawerItem(Icons.fact_check, 'Asistencia',
                      () => _pushScreen(const AsistenciaScreen())),
                  _drawerItem(Icons.emoji_events, 'Especialidades',
                      () => _pushScreen(const EspecialidadesScreen())),
                  _drawerItem(Icons.approval, 'Aprobar Carpetas',
                      () => _pushScreen(const CarpetaApproveScreen())),
                  _drawerItem(Icons.photo_library, 'Evidencias',
                      () => _pushScreen(const EvidenciasScreen())),
                  _drawerItem(Icons.notifications, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                  const Divider(),
                  _drawerItem(Icons.manage_accounts, 'Gestion de Cuentas',
                      () => _pushScreen(const GestionCuentasScreen())),
                  _drawerItem(
                    Icons.settings,
                    'Ajustes',
                    () => _pushScreen(AjustesScreen(
                      darkMode: widget.darkMode,
                      onDarkModeChanged: widget.onDarkModeChanged,
                    )),
                  ),
                ],

                // ── Consejero ──
                if (_auth.isConsejero) ...[
                  _drawerItem(
                      Icons.group, 'Mi Unidad', () => _goTab(1)),
                  _drawerItem(
                      Icons.calendar_month, 'Calendario', () => _goTab(2)),
                  _drawerItem(Icons.fact_check, 'Asistencia',
                      () => _pushScreen(const AsistenciaScreen())),
                  _drawerItem(Icons.folder_special, 'Revisar Carpetas',
                      () => _pushScreen(const CarpetaReviewScreen())),
                  _drawerItem(Icons.emoji_events, 'Especialidades',
                      () => _pushScreen(const EspecialidadesScreen())),
                  _drawerItem(Icons.photo_library, 'Evidencias',
                      () => _pushScreen(const EvidenciasScreen())),
                  _drawerItem(Icons.menu_book, 'Manual',
                      () => _pushScreen(const ManualScreen())),
                  _drawerItem(
                      Icons.handyman, 'Herramientas', () => _goTab(3)),
                  _drawerItem(Icons.notifications, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                ],

                // ── Aspirante ──
                if (_auth.isAspirante) ...[
                  _drawerItem(
                      Icons.folder, 'Mi Carpeta', () => _goTab(1)),
                  _drawerItem(
                      Icons.calendar_month, 'Calendario', () => _goTab(2)),
                  _drawerItem(Icons.emoji_events, 'Especialidades',
                      () => _pushScreen(const EspecialidadesScreen())),
                  _drawerItem(Icons.photo_library, 'Evidencias',
                      () => _pushScreen(const EvidenciasScreen())),
                  _drawerItem(Icons.menu_book, 'Manual',
                      () => _pushScreen(const ManualScreen())),
                  _drawerItem(
                      Icons.handyman, 'Herramientas', () => _goTab(3)),
                  _drawerItem(Icons.map, 'Mapas',
                      () => _pushScreen(const MapasScreen())),
                  _drawerItem(Icons.notifications, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                ],

                // ── Cerrar sesion ──
                const Divider(),
                _drawerItem(Icons.logout, 'Cerrar Sesion', () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                }, color: Colors.red),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'GMU Doulos v1.0.0\n© 2025 Pablo',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title:
          Text(title, style: color != null ? TextStyle(color: color) : null),
      onTap: onTap,
    );
  }

  void _goTab(int index) {
    Navigator.pop(context);
    setState(() => _currentIndex = index);
  }

  void _pushScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesion'),
        content: const Text('Seguro que deseas cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesion'),
          ),
        ],
      ),
    );
  }
}
