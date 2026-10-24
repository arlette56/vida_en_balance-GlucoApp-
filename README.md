# Vida en Balance (GlucoApp)

## 1. Descripción breve

**Vida en Balance (GlucoApp)** es una aplicación móvil hecha con Flutter para el
autocuidado de personas con diabetes. Permite registrar la glucosa, llevar el
control de medicamentos, consultar recomendaciones de alimentación y programar
recordatorios. Operadores y administradores pueden acompañar al
cliente con permisos distintos.

Lema: *pequeños hábitos hacen grandes cambios en tu salud.*

## 2. Los 3 tipos de usuario y sus dashboards

Los permisos de cada rol se definen en un solo lugar (`UserRole` en
`lib/models.dart`). Las rutas (`lib/routes.dart`), los botones y el estado
consultan esa misma tabla. El menú principal (`MenuScreen`) muestra un
contenido propio para cada rol: el cliente ve el menú completo; el operador
y el administrador ven además un resumen del cliente que acompañan
(`lib/widgets/role_dashboard.dart`) y solo los accesos que su rol permite.

| Rol | Dashboard | Puede |

| **Administrador** | Promedio, porcentaje en rango y número de lecturas de 7 días del cliente que supervisa | Consultar historial, agregar medicamentos, administrar recordatorios y editar alimentación. No registra glucosa |
| **Cliente** | Saludo, última glucosa y accesos a registrar glucosa, medicamentos, alimentación, recordatorios y motivación (su código de vinculación está en Ajustes) | Registrar glucosa, ver y agregar medicamentos, marcar tomas, administrar recordatorios, ver alimentación y motivación |
| **Operador** | Última glucosa del cliente (con alerta fuera de rango), tomas pendientes y recordatorios de hoy | Registrar glucosa, marcar tomas, administrar recordatorios. No cambia medicamentos |

Cuentas de demostración (contraseña `Demo1234`):

- `admin@demo.com` (Administrador)
- `cliente@demo.com` (Cliente)
- `operador@demo.com` (Operador)

Un operador o administrador se registra con el código de vinculación del
cliente (el cliente demo usa `VIDA-2026`).

### Flujo de inicio

`Splashscreen` (3 s, barra de carga, pasa sola) → `Inicio` (botón
**Comenzar**) → `Login` / `Registro` → `Menú principal` según el rol.

### Imágenes

Las ilustraciones se cargan desde `assets/`. Si un archivo no existe, la app
muestra un respaldo y no falla:

- `assets/pareja.png`: pantalla de Inicio.
- `assets/medicinas.png`: pantalla «Medicamento registrado».
- `assets/icons/*.png`: íconos de los botones del menú principal.

### Pantallas y datos

- **Listas con datos dinámicos:** medicamentos, historial de glucosa,
  recordatorios y alimentación. Todas muestran un mensaje de **estado vacío**
  cuando no hay elementos (por ejemplo, al registrar un cliente nuevo).
- **Formularios:** registrar glucosa, agregar medicamento, agregar
  recordatorio, agregar alimento y editar perfil, con validación.

## 3. Manejo de estado elegido (y por qué)

Se usa **`ChangeNotifier` + `InheritedNotifier`** (`AppState` y `AppScope` en
`lib/state.dart`), sin paquetes externos.

- `AppState` concentra la sesión, los permisos, las preferencias y los datos
  de salud. Las pantallas llaman a sus métodos y se reconstruyen solas con
  `notifyListeners()`.
- `AppScope` expone el estado a todo el árbol de widgets con
  `AppScope.of(context)`.
- Los datos de salud se guardan por cliente, así que operador y administrador
  ven y modifican el mismo `PatientData`, según sus permisos.
- Es suficiente para el tamaño de la app, no añade dependencias y es fácil de
  explicar. La autenticación está detrás de la interfaz `AuthRepository`
  (`lib/auth.dart`), por lo que se puede cambiar a Firebase o a una API sin
  tocar las pantallas.

> Los datos viven en memoria: el estado se conserva al navegar entre pantallas,
> pero se reinicia al cerrar la app.

### Estructura del proyecto

```
lib/
├── main.dart            # arranque, tema y localización
├── routes.dart          # rutas y guardia de acceso por rol
├── state.dart           # AppState + AppScope (manejo de estado)
├── auth.dart            # autenticación (interfaz + implementación local)
├── models.dart          # modelos, roles y permisos
├── theme.dart / format.dart
├── views/               # pantallas (una por archivo o por flujo)
│   ├── splash_view.dart, inicio_view.dart
│   ├── login_view.dart, registro_view.dart, acceso_denegado_view.dart
│   ├── menu_view.dart, glucosa_view.dart, historial_view.dart
│   ├── medicamentos_view.dart, alimentacion_view.dart
│   └── recordatorios_view.dart, motivacion_view.dart, ajustes_view.dart
└── widgets/             # componentes reutilizables
    ├── widgets.dart     # exporta todos (las vistas importan solo este)
    ├── nav_scaffold.dart, buttons.dart, cards.dart
    ├── form_fields.dart, images.dart, layout.dart
    └── role_dashboard.dart
```

## 4. Cómo ejecutar la app

Requisitos: Flutter (SDK de Dart `^3.4.0`) y un emulador o dispositivo Android.

```bash
flutter pub get
flutter run
```

Pruebas:

```bash
flutter test
```

## 5. Demostración al docente

- Dispositivo/emulador usado: [Android/iOS · modelo/versión]
- Fecha y modalidad de la demostración: [presencial / videollamada]

## 6. Screenshots

Cada captura indica el tipo de usuario con el que se tomó.

### Splashscreen
![Splash](screenshots/01-splash.png)
![Bienvenida](screenshots/01b-bienvenida.png)

### Autenticación
**Login**

![Login](screenshots/02-login.png)
![Login con validación](screenshots/02b-login-validacion.png)

**Registro (selección de rol y datos)**

![Registro: rol Cliente](screenshots/03-registro.png)
![Registro: rol Operador](screenshots/03e-registro-rol-operador.png)
![Registro: rol Administrador](screenshots/03d-registro-rol-administrador.png)
![Registro: datos de la cuenta](screenshots/03b-registro-datos.png)
![Registro: datos (continuación)](screenshots/03c-registro-datos-2.png)
![Registro Cliente: objetivo](screenshots/03g-registro-objetivo-cliente.png)
![Registro Operador/Admin: código de vinculación](screenshots/03h-registro-codigo-vinculacion.png)

### Dashboards
**Administrador**

![Dashboard Administrador](screenshots/04-dashboard-admin.png)
![Dashboard Administrador (2)](screenshots/04b-dashboard-admin-2.png)
![Dashboard Administrador (login)](screenshots/04c-dashboard-admin-login.png)

**Cliente**

![Dashboard Cliente](screenshots/05-dashboard-cliente.png)
![Dashboard Cliente (2)](screenshots/05b-dashboard-cliente-2.png)
![Dashboard Cliente (login)](screenshots/05c-dashboard-cliente-login.png)
![Dashboard Cliente (cuenta nueva)](screenshots/05d-dashboard-cliente-nuevo.png)
![Motivación](screenshots/15-motivacion-cliente.png)

**Operador**

![Dashboard Operador](screenshots/06-dashboard-operador.png)
![Dashboard Operador (2)](screenshots/06b-dashboard-operador-2.png)
![Dashboard Operador (login)](screenshots/06c-dashboard-operador-login.png)

### Listas
**Lista principal**

![Mis medicamentos (Cliente)](screenshots/07-lista-principal-cliente.png)
![Alimentación (Cliente)](screenshots/07b-lista-alimentacion-cliente.png)
![Recordatorios (Cliente)](screenshots/07c-lista-recordatorios-cliente.png)
![Medicamentos (Operador)](screenshots/07d-lista-medicamentos-operador.png)
![Medicamentos (Administrador)](screenshots/07e-lista-medicamentos-admin.png)

**Lista detalle**

![Historial de glucosa](screenshots/08-lista-detalle-cliente.png)

**Estado vacío**

![Mis medicamentos vacío](screenshots/09-lista-vacia.png)
![Recordatorios vacío](screenshots/09b-recordatorios-vacio.png)
![Historial vacío](screenshots/09c-historial-vacio.png)

### Formularios
**Cliente**

![Registrar glucosa](screenshots/10-formulario-glucosa-cliente.png)
![Agregar medicamento](screenshots/10b-formulario-medicamento-cliente.png)
![Agregar medicamento (2)](screenshots/10c-formulario-medicamento-cliente-2.png)
![Medicamento registrado](screenshots/10d-medicamento-registrado-cliente.png)
![Agregar recordatorio](screenshots/10e-formulario-recordatorio-cliente.png)
![Perfil](screenshots/10f-perfil-cliente.png)
![Perfil (2)](screenshots/10g-perfil-cliente-2.png)

**Operador**

![Perfil Operador](screenshots/11-formulario-perfil-operador.png)

**Administrador**

![Perfil Administrador](screenshots/12-formulario-perfil-admin.png)

**Ajustes**

![Ajustes Cliente](screenshots/16-ajustes-cliente.png)
![Ajustes Cliente (2)](screenshots/16b-ajustes-cliente-2.png)
![Ajustes Operador](screenshots/16c-ajustes-operador.png)
![Ajustes Administrador](screenshots/16d-ajustes-admin.png)

### Evidencia funcional
![Foto del equipo](screenshots/13-foto-equipo.png)
![Navegación](screenshots/14-navegacion.png)
