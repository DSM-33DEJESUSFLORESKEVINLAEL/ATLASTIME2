# 🕒 AtlasTime

**AtlasTime** es una aplicación multiplataforma desarrollada en **Flutter** que permite registrar la asistencia de empleados mediante **geolocalización**, validación de dispositivos y sincronización en línea/offline.  
Incluye un panel web complementario desarrollado en **Vue.js** para supervisores y administradores.

---

## 🚀 Características principales

- ✅ Registro de **entradas y salidas** con validación de zona geográfica.  
- 🌐 Funciona **sin conexión** (sincroniza cuando hay Wi-Fi disponible).  
- 📱 Validación de **dispositivo autorizado** mediante número de serie.  
- 🕓 Detección automática de cambio de día para evitar duplicados.  
- 💾 Almacenamiento local con **SharedPreferences** y base de datos SQLite.  
- 📤 Sincronización automática con el servidor vía API REST.  
- 🧭 Onboarding interactivo para nuevos usuarios.  
- 👩‍💼 Roles: **Empleado, Supervisor y Administrador**.

---

## 🧩 Tecnologías utilizadas

### Aplicación móvil
- Flutter 3.x
- Dart
- SharedPreferences
- Geolocator
- Connectivity Plus
- Onboarding Overlay

### Panel web
- Vue.js 3
- Axios
- ExcelJS / FileSaver (para exportaciones)
- TailwindCSS

---

## ⚙️ Configuración del proyecto

Clona el repositorio y ejecuta los siguientes comandos:

```bash
git clone https://github.com/DSM-33DEJESUSFLORESKEVINLAEL/ATLASTIME2.git
cd ATLASTIME2
flutter pub get
flutter run
