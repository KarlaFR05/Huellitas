import 'package:flutter/material.dart';

class PreguntasFrecuentesScreen extends StatelessWidget {
  const PreguntasFrecuentesScreen({super.key});

  Widget _buildLeadingIcon(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preguntas frecuentes")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExpansionTile(
            leading: _buildLeadingIcon(context, Icons.pets),
            title: const Text("¿Cómo puedo reportar un animal?"),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "Ubícate en la pantalla principal, la podrás identificar en nuestra barra de navegación inferior ya que cuenta con un icono de una casa ",
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.home_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ". Ahora puedes dar click en el botón verde que dice 'Realizar Reporte', el cual se encuentra justo arriba de la barra de navegación.\n"
                            "Completa la información solicitada para cada uno de los campos, si tienes alguna duda puedes dar click en el botón de información ",
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const TextSpan(
                        text:
                            " para que puedas conocer más a detalle a que se refiere el campo respectivo y que información se solicita.\n"
                            "No olvides dar acceso a usar tu ubicación actual, esto es únicamente para conocer una ubicación aproximada del animal que se esta reportando. Tampoco olvides adjuntar una evidencia, puedes tomas una fotografía en ese instante o subir una desde tu galería de fotos. Una vez completada toda la información requerida, da click en el botón de 'Enviar reporte'\n"
                            "¡Felicidades! Haz creado con éxito un reporte. Ahora tú y cualquier usuario más de Huellitas podrán ver en el mapa un marcador con el nivel de urgencia y con un radio de 180 metros.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: _buildLeadingIcon(context, Icons.location_on),
            title: const Text(
              "¿Qué significan los colores y marcadores en el mapa?",
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Habrás notado que el mapa cuenta con 5 tipos de marcadores, los cuáles se describen con los siguientes colores:\n"
                  "\n"
                  "• Rojo intenso: Prioridad crítica.\n"
                  "• Rojo: Prioridad alta.\n"
                  "• Naranja: Prioridad media.\n"
                  "• Amarillo: Prioridad baja.\n"
                  "• Verde: Animal rescatado.\n"
                  "\n"
                  "Todos los marcadores cuentan con un radio de 180 metros, el cual establece un radio aproximado en el cual el animal puede ser encontrado, ya que el marcador es el punto donde fue visto el animal por última vez y puede ser que este ya no se encuentre ahí mismo dentro de los próximos minutos u horas.\n"
                  "También puedes dar click en el marcador, este te mostrará la información que el usuario relleno cuando realizo el reporte. En la parte superior derecha encontrarás un botón sobre la imagen que dice 'Ver', el cual te permitirá visualizar la foto de evidencia por completo.\n"
                  "Además puedes seguir en tiempo real las actualizaciones y el estado del rescate, dando click en el botón de 'Ver estado del reporte'.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: _buildLeadingIcon(
              context,
              Icons.volunteer_activism_outlined,
            ),
            title: const Text("¿Puedo realizar el rescate de un reporte?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Por su puesto. Cualquier usuario registrado en Huellitas puede realizar los rescates.\n"
                  "\n"
                  "¿Cómo hacerlo?\n"
                  "Debes seleccionar el marcador del reporte que quieres realizar, dar click en el botón 'Ver estado del reporte' y posteriormente te enviará a otra pantalla en la cual puedes identificar dos botones, debes dar click en el botón que dice 'Tomar caso', te aparecerá un mensaje de confirmación, una vez confirmada tu decisión te aparecerá un mensaje de éxito que te hace saber que ahora eres el encargado de realizar el rescate.\n"
                  "¡Listo! Ahora podrás realizar el rescate del animal, por lo cual te pedimos total responsabilidad al realizar el rescate y actualizar el estado agregando descripciones de la fase en la que te encuentras y su respectiva foto de evidencia, con el objetivo de mantener informado a cualquier usuario de Huellitas interesado.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: _buildLeadingIcon(context, Icons.update_outlined),
            title: const Text("¿Puedo ver las actualizaciones de un reporte?"),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Sí. Cualquier usuario registrado en Huellitas puedes ver y seguir las actualizaciones de los reportes, pero con una única excepción, los reportes que se encuentren con una clasificación de Tipo de Reporte como 'Maltrato Animal', no pueden ser vísibles para todos los usuarios comúnes, únicamenta para usuarios verificados, ya que estos reportes son realizados para animales que estan recibiendo un maltrato dentro de un domicilio privado y no podemos dejar este tipo de información pública a todos nuestros usuarios.\n"
                  "\n"
                  "Lo que vas a encontrar cuando quieras ver las actualizaciones de un reporte es lo siguiente:\n"
                  "• En la parte superior encontrarás los estados en los que se encuentra el rescate, que esta divida en tres fases y se pintarán conforme el rescatista actualice el estado del rescate.\n"
                  "• Podrás visualizar la información que el usuario agrego cuando realizo el reporte, si gustas ver más información puedes dar click en el botón de 'Ver más sobre el rescate', donde estarán más detalles lo que también incluye la respectiva descripción y foto de evidencia de la actualización por parte del rescatista.\n"
                  "• También puedes conocer el nombre y el perfil del usuario que esta realizando el rescate, solo tienes que dar click en 'Ver perfil' que se encuentra justo debajo del nombre del usuario.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: _buildLeadingIcon(context, Icons.verified_user_outlined),
            title: const Text(
              "¿Por qué debo verificar mi identidad y cómo puedo hacerlo?",
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "La verificación ayuda a prevenir revelar información privada sobre reportes de maltrato animal en domicilios privados y mejorar la seguridad de la comunidad.\n"
                  "Por lo cual si eres un usuario que desea realizar rescates a animales en domicilios privados debes deberás identificar tu identidad y proporcionar tus datos de dirección. No te preocupes tus datos estarán a salvo y no serán publicados por ningún medio, ya que el objetivo de esto es conocer qué usuario está realizando qué rescate y en qué domicilio.\n"
                  "La forma en que puedas ser un usuario verificado es la siguiente.\n"
                  "Con la barra de navegación que se encuentra en la parte inferior, dirigite dando click en el botón que tiene el icono de usuario"
                  " una vez que estes ahí, justo debajo de tu foto de perfil podrás ver un botón que dice 'Completar perfil', da click en ese botón y completa los datos que se te piden:\n"
                  "• Datos de dirección.\n"
                  "• Foto de tu identificación oficial por la parte frontal.\n"
                  "• Foto de tu identificación oficial por la parte trasera.\n"
                  "• Selfie de ti sosteniendo tu identificación oficial por la parte frontal.\n"
                  "Una vez que hayas conluido con todos estos datos tendrás que esperar a la validación por parte de Huellitas para ser usuario verificado, verás un mensaje justo debabajo de tu foto de perfil que te hará mención a que tu verificación se esta validando y una vez que haya sido validada en ese mismo lugar tendrás un mensaje de éxito.\n"
                  "¡Felicidades ahora eres usuario verificado de Huellitas! Puedes realizar rescates de reportes de domicilios privados, por lo cual te pedimos no publicar información privada y mantener las actualizaciones de las fases de rescate con sus debidas fotos de evidencia.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: _buildLeadingIcon(
              context,
              Icons.workspace_premium_outlined,
            ),
            title: const Text(
              "¿Qué son las insignias y cómo puedo obtenerlas?",
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Las insignias podrás obtenerlas realizando cualquiera de las siguientes tres cosas:\n"
                  "• Realizando reportes.\n"
                  "• Realizando rescates\n"
                  "• Realizando donaciones.\n"
                  "Las insignias nos permiten conocer tu historial como usuario de Huellitas, es importante ya que los usuarios que deseen dar en adopción a una mascota les puede ayudar como referencia inicial. Pero no te preocupes por realizar la mayor cantidad de reportes, donaciones o rescates, lo importante es que seas un usuario que realmente lo hace por ayudar de cualquier forma posible. Todos los usuarios de Huellitas y los animales agradecen tu ayuda.\n",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
