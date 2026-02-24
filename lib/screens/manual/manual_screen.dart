import 'package:flutter/material.dart';

// ─── Modelo de contenido ───
class _Tema {
  final String titulo;
  final String seccion;
  final String contenido;
  final List<String>? pasos;
  final String? consejo;

  const _Tema({
    required this.titulo,
    required this.seccion,
    required this.contenido,
    this.pasos,
    this.consejo,
  });
}

// ─── Datos del Manual ───
const _secciones = <Map<String, dynamic>>[
  {
    'titulo': 'Ley y Voto',
    'icon': 'gavel',
    'color': 'purple',
  },
  {
    'titulo': 'Uniforme Correcto',
    'icon': 'checkroom',
    'color': 'blue',
  },
  {
    'titulo': 'Honores a la Bandera',
    'icon': 'flag',
    'color': 'red',
  },
];

final List<_Tema> _todosLosTemas = [
  // ── Ley y Voto ──
  const _Tema(
    titulo: 'Voto del Guia Mayor',
    seccion: 'Ley y Voto',
    contenido:
        '"Por la gracia de Dios, sere puro, bondadoso y leal. Guardare la Ley del Guia Mayor. '
        'Sere siervo de Dios y amigo de la humanidad."\n\n'
        'El Voto es una promesa personal ante Dios y la comunidad. Refleja el compromiso '
        'del Guia Mayor de vivir segun principios cristianos y de servicio. Se recita '
        'al inicio de cada reunion y en ceremonias especiales.',
    consejo:
        'Memoriza el Voto y reflexiona sobre su significado regularmente. Cada frase representa un area de tu vida.',
  ),
  const _Tema(
    titulo: 'Ley del Guia Mayor',
    seccion: 'Ley y Voto',
    contenido:
        'La Ley del Guia Mayor establece los principios de conducta:\n\n'
        '1. Observar la devocion matutina\n'
        '2. Cumplir fielmente con la parte que me toca\n'
        '3. Cuidar mi cuerpo\n'
        '4. Mantener una conciencia limpia\n'
        '5. Ser cortes y obediente\n'
        '6. Andar con reverencia en la casa de Dios\n'
        '7. Tener una cancion en el corazon\n'
        '8. Ir donde Dios me mande\n\n'
        'Cada punto guia un aspecto de la vida del lider cristiano, desde la vida espiritual '
        'personal hasta el servicio a los demas.',
    consejo:
        'Practica un punto de la Ley cada semana como meta personal.',
  ),
  const _Tema(
    titulo: 'Himno de los Guias Mayores',
    seccion: 'Ley y Voto',
    contenido:
        'El Himno de los Guias Mayores se canta en reuniones oficiales, '
        'investiduras y campamentos. Representa la identidad y mision del Club.\n\n'
        'El himno refuerza el espiritu de unidad y proposito del grupo. '
        'Se espera que todos los miembros lo conozcan de memoria y lo canten '
        'con entusiasmo y reverencia.',
    consejo:
        'Practica el himno en grupo regularmente. La musica fortalece la unidad del club.',
  ),
  const _Tema(
    titulo: 'Lema y Blanco',
    seccion: 'Ley y Voto',
    contenido:
        'Lema: "El amor de Cristo me motiva"\n\n'
        'Blanco: "El mensaje adventista a todo el mundo en mi generacion"\n\n'
        'El Lema refleja la motivacion interna del Guia Mayor: el amor de Cristo '
        'como fuerza impulsora para el servicio. El Blanco establece la mision '
        'evangelistica como proposito del ministerio juvenil adventista.',
    consejo:
        'Integra el Lema y Blanco en tus devocionales y actividades de club.',
  ),

  // ── Uniforme Correcto ──
  const _Tema(
    titulo: 'Componentes del Uniforme',
    seccion: 'Uniforme Correcto',
    contenido:
        'El uniforme del Guia Mayor consta de las siguientes piezas:\n\n'
        '- Camisa/blusa verde olivo oficial con insignias\n'
        '- Pantalon/falda color caqui o verde oscuro\n'
        '- Panoleta (mascada) del club con nudo oficial\n'
        '- Boina o gorra oficial (segun el campo local)\n'
        '- Cinturon negro con hebilla oficial\n'
        '- Zapatos negros cerrados y lustrados\n'
        '- Medias/calcetines oscuros\n\n'
        'Cada pieza tiene un significado simbolico y debe portarse con dignidad '
        'y respeto, representando los valores del Club de Guias Mayores.',
    pasos: [
      'Verificar que la camisa este limpia, planchada y con todos los botones',
      'Colocar las insignias en la posicion correcta segun el manual de insignias',
      'La panoleta se dobla en triangulo y se enrolla desde la base',
      'La boina se coloca ligeramente inclinada hacia la derecha',
      'El cinturon se abrocha con la hebilla centrada',
      'Los zapatos deben estar lustrados y en buen estado',
    ],
    consejo:
        'Prepara tu uniforme la noche anterior a cada reunion para asegurarte de que este completo y en buen estado.',
  ),
  const _Tema(
    titulo: 'Insignias y su Ubicacion',
    seccion: 'Uniforme Correcto',
    contenido:
        'Las insignias del uniforme se colocan en posiciones especificas:\n\n'
        '- Bolsillo izquierdo: insignia del club y triangulo de la clase\n'
        '- Manga izquierda: bandera del pais (arriba), insignia del campo/mision (abajo)\n'
        '- Manga derecha: especialidades ganadas\n'
        '- Bolsillo derecho: insignia de cargo o funcion\n\n'
        'Las insignias deben estar cosidas firmemente, no con alfileres, y centradas en la posicion indicada.',
    consejo:
        'Consulta con tu director de club si tienes dudas sobre la posicion de alguna insignia especifica.',
  ),
  const _Tema(
    titulo: 'Ocasiones de Uso',
    seccion: 'Uniforme Correcto',
    contenido:
        'El uniforme completo se porta en las siguientes ocasiones:\n\n'
        '- Reuniones regulares del club (sabado)\n'
        '- Ceremonias de investidura\n'
        '- Desfiles y marchas\n'
        '- Cultos especiales del club\n'
        '- Campamentos (uniforme de gala para ceremonias)\n'
        '- Eventos oficiales de la Asociacion/Mision\n\n'
        'En actividades de campo se permite el uniforme deportivo del club o ropa adecuada '
        'para la actividad, pero la panoleta siempre debe portarse.',
    consejo:
        'Lleva siempre una panoleta extra en tu mochila de campamento.',
  ),

  // ── Honores a la Bandera ──
  const _Tema(
    titulo: 'Orden de la Ceremonia',
    seccion: 'Honores a la Bandera',
    contenido:
        'La ceremonia de honores a la bandera sigue un orden protocolar estricto. '
        'Se realiza al inicio de cada reunion oficial del club y en ceremonias especiales. '
        'Debe conducirse con reverencia y solemnidad.',
    pasos: [
      'Formar las unidades en posicion de firmes',
      'El director ordena: "Atencion para los honores a la bandera"',
      'La escolta de la bandera se dirige al frente con paso marcial',
      'Se ordena: "Saludo a la bandera nacional... Ya!"',
      'Todos saludan (mano derecha a la sien o al corazon)',
      'Se canta el Himno Nacional completo o se guarda silencio solemne',
      'Se ordena: "Firmes!" para concluir el saludo',
      'Honores a la Bandera del Club / JA',
      'Se recita el Voto y la Ley del Guia Mayor',
      'La escolta se retira o la bandera se coloca en su posicion',
    ],
    consejo:
        'Practica con tu unidad el protocolo completo antes de ceremonias importantes.',
  ),
  const _Tema(
    titulo: 'Escolta de la Bandera',
    seccion: 'Honores a la Bandera',
    contenido:
        'La escolta de la bandera esta compuesta por un grupo seleccionado de miembros '
        'que tienen el honor de portar y custodiar la bandera durante las ceremonias. '
        'Generalmente se compone de:\n\n'
        '- 1 portabandera (lleva la bandera nacional)\n'
        '- 2 escoltas laterales\n'
        '- 1 comandante de escolta (dirige los movimientos)\n\n'
        'La escolta se desplaza con paso marcial sincronizado y debe mantener '
        'una postura impecable durante toda la ceremonia.',
    pasos: [
      'El comandante da la orden de avance',
      'La escolta marcha al frente en formacion (portabandera al centro)',
      'Los escoltas laterales se colocan a un paso del portabandera',
      'Al llegar al frente, se detienen y el portabandera iza o presenta la bandera',
      'Permanecen firmes durante los honores',
      'Al concluir, el comandante ordena la retirada con paso marcial',
    ],
    consejo:
        'Ser parte de la escolta de la bandera es un privilegio. Manten siempre tu uniforme impecable cuando seas designado.',
  ),
  const _Tema(
    titulo: 'Cuidado y Respeto a la Bandera',
    seccion: 'Honores a la Bandera',
    contenido:
        'La bandera nacional y la bandera del club merecen un trato respetuoso en todo momento:\n\n'
        '- Nunca debe tocar el suelo\n'
        '- Se guarda doblada correctamente despues de cada uso\n'
        '- No se usa como mantel, cobertor ni decoracion informal\n'
        '- Se iza al amanecer y se arria al atardecer (en campamentos)\n'
        '- Cuando esta danada o desgastada, se retira con ceremonia especial\n'
        '- Al pasar una bandera en desfile, se saluda con la mano al corazon',
    consejo:
        'Ensena a los miembros nuevos como doblar correctamente la bandera desde su primer campamento.',
  ),
];

IconData _getSeccionIcon(String icon) {
  switch (icon) {
    case 'gavel':
      return Icons.gavel;
    case 'checkroom':
      return Icons.checkroom;
    case 'flag':
      return Icons.flag;
    default:
      return Icons.book;
  }
}

Color _getSeccionColor(String color) {
  switch (color) {
    case 'blue':
      return Colors.blue;
    case 'red':
      return Colors.red;
    case 'purple':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

// ─── Pantalla principal ───
class ManualScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const ManualScreen({super.key, this.onOpenDrawer});

  List<_Tema> _temasDeSeccion(String titulo) {
    return _todosLosTemas.where((t) => t.seccion == titulo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: onOpenDrawer != null
            ? IconButton(icon: const Icon(Icons.menu), onPressed: onOpenDrawer)
            : null,
        title: const Text('Manual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _ManualSearchDelegate());
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _secciones.length,
        itemBuilder: (context, index) {
          final seccion = _secciones[index];
          final temas = _temasDeSeccion(seccion['titulo']);
          return _buildSeccionCard(context, seccion, temas);
        },
      ),
    );
  }

  Widget _buildSeccionCard(
      BuildContext context, Map<String, dynamic> seccion, List<_Tema> temas) {
    final color = _getSeccionColor(seccion['color']);
    final icon = _getSeccionIcon(seccion['icon']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          seccion['titulo'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${temas.length} temas'),
        children: [
          const Divider(height: 1),
          ...temas.map((tema) {
            return ListTile(
              leading: const Icon(Icons.article, size: 20),
              title: Text(tema.titulo),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _abrirTema(context, tema),
            );
          }),
        ],
      ),
    );
  }

  static void _abrirTema(BuildContext context, _Tema tema) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _TemaDetailScreen(tema: tema)),
    );
  }
}

// ─── Pantalla de detalle de tema ───
class _TemaDetailScreen extends StatelessWidget {
  final _Tema tema;
  const _TemaDetailScreen({required this.tema});

  Color get _color {
    final seccion =
        _secciones.firstWhere((s) => s['titulo'] == tema.seccion);
    return _getSeccionColor(seccion['color']);
  }

  IconData get _icon {
    final seccion =
        _secciones.firstWhere((s) => s['titulo'] == tema.seccion);
    return _getSeccionIcon(seccion['icon']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tema.titulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Encabezado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: _color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tema.titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tema.seccion,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Descripcion
          const Text(
            'Descripcion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            tema.contenido,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 15,
            ),
          ),

          // Pasos
          if (tema.pasos != null && tema.pasos!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.format_list_numbered, color: _color, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Pasos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...tema.pasos!.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: _color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Consejo
          if (tema.consejo != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consejo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tema.consejo!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Busqueda ───
class _ManualSearchDelegate extends SearchDelegate<String> {
  _ManualSearchDelegate()
      : super(
          searchFieldLabel: 'Buscar en el manual...',
          searchFieldStyle: const TextStyle(fontSize: 16),
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  List<_Tema> _buscar(String q) {
    if (q.isEmpty) return [];
    final lower = q.toLowerCase();
    return _todosLosTemas.where((tema) {
      return tema.titulo.toLowerCase().contains(lower) ||
          tema.seccion.toLowerCase().contains(lower) ||
          tema.contenido.toLowerCase().contains(lower) ||
          (tema.pasos?.any((p) => p.toLowerCase().contains(lower)) ?? false) ||
          (tema.consejo?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final resultados = _buscar(query);

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Busca cualquier tema del manual',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Ley, voto, uniforme, bandera...',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    if (resultados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para "$query"',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return _buildResultList(context, resultados);
  }

  @override
  Widget buildResults(BuildContext context) {
    final resultados = _buscar(query);

    if (resultados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para "$query"',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return _buildResultList(context, resultados);
  }

  Widget _buildResultList(BuildContext context, List<_Tema> resultados) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        final tema = resultados[index];
        final seccion =
            _secciones.firstWhere((s) => s['titulo'] == tema.seccion);
        final color = _getSeccionColor(seccion['color']);
        final icon = _getSeccionIcon(seccion['icon']);

        // Encontrar fragmento relevante
        String fragmento = tema.contenido;
        if (query.isNotEmpty) {
          final lower = tema.contenido.toLowerCase();
          final idx = lower.indexOf(query.toLowerCase());
          if (idx >= 0) {
            final start = (idx - 40).clamp(0, tema.contenido.length);
            final end = (idx + query.length + 60).clamp(0, tema.contenido.length);
            fragmento =
                '${start > 0 ? "..." : ""}${tema.contenido.substring(start, end)}${end < tema.contenido.length ? "..." : ""}';
          } else {
            fragmento = tema.contenido.length > 100
                ? '${tema.contenido.substring(0, 100)}...'
                : tema.contenido;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(tema.titulo,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tema.seccion,
                    style: TextStyle(color: color, fontSize: 12)),
                const SizedBox(height: 2),
                Text(fragmento,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            isThreeLine: true,
            onTap: () {
              close(context, '');
              ManualScreen._abrirTema(context, tema);
            },
          ),
        );
      },
    );
  }
}
