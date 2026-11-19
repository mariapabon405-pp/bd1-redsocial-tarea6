# Tarea 6 - Arquitectura de Base de Datos Híbrida (SQL + NoSQL/JSONB + IoT)

**Estudiante:** María Sofía Pabón Pabón  
**Asignatura:** Bases de Datos I (G101)  
**Institución:** Institución Universitaria Pascual Bravo  
**Motor de Base de Datos:** PostgreSQL 17  

---

## Descripción del Proyecto

Diseño e implementación de una **arquitectura de base de datos híbrida** para la red social universitaria **Comunicación Pascualina**, integrando el modelo relacional tradicional (15 tablas normalizadas) con flujos masivos de **Big Data** y dispositivos **IoT** mediante el tipo de dato nativo `JSONB` (17 tablas en total). 

El sistema combina integridad referencial estricta para la gestión académica con almacenamiento flexible e indexación avanzada (`GIN` y `B-Tree` compuestos) para procesar lecturas de sensores inteligentes del campus y registros de actividad en tiempo real.

---

## Estructura del Repositorio

Todos los entregables de la entrega final se encuentran organizados dentro de la carpeta **`tarea 6/`**:

* **`Script_Tarea6.sql`:** Script completo en PostgreSQL 17 con la creación de las 17 tablas híbridas, índices `GIN` y `B-Tree`, datos de prueba, vista analítica y 5 consultas DML sobre campos `JSONB`.
* **`Informe_Tarea6_Final.pdf`:** Documento técnico detallado con la justificación arquitectónica, explicación de las consultas, capturas de ejecución en pgAdmin, análisis de dificultades/ventajas/desventajas, conclusiones y diagrama Entidad-Relación final.
* **`Inventario Campos_6.pdf`:** Diccionario de datos completo con el inventario de las 17 tablas, diferenciando los campos relacionales (`SQL`) y los campos semiestructurados (`JSONB`), y y inventario de consultas SQL 
* **`video/`:** Carpeta con el enlace directo a la sustentación en YouTube explicando la solución y las conclusiones individuales.

