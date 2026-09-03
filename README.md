# Huellitas

- Logo de Huellitas (assets/images/logoo.png)

Huellitas es una aplicación móvil desarrolla en Flutter para ayudar a conectar personas, rescatistas y organizaciones que apoyan a animales en situación vulnerable.

La idea es que desde un mismo lugar se puedan reportar animales que necesitan ayuda, dar seguimiento a los casos, encontrar adopciones y apoyar a organizaciones por medio de donaciones.

## Funciones principales

- Registro e inicio de sesión para usuarios y organizaciones.
- Verificación de correo y proceso para completar el perfil.
- Mapa con reportes cercanos y filtros por tipo de reporte.
- Creación y seguimiento de reportes de animales.
- Foro con publicaciones, comentarios y grupos.
- Publicación de adopciones y postulaciones.
- Donaciones a organizaciones e historial de movimientos.
- Notificaciones dentro de la aplicación.
- Insignias por la participación de cada usuario.
- Perfiles, configuración y tema claro/oscuro.

## Tecnologías que utilicé

- **Flutter y Dart** para la aplicación.
- **BLoC** para el manejo de estados.
- **Dio y HTTP** para la comunicación con la API.
- **GoRouter** para la navegación.
- **Flutter Map, CARTO y OpenStreetMap** para el mapa y las ubicaciones.
- **Flutter Secure Storage** para guardar el token de sesión.
- Una estructura por funcionalidades, separando presentación, dominio y datos.

Actualmente la app consume el backend desplegado en Render.

## Antes de ejecutar el proyecto

Se necesita tener instalado:

- Flutter con una versión compatible con Dart `^3.12.1`.
- Android Studio o Xcode, dependiendo del dispositivo donde se vaya a probar.
- Un emulador configurado o un dispositivo físico.
- Una API key de CARTO para cargar el mapa.

Se puede revisar que la instalación de Flutter esté lista con:

```bash
flutter doctor
```

## Configuración

Primero hay que clonar el repositorio e instalar las dependencias:

```bash
git clone <URL_DEL_REPOSITORIO>
cd Huellitas
flutter pub get
```

En la raíz del proyecto se debe crear un archivo llamado `env.local.json` con la clave del mapa:

```json
{
  "CARTO_API_KEY": "TU_API_KEY"
}
```

Este archivo está ignorado por Git para evitar subir la clave al repositorio.

## Cómo correr la app

Con un dispositivo o emulador disponible:

```bash
flutter run --dart-define-from-file=env.local.json
```

Para elegir un dispositivo específico se pueden consultar primero los disponibles:

```bash
flutter devices
```

## Estructura general

```text
lib/
├── app/          # configuración principal y rutas
├── core/         # tema, almacenamiento, ubicación y widgets compartidos
├── features/     # módulos de la aplicación
│   ├── auth/
│   ├── donaciones/
│   ├── foro/
│   ├── home/
│   ├── insignias/
│   ├── notificaciones/
│   ├── perfil/
│   └── reporte/
└── main.dart     # punto de entrada e inyección de dependencias
```

Los recursos gráficos, avatares e insignias se encuentran dentro de `assets/`.

## Comandos útiles

```bash
# Revisar posibles errores
flutter analyze

# Ejecutar las pruebas
flutter test

# Generar el APK
flutter build apk --release --dart-define-from-file=env.local.json

## Estado del proyecto

El proyecto sigue en desarrollo, por lo que algunas pantallas y flujos todavía pueden cambiar. Mi objetivo es seguir mejorando la experiencia de uso y agregar herramientas que faciliten la ayuda, el rescate y la adopción responsable de animales.
