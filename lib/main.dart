import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Pantallas
import 'screens/home_screen.dart';
import 'screens/miembros/miembros_screen.dart';
import 'screens/calendario/calendario_screen.dart';
import 'screens/asistencia/asistencia_screen.dart';
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
import 'screens/carpeta/carpeta_manage_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'screens/admin/gestion_cuentas_screen.dart';
import 'screens/perfil/perfil_screen.dart';
import 'screens/estadisticas/estadisticas_screen.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/busqueda/busqueda_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

// Widgets
import 'widgets/user_avatar.dart';

// Servicios
import 'services/notification_service.dart'
    show NotificationService, firebaseMessagingBackgroundHandler;
import 'services/auth_service.dart';
import 'services/database_service.dart';

// Tema
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final saved = await _db.getConfig('dark_mode');
    if (saved == 'true' && mounted) {
      setState(() => _darkMode = true);
    }
  }

  void toggleDarkMode(bool value) {
    setState(() => _darkMode = value);
    _db.setConfig('dark_mode', value.toString());
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
  final DatabaseService _db = DatabaseService();
  bool _isChecking = true;
  bool _isFirstRun = false;
  bool _isLoggedIn = false;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final firstRun = await _auth.isFirstRun();
      if (firstRun) {
        // Check if onboarding was already shown
        final onboardingSeen = await _db.getConfig('onboarding_seen');
        setState(() {
          _showOnboarding = onboardingSeen != 'true';
          _isFirstRun = !_showOnboarding;
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

  void _onOnboardingComplete() {
    _db.setConfig('onboarding_seen', 'true');
    setState(() {
      _showOnboarding = false;
      _isFirstRun = true;
    });
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
      return const _SplashScreen();
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
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
  late final List<Widget> _screens;

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  @override
  void initState() {
    super.initState();
    _screens = _buildScreens();
  }

  // ── Tabs por rol (se crean una sola vez) ──
  List<Widget> _buildScreens() {
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
        ManualScreen(onOpenDrawer: _openDrawer),
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
        ManualScreen(onOpenDrawer: _openDrawer),
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
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Manual',
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
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Manual',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _screens[_currentIndex],
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
          // ── Header con gradiente y decoracion ──
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreenDark,
                  AppTheme.primaryGreen,
                  Color(0xFF43A047),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Circulos decorativos
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Avatar con borde (tappable para ir al perfil)
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2.5),
                          ),
                          child: UserAvatar(
                            fotoUrl: user?.fotoUrl,
                            iniciales: user?.iniciales ?? 'U',
                            radius: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Rol como pill badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rol,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Items del drawer ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ── Comunes: Inicio y Busqueda ──
                _drawerItem(Icons.home_rounded, 'Inicio', () => _goTab(0)),
                _drawerItem(Icons.search_rounded, 'Buscar',
                    () => _pushScreen(const BusquedaScreen())),

                // ── Admin ──
                if (_auth.isAdmin) ...[
                  _drawerItem(Icons.people_rounded, 'Miembros', () => _goTab(1)),
                  _drawerItem(Icons.group_work_rounded, 'Unidades',
                      () => _pushScreen(const UnidadesScreen())),
                  _drawerItem(
                      Icons.calendar_month_rounded, 'Calendario', () => _goTab(2)),
                  _drawerItem(Icons.fact_check_rounded, 'Asistencia',
                      () => _pushScreen(const AsistenciaScreen())),
                  _drawerItem(Icons.folder_copy_rounded, 'Gestionar Carpeta',
                      () => _pushScreen(const CarpetaManageScreen())),
                  _drawerItem(Icons.approval_rounded, 'Aprobar Carpetas',
                      () => _pushScreen(const CarpetaApproveScreen())),
                  _drawerItem(Icons.notifications_rounded, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                  _drawerItem(Icons.bar_chart_rounded, 'Estadisticas',
                      () => _pushScreen(const EstadisticasScreen())),
                  _drawerItem(Icons.picture_as_pdf_rounded, 'Reportes',
                      () => _pushScreen(const ReportesScreen())),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 16),
                  ),
                  _drawerItem(Icons.person_rounded, 'Mi Perfil',
                      () => _pushScreen(const PerfilScreen())),
                  _drawerItem(Icons.manage_accounts_rounded, 'Gestion de Cuentas',
                      () => _pushScreen(const GestionCuentasScreen())),
                  _drawerItem(
                    Icons.settings_rounded,
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
                      Icons.group_rounded, 'Mi Unidad', () => _goTab(1)),
                  _drawerItem(
                      Icons.calendar_month_rounded, 'Calendario', () => _goTab(2)),
                  _drawerItem(Icons.fact_check_rounded, 'Asistencia',
                      () => _pushScreen(const AsistenciaScreen())),
                  _drawerItem(Icons.folder_special_rounded, 'Revisar Carpetas',
                      () => _pushScreen(const CarpetaReviewScreen())),
                  _drawerItem(
                      Icons.menu_book_rounded, 'Manual', () => _goTab(3)),
                  _drawerItem(Icons.notifications_rounded, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                  _drawerItem(Icons.person_rounded, 'Mi Perfil',
                      () => _pushScreen(const PerfilScreen())),
                ],

                // ── Aspirante ──
                if (_auth.isAspirante) ...[
                  _drawerItem(
                      Icons.folder_rounded, 'Mi Carpeta', () => _goTab(1)),
                  _drawerItem(
                      Icons.calendar_month_rounded, 'Calendario', () => _goTab(2)),
                  _drawerItem(
                      Icons.menu_book_rounded, 'Manual', () => _goTab(3)),
                  _drawerItem(Icons.notifications_rounded, 'Notificaciones',
                      () => _pushScreen(const NotificacionesScreen())),
                  _drawerItem(Icons.person_rounded, 'Mi Perfil',
                      () => _pushScreen(const PerfilScreen())),
                ],

                // ── Cerrar sesion ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 16),
                ),
                _drawerItem(Icons.logout_rounded, 'Cerrar Sesion', () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                }, color: AppTheme.errorRed),
              ],
            ),
          ),

          // ── Footer refinado ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_rounded, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  'GMU Doulos v1.1.0',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color ?? Colors.grey[700], size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar Sesion'),
        content: const Text('Seguro que deseas cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesion'),
          ),
        ],
      ),
    );
  }
}

// ── Splash Screen animado ──
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Color(0xFF43A047),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo animado
              FadeTransition(
                opacity: _fadeIn,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Texto animado
              SlideTransition(
                position: _slideUp,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    children: [
                      Text(
                        'GMU Doulos',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"Siervos de Cristo"',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Loading indicator
              FadeTransition(
                opacity: _fadeIn,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
