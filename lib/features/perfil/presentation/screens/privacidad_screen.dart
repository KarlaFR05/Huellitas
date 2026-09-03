import 'package:flutter/material.dart';

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  static const _responsable = '[NOMBRE O RAZÓN SOCIAL DEL RESPONSABLE]';
  static const _domicilio = '[DOMICILIO COMPLETO DEL RESPONSABLE]';
  static const _correo = '[CORREO DE PRIVACIDAD Y SOLICITUDES ARCO]';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidad')),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: const [
            _Encabezado(),
            SizedBox(height: 16),
            _AvisoBorrador(),
            _Seccion(
              titulo: '1. Responsable',
              texto:
                  '$_responsable, con domicilio en $_domicilio, es responsable '
                  'del tratamiento realizado mediante Huellitas, su API y sus '
                  'servicios relacionados. El área de datos personales puede '
                  'ser contactada en $_correo.',
            ),
            _Seccion(
              titulo: '2. Datos que tratamos',
              items: [
                'Cuenta e identidad: nombre, apellidos, usuario, nacimiento, rol, contraseña protegida e identificadores.',
                'Contacto y perfil: correo, teléfono, domicilio, ciudad, estado, fotografía o avatar.',
                'Ubicación: dirección, coordenadas y fecha de actualización cuando otorgas permiso.',
                'Imágenes y verificación: perfil, publicaciones, animales, reportes, identificación oficial y selfie.',
                'Comunidad y reportes: publicaciones, comentarios, reacciones, grupos, evidencia, ubicación e historial.',
                'Adopciones: publicación, preguntas, respuestas, puntuación de apoyo, estado, adoptante y contactos privados.',
                'Organizaciones y donaciones: información legal, contacto institucional, cuentas, montos e historial.',
                'Tarjetas: titular, número cifrado y enmascarado, vencimiento y tipo. El CVV no se almacena actualmente.',
                'Datos técnicos: tokens de sesión y notificaciones, fechas de operación y registros de seguridad.',
              ],
              cierre:
                  'La identificación, selfie y ubicación precisa reciben '
                  'protección reforzada. Los datos financieros o patrimoniales '
                  'requieren consentimiento expreso.',
            ),
            _Seccion(
              titulo: '3. Para qué usamos los datos',
              items: [
                'Crear, autenticar, mantener y proteger cuentas.',
                'Verificar correo, identidad u organización.',
                'Operar perfiles, comunidad, grupos y publicaciones.',
                'Crear, localizar y dar seguimiento a reportes de animales.',
                'Gestionar adopciones, postulaciones y resultados.',
                'Intercambiar contactos solo entre responsable y adoptante seleccionado.',
                'Registrar donaciones, métodos de pago y organizaciones.',
                'Enviar códigos, avisos operativos y notificaciones.',
                'Prevenir abuso, fraude y accesos no autorizados, y atender obligaciones legales.',
              ],
              cierre:
                  'Huellitas no vende datos personales ni los utiliza actualmente '
                  'para publicidad comportamental o mercadotecnia de terceros.',
            ),
            _Seccion(
              titulo: '4. Visibilidad y adopciones',
              texto:
                  'Según la función pueden ser visibles tu usuario, avatar, '
                  'publicaciones, comentarios, grupos públicos, organizaciones '
                  'y elementos necesarios de reportes o adopciones. Evita '
                  'publicar datos de terceros sin autorización.',
              items: [
                'El contacto del postulante no se muestra ni puntúa durante la evaluación.',
                'Al completarse la adopción, el responsable ve solo el contacto del seleccionado.',
                'El seleccionado ve el contacto proporcionado por el responsable.',
                'Personas rechazadas y terceros no reciben esos contactos mediante el flujo de adopción.',
              ],
            ),
            _Seccion(
              titulo: '5. Automatización y permisos',
              texto:
                  'Usamos herramientas para sugerir preguntas, calcular '
                  'indicadores de apoyo y comparar reportes por texto e imágenes. '
                  'La decisión final de adopción la toma una persona. Puedes '
                  'administrar ubicación, cámara, fotos y notificaciones desde '
                  'los ajustes del dispositivo; negar un permiso puede impedir '
                  'la función que lo necesita.',
            ),
            _Seccion(
              titulo: '6. Proveedores',
              texto:
                  'Pueden intervenir Supabase (datos y almacenamiento), Render '
                  '(API), Brevo (correo), Hugging Face (texto), Roboflow '
                  '(imágenes) y servicios de notificaciones. Pueden procesar '
                  'datos fuera de México. Limitaremos la información a lo '
                  'necesario y exigiremos tratamiento conforme a nuestras '
                  'instrucciones. También podremos comunicar datos por obligación '
                  'legal u orden de autoridad competente.',
            ),
            _Seccion(
              titulo: '7. Conservación y seguridad',
              texto:
                  'Conservamos datos mientras la cuenta esté activa y durante el '
                  'tiempo necesario para prestar funciones, atender '
                  'responsabilidades y cumplir la ley. Después se bloquearán y '
                  'eliminarán o anonimizarán. Aplicamos autenticación, controles '
                  'de acceso, cifrado y enmascaramiento de tarjetas y restricciones '
                  'para contactos privados. Ningún sistema es infalible. Si una '
                  'vulneración afecta significativamente tus derechos, te '
                  'informaremos sin demora mediante los medios disponibles.',
            ),
            _Seccion(
              titulo: '8. Derechos ARCO',
              texto:
                  'Puedes solicitar Acceso, Rectificación, Cancelación u Oposición, '
                  'revocar el consentimiento o limitar usos mediante $_correo. '
                  'Incluye nombre, medio de respuesta, acreditación de identidad, '
                  'datos involucrados, derecho solicitado y elementos para '
                  'localizarlos. Responderemos en un máximo de 20 días y, si '
                  'procede, actuaremos dentro de los 15 días siguientes. Los '
                  'plazos pueden ampliarse una vez por un periodo igual cuando '
                  'las circunstancias lo justifiquen.',
            ),
            _Seccion(
              titulo: '9. Menores, cambios y consentimiento',
              texto:
                  'Las personas menores no deben proporcionar por sí solas '
                  'identificación, datos financieros o sensibles; requieren '
                  'intervención y autorización verificable de quien ejerza patria '
                  'potestad o tutela. Los cambios al aviso se publicarán aquí y, '
                  'si son sustanciales, se comunicarán por un medio destacado. '
                  'Cuando la ley exija consentimiento expreso, Huellitas deberá '
                  'solicitarlo por separado antes del tratamiento.',
            ),
            _Seccion(
              titulo: '10. Contacto y autoridad',
              texto:
                  'Envía dudas o quejas a $_correo. También puedes acudir a la '
                  'autoridad mexicana competente. A la fecha de esta versión, la '
                  'ley identifica a la Secretaría Anticorrupción y Buen Gobierno '
                  'como autoridad federal en protección de datos personales.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: colors.primary, size: 38),
          const SizedBox(height: 12),
          Text(
            'Aviso integral de privacidad',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Conoce qué información utiliza Huellitas, para qué la necesita '
            'y cómo puedes ejercer control sobre ella.',
          ),
          const SizedBox(height: 12),
          Text(
            'Versión 1.0 · 3 de septiembre de 2026',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoBorrador extends StatelessWidget {
  const _AvisoBorrador();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Borrador: antes de publicar deben completarse la identidad, '
              'domicilio y correo real del responsable.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    this.texto,
    this.items = const [],
    this.cierre,
  });

  final String titulo;
  final String? texto;
  final List<String> items;
  final String? cierre;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (texto != null) ...[
            Text(texto!, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 8),
          ],
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.45)),
                  ),
                ],
              ),
            ),
          if (cierre != null)
            Text(cierre!, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 12),
          Divider(color: colors.outlineVariant),
        ],
      ),
    );
  }
}
