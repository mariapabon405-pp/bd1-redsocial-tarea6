-- BASES DE DATOS I - TAREA 6 (PROYECTO FINAL): ARQUITECTURA HÍBRIDA (SQL + NoSQL/JSONB + IoT)
-- Estudiante: María Sofía Pabón Pabón
-- Institución: Institución Universitaria Pascual Bravo
-- 1. Limpieza estructuras previas 
DROP VIEW IF EXISTS vw_analitica_iot_eventos CASCADE;
DROP VIEW IF EXISTS vw_metricas_eventos_grupos CASCADE;
DROP VIEW IF EXISTS vw_analitica_publicaciones CASCADE;
DROP VIEW IF EXISTS vw_perfil_estudiantil_completo CASCADE;

DROP TABLE IF EXISTS log_actividad_bigdata, telemetria_campus_iot, mentoria, seguir, reaccion, asistente_evento, miembro_grupo, estudiante_interes, estudiante_habilidad, interes, habilidad, evento, grupo, comentario, publicacion, perfil, estudiante CASCADE;

-- 2. Modelo físico hibrido: 15 TABLAS RELACIONALES + 2 TABLAS BIG DATA / IoT
CREATE TABLE estudiante (
    id_estudiante SERIAL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ultima_actividad TIMESTAMP NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo' NOT NULL,
    -- Nuevo campo semiestructurado: Preferencias dinámicas de notificaciones y accesibilidad
    preferencias_json JSONB DEFAULT '{"tema": "oscuro", "notificaciones": ["eventos", "mentorias"]}'::jsonb,
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT uk_estudiante_correo UNIQUE (correo)
);

CREATE TABLE perfil (
    id_perfil SERIAL,
    id_estudiante INT NOT NULL,
    area_estudio VARCHAR(100),
    biografia TEXT,
    programa VARCHAR(100) NOT NULL,
    semestre INT NOT NULL,
    ciudad VARCHAR(50),
    foto_perfil VARCHAR(255),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_perfil PRIMARY KEY (id_perfil),
    CONSTRAINT uk_perfil_estudiante UNIQUE (id_estudiante),
    CONSTRAINT fk_perfil_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE publicacion (
    id_publicacion SERIAL,
    id_estudiante INT NOT NULL,
    contenido TEXT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    -- Campo semiestructurado (NoSQL): Metadatos variables (dispositivo, hashtags, multimedia, ubicación)
    metadatos_bigdata JSONB NOT NULL,
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE comentario (
    id_comentario SERIAL,
    id_publicacion INT NOT NULL,
    id_estudiante INT NOT NULL,
    comentario TEXT NOT NULL,
    fecha_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_comentario_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE grupo (
    id_grupo SERIAL,
    creador_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(50) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    estado VARCHAR(20) DEFAULT 'activo' NOT NULL,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (creador_id) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE evento (
    id_evento SERIAL,
    id_grupo INT,
    organizador INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    -- Campo semiestructurado (IoT): Configuración del aula inteligente y sensores asociados
    ubicacion_iot JSONB NOT NULL,
    fecha_inicio TIMESTAMP NOT NULL,
    fecha_fin TIMESTAMP NOT NULL,
    lugar VARCHAR(150) NOT NULL,
    modalidad VARCHAR(50) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_evento_organizador FOREIGN KEY (organizador) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE interes (
    id_interes SERIAL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    CONSTRAINT pk_interes PRIMARY KEY (id_interes),
    CONSTRAINT uk_interes_nombre UNIQUE (nombre)
);

CREATE TABLE habilidad (
    id_habilidad SERIAL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uk_habilidad_nombre UNIQUE (nombre)
);

CREATE TABLE estudiante_habilidad (
    id_estudiante INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(20),
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_estudiante_habilidad PRIMARY KEY (id_estudiante, id_habilidad),
    CONSTRAINT fk_esthab_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_esthab_habilidad FOREIGN KEY (id_habilidad) 
        REFERENCES habilidad(id_habilidad) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE estudiante_interes (
    id_estudiante INT NOT NULL,
    id_interes INT NOT NULL,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_estudiante_interes PRIMARY KEY (id_estudiante, id_interes),
    CONSTRAINT fk_estint_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_estint_interes FOREIGN KEY (id_interes) 
        REFERENCES interes(id_interes) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE miembro_grupo (
    id_estudiante INT NOT NULL,
    id_grupo INT NOT NULL,
    fecha_ingreso TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    rol VARCHAR(30) DEFAULT 'miembro',
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_estudiante, id_grupo),
    CONSTRAINT fk_mgrupo_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_mgrupo_grupo FOREIGN KEY (id_grupo) 
        REFERENCES grupo(id_grupo) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE asistente_evento (
    id_estudiante INT NOT NULL,
    id_evento INT NOT NULL,
    estado VARCHAR(30) DEFAULT 'confirmado',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_asistente_evento PRIMARY KEY (id_estudiante, id_evento),
    CONSTRAINT fk_asist_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_asist_evento FOREIGN KEY (id_evento) 
        REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE reaccion (
    id_estudiante INT NOT NULL,
    id_publicacion INT NOT NULL,
    tipo_reaccion VARCHAR(30) NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_reaccion PRIMARY KEY (id_estudiante, id_publicacion),
    CONSTRAINT fk_reac_estudiante FOREIGN KEY (id_estudiante) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_reac_publicacion FOREIGN KEY (id_publicacion) 
        REFERENCES publicacion(id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE seguir (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_seguir PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE mentoria (
    id_mentor INT NOT NULL,
    id_aprendiz INT NOT NULL,
    tema VARCHAR(100) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    fecha_mentoria TIMESTAMP NOT NULL,
    CONSTRAINT pk_mentoria PRIMARY KEY (id_mentor, id_aprendiz),
    CONSTRAINT fk_mentoria_mentor FOREIGN KEY (id_mentor) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_mentoria_aprendiz FOREIGN KEY (id_aprendiz) 
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Nuevas tablas hibridas para: BIG DATA E IoT (ALTO VOLUMEN Y VELOCIDAD)

-- TABLA 16: Telemetría de Sensores IoT del Campus Inteligente
-- Almacena lecturas en tiempo real provenientes de sensores ambientales, conteo RFID/WiFi y energía, se usa BIGSERIAL por el alto volumen de escritura continua (millones de tramas IoT)
CREATE TABLE telemetria_campus_iot (
    id_lectura BIGSERIAL,
    id_evento INT, -- Puede asociarse a un evento activo o al monitoreo general del campus
    codigo_sensor VARCHAR(30) NOT NULL,
    bloque_campus VARCHAR(50) NOT NULL,
    fecha_lectura TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    -- Payload semiestructurado: cada tipo de sensor envía métricas distintas sin alterar el esquema
    payload_sensor JSONB NOT NULL,
    CONSTRAINT pk_telemetria_iot PRIMARY KEY (id_lectura),
    CONSTRAINT fk_telemetria_evento FOREIGN KEY (id_evento)
        REFERENCES evento(id_evento) ON UPDATE CASCADE ON DELETE SET NULL
);

-- TABLA 17: Logs de Actividad y Analítica Big Data de usuarios, registra flujos masivos de interacción ( busquedas, tiempo en pantalla, alertas)
CREATE TABLE log_actividad_bigdata (
    id_log BIGSERIAL,
    id_estudiante INT NOT NULL,
    tipo_accion VARCHAR(50) NOT NULL,
    fecha_evento TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    -- Contexto dinámico de la sesión y métricas de rendimiento
    contexto_json JSONB NOT NULL,
    CONSTRAINT pk_log_bigdata PRIMARY KEY (id_log),
    CONSTRAINT fk_log_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante(id_estudiante) ON UPDATE CASCADE ON DELETE CASCADE
);

-- 3. Optimización para Big Data: ÍNDICES GIN (JSONB) Y B-TREE. Los índices GIN indexan cada clave y valor dentro de un JSONB evitando escaneos secuenciales cuando hay millones de registros

CREATE INDEX idx_publicacion_metadatos_gin ON publicacion USING GIN (metadatos_bigdata);
CREATE INDEX idx_evento_iot_gin ON evento USING GIN (ubicacion_iot);
CREATE INDEX idx_telemetria_payload_gin ON telemetria_campus_iot USING GIN (payload_sensor);
CREATE INDEX idx_log_contexto_gin ON log_actividad_bigdata USING GIN (contexto_json);

-- Índices B-Tree compuestos para acelerar consultas por ventanas de tiempo en IoT y Big Data
CREATE INDEX idx_telemetria_sensor_fecha ON telemetria_campus_iot (codigo_sensor, fecha_lectura DESC);
CREATE INDEX idx_log_estudiante_fecha ON log_actividad_bigdata (id_estudiante, fecha_evento DESC);

-- 4. Insercion de datos de prueba(RELACIONALES + JSONB + IoT)

INSERT INTO estudiante (nombre, apellido, correo, password, ultima_actividad, estado, preferencias_json) VALUES
('María Sofía', 'Pabón', 'sofia.pabon@pascualbravo.edu.co', 'pass123', NOW(), 'activo', '{"tema": "oscuro", "notificaciones": ["eventos", "mentorias", "iot_alertas"], "idioma": "es"}'::jsonb),
('Marina', 'Rodríguez', 'marina.rodriguez@pascualbravo.edu.co', 'pass123', NOW(), 'activo', '{"tema": "claro", "notificaciones": ["eventos"], "idioma": "es"}'::jsonb),
('Luna', 'Valencia', 'luna.valencia@pascualbravo.edu.co', 'pass123', NOW(), 'activo', '{"tema": "oscuro", "notificaciones": ["mentorias"], "idioma": "en"}'::jsonb),
('Juan', 'Hincapié', 'juan.hincapie@pascualbravo.edu.co', 'pass123', NOW(), 'activo', '{"tema": "oscuro", "notificaciones": ["iot_alertas", "eventos"], "idioma": "es"}'::jsonb),
('Julieta', 'Rios', 'julieta.rios@pascualbravo.edu.co', 'pass123', NOW(), 'inactivo', '{"tema": "claro", "notificaciones": [], "idioma": "es"}'::jsonb),
('Kevin', 'Gómez', 'kevin.gomez@pascualbravo.edu.co', 'pass123', NOW(), 'activo', '{"tema": "oscuro", "notificaciones": ["eventos", "mentorias"], "idioma": "es"}'::jsonb);

INSERT INTO perfil (id_estudiante, area_estudio, biografia, programa, semestre, ciudad) VALUES
(1, 'Desarrollo de Software', 'Apasionada por las BD y C++', 'Tecnología en Desarrollo de Software', 4, 'Medellín'),
(2, 'Sistemas', 'Interesada en mentorías de bases de datos', 'Ingeniería de Software', 6, 'Medellín'),
(3, 'Inteligencia Artificial', 'Estudiante de IA', 'Tecnología en Desarrollo de Software', 2, 'Envigado'),
(4, 'Electrónica', 'Me gusta la robótica e IoT', 'Ingeniería Electrónica', 5, 'Medellín'),
(6, 'Bases de Datos Avanzadas', 'Monitor de SQL y PostgreSQL', 'Tecnología en Desarrollo de Software', 7, 'Bello');

INSERT INTO habilidad (nombre, descripcion) VALUES
('C++', 'Programación estructurada y POO en C++'),
('PostgreSQL', 'Manejo de SQL DDL, DML y Vistas'),
('Python', 'Análisis de datos y scripts'),
('Diseño UI/UX', 'Figma y diseño de interfaces');

INSERT INTO estudiante_habilidad (id_estudiante, id_habilidad, nivel) VALUES
(1, 1, 'Avanzado'),
(1, 2, 'Intermedio'),
(2, 2, 'Avanzado'),
(4, 3, 'Básico'),
(6, 2, 'Experto');

INSERT INTO interes (nombre, descripcion) VALUES
('Programación Competitiva', 'Entrenamiento para Hackatones'),
('Desarrollo Web', 'Frontend y Backend'),
('Base de Datos', 'Optimización de consultas DML');

INSERT INTO estudiante_interes (id_estudiante, id_interes) VALUES
(1, 1), (1, 3),
(2, 3),
(3, 2),
(6, 1), (6, 3);

-- Publicaciones con metadatos JSONB enriquecidos (hashtags, multimedia, geolocalización)
INSERT INTO publicacion (id_estudiante, contenido, tipo, metadatos_bigdata) VALUES
(1, '¡Bienvenidos a la Red Pascualina!', 'post', '{"dispositivo": "Android", "ip": "192.168.1.1", "hashtags": ["#PascualBravo", "#Bienvenida", "#Software"], "multimedia": {"tiene_imagen": true, "resolucion": "1080p"}}'::jsonb),
(1, 'Revisando temas de PostgreSQL y JSONB para el proyecto final', 'post', '{"dispositivo": "Windows", "ip": "192.168.1.2", "hashtags": ["#PostgreSQL", "#BigData", "#JSONB"], "tiempo_lectura_seg": 45}'::jsonb),
(2, '¿Alguien para estudiar Álgebra Lineal en la biblioteca?', 'pregunta', '{"dispositivo": "iOS", "ip": "192.168.1.3", "hashtags": ["#Estudio", "#Biblioteca"], "ubicacion_campus": "Bloque 10"}'::jsonb),
(3, 'Taller de IoT y sensores inteligentes mañana en el laboratorio', 'evento_info', '{"dispositivo": "Linux", "ip": "192.168.1.4", "hashtags": ["#IoT", "#Electronica", "#PascualBravo"], "multimedia": {"tiene_video": true, "duracion_seg": 120}}'::jsonb);

INSERT INTO comentario (id_publicacion, id_estudiante, comentario) VALUES
(1, 2, '¡Muy interesante!'),
(1, 3, 'Yo iré, sin falta'),
(2, 2, 'Excelente aporte sobre índices GIN'),
(3, 1, 'Yo me apunto para el grupo de estudio');

INSERT INTO reaccion (id_estudiante, id_publicacion, tipo_reaccion) VALUES
(1, 1, 'me_gusta'), (2, 1, 'me_gusta'), (3, 1, 'excelente'), (4, 1, 'me_gusta'),
(1, 2, 'me_gusta'), (2, 2, 'excelente'),
(3, 3, 'me_gusta');

INSERT INTO grupo (creador_id, nombre, descripcion, tipo) VALUES
(1, 'English club', 'Grupo para proyectos de habla inglesa', 'Académico'),
(2, 'Club de Software', 'Estudio de PostgreSQL, Big Data y C++', 'Académico');

INSERT INTO miembro_grupo (id_estudiante, id_grupo, rol) VALUES
(1, 1, 'lider'),
(1, 2, 'miembro'),
(2, 2, 'lider'),
(6, 2, 'miembro');

INSERT INTO evento (organizador, id_grupo, nombre, descripcion, fecha_inicio, fecha_fin, lugar, modalidad, ubicacion_iot) VALUES
(1, 1, 'Hackathon Pascualina 2026', 'Competencia de prototipos', NOW(), NOW() + INTERVAL '5 hours', 'Bloque 8 - Aula 201', 'Presencial', '{"aforo_max": 20, "sensor_id": "SENS-B8-201", "equipamiento": ["proyector_4k", "aire_acondicionado", "red_wifi6"]}'::jsonb),
(2, 2, 'Taller de SQL Avanzado e IoT', 'Creación de vistas y optimización', NOW(), NOW() + INTERVAL '2 hours', 'Bloque 5 - Lab 104', 'Presencial', '{"aforo_max": 35, "sensor_id": "SENS-B5-104", "equipamiento": ["pc_workstations", "pantalla_interactiva"]}'::jsonb);

INSERT INTO asistente_evento (id_estudiante, id_evento, estado) VALUES
(1, 1, 'confirmado'), (2, 1, 'confirmado'), (3, 1, 'confirmado'), (4, 1, 'confirmado'),
(2, 2, 'confirmado'), (6, 2, 'confirmado');

INSERT INTO seguir (id_seguidor, id_seguido) VALUES
(1, 2), (2, 1), (3, 1), (6, 1), (4, 2);

INSERT INTO mentoria (id_mentor, id_aprendiz, tema, estado, fecha_mentoria) VALUES
(6, 1, 'Optimización con Índices GIN en PostgreSQL', 'completada', NOW() - INTERVAL '2 days'),
(2, 3, 'Modelado Entidad-Relación', 'programada', NOW() + INTERVAL '1 day');

-- Inserción de tramas heterogéneas en Telemetría IoT (distintos sensores envían distintas llaves JSON)
INSERT INTO telemetria_campus_iot (id_evento, codigo_sensor, bloque_campus, fecha_lectura, payload_sensor) VALUES
(1, 'SENS-B8-201', 'Bloque 8', NOW() - INTERVAL '30 minutes', '{"tipo": "ambiental_aforo", "personas_detectadas": 18, "temperatura_c": 23.4, "humedad_pct": 58, "alerta_ruido": false}'::jsonb),
(1, 'SENS-B8-201', 'Bloque 8', NOW() - INTERVAL '15 minutes', '{"tipo": "ambiental_aforo", "personas_detectadas": 19, "temperatura_c": 25.1, "humedad_pct": 62, "alerta_ruido": true}'::jsonb),
(2, 'SENS-B5-104', 'Bloque 5', NOW() - INTERVAL '10 minutes', '{"tipo": "laboratorio_energia", "personas_detectadas": 28, "consumo_kwh": 4.75, "equipos_encendidos": 30, "temperatura_c": 21.8}'::jsonb),
(2, 'SENS-B5-104', 'Bloque 5', NOW() - INTERVAL '5 minutes',  '{"tipo": "laboratorio_energia", "personas_detectadas": 31, "consumo_kwh": 5.20, "equipos_encendidos": 32, "temperatura_c": 22.3}'::jsonb),
(NULL, 'SENS-BIB-01', 'Bloque 10 - Biblioteca', NOW(), '{"tipo": "ocupacion_zona", "personas_detectadas": 64, "capacidad_zona": 80, "nivel_ruido_db": 42}'::jsonb);

-- Inserción de flujos de actividad Big Data de estudiantes
INSERT INTO log_actividad_bigdata (id_estudiante, tipo_accion, fecha_evento, contexto_json) VALUES
(1, 'busqueda_academica', NOW() - INTERVAL '1 hour', '{"termino": "indices GIN postgresql", "resultados_vistos": 5, "duracion_seg": 180, "red": "WiFi_Campus"}'::jsonb),
(1, 'registro_asistencia_qr', NOW() - INTERVAL '25 minutes', '{"id_evento": 1, "metodo": "NFC_Carnet", "latencia_ms": 42, "red": "WiFi_Campus"}'::jsonb),
(2, 'busqueda_academica', NOW() - INTERVAL '40 minutes', '{"termino": "arquitectura hibrida nosql", "resultados_vistos": 8, "duracion_seg": 310, "red": "Datos_Moviles"}'::jsonb),
(3, 'visualizacion_multimedia', NOW() - INTERVAL '20 minutes', '{"id_publicacion": 4, "porcentaje_visto": 95, "duracion_seg": 114, "red": "WiFi_Campus"}'::jsonb),
(6, 'descarga_material', NOW() - INTERVAL '10 minutes', '{"archivo": "guia_jsonb.pdf", "tamano_kb": 1450, "duracion_seg": 12, "red": "WiFi_Campus"}'::jsonb);


-- 5. Vistas hibridas (INTEGRANDO RELACIONAL + JSONB + IoT)
CREATE OR REPLACE VIEW vw_analitica_iot_eventos AS
SELECT 
    ev.id_evento,
    ev.nombre AS evento,
    ev.lugar,
    ev.ubicacion_iot->>'sensor_id' AS sensor_asignado,
    (ev.ubicacion_iot->>'aforo_max')::INT AS aforo_maximo_configurado,
    COUNT(t.id_lectura) AS total_tramas_recibidas,
    ROUND(AVG((t.payload_sensor->>'personas_detectadas')::NUMERIC), 1) AS promedio_personas_iot,
    ROUND(AVG((t.payload_sensor->>'temperatura_c')::NUMERIC), 2) AS temperatura_promedio_c
FROM evento ev
LEFT JOIN telemetria_campus_iot t ON ev.id_evento = t.id_evento
GROUP BY ev.id_evento, ev.nombre, ev.lugar, ev.ubicacion_iot;
SELECT * FROM vw_analitica_iot_eventos;

-- 6.Consultas DML analíticas sobre datos semiestructurados (JSONB) E IoT
-- Consulta 1: (IoT + JOIN + Agregación): Monitoreo de ocupación real por sensores vs aforo máximo
-- Responde: ¿Cual es el promedio y el pico maximo de personas detectadas por sensores IoT en cada evento y que porcentaje del aforo real está siendo ocupado?
SELECT 
    ev.nombre AS nombre_evento,
    t.bloque_campus,
    t.codigo_sensor,
    (ev.ubicacion_iot->>'aforo_max')::INT AS aforo_maximo,
    MAX((t.payload_sensor->>'personas_detectadas')::INT) AS pico_asistentes_iot,
    ROUND(AVG((t.payload_sensor->>'temperatura_c')::NUMERIC), 1) AS temp_media_c,
    ROUND((MAX((t.payload_sensor->>'personas_detectadas')::NUMERIC) / (ev.ubicacion_iot->>'aforo_max')::NUMERIC) * 100, 2) AS porcentaje_ocupacion_real
FROM evento ev
INNER JOIN telemetria_campus_iot t ON ev.id_evento = t.id_evento
GROUP BY ev.id_evento, ev.nombre, t.bloque_campus, t.codigo_sensor, ev.ubicacion_iot
ORDER BY porcentaje_ocupacion_real DESC;


-- Consulta 2 (Operador de contención JSONB '@>' optimizado con indice GIN):
-- Responde: ¿Que eventos activos cuentan con 'aire_acondicionado' en su arreglo JSON de equipamiento y han generado alertas de ruido en las lecturas de telemetría IoT?
SELECT 
    ev.id_evento,
    ev.nombre AS evento,
    ev.lugar,
    t.fecha_lectura,
    t.payload_sensor->>'personas_detectadas' AS personas_en_sala,
    t.payload_sensor->>'temperatura_c' AS temperatura
FROM evento ev
INNER JOIN telemetria_campus_iot t ON ev.id_evento = t.id_evento
WHERE ev.ubicacion_iot @> '{"equipamiento": ["aire_acondicionado"]}'::jsonb
  AND t.payload_sensor @> '{"alerta_ruido": true}'::jsonb;
  
-- Consulta 3 (muestra de arreglos JSON con jsonb_array_elements_text + Agregacion):
-- Responde: ¿Cuales son los hashtags más utilizados dentro de los metadatos JSONB de las publicaciones y cuantas reacciones totales acumulan las publicaciones que los contienen?
SELECT 
    hashtag,
    COUNT(DISTINCT p.id_publicacion) AS total_publicaciones,
    COUNT(r.id_estudiante) AS total_reacciones_generadas
FROM publicacion p
CROSS JOIN LATERAL jsonb_array_elements_text(p.metadatos_bigdata->'hashtags') AS hashtag
LEFT JOIN reaccion r ON p.id_publicacion = r.id_publicacion
GROUP BY hashtag
ORDER BY total_reacciones_generadas DESC, total_publicaciones DESC;


-- Consulta 4 (Analítica Big Data de Logs + JOIN con Perfil Estudiantil + SUM/AVG):
-- Responde: ¿Que estudiantes generan mayor tráfico de actividad en la red WiFi del campus, sumando el tiempo total de interaccion (en segundos) extraído del JSON de logs?
SELECT 
    e.id_estudiante,
    e.nombre || ' ' || e.apellido AS estudiante,
    pr.programa,
    pr.semestre,
    COUNT(l.id_log) AS total_eventos_registrados,
    SUM((l.contexto_json->>'duracion_seg')::INT) AS tiempo_total_segundos,
    ROUND(AVG((l.contexto_json->>'duracion_seg')::NUMERIC), 1) AS promedio_segundos_por_accion
FROM estudiante e
INNER JOIN perfil pr ON e.id_estudiante = pr.id_estudiante
INNER JOIN log_actividad_bigdata l ON e.id_estudiante = l.id_estudiante
WHERE l.contexto_json->>'red' = 'WiFi_Campus'
GROUP BY e.id_estudiante, e.nombre, e.apellido, pr.programa, pr.semestre
HAVING SUM((l.contexto_json->>'duracion_seg')::INT) > 100
ORDER BY tiempo_total_segundos DESC;


-- Consulta 5 (Operador de existencia de llave '?' en JSONB heterogéneo + SUM):
-- Responde: ¿Cual es el consumo energético total (kWh) y promedio de equipos encendidos en las lecturas IoT que reportan los laboratorios ('consumo_kwh')?
SELECT 
    codigo_sensor,
    bloque_campus,
    COUNT(*) AS cantidad_mediciones,
    SUM((payload_sensor->>'consumo_kwh')::NUMERIC) AS consumo_total_kwh,
    ROUND(AVG((payload_sensor->>'equipos_encendidos')::NUMERIC), 0) AS promedio_equipos_activos
FROM telemetria_campus_iot
WHERE payload_sensor ? 'consumo_kwh'
GROUP BY codigo_sensor, bloque_campus;
