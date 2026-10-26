# Turco App

Aplicación móvil desarrollada con Flutter y Dart.

## 1. Requisitos

- Flutter 3.47.3
- Dart 3.13.3
- Android SDK
- Git

## 2. Inicializar el proyecto

Clonar el repositorio:

```bash
git clone https://github.com/randyvalle1973/turco-app.git
```

Entrar en la carpeta del proyecto:

```bash
cd turco-app
```

Descargar las dependencias:

```bash
flutter pub get
```

## 3. Ejecutar la aplicación

Para ejecutar la aplicación en un dispositivo Android conectado o en un emulador:

```bash
flutter devices
flutter run
```

El primer comando permite comprobar los dispositivos disponibles y el segundo inicia la aplicación.

## 4. Versión de Flutter

La versión de Flutter utilizada para desarrollar el proyecto es:

```text
Flutter 3.47.3 (stable)
Dart 3.13.3
```

Para comprobar las versiones instaladas en el equipo:

```bash
flutter --version
```

## 5. Application ID

El identificador de la aplicación Android es:

```text
com.example.turcoa_app
```

Este identificador se encuentra configurado en `android/app/build.gradle.kts`, mediante las propiedades `applicationId` y `namespace`.

## 6. Generar el APK de lanzamiento (Release)

Para generar el APK de lanzamiento, ejecutar desde la raíz del proyecto:

```bash
flutter build apk --release
```

Si la compilación termina correctamente, el archivo generado estará en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Este archivo puede instalarse en un dispositivo Android compatible.

## 7. Estructura de carpetas

```text
turco-app/
├── android/                         # Configuración de Android
├── lib/                             # Código fuente Dart
├── test/                            # Pruebas automatizadas
├── build/                           # Archivos generados durante la compilación
├── pubspec.yaml                     # Configuración y dependencias
├── pubspec.lock                     # Versiones de las dependencias
├── analysis_options.yaml             # Reglas de análisis de Dart
└── README.md                        # Documentación del proyecto
```

La carpeta `build/` se genera durante la compilación y no es necesaria para ejecutar `flutter pub get`.

## 8. Autor

Randy Valle

