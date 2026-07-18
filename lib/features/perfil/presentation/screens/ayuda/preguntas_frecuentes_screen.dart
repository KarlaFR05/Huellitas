import 'package:flutter/material.dart';

class PreguntasFrecuentesScreen extends StatelessWidget {
  const PreguntasFrecuentesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preguntas frecuentes"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          ExpansionTile(
            leading: Icon(Icons.pets),
            title: Text("¿Cómo reporto un animal?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Desde la pantalla principal selecciona 'Reportar', completa la información solicitada y envía el reporte.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: Icon(Icons.location_on),
            title: Text("¿Qué significan los colores del mapa?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Rojo intenso: crítico.\n"
                  "Rojo: alta prioridad.\n"
                  "Amarillo: atención pronta.\n"
                  "Verde: animal estable.",
                ),
              ),
            ],
          ),

          ExpansionTile(
            leading: Icon(Icons.edit),
            title: Text("¿Puedo actualizar un reporte?"),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Sí. Si siempre y cuando se adjunten evidencias veridicas de su estado.",
                ),
              ),
            ],
          ),

          ExpansionTile(
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