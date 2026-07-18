import 'package:flutter/material.dart';

class PreguntasFrecuentesScreen extends StatelessWidget {
  const PreguntasFrecuentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preguntas frecuentes")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExpansionTile(
            leading: const Icon(Icons.pets),
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
                            ". Ahora puedes dar click en el botón verde que dice 'Realizar Reporte', el cual se encuentra justo arriba de la barra de navegación. Completa la información solicitada para cada uno de los campos, si tienes alguna duda puedes dar click en el botón de información ",
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
                            "No olvides dar acceso a usar tu ubicación actual, esto es únicamente para conocer una ubicación aproximada del animal que se esta reportando. Tampoco olvides adjuntar una evidencia, puedes tomas una fotografía en ese instante o subir una desde tu galería de fotos. Una vez completada toda la información requerida, da click en el botón de enviar reportes\n"
                            "¡Felicidades! Haz creado con éxito un reporte. Ahora tú y cualquier usuario más de Huellitas podrán ver en el mapa un marcador con el nivel de urgencia y con un radio de 180 metros.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const ExpansionTile(
            leading: Icon(Icons.location_on),
            title: Text(
              "\n¿Qué significan los colores y marcadores en el mapa?",
            ),
            children: [
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
                  "También puedes dar click en el marcador, este te mostrará la información que el usuario relleno cuando realizo el reporte. Encontrarás un botón sobre la imagen en la parte superior derecha que dice 'Ver', el cual te permitirá visualizar con más detalle la foto de evidencia.\n"
                  "Además puedes seguir en tiempo real las actualizaciones y el estado del rescate, dando click en el botón de 'Ver estado del reporte'.",
                ),
              ),
            ],
          ),

          const ExpansionTile(
            leading: Icon(Icons.edit),
            title: Text("¿Puedo realizar el rescate de un reporte?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Por su puesto. Cualquier usuario registrado en Huellitas puede realizar los rescates.\n"
                  "¿Cómo hacerlo?\n"
                  "Debes seleccionar el marcador del reporte que quieres realizar, dar click en el botón 'Ver estado del reporte' y posteriormente te enviará a otra pantalla en la cual puedes identificar dos botones, debes dar click el botón que dice 'Tomar caso', te aparecerá un mensaje de éxito que te hace saber que ahora eres el encargado de realizar el rescate.\n"
                  "",
                ),
              ),
            ],
          ),

          const ExpansionTile(
            leading: Icon(Icons.edit),
            title: Text("¿Puedo ver las actualizaciones de un reporte?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Sí. Cualquier usuario registrado en Huellitas puedes ver y seguir las actualizaciones de los reportes, pero con una única excepción, los reportes que se encuentren con una clasificación de Tipo de Reporte como 'Maltrato Animal', no pueden ser vísibles para todos los usuarios comúnes, únicamenta para usuarios verificados, ya que estos reportes son realizados para animales que estan recibiendo un maltrato dentro de un domicilio privado y no podemos dejar este tipo de información pública a todos nuestros usuarios.\n"
                  "\n"
                  "Lo que vas a encontrar cuando quieras ver las actualizaciones de un reporte es lo siguiente:\n"
                  "• En la parte superior encontrarás los estados en los que se encuentra el rescate, que esta divida en tres fases y se pintarán conforme el rescatista actualice el estado del rescate.\n"
                  "• Podrás visualizar información relevante acerca del rescate que se esta realizando, si gustas ver más información puedes dar click en el botón de 'Ver más sobre el rescate', donde estarán más detalles y las actualizaciones, lo que incluye una descripción y una foto de evidencia.\n"
                  "• También puedes conocer el nombre y el perfil del usuario que esta realizando el rescate, solo tienes que dar click en 'Ver perfil' que se encuentra justo debajo del nombre del usuario.",
                ),
              ),
            ],
          ),

          const ExpansionTile(
            leading: Icon(Icons.verified_user),
            title: Text("¿Por qué debo verificar mi identidad?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "La verificación ayuda a prevenir revelar información privada sobre reportes criticos y mejorar la seguridad de la comunidad.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
