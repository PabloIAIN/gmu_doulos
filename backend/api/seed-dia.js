const { sql } = require('./_db');
const { handleOptions } = require('./_auth');

module.exports = async (req, res) => {
  if (handleOptions(req, res)) return;

  // Requiere SuperAdmin key
  const superKey = req.headers['x-superadmin-key'];
  if (!superKey || superKey !== process.env.SUPER_ADMIN_KEY) {
    return res.status(403).json({ error: 'Se requiere clave de super administrador' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    // ═══════════════════════════════════════════
    //  GUÍAS MAYORES - DIA TEMPLATE
    // ═══════════════════════════════════════════

    const seccionesGM = [
      { id: 'gm-pre',   nombre: 'Prerrequisitos',                    orden: 1 },
      { id: 'gm-esp',   nombre: 'Área Espiritual',                   orden: 2 },
      { id: 'gm-den',   nombre: 'Área Denominacional',               orden: 3 },
      { id: 'gm-edu',   nombre: 'Área de Educación',                 orden: 4 },
      { id: 'gm-lid',   nombre: 'Área de Liderazgo – 12 Seminarios', orden: 5 },
      { id: 'gm-espec', nombre: 'Especialidades Requeridas',         orden: 6 },
      { id: 'gm-sup',   nombre: 'Área de Supervisión',               orden: 7 },
      { id: 'gm-fis',   nombre: 'Área Física',                       orden: 8 },
    ];

    for (const s of seccionesGM) {
      await sql`INSERT INTO carpeta_secciones (id, nombre, orden, club_id)
        VALUES (${s.id}, ${s.nombre}, ${s.orden}, 'DIA_TEMPLATE_GM')
        ON CONFLICT (id) DO NOTHING`;
    }

    const requisitosGM = [
      // Prerrequisitos
      { s:'gm-pre', o:1, n:'Ser miembro bautizado, fiel y en regla de la IASD' },
      { s:'gm-pre', o:2, n:'Tener mínimo 16 años al iniciar el programa' },
      { s:'gm-pre', o:3, n:'Tener mínimo 18 años en la investidura' },
      { s:'gm-pre', o:4, n:'Tener recomendación escrita de la junta directiva local' },
      { s:'gm-pre', o:5, n:'Ser miembro activo del personal de Aventureros o Conquistadores (mín. 6 meses)' },
      { s:'gm-pre', o:6, n:'Completar el curso básico de capacitación para consejeros (10 horas)' },
      // Espiritual
      { s:'gm-esp', o:1, n:'Mantener un diario devocional por mínimo 4 semanas' },
      { s:'gm-esp', o:2, n:'Completar el programa espiritual "Pasos para el Discipulado"' },
      { s:'gm-esp', o:3, n:'Participar en evento de evangelismo o servicio comunitario' },
      { s:'gm-esp', o:4, n:'Preparar resumen de 1 página de cada una de las 28 Creencias Fundamentales' },
      { s:'gm-esp', o:5, n:'Desarrollar y presentar 4 creencias con ayudas visuales' },
      // Denominacional
      { s:'gm-den', o:1, n:'Obtener la especialidad "Herencia de los Pioneros Adventistas"' },
      { s:'gm-den', o:2, n:'Leer libro de historia denominacional aprobado' },
      { s:'gm-den', o:3, n:'Leer libro sobre historia de los Conquistadores' },
      { s:'gm-den', o:4, n:'Completar investigación de ≥2 páginas sobre análisis del temperamento' },
      // Educación
      { s:'gm-edu', o:1, n:'Leer "La Educación" de E.G. White y presentar 1 página de reflexión' },
      { s:'gm-edu', o:2, n:'Leer "La Conducción del Niño" o "Mensaje para los Jóvenes" y presentar reflexión' },
      { s:'gm-edu', o:3, n:'Asistir a 3 seminarios sobre desarrollo del niño o teoría de la educación' },
      { s:'gm-edu', o:4, n:'Observar 2 horas a un grupo de Aventureros o Conquistadores y escribir reflexión' },
      { s:'gm-edu', o:5, n:'Leer 1 libro sobre desarrollo de habilidades de liderazgo' },
      // 12 Seminarios
      { s:'gm-lid', o:1,  n:'Seminario 1: Cómo ser un líder cristiano' },
      { s:'gm-lid', o:2,  n:'Seminario 2: Visión, misión y motivación' },
      { s:'gm-lid', o:3,  n:'Seminario 3: Manejo de riesgos en el ministerio' },
      { s:'gm-lid', o:4,  n:'Seminario 4: Disciplina' },
      { s:'gm-lid', o:5,  n:'Seminario 5: Teoría de la comunicación y habilidades para escuchar' },
      { s:'gm-lid', o:6,  n:'Seminario 6: Entrenamiento en comunicación práctica' },
      { s:'gm-lid', o:7,  n:'Seminario 7: Entendiendo y enseñando los estilos de aprendizaje' },
      { s:'gm-lid', o:8,  n:'Seminario 8: Cómo preparar la adoración creativa efectiva' },
      { s:'gm-lid', o:9,  n:'Seminario 9: Comprender y usar la creatividad' },
      { s:'gm-lid', o:10, n:'Seminario 10: Principios de evangelización en jóvenes y niños' },
      { s:'gm-lid', o:11, n:'Seminario 11: Cómo llevar a un niño a Cristo' },
      { s:'gm-lid', o:12, n:'Seminario 12: Comprendiendo tus dones espirituales' },
      // Especialidades
      { s:'gm-espec', o:1, n:'Especialidad: Narración de historias' },
      { s:'gm-espec', o:2, n:'Especialidad: Habilidades de campamento I' },
      { s:'gm-espec', o:3, n:'Especialidad: Habilidades de campamento II' },
      { s:'gm-espec', o:4, n:'Especialidad: Habilidades de campamento III' },
      { s:'gm-espec', o:5, n:'Especialidad: Habilidades de campamento IV' },
      { s:'gm-espec', o:6, n:'Especialidad de libre elección #1' },
      { s:'gm-espec', o:7, n:'Especialidad de libre elección #2' },
      // Supervisión
      { s:'gm-sup', o:1, n:'Supervisar un grupo por ≥1 año (Aventureros, Conquistadores o Escuela Sabática infantil)' },
      { s:'gm-sup', o:2, n:'Desarrollar y dirigir 3 talleres creativos para niños y/o adolescentes' },
      { s:'gm-sup', o:3, n:'Participar en rol de liderazgo en evento de la Asociación/Misión' },
      // Física
      { s:'gm-fis', o:1, n:'Completar los requisitos del Medallón de Plata' },
    ];

    for (const r of requisitosGM) {
      const id = `${r.s}-r${r.o}`;
      await sql`INSERT INTO carpeta_requisitos (id, seccion_id, nombre, orden, club_id)
        VALUES (${id}, ${r.s}, ${r.n}, ${r.o}, 'DIA_TEMPLATE_GM')
        ON CONFLICT (id) DO NOTHING`;
    }

    // ═══════════════════════════════════════════
    //  CONQUISTADORES - DIA TEMPLATE
    // ═══════════════════════════════════════════

    const clasesConq = [
      { id:'conq-amigo',       nombre:'Amigo',                         edad:10 },
      { id:'conq-companero',   nombre:'Compañero',                     edad:11 },
      { id:'conq-explorador',  nombre:'Explorador',                    edad:12 },
      { id:'conq-orientador',  nombre:'Orientador',                    edad:13 },
      { id:'conq-viajero',     nombre:'Viajero',                       edad:14 },
      { id:'conq-guia',        nombre:'Guía',                          edad:15 },
    ];

    for (const c of clasesConq) {
      await sql`INSERT INTO carpeta_secciones (id, nombre, orden, club_id)
        VALUES (${c.id}, ${c.nombre}, ${c.edad}, 'DIA_TEMPLATE_CONQ')
        ON CONFLICT (id) DO NOTHING`;

      // Requisitos por área para cada clase
      const areas = [
        { o:1, n:`${c.nombre}: Conocer el Voto y la Ley del Conquistador` },
        { o:2, n:`${c.nombre}: Completar requisitos del área Espiritual` },
        { o:3, n:`${c.nombre}: Completar requisitos del área de Salud y Aptitud Física` },
        { o:4, n:`${c.nombre}: Completar requisitos del área de Naturaleza` },
        { o:5, n:`${c.nombre}: Completar requisitos del área de Servicio y Campamento` },
        { o:6, n:`${c.nombre}: Obtener 2 especialidades requeridas` },
      ];

      for (const a of areas) {
        const rid = `${c.id}-r${a.o}`;
        await sql`INSERT INTO carpeta_requisitos (id, seccion_id, nombre, orden, club_id)
          VALUES (${rid}, ${c.id}, ${a.n}, ${a.o}, 'DIA_TEMPLATE_CONQ')
          ON CONFLICT (id) DO NOTHING`;
      }
    }

    // ═══════════════════════════════════════════
    //  AVENTUREROS - DIA TEMPLATE (placeholder)
    // ═══════════════════════════════════════════

    const clasesAv = [
      { id:'av-corderitos',   nombre:'Corderitos',         edad:4 },
      { id:'av-aves',         nombre:'Aves Madrugadoras',  edad:6 },
      { id:'av-abejas',       nombre:'Abejas Industriosas',edad:7 },
      { id:'av-rayos',        nombre:'Rayos de Sol',        edad:8 },
      { id:'av-constructor',  nombre:'Constructor',         edad:9 },
      { id:'av-manos',        nombre:'Manos Ayudadoras',    edad:10 },
    ];

    for (const c of clasesAv) {
      await sql`INSERT INTO carpeta_secciones (id, nombre, orden, club_id)
        VALUES (${c.id}, ${c.nombre}, ${c.edad}, 'DIA_TEMPLATE_AV')
        ON CONFLICT (id) DO NOTHING`;

      const areas = [
        { o:1, n:`${c.nombre}: Mi Dios` },
        { o:2, n:`${c.nombre}: Mi Yo` },
        { o:3, n:`${c.nombre}: Mi Familia` },
        { o:4, n:`${c.nombre}: Mi Mundo` },
      ];

      for (const a of areas) {
        const rid = `${c.id}-r${a.o}`;
        await sql`INSERT INTO carpeta_requisitos (id, seccion_id, nombre, orden, club_id)
          VALUES (${rid}, ${c.id}, ${a.n}, ${a.o}, 'DIA_TEMPLATE_AV')
          ON CONFLICT (id) DO NOTHING`;
      }
    }

    return res.status(200).json({
      ok: true,
      message: 'Plantillas DIA cargadas correctamente',
      datos: {
        gm: { secciones: seccionesGM.length, requisitos: requisitosGM.length },
        conq: { clases: clasesConq.length, requisitos: clasesConq.length * 6 },
        av: { clases: clasesAv.length, requisitos: clasesAv.length * 4 },
      }
    });
  } catch (error) {
    console.error('Error en /api/seed-dia:', error);
    return res.status(500).json({ error: error.message });
  }
};
