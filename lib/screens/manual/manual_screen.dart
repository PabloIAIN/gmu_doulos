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
    'titulo': 'Clases de Guías Mayores',
    'icon': 'school',
    'color': 'blue',
  },
  {
    'titulo': 'Nudos y Amarres',
    'icon': 'link',
    'color': 'green',
  },
  {
    'titulo': 'Señales de Pista',
    'icon': 'signpost',
    'color': 'orange',
  },
  {
    'titulo': 'Primeros Auxilios',
    'icon': 'medical',
    'color': 'red',
  },
  {
    'titulo': 'Ley y Voto',
    'icon': 'gavel',
    'color': 'purple',
  },
  {
    'titulo': 'Vida en la Naturaleza',
    'icon': 'park',
    'color': 'teal',
  },
];

final List<_Tema> _todosLosTemas = [
  // ── Clases de Guías Mayores ──
  const _Tema(
    titulo: 'Guía Mayor Aspirante',
    seccion: 'Clases de Guías Mayores',
    contenido:
        'El Guía Mayor Aspirante es el primer nivel de liderazgo en el Club. '
        'Está diseñado para jóvenes que desean comenzar su formación como líderes '
        'y servir de ejemplo a los Conquistadores y Aventureros.',
    pasos: [
      'Tener al menos 16 años de edad',
      'Haber completado la clase de Guía o equivalente',
      'Conocer y practicar el Voto y la Ley del Guía Mayor',
      'Completar la lectura del libro del año del Club',
      'Participar activamente en las actividades del Club por al menos 1 año',
      'Aprobar el examen teórico de la clase',
    ],
    consejo:
        'Comienza un cuaderno de campo para registrar tus actividades y aprendizajes.',
  ),
  const _Tema(
    titulo: 'Guía Mayor',
    seccion: 'Clases de Guías Mayores',
    contenido:
        'El Guía Mayor es el nivel intermedio de liderazgo. Requiere habilidades '
        'prácticas en campismo, liderazgo de grupos y conocimiento bíblico más profundo. '
        'Es capaz de dirigir actividades de campo y enseñar a otros.',
    pasos: [
      'Haber completado la clase de Guía Mayor Aspirante',
      'Tener al menos 18 años de edad',
      'Completar 2 especialidades en Vida Primitiva o Naturaleza',
      'Dirigir al menos 1 actividad de campo completa',
      'Conocer técnicas avanzadas de campismo y orientación',
      'Aprobar la evaluación práctica y teórica',
    ],
    consejo:
        'Busca un mentor que sea Guía Mayor Avanzado para guiar tu proceso.',
  ),
  const _Tema(
    titulo: 'Guía Mayor Avanzado',
    seccion: 'Clases de Guías Mayores',
    contenido:
        'El Guía Mayor Avanzado es el nivel más alto de liderazgo. Implica ser un líder '
        'experimentado capaz de planificar, ejecutar y evaluar programas completos del Club. '
        'Puede capacitar a otros Guías Mayores y dirigir campamentos regionales.',
    pasos: [
      'Haber completado la clase de Guía Mayor',
      'Tener al menos 21 años de edad',
      'Completar 4 especialidades adicionales de nivel avanzado',
      'Haber dirigido al menos 2 campamentos completos',
      'Capacitar a al menos 3 Guías Mayores Aspirantes',
      'Presentar un proyecto de servicio comunitario',
      'Aprobar la evaluación final ante la Asociación/Misión',
    ],
    consejo:
        'Documenta cada campamento y actividad; la experiencia comprobable es clave.',
  ),

  // ── Nudos y Amarres ──
  const _Tema(
    titulo: 'Nudo Llano',
    seccion: 'Nudos y Amarres',
    contenido:
        'El nudo llano (o nudo rizo) se usa para unir dos cuerdas del mismo grosor. '
        'Es uno de los nudos más básicos y esenciales. Se reconoce porque los dos cabos '
        'salen del mismo lado del nudo.',
    pasos: [
      'Toma un cabo en cada mano',
      'Cruza el cabo derecho sobre el izquierdo y pásalo por debajo',
      'Ahora cruza el cabo izquierdo sobre el derecho y pásalo por debajo',
      'Tira de ambos cabos para ajustar',
      'Verifica: los cabos paralelos deben salir del mismo lado',
    ],
    consejo:
        'Recuerda: "derecho sobre izquierdo, izquierdo sobre derecho". Si lo haces al revés obtendrás un nudo de abuela que se desliza.',
  ),
  const _Tema(
    titulo: 'As de Guía',
    seccion: 'Nudos y Amarres',
    contenido:
        'El As de Guía (bowline) forma un lazo fijo que no se aprieta bajo tensión. '
        'Es el "rey de los nudos" por su versatilidad. Se usa en rescate, navegación '
        'y para asegurar cargas. Es fácil de desatar incluso después de soportar mucho peso.',
    pasos: [
      'Haz un pequeño lazo en la cuerda (el "pozo")',
      'Pasa el cabo libre por el lazo de abajo hacia arriba ("la serpiente sale del pozo")',
      'Rodea el cabo fijo por detrás ("rodea el árbol")',
      'Vuelve a meter el cabo por el lazo de arriba hacia abajo ("regresa al pozo")',
      'Ajusta tirando del cabo fijo y del lazo formado',
    ],
    consejo:
        'Mnemotecnia: "La serpiente sale del pozo, rodea el árbol y vuelve al pozo."',
  ),
  const _Tema(
    titulo: 'Ballestrinque',
    seccion: 'Nudos y Amarres',
    contenido:
        'El ballestrinque se usa para sujetar una cuerda a un poste o estaca. '
        'Es el nudo de amarre más usado en campismo para iniciar y terminar amarres. '
        'Se ajusta fácilmente y se puede hacer con una sola mano.',
    pasos: [
      'Pasa la cuerda alrededor del poste',
      'Cruza la cuerda por encima de sí misma formando una X',
      'Da otra vuelta alrededor del poste',
      'Mete el cabo libre por debajo de la última vuelta (bajo la X)',
      'Tira para ajustar',
    ],
    consejo:
        'Siempre debe estar bajo tensión; si se afloja puede deslizarse. Úsalo como inicio de un amarre cuadrado.',
  ),
  const _Tema(
    titulo: 'Vuelta de Escota',
    seccion: 'Nudos y Amarres',
    contenido:
        'La vuelta de escota se utiliza para unir dos cuerdas de diferente grosor. '
        'A diferencia del nudo llano, funciona bien cuando las cuerdas tienen '
        'distinto diámetro. Se puede hacer doble para mayor seguridad.',
    pasos: [
      'Haz un seno (curva en U) con la cuerda más gruesa',
      'Pasa la cuerda delgada por dentro del seno, de abajo hacia arriba',
      'Rodea ambos lados del seno con la cuerda delgada',
      'Mete la cuerda delgada debajo de sí misma',
      'Ajusta tirando de los cabos opuestos',
    ],
    consejo:
        'Para la versión doble, da dos vueltas alrededor del seno antes de meter el cabo.',
  ),
  const _Tema(
    titulo: 'Nudo Corredizo',
    seccion: 'Nudos y Amarres',
    contenido:
        'El nudo corredizo crea un lazo que se ajusta al tirar del cabo fijo. '
        'Se usa para sujetar objetos temporalmente, colgar utensilios en el campamento '
        'y como base de trampas para supervivencia.',
    pasos: [
      'Haz un lazo simple en la cuerda',
      'Pasa el cabo libre a través del lazo',
      'Esto crea un segundo lazo que se desliza',
      'Tira del cabo fijo para apretar el lazo alrededor del objeto',
    ],
    consejo:
        'Nunca uses un nudo corredizo alrededor de personas; se puede apretar peligrosamente.',
  ),

  // ── Señales de Pista ──
  const _Tema(
    titulo: 'Camino correcto',
    seccion: 'Señales de Pista',
    contenido:
        'Indica que vas por el camino correcto. Se marca con una flecha en la dirección '
        'del recorrido. Puede hacerse con piedras, ramas o tiza. Se coloca en lugares '
        'visibles como bifurcaciones o cruces.',
    pasos: [
      'Con piedras: coloca una flecha con piedras pequeñas apuntando al camino',
      'Con ramas: cruza dos ramas en forma de flecha',
      'Con tiza: dibuja una flecha en una roca o árbol visible',
      'Colócala a la altura de los ojos cuando sea posible',
      'Asegúrate de que sea visible desde al menos 3 metros de distancia',
    ],
    consejo:
        'Coloca las señales en el lado derecho del camino por convención.',
  ),
  const _Tema(
    titulo: 'Giro a la derecha',
    seccion: 'Señales de Pista',
    contenido:
        'Señal que indica que el camino gira a la derecha. Es crucial en bifurcaciones '
        'donde el grupo podría tomar la dirección equivocada.',
    pasos: [
      'Con piedras: una piedra grande con una pequeña a su derecha',
      'Con ramas: rama larga con otra corta apuntando a la derecha',
      'Con tiza: flecha curva hacia la derecha',
      'Colocar justo antes de la curva o bifurcación',
    ],
    consejo:
        'Añade una segunda señal después del giro confirmando el camino correcto.',
  ),
  const _Tema(
    titulo: 'Peligro',
    seccion: 'Señales de Pista',
    contenido:
        'Señal de advertencia que indica peligro adelante. Puede señalar terreno inestable, '
        'animales peligrosos, agua no potable o cualquier riesgo. Se marca con una X grande.',
    pasos: [
      'Con piedras: forma una X con piedras visibles',
      'Con ramas: cruza dos ramas grandes en forma de X',
      'Con tiza: dibuja una X grande y visible',
      'Colócala ANTES de la zona de peligro, a distancia segura',
      'Si es posible, añade una señal de dirección alternativa',
    ],
    consejo:
        'La señal de peligro es prioritaria; si la encuentras, detente y evalúa antes de avanzar.',
  ),
  const _Tema(
    titulo: 'Mensaje oculto',
    seccion: 'Señales de Pista',
    contenido:
        'Indica que hay un mensaje escondido cerca. Se representa con un círculo '
        'con un punto en el centro. El mensaje suele estar debajo de una piedra, '
        'dentro de un tronco hueco o en un recipiente cercano.',
    pasos: [
      'Con piedras: un círculo de piedras con una piedra en el centro',
      'Con tiza: dibuja un círculo con un punto central',
      'Busca el mensaje en un radio de 2-3 metros de la señal',
      'Revisa debajo de piedras, troncos y dentro de recipientes',
    ],
    consejo:
        'Al dejar un mensaje, protégelo del agua dentro de una bolsa plástica.',
  ),
  const _Tema(
    titulo: 'Fin del rastro',
    seccion: 'Señales de Pista',
    contenido:
        'Señal que marca el final del recorrido. Se representa con un círculo grande '
        'o tres líneas horizontales. Indica que has llegado al destino.',
    pasos: [
      'Con piedras: forma un círculo grande con piedras',
      'Con ramas: tres líneas paralelas horizontales',
      'Con tiza: tres líneas horizontales o un círculo',
      'Coloca la señal en un lugar abierto y despejado',
    ],
    consejo:
        'Es buena práctica dejar un mensaje de felicitación o instrucciones de regreso en la señal final.',
  ),

  // ── Primeros Auxilios ──
  const _Tema(
    titulo: 'RCP (Reanimación Cardiopulmonar)',
    seccion: 'Primeros Auxilios',
    contenido:
        'La RCP es una técnica de emergencia para mantener el flujo de sangre oxigenada '
        'al cerebro y otros órganos cuando el corazón deja de latir. Cada minuto sin RCP '
        'reduce la probabilidad de supervivencia un 10%.',
    pasos: [
      'Verifica la seguridad de la escena',
      'Comprueba si la persona responde: tócala y pregúntale en voz alta',
      'Si no responde, llama a emergencias (911) inmediatamente',
      'Coloca a la persona boca arriba sobre una superficie firme',
      'Coloca el talón de tu mano en el centro del pecho (entre los pezones)',
      'Pon tu otra mano encima, entrelaza los dedos',
      'Comprime fuerte y rápido: 5-6 cm de profundidad, 100-120 por minuto',
      'Cada 30 compresiones, da 2 respiraciones de rescate (si estás capacitado)',
      'No te detengas hasta que llegue ayuda profesional',
    ],
    consejo:
        'Ritmo de las compresiones: sigue el ritmo de la canción "Stayin\' Alive" de Bee Gees (100 BPM).',
  ),
  const _Tema(
    titulo: 'Heridas y Hemorragias',
    seccion: 'Primeros Auxilios',
    contenido:
        'El manejo correcto de heridas previene infecciones y controla el sangrado. '
        'Las heridas se clasifican en abrasiones, cortantes, punzantes y contusas. '
        'El control de hemorragias puede salvar vidas.',
    pasos: [
      'Lávate las manos o usa guantes si están disponibles',
      'Aplica presión directa con un paño limpio sobre la herida',
      'Mantén la presión constante por al menos 10-15 minutos',
      'Si el sangrado es en una extremidad, elévala por encima del corazón',
      'No retires el paño si se empapa; coloca otro encima',
      'Limpia la herida con agua limpia cuando el sangrado se detenga',
      'Aplica un vendaje limpio y firme (no apretado)',
      'Busca atención médica si la herida es profunda o no deja de sangrar',
    ],
    consejo:
        'Lleva siempre un botiquín básico en salidas de campo con gasas, vendas, antiséptico y guantes.',
  ),
  const _Tema(
    titulo: 'Quemaduras',
    seccion: 'Primeros Auxilios',
    contenido:
        'Las quemaduras se clasifican en grados: 1er grado (enrojecimiento), '
        '2do grado (ampollas) y 3er grado (tejido destruido). El tratamiento '
        'inmediato con agua fría es clave para reducir el daño.',
    pasos: [
      'Retira a la persona de la fuente de calor',
      'Enfría la quemadura con agua corriente fría por 10-20 minutos',
      'NO uses hielo, mantequilla, pasta de dientes ni remedios caseros',
      'NO revientes las ampollas',
      'Cubre con un vendaje estéril húmedo y suelto',
      'Si la quemadura es mayor que la palma de la mano, busca ayuda médica',
      'Si es en cara, manos, pies, genitales o articulaciones: emergencia',
    ],
    consejo:
        'En campamentos, mantén una distancia segura del fuego y ten agua cerca siempre.',
  ),
  const _Tema(
    titulo: 'Fracturas e Inmovilización',
    seccion: 'Primeros Auxilios',
    contenido:
        'Una fractura es la ruptura de un hueso. Se manifiesta con dolor intenso, '
        'hinchazón, deformidad y pérdida de función. La inmovilización adecuada '
        'previene daño adicional durante el traslado.',
    pasos: [
      'No muevas la zona afectada innecesariamente',
      'Inmoviliza la articulación por encima y por debajo de la fractura',
      'Usa férulas improvisadas: ramas rectas, cartón, revistas enrolladas',
      'Acolcha la férula con tela o ropa antes de colocarla',
      'Sujeta con vendas o tiras de tela (no muy apretadas)',
      'Verifica la circulación: comprueba pulso, color y sensibilidad más allá de la férula',
      'Aplica hielo envuelto en tela para reducir la hinchazón',
      'Traslada a un centro médico lo antes posible',
    ],
    consejo:
        'Regla: "Férula como lo encuentres". No intentes realinear un hueso roto.',
  ),
  const _Tema(
    titulo: 'Picaduras y Mordeduras',
    seccion: 'Primeros Auxilios',
    contenido:
        'Las picaduras de insectos y mordeduras de serpientes requieren atención inmediata. '
        'La mayoría de las picaduras de insectos son leves, pero las reacciones alérgicas '
        'pueden ser mortales (anafilaxia).',
    pasos: [
      'Aléjate del animal o insecto para evitar más picaduras',
      'En picaduras de abeja: retira el aguijón raspando con una tarjeta (no con pinzas)',
      'Lava la zona con agua y jabón',
      'Aplica hielo envuelto en tela por 10 minutos',
      'En mordedura de serpiente: NO hagas torniquete, NO chupes el veneno',
      'Inmoviliza la extremidad mordida y mantén a la persona en reposo',
      'Lleva a la persona al hospital lo más rápido posible',
      'Signos de alarma: dificultad para respirar, hinchazón de cara/garganta, mareo severo → emergencia',
    ],
    consejo:
        'Aprende a identificar las serpientes venenosas de tu región. Una foto del animal ayuda al médico.',
  ),

  // ── Ley y Voto ──
  const _Tema(
    titulo: 'Voto del Guía Mayor',
    seccion: 'Ley y Voto',
    contenido:
        '"Por la gracia de Dios, seré puro, bondadoso y leal. Guardaré la Ley del Guía Mayor. '
        'Seré siervo de Dios y amigo de la humanidad."\n\n'
        'El Voto es una promesa personal ante Dios y la comunidad. Refleja el compromiso '
        'del Guía Mayor de vivir según principios cristianos y de servicio. Se recita '
        'al inicio de cada reunión y en ceremonias especiales.',
    consejo:
        'Memoriza el Voto y reflexiona sobre su significado regularmente. Cada frase representa un área de tu vida.',
  ),
  const _Tema(
    titulo: 'Ley del Guía Mayor',
    seccion: 'Ley y Voto',
    contenido:
        'La Ley del Guía Mayor establece los principios de conducta:\n\n'
        '1. Observar la devoción matutina\n'
        '2. Cumplir fielmente con la parte que me toca\n'
        '3. Cuidar mi cuerpo\n'
        '4. Mantener una conciencia limpia\n'
        '5. Ser cortés y obediente\n'
        '6. Andar con reverencia en la casa de Dios\n'
        '7. Tener una canción en el corazón\n'
        '8. Ir donde Dios me mande\n\n'
        'Cada punto guía un aspecto de la vida del líder cristiano, desde la vida espiritual '
        'personal hasta el servicio a los demás.',
    consejo:
        'Practica un punto de la Ley cada semana como meta personal.',
  ),
  const _Tema(
    titulo: 'Himno de los Guías Mayores',
    seccion: 'Ley y Voto',
    contenido:
        'El Himno de los Guías Mayores se canta en reuniones oficiales, '
        'investiduras y campamentos. Representa la identidad y misión del Club.\n\n'
        'El himno refuerza el espíritu de unidad y propósito del grupo. '
        'Se espera que todos los miembros lo conozcan de memoria y lo canten '
        'con entusiasmo y reverencia.',
    consejo:
        'Practica el himno en grupo regularmente. La música fortalece la unidad del club.',
  ),
  const _Tema(
    titulo: 'Lema y Blanco',
    seccion: 'Ley y Voto',
    contenido:
        'Lema: "El amor de Cristo me motiva"\n\n'
        'Blanco: "El mensaje adventista a todo el mundo en mi generación"\n\n'
        'El Lema refleja la motivación interna del Guía Mayor: el amor de Cristo '
        'como fuerza impulsora para el servicio. El Blanco establece la misión '
        'evangelística como propósito del ministerio juvenil adventista.',
    consejo:
        'Integra el Lema y Blanco en tus devocionales y actividades de club.',
  ),

  // ── Vida en la Naturaleza ──
  const _Tema(
    titulo: 'Orientación sin Brújula',
    seccion: 'Vida en la Naturaleza',
    contenido:
        'Saber orientarse sin instrumentos es una habilidad esencial de supervivencia. '
        'Se puede determinar la dirección usando el sol, las estrellas, la vegetación '
        'y otros indicadores naturales.',
    pasos: [
      'Por el sol: sale por el Este y se pone por el Oeste',
      'Método del reloj: apunta la manecilla de la hora al sol; el Sur está entre ella y el 12',
      'Por la noche: localiza la Estrella Polar (hemisferio norte) o la Cruz del Sur (hemisferio sur)',
      'Por la vegetación: el musgo suele crecer en el lado más húmedo (norte en hemisferio sur)',
      'Por las hormigas: sus hormigueros suelen estar en el lado que recibe más sol',
      'Por los árboles: las ramas más densas suelen apuntar hacia donde reciben más luz',
    ],
    consejo:
        'Practica estos métodos en zonas conocidas antes de depender de ellos en situación real.',
  ),
  const _Tema(
    titulo: 'Plantas Comestibles',
    seccion: 'Vida en la Naturaleza',
    contenido:
        'Conocer plantas comestibles silvestres puede ser vital en una emergencia. '
        'La regla fundamental es: si no estás 100% seguro de que es comestible, NO la comas. '
        'Muchas plantas tóxicas se parecen a las comestibles.',
    pasos: [
      'Aprende a identificar al menos 5 plantas comestibles de tu región',
      'Regla de la prueba: frota en la piel, espera 15 min; toca los labios, espera; prueba un trozo pequeño',
      'Evita plantas con savia lechosa blanca (muchas son tóxicas)',
      'Evita hojas en grupos de 3 (pueden ser urticantes)',
      'Evita frutos y semillas de colores muy brillantes sin identificación',
      'Las plantas cerca de fuentes de agua suelen ser más seguras',
      'Cocinar las plantas reduce muchas toxinas',
    ],
    consejo:
        'Crea un herbario con fotos y muestras de las plantas comestibles de tu zona.',
  ),
  const _Tema(
    titulo: 'Construcción de Refugios',
    seccion: 'Vida en la Naturaleza',
    contenido:
        'Un refugio protege del frío, lluvia, viento y sol. En supervivencia, encontrar o '
        'construir refugio es la primera prioridad después de tratar heridas. La hipotermia '
        'puede matar en horas, incluso en climas templados.',
    pasos: [
      'Busca un lugar elevado, protegido del viento y lejos de cauces de agua',
      'Refugio de ramas inclinadas: apoya ramas largas contra un tronco o roca',
      'Cubre con hojas, pasto o ramas con follaje para impermeabilizar',
      'Aísla el suelo con hojas secas, pasto o ramas (el suelo roba calor)',
      'Haz la entrada pequeña y opuesta al viento',
      'El refugio debe ser justo del tamaño necesario (más pequeño = más cálido)',
      'Si tienes plástico o lona, úsalo como capa impermeable exterior',
    ],
    consejo:
        'Practica construir refugios en campamentos; la experiencia previa es invaluable en emergencias.',
  ),
  const _Tema(
    titulo: 'Encendido de Fuego',
    seccion: 'Vida en la Naturaleza',
    contenido:
        'El fuego proporciona calor, purifica agua, cocina alimentos y señaliza para rescate. '
        'Es una de las habilidades más importantes en vida al aire libre. Siempre respeta las '
        'normas de seguridad y el medio ambiente.',
    pasos: [
      'Prepara 3 tipos de material: yesca (fibras finas), leña fina (ramitas), leña gruesa',
      'Escoge un lugar seguro: lejos de árboles, sobre tierra o piedra',
      'Haz un círculo de piedras para contener el fuego',
      'Coloca la yesca en el centro y enciéndela (fósforos, pedernal, lupa)',
      'Añade leña fina poco a poco conforme crece la llama',
      'Cuando la leña fina arde bien, añade leña gruesa gradualmente',
      'Nunca dejes un fuego sin supervisión',
      'Para apagar: esparce las brasas, vierte agua, remueve y verifica que esté frío',
    ],
    consejo:
        'Lleva siempre 2 métodos para encender fuego (fósforos impermeabilizados + pedernal).',
  ),
  const _Tema(
    titulo: 'Purificación de Agua',
    seccion: 'Vida en la Naturaleza',
    contenido:
        'El agua es la necesidad más urgente en supervivencia. Una persona puede sobrevivir '
        'solo 3 días sin agua. Toda agua de fuente natural debe purificarse antes de beber '
        'para evitar enfermedades graves.',
    pasos: [
      'Hervir: lleva el agua a ebullición por al menos 1 minuto (3 min en altitud)',
      'Pastillas purificadoras: sigue las instrucciones del fabricante',
      'Filtro improvisado: capas de arena, carbón y grava en una botella cortada',
      'Destilación solar: plástico sobre un hoyo con un recipiente al centro',
      'Evita agua estancada, turbia o con mal olor como primera opción',
      'Busca agua de manantiales, lluvia o arroyos con corriente',
      'Si no puedes purificar, el agua de lluvia recién recolectada es la más segura',
    ],
    consejo:
        'Lleva siempre pastillas purificadoras en tu equipo; pesan poco y pueden salvar tu vida.',
  ),
];

IconData _getSeccionIcon(String icon) {
  switch (icon) {
    case 'school':
      return Icons.school;
    case 'link':
      return Icons.link;
    case 'signpost':
      return Icons.signpost;
    case 'medical':
      return Icons.medical_services;
    case 'gavel':
      return Icons.gavel;
    case 'park':
      return Icons.park;
    default:
      return Icons.book;
  }
}

Color _getSeccionColor(String color) {
  switch (color) {
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'orange':
      return Colors.orange;
    case 'red':
      return Colors.red;
    case 'purple':
      return Colors.purple;
    case 'teal':
      return Colors.teal;
    default:
      return Colors.grey;
  }
}

// ─── Pantalla principal ───
class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  List<_Tema> _temasDeSeccion(String titulo) {
    return _todosLosTemas.where((t) => t.seccion == titulo).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            color: color.withOpacity(0.1),
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
              color: _color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.15),
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

          // Descripción
          const Text(
            'Descripción',
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
                        color: _color.withOpacity(0.15),
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
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
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

// ─── Búsqueda ───
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
              'Nudos, primeros auxilios, señales...',
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
                color: color.withOpacity(0.1),
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
