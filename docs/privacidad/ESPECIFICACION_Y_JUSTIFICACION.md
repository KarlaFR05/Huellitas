# Especificación y justificación del Aviso de Privacidad de Huellitas

**Fecha del análisis:** 3 de septiembre de 2026  
**Documento asociado:** `POLITICA_DE_PRIVACIDAD.md`

## 1. Propósito y alcance de este documento

Este documento explica por qué cada bloque del aviso existe, qué tratamiento real del código lo sustenta y qué trabajo falta para que Huellitas pueda afirmar cumplimiento operativo. No sustituye la revisión de una persona profesional del derecho ni convierte por sí solo las prácticas técnicas en conformes.

La referencia principal es la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP) publicada el 20 de marzo de 2025 y reformada por última vez el 14 de noviembre de 2025. También se consideró el Reglamento vigente en aquello que resulte aplicable.

## 2. Base normativa de la estructura

El artículo 15 de la LFPDPPP exige, como mínimo, identidad y domicilio del responsable; datos tratados, incluidos los sensibles; finalidades; opciones para limitar uso o divulgación; mecanismos ARCO; y procedimiento para comunicar cambios. Los artículos 14 y 16 exigen informar las características principales del tratamiento y poner el aviso a disposición al recabar datos por medios electrónicos.

El Reglamento señala que el aviso debe ser sencillo, necesario, claro y estructurado para facilitar su comprensión. Por eso la pantalla y el documento se dividen por temas y usan listas breves en lugar de un bloque jurídico continuo.

## 3. Inventario técnico que sustenta el aviso

### Cuenta, identidad y perfil

El backend registra correo, contraseña con hash bcrypt, nombre, apellidos, nombre de usuario, teléfono, nacimiento, domicilio, rol y verificación. El flujo de perfil puede almacenar identificación frontal, reverso y selfie en Supabase Storage. Esto justifica las secciones de identificación, contacto, domicilio, imágenes, seguridad y datos de protección reforzada.

### Ubicación y reportes

Android solicita ubicación fina y aproximada; iOS declara ubicación durante el uso. El backend guarda coordenadas actuales y la hora de actualización, usa ubicaciones recientes para notificaciones y registra ubicación, coordenadas y evidencias en reportes. Esto exige explicar finalidad, permiso, visibilidad y riesgos de ubicación precisa.

### Comunidad

El foro trata publicaciones, imágenes, comentarios, reacciones, grupos, membresías y perfiles. Parte del contenido está diseñado para ser visible a otras personas, por lo que el aviso distingue publicación voluntaria de tratamiento interno y advierte sobre datos de terceros en texto e imágenes.

### Adopciones

El flujo guarda preguntas, respuestas, puntuaciones, insignias, estados, adoptante seleccionado y contactos. El backend separa el contacto de las respuestas evaluables, lo oculta durante el ranking y lo revela bilateralmente después de completar la adopción. Esta regla técnica sustenta la sección específica de visibilidad.

La evaluación usa Hugging Face para analizar respuestas y pondera resultados con insignias; la decisión final la toma el responsable. Se documenta como asistencia automatizada, no como decisión exclusivamente automatizada.

### Organizaciones, donaciones y tarjetas

Se tratan datos legales y de contacto de organizaciones, cuentas bancarias, montos e historial de donación. El módulo de tarjetas recibe número, titular, vencimiento y CVV; almacena el número cifrado y enmascarado, pero no persiste CVV. Son datos financieros o patrimoniales y, conforme al artículo 7 de la Ley, requieren consentimiento expreso.

### Notificaciones y comunicaciones

El backend registra notificaciones por usuario y el frontend envía un token FCM al servidor. Brevo entrega códigos de verificación por correo. Esto justifica identificar tokens y proveedores de comunicación.

### Proveedores e internacionalización

El código y configuración evidencian Supabase, Render, Brevo, Hugging Face y Roboflow. Pueden actuar como encargados y procesar datos fuera de México. Los artículos 35 y 36 regulan transferencias; el aviso diferencia encargados operativos de transferencias a terceros y exige limitar datos y documentar contratos.

## 4. Correspondencia entre secciones y obligaciones

| Sección del aviso | Razón jurídica u operativa |
| --- | --- |
| Responsable y domicilio | Elemento obligatorio; artículo 15, fracción I. |
| Categorías de datos | Transparencia y señalamiento de sensibles; artículo 15, fracción II. |
| Finalidades | Limitación por finalidad y distinción del consentimiento; artículos 11 y 15, fracción III. |
| Visibilidad | Lealtad, expectativa razonable de privacidad y control de divulgación. |
| Automatización | Derecho de oposición frente a ciertos tratamientos automatizados; artículo 26. |
| Permisos | Consentimiento informado y proporcionalidad respecto de cámara, fotos y ubicación. |
| Proveedores y transferencias | Información y obligaciones para transferencias; artículos 35 y 36. |
| Conservación | Calidad, bloqueo y supresión cuando los datos dejan de ser necesarios; artículo 10 y artículos 24–25. |
| Seguridad e incidentes | Medidas administrativas, técnicas y físicas y aviso de vulneraciones; artículos 18–20. |
| Derechos ARCO | Artículos 21–34; respuesta en veinte días y ejecución en quince días si procede. |
| Cambios al aviso | Artículo 15, fracción VI. |
| Consentimiento expreso | Datos financieros/patrimoniales y sensibles; artículos 7 y 8. |

## 5. Decisiones de redacción

- Se usa “aviso integral y política” porque la pantalla debe cumplir el deber informativo y, al mismo tiempo, explicar prácticas de privacidad en lenguaje accesible.
- No se afirma que Huellitas sea anónima ni que nunca comparta información: existen funciones públicas y proveedores necesarios.
- No se promete seguridad absoluta; se describen medidas verificables y obligación de respuesta.
- No se inventan periodos exactos de conservación porque el repositorio no implementa una matriz de retención. Se usan criterios legales y se registra esta ausencia como tarea pendiente.
- No se afirma que el CVV se almacena, porque el servicio lo valida pero no lo persiste.
- Se aclara que el contacto de adopción es privado porque existen controles concretos en API y base de datos.
- No se declara uso publicitario, analítica comportamental ni venta porque no se encontraron SDK o flujos que lo hagan.

## 6. Pendientes obligatorios antes de publicación

1. Sustituir nombre o razón social, domicilio, correo de privacidad y medios ARCO.
2. Designar formalmente a la persona o área que atenderá solicitudes.
3. Definir y aprobar una tabla de conservación por categoría y proceso de eliminación/bloqueo.
4. Implementar o documentar un procedimiento verificable de cancelación de cuenta y datos.
5. Obtener consentimiento expreso, separado y registrable antes de guardar tarjetas, cuentas bancarias, identificaciones y cualquier dato sensible.
6. Revisar contratos y términos de Supabase, Render, Brevo, Hugging Face, Roboflow y notificaciones; documentar regiones, subencargados y transferencias.
7. Confirmar si las evidencias y documentos de identificación se almacenan en buckets públicos. Deben ser privados y usar accesos temporales autorizados.
8. Establecer una política de menores y control efectivo de edad/consentimiento parental; actualmente se captura fecha de nacimiento pero no se encontró un control suficiente.
9. Añadir el aviso simplificado y consentimiento en el punto de registro y antes de tratamientos sensibles, no únicamente como enlace desde Perfil.
10. Mantener evidencia de versiones del aviso y del consentimiento aceptado por cada usuario.
11. Definir respuesta a incidentes, responsables, canales y registro de vulneraciones.
12. Evaluar cumplimiento de seguridad de tarjetas. Guardar números completos cifrados implica obligaciones técnicas y contractuales adicionales; debe preferirse tokenización mediante un proveedor de pagos compatible y nunca almacenar CVV.

## 7. Riesgos detectados que una política no corrige

- No se encontró endpoint de eliminación de cuenta ni flujo ARCO implementado.
- No existe un calendario técnico de retención o purga general.
- Algunos buckets obtienen URL pública; documentos de identidad y evidencias requieren revisión de configuración real en Supabase.
- El backend usa una clave global de Supabase y la eficacia de RLS no puede confirmarse solo desde el repositorio.
- Las funciones de IA envían texto o imágenes a proveedores; deben aplicarse minimización, revisión contractual y exclusión de datos innecesarios.
- La implementación propia de tarjetas debe someterse a una evaluación especializada de seguridad y cumplimiento del sector de pagos.
- No se observó registro versionado del consentimiento al aviso.

Publicar un texto correcto sin corregir estos puntos puede crear una diferencia entre lo prometido y la operación real, contraria a los principios de lealtad y responsabilidad.

## 8. Validación recomendada

Antes de liberar la política:

1. Revisión jurídica bajo legislación mexicana y mercados donde se distribuirá la app.
2. Revisión técnica de cada afirmación contra producción, Supabase y contratos.
3. Prueba de solicitudes ARCO de extremo a extremo.
4. Prueba de privacidad de perfiles, grupos, reportes y contactos de adopción.
5. Revisión de permisos y fichas de privacidad de Google Play y App Store.
6. Revisión cada vez que se incorpore un proveedor, dato, finalidad o país.

## 9. Fuentes oficiales consultadas

- [Cámara de Diputados: LFPDPPP vigente, última reforma DOF 14-11-2025](https://www.diputados.gob.mx/LeyesBiblio/pdf/LFPDPPP.pdf).
- [Orden Jurídico Nacional: texto electrónico de la LFPDPPP](https://www.ordenjuridico.gob.mx/Documentos/Federal/html/wo125102.html).
- [Orden Jurídico Nacional: Reglamento de la LFPDPPP](https://www.ordenjuridico.gob.mx/Documentos/Federal/html/wo88475.html).
- [Secretaría Anticorrupción y Buen Gobierno](https://www.gob.mx/buengobierno).

