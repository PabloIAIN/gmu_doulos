import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HerramientasScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const HerramientasScreen({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final herramientas = [
      {
        'nombre': 'Brújula',
        'icon': Icons.explore,
        'color': Colors.blue,
        'descripcion': 'Brújula digital con sensor magnético',
      },
      {
        'nombre': 'Linterna',
        'icon': Icons.flashlight_on,
        'color': Colors.amber,
        'descripcion': 'Usa el flash como linterna',
      },
      {
        'nombre': 'Silbato',
        'icon': Icons.volume_up,
        'color': Colors.red,
        'descripcion': 'Silbato de emergencia',
      },
      {
        'nombre': 'Nivel',
        'icon': Icons.straighten,
        'color': Colors.green,
        'descripcion': 'Nivel con acelerómetro',
      },
      {
        'nombre': 'Cronómetro',
        'icon': Icons.timer,
        'color': Colors.purple,
        'descripcion': 'Cronómetro para actividades',
      },
      {
        'nombre': 'Conversor',
        'icon': Icons.swap_horiz,
        'color': Colors.teal,
        'descripcion': 'Conversor de unidades',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: onOpenDrawer)
            : null,
        title: const Text('Herramientas'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: herramientas.length,
        itemBuilder: (context, index) {
          final h = herramientas[index];
          return _buildHerramientaCard(context, h);
        },
      ),
    );
  }

  Widget _buildHerramientaCard(BuildContext context, Map<String, dynamic> h) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openHerramienta(context, h['nombre']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (h['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  h['icon'] as IconData,
                  size: 40,
                  color: h['color'] as Color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                h['nombre'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                h['descripcion'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openHerramienta(BuildContext context, String nombre) {
    Widget screen;
    switch (nombre) {
      case 'Brújula':
        screen = const BrujulaScreen();
        break;
      case 'Linterna':
        screen = const LinternaScreen();
        break;
      case 'Silbato':
        screen = const SilbatoScreen();
        break;
      case 'Nivel':
        screen = const NivelScreen();
        break;
      case 'Cronómetro':
        screen = const CronometroScreen();
        break;
      case 'Conversor':
        screen = const ConversorScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// ==================== BRÚJULA ====================
class BrujulaScreen extends StatefulWidget {
  const BrujulaScreen({super.key});

  @override
  State<BrujulaScreen> createState() => _BrujulaScreenState();
}

class _BrujulaScreenState extends State<BrujulaScreen> {
  double _heading = 0;

  // En producción, esto usaría el paquete flutter_compass
  // Por ahora es una demostración visual

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brújula'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_heading.toStringAsFixed(0)}°',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getDirection(_heading),
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _heading = (_heading + details.delta.dx) % 360;
                  if (_heading < 0) _heading += 360;
                });
              },
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Marcas de dirección
                    ..._buildDirectionMarks(),
                    // Aguja
                    Transform.rotate(
                      angle: -_heading * (math.pi / 180),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Desliza para simular\n(En dispositivo real usa el sensor)',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDirectionMarks() {
    final directions = ['N', 'E', 'S', 'O'];
    return List.generate(4, (index) {
      return Transform.rotate(
        angle: index * (math.pi / 2),
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              directions[index],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: index == 0 ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
        ),
      );
    });
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'Norte';
    if (heading >= 22.5 && heading < 67.5) return 'Noreste';
    if (heading >= 67.5 && heading < 112.5) return 'Este';
    if (heading >= 112.5 && heading < 157.5) return 'Sureste';
    if (heading >= 157.5 && heading < 202.5) return 'Sur';
    if (heading >= 202.5 && heading < 247.5) return 'Suroeste';
    if (heading >= 247.5 && heading < 292.5) return 'Oeste';
    return 'Noroeste';
  }
}

// ==================== LINTERNA ====================
class LinternaScreen extends StatefulWidget {
  const LinternaScreen({super.key});

  @override
  State<LinternaScreen> createState() => _LinternaScreenState();
}

class _LinternaScreenState extends State<LinternaScreen> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isOn ? Colors.white : Colors.black,
      appBar: AppBar(
        title: const Text('Linterna'),
        backgroundColor: _isOn ? Colors.white : Colors.grey[900],
        foregroundColor: _isOn ? Colors.black : Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isOn = !_isOn;
                });
                // En producción: TorchLight.enableTorch(_isOn);
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOn
                      ? Colors.amber
                      : Colors.grey[800],
                  boxShadow: _isOn
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _isOn ? Icons.flashlight_on : Icons.flashlight_off,
                  size: 60,
                  color: _isOn ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isOn ? 'ENCENDIDA' : 'APAGADA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isOn ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Toca para ${_isOn ? 'apagar' : 'encender'}',
              style: TextStyle(
                color: _isOn ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CRONÓMETRO ====================
class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<String> _laps = [];

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void _startStop() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
        _updateTime();
      }
    });
  }

  void _reset() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
    });
  }

  void _lap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _formatTime(_stopwatch.elapsedMilliseconds));
      });
    }
  }

  void _updateTime() {
    if (_stopwatch.isRunning) {
      Future.delayed(const Duration(milliseconds: 30), () {
        if (mounted && _stopwatch.isRunning) {
          setState(() {});
          _updateTime();
        }
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate();

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${hundreds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronómetro'),
      ),
      body: Column(
        children: [
          const Spacer(),
          // Display
          Text(
            _formatTime(_stopwatch.elapsedMilliseconds),
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.w300,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          // Botones
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset / Lap
                FloatingActionButton(
                  heroTag: 'lap',
                  onPressed: _stopwatch.isRunning ? _lap : _reset,
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  child: Icon(
                    _stopwatch.isRunning ? Icons.flag : Icons.refresh,
                  ),
                ),
                // Start / Stop
                FloatingActionButton.large(
                  heroTag: 'start',
                  onPressed: _startStop,
                  backgroundColor: _stopwatch.isRunning
                      ? Colors.red
                      : Colors.green,
                  child: Icon(
                    _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                ),
                // Placeholder para simetría
                const SizedBox(width: 56),
              ],
            ),
          ),
          // Laps
          if (_laps.isNotEmpty)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _laps.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text('${_laps.length - index}'),
                      ),
                      title: Text(
                        _laps[index],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

// ==================== SILBATO ====================
class SilbatoScreen extends StatefulWidget {
  const SilbatoScreen({super.key});

  @override
  State<SilbatoScreen> createState() => _SilbatoScreenState();
}

class _SilbatoScreenState extends State<SilbatoScreen>
    with SingleTickerProviderStateMixin {
  bool _activo = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _activarSilbato() {
    setState(() => _activo = true);
    _animController.forward();
    HapticFeedback.vibrate();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _activo = false);
        _animController.reverse();
      }
    });
  }

  void _sos() async {
    // Patrón SOS: 3 cortos, 3 largos, 3 cortos
    final pattern = [
      200, 100, 200, 100, 200, 300, // 3 cortos
      400, 100, 400, 100, 400, 300, // 3 largos
      200, 100, 200, 100, 200, 0, // 3 cortos
    ];

    for (int i = 0; i < pattern.length; i += 2) {
      if (!mounted) return;
      setState(() => _activo = true);
      HapticFeedback.vibrate();
      await Future.delayed(Duration(milliseconds: pattern[i]));
      if (!mounted) return;
      setState(() => _activo = false);
      if (i + 1 < pattern.length && pattern[i + 1] > 0) {
        await Future.delayed(Duration(milliseconds: pattern[i + 1]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Silbato')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _activo ? 'PIIIIP!' : 'Silbato de Emergencia',
              style: TextStyle(
                fontSize: _activo ? 32 : 20,
                fontWeight: FontWeight.bold,
                color: _activo ? Colors.red : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTapDown: (_) => _activarSilbato(),
              onLongPress: _activarSilbato,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _activo ? Colors.red : Colors.red[100],
                    boxShadow: _activo
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.volume_up,
                    size: 80,
                    color: _activo ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Presiona para activar',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _sos,
              icon: const Icon(Icons.sos, color: Colors.red),
              label: const Text('Señal SOS',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '3 cortos - 3 largos - 3 cortos',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== NIVEL ====================
class NivelScreen extends StatefulWidget {
  const NivelScreen({super.key});

  @override
  State<NivelScreen> createState() => _NivelScreenState();
}

class _NivelScreenState extends State<NivelScreen> {
  double _xAngle = 0;
  double _yAngle = 0;

  // En producción usaría sensors_plus para el acelerómetro real
  // Por ahora es interactivo con gestos

  bool get _isLevel =>
      _xAngle.abs() < 2 && _yAngle.abs() < 2;

  @override
  Widget build(BuildContext context) {
    final bubbleX = (_xAngle / 45).clamp(-1.0, 1.0);
    final bubbleY = (_yAngle / 45).clamp(-1.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Nivel')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xAngle = (_xAngle + details.delta.dx * 0.5).clamp(-45.0, 45.0);
            _yAngle = (_yAngle + details.delta.dy * 0.5).clamp(-45.0, 45.0);
          });
        },
        onDoubleTap: () {
          setState(() {
            _xAngle = 0;
            _yAngle = 0;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ángulos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAngleDisplay('X', _xAngle),
                    const SizedBox(width: 32),
                    _buildAngleDisplay('Y', _yAngle),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isLevel ? 'NIVELADO' : 'DESNIVELADO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isLevel ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 40),
                // Nivel circular (burbuja)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: _isLevel ? Colors.green : Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cruz central
                      Container(width: 1, height: 250, color: Colors.grey[400]),
                      Container(width: 250, height: 1, color: Colors.grey[400]),
                      // Círculos guía
                      ...List.generate(3, (i) => Container(
                        width: 60.0 + (i * 60),
                        height: 60.0 + (i * 60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      )),
                      // Burbuja
                      Transform.translate(
                        offset: Offset(bubbleX * 100, bubbleY * 100),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isLevel
                                ? Colors.green.withOpacity(0.7)
                                : Colors.red.withOpacity(0.7),
                            border: Border.all(
                              color: _isLevel ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Nivel horizontal (barra)
                Container(
                  width: 280,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(width: 2, height: 40, color: Colors.grey[400]),
                      Transform.translate(
                        offset: Offset(bubbleX * 120, 0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _xAngle.abs() < 2
                                ? Colors.green.withOpacity(0.7)
                                : Colors.orange.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Desliza para simular inclinación\nDoble toque para centrar',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAngleDisplay(String axis, double angle) {
    return Column(
      children: [
        Text(axis, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          '${angle.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

// ==================== CONVERSOR ====================
class ConversorScreen extends StatefulWidget {
  const ConversorScreen({super.key});

  @override
  State<ConversorScreen> createState() => _ConversorScreenState();
}

class _ConversorScreenState extends State<ConversorScreen> {
  final _inputController = TextEditingController(text: '1');
  String _categoriaActual = 'Longitud';
  String _unidadOrigen = 'Metros';
  String _unidadDestino = 'Kilómetros';

  final Map<String, Map<String, double>> _conversiones = {
    'Longitud': {
      'Metros': 1,
      'Kilómetros': 0.001,
      'Centímetros': 100,
      'Milímetros': 1000,
      'Pulgadas': 39.3701,
      'Pies': 3.28084,
      'Yardas': 1.09361,
      'Millas': 0.000621371,
    },
    'Peso': {
      'Kilogramos': 1,
      'Gramos': 1000,
      'Libras': 2.20462,
      'Onzas': 35.274,
      'Toneladas': 0.001,
    },
    'Temperatura': {
      'Celsius': 1,
      'Fahrenheit': 1,
      'Kelvin': 1,
    },
    'Volumen': {
      'Litros': 1,
      'Mililitros': 1000,
      'Galones': 0.264172,
      'Tazas': 4.22675,
      'Onzas líq.': 33.814,
    },
  };

  double _convertir() {
    final input = double.tryParse(_inputController.text) ?? 0;

    if (_categoriaActual == 'Temperatura') {
      return _convertirTemperatura(input, _unidadOrigen, _unidadDestino);
    }

    final factores = _conversiones[_categoriaActual]!;
    final factorOrigen = factores[_unidadOrigen]!;
    final factorDestino = factores[_unidadDestino]!;

    // Convertir a unidad base y luego a destino
    final enBase = input / factorOrigen;
    return enBase * factorDestino;
  }

  double _convertirTemperatura(double valor, String origen, String destino) {
    // Primero convertir a Celsius
    double celsius;
    switch (origen) {
      case 'Fahrenheit':
        celsius = (valor - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = valor - 273.15;
        break;
      default:
        celsius = valor;
    }

    // Luego convertir de Celsius al destino
    switch (destino) {
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  void _cambiarCategoria(String categoria) {
    final unidades = _conversiones[categoria]!.keys.toList();
    setState(() {
      _categoriaActual = categoria;
      _unidadOrigen = unidades[0];
      _unidadDestino = unidades.length > 1 ? unidades[1] : unidades[0];
    });
  }

  void _intercambiar() {
    setState(() {
      final temp = _unidadOrigen;
      _unidadOrigen = _unidadDestino;
      _unidadDestino = temp;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unidades = _conversiones[_categoriaActual]!.keys.toList();
    final resultado = _convertir();
    final resultadoStr = resultado == resultado.roundToDouble()
        ? resultado.toStringAsFixed(0)
        : resultado.toStringAsFixed(4);

    return Scaffold(
      appBar: AppBar(title: const Text('Conversor de Unidades')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Categorías
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _conversiones.keys.map((cat) {
                  final isSelected = _categoriaActual == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => _cambiarCategoria(cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('De:', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _unidadOrigen,
                          items: unidades
                              .map((u) => DropdownMenuItem(
                                  value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _unidadOrigen = v!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Botón intercambiar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton.filled(
                onPressed: _intercambiar,
                icon: const Icon(Icons.swap_vert),
              ),
            ),

            // Resultado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A:', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resultadoStr,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _unidadDestino,
                          items: unidades
                              .map((u) => DropdownMenuItem(
                                  value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _unidadDestino = v!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabla rápida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tabla rápida',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    ...unidades
                        .where((u) => u != _unidadOrigen)
                        .map((u) {
                      final oldDestino = _unidadDestino;
                      _unidadDestino = u;
                      final val = _convertir();
                      _unidadDestino = oldDestino;
                      final valStr = val == val.roundToDouble()
                          ? val.toStringAsFixed(0)
                          : val.toStringAsFixed(4);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(u),
                            Text(valStr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
