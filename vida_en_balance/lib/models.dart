import 'package:flutter/material.dart';

import 'format.dart';

// ───────────── Glucosa (RegistroGlucosa) ─────────────

enum GlucoseMoment {
  ayunas('En ayunas', Icons.wb_twilight),
  despuesDeComer('Después de comer', Icons.restaurant),
  antesDeDormir('Antes de dormir', Icons.nightlight_round);

  const GlucoseMoment(this.label, this.icon);
  final String label;
  final IconData icon;
}

class GlucoseReading {
  const GlucoseReading(this.value, this.moment, this.at);
  final int value;
  final GlucoseMoment moment;
  final DateTime at;
}

// ───────────── Medicamento ─────────────

class Medication {
  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.when,
    required this.time,
    this.taken = false,
  });
  final String id;
  final String name;
  final String dose;
  final String when; // «con el desayuno»
  final TimeOfDay time;
  bool taken;

  String get detail => when.isEmpty ? dose : '$dose · $when';
}

// ───────────── Recordatorio ─────────────

enum ReminderKind {
  medicamento('Medicamento', 'Tomar medicamento', Icons.medication_outlined),
  glucosa('Medir glucosa', 'Medir glucosa', Icons.water_drop_outlined),
  cita('Cita médica', 'Cita con el médico', Icons.event_outlined);

  const ReminderKind(this.label, this.defaultTitle, this.icon);
  final String label;
  final String defaultTitle;
  final IconData icon;
}

class Reminder {
  Reminder({
    required this.id,
    required this.kind,
    required this.title,
    required this.time,
    required this.date,
    required this.daily,
    this.active = true,
  });
  final String id;
  final ReminderKind kind;
  final String title;
  final TimeOfDay time;
  final DateTime date;
  final bool daily;
  bool active;

  bool get isToday => daily || isSameDay(date, DateTime.now());

  String get subtitle {
    if (daily) return 'Todos los días';
    final d = daysFromToday(date);
    if (d == 0) return 'Hoy';
    if (d == 1) return 'Mañana';
    return longDate(date);
  }
}

// ───────────── Alimento / RecomendaciónAlimentaria ─────────────

class FoodItem {
  const FoodItem({
    required this.id,
    required this.nombre,
    required this.restringido,
  });
  final String id;
  final String nombre;
  final bool restringido;
}

// ───────────── Preferencias ─────────────

enum TextSizeOption {
  normal('Normal', 1.0),
  grande('Grande', 1.15),
  muyGrande('Muy grande', 1.3);

  const TextSizeOption(this.label, this.scale);
  final String label;
  final double scale;
}

// ───────────── Roles y permisos ─────────────

enum Permission {
  registrarGlucosa,
  verHistorial,
  verMedicamentos,
  agregarMedicamento,
  marcarToma,
  verAlimentacion,
  editarAlimentacion,
  verRecordatorios,
  administrarRecordatorios,
  verMotivacion,
  compartirAcceso,
}

/// Tres perfiles de la aplicación. Los permisos se definen aquí, en un solo
/// lugar: las rutas, los botones y el estado consultan esta misma tabla.
enum UserRole {
  cliente(
    'Cliente',
    'Eres el usuario principal: llevas el control de tu propia salud '
        '(glucosa, medicamentos, recordatorios y alimentación) y decides quién '
        'te acompaña.',
    Icons.person_outline,
    {
      Permission.registrarGlucosa,
      Permission.verHistorial,
      Permission.verMedicamentos,
      Permission.agregarMedicamento,
      Permission.marcarToma,
      Permission.verAlimentacion,
      Permission.verRecordatorios,
      Permission.administrarRecordatorios,
      Permission.verMotivacion,
      Permission.compartirAcceso,
    },
  ),
  operador(
    'Operador',
    'Acompañas a un cliente: registras su glucosa, marcas sus tomas y '
        'administras sus recordatorios. No cambias sus medicamentos.',
    Icons.volunteer_activism_outlined,
    {
      Permission.registrarGlucosa,
      Permission.verHistorial,
      Permission.verMedicamentos,
      Permission.marcarToma,
      Permission.verAlimentacion,
      Permission.verRecordatorios,
      Permission.administrarRecordatorios,
      Permission.verMotivacion,
    },
  ),
  administrador(
    'Administrador',
    'Supervisas a un cliente: consultas su historial, administras sus '
        'medicamentos, recordatorios y recomendaciones alimentarias. No '
        'registras su glucosa.',
    Icons.admin_panel_settings_outlined,
    {
      Permission.verHistorial,
      Permission.verMedicamentos,
      Permission.agregarMedicamento,
      Permission.verAlimentacion,
      Permission.editarAlimentacion,
      Permission.verRecordatorios,
      Permission.administrarRecordatorios,
      Permission.verMotivacion,
    },
  );

  const UserRole(this.label, this.description, this.icon, this.permissions);
  final String label;
  final String description;
  final IconData icon;
  final Set<Permission> permissions;

  bool get isCliente => this == UserRole.cliente;
}

// ───────────── Usuario ─────────────

class AppUser {
  AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.role,
    required this.salt,
    required this.passwordHash,
    this.fechaNacimiento,
    this.sexo = '',
    this.objetivo = '',
    this.linkCode,
    this.patientId,
    this.textSize = TextSizeOption.grande,
    this.notificaciones = true,
  });

  final int id;
  String nombre;
  final String correo;
  final UserRole role;
  final String salt;
  final String passwordHash;
  DateTime? fechaNacimiento;
  String sexo;
  String objetivo;

  /// Solo clientes: código que comparte para dar acceso a su información.
  final String? linkCode;

  /// Solo operadores y administradores: id del cliente al que acompañan.
  final int? patientId;

  // Preferencias
  TextSizeOption textSize;
  bool notificaciones;

  /// Id del cliente cuyos datos de salud se ven y se editan.
  int get dataOwnerId => role.isCliente ? id : patientId!;

  String get firstName {
    final parts = nombre.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Usuario' : parts.first;
  }
}
