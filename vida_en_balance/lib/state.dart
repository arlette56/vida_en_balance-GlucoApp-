import 'package:flutter/material.dart';

import 'auth.dart';
import 'format.dart';
import 'models.dart';

// Las pantallas importan solo state.dart y reciben los modelos desde aquí.
export 'auth.dart' show AuthException, validatePassword, isValidEmail;
export 'models.dart';

const glucoseLow = 70;
const glucoseHigh = 130;

const motivationalMessages = [
  'Cada pequeño paso cuenta. ¡Hoy lo estás haciendo muy bien!',
  'Cuidarte hoy es el mejor regalo para tu yo de mañana.',
  'Un vaso de agua, una caminata corta, una sonrisa: ¡todo suma!',
  'Tu constancia vale más que la perfección.',
  'Descansar también es cuidar tu salud.',
  'Qué bueno tenerte aquí. ¡Sigue así!',
];

/// Datos de salud de un cliente. Operadores y administradores vinculados
/// leen y escriben sobre este mismo objeto (según sus permisos).
class PatientData {
  PatientData({
    List<GlucoseReading>? readings,
    List<Medication>? meds,
    List<Reminder>? reminders,
  })  : readings = readings ?? [],
        meds = meds ?? [],
        reminders = reminders ?? [];

  final List<GlucoseReading> readings; // más reciente primero
  final List<Medication> meds;
  final List<Reminder> reminders;

  factory PatientData.demo() {
    final now = DateTime.now();
    DateTime at(int daysAgo, int h, int m) {
      final d = now.subtract(Duration(days: daysAgo));
      return DateTime(d.year, d.month, d.day, h, m);
    }

    return PatientData(
      readings: [
        GlucoseReading(112, GlucoseMoment.ayunas,
            now.subtract(const Duration(hours: 2))),
        GlucoseReading(109, GlucoseMoment.antesDeDormir, at(1, 20, 5)),
        GlucoseReading(126, GlucoseMoment.despuesDeComer, at(2, 14, 20)),
        GlucoseReading(118, GlucoseMoment.ayunas, at(3, 7, 10)),
        GlucoseReading(103, GlucoseMoment.antesDeDormir, at(4, 21, 0)),
        GlucoseReading(121, GlucoseMoment.despuesDeComer, at(5, 15, 0)),
        GlucoseReading(115, GlucoseMoment.ayunas, at(6, 7, 30)),
      ],
      meds: [
        Medication(
          id: 'm1',
          name: 'Metformina',
          dose: '850 mg',
          when: 'con el desayuno',
          time: const TimeOfDay(hour: 8, minute: 0),
          taken: true,
        ),
        Medication(
          id: 'm2',
          name: 'Glibenclamida',
          dose: '5 mg',
          when: 'con la comida',
          time: const TimeOfDay(hour: 14, minute: 0),
        ),
        Medication(
          id: 'm3',
          name: 'Metformina',
          dose: '850 mg',
          when: 'con la cena',
          time: const TimeOfDay(hour: 20, minute: 0),
        ),
      ],
      reminders: [
        Reminder(
          id: 'r1',
          kind: ReminderKind.medicamento,
          title: 'Tomar medicamento',
          time: const TimeOfDay(hour: 14, minute: 0),
          date: now,
          daily: true,
        ),
        Reminder(
          id: 'r2',
          kind: ReminderKind.glucosa,
          title: 'Medir glucosa',
          time: const TimeOfDay(hour: 18, minute: 0),
          date: now,
          daily: false,
        ),
        Reminder(
          id: 'r3',
          kind: ReminderKind.cita,
          title: 'Cita con el médico',
          time: const TimeOfDay(hour: 10, minute: 0),
          date: now.add(const Duration(days: 9)),
          daily: false,
        ),
        Reminder(
          id: 'r4',
          kind: ReminderKind.glucosa,
          title: 'Medir glucosa en ayunas',
          time: const TimeOfDay(hour: 7, minute: 0),
          date: now.add(const Duration(days: 1)),
          daily: false,
          active: false,
        ),
      ],
    );
  }
}

class AppState extends ChangeNotifier {
  AppState({AuthRepository? auth}) : auth = auth ?? LocalAuthRepository() {
    _data[LocalAuthRepository.demoClienteId] = PatientData.demo();
  }

  final AuthRepository auth;
  final Map<int, PatientData> _data = {};

  // ───────── Sesión y permisos ─────────

  AppUser? user;

  bool get isSignedIn => user != null;

  bool can(Permission p) => user?.role.permissions.contains(p) ?? false;

  void _require(Permission p) {
    if (!can(p)) throw StateError('Acción no permitida para este rol: ${p.name}');
  }

  /// Cliente cuyos datos se están viendo (el propio usuario si es cliente).
  AppUser? get patient {
    final u = user;
    return u == null ? null : auth.findById(u.dataOwnerId);
  }

  PatientData get _d =>
      _data.putIfAbsent(user?.dataOwnerId ?? -1, () => PatientData());

  /// Devuelve `null` si todo salió bien, o el mensaje de error.
  Future<String?> signIn(String correo, String password) async {
    try {
      user = await auth.signIn(correo, password);
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> register({
    required String nombre,
    required String correo,
    required String password,
    required UserRole role,
    DateTime? fechaNacimiento,
    String sexo = '',
    String objetivo = '',
    String? linkCode,
  }) async {
    try {
      user = await auth.register(
        nombre: nombre,
        correo: correo,
        password: password,
        role: role,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
        objetivo: objetivo,
        linkCode: linkCode,
      );
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  void signOut() {
    user = null;
    notifyListeners();
  }

  String get displayName => user?.firstName ?? 'Usuario';

  // ───────── Preferencias y perfil ─────────

  TextSizeOption get textSize => user?.textSize ?? TextSizeOption.grande;

  void setTextSize(TextSizeOption o) {
    user?.textSize = o;
    notifyListeners();
  }

  bool get notificaciones => user?.notificaciones ?? true;

  void setNotificaciones(bool v) {
    user?.notificaciones = v;
    notifyListeners();
  }

  void saveProfile({
    required String nombre,
    DateTime? fechaNacimiento,
    required String sexo,
    required String objetivo,
  }) {
    final u = user;
    if (u == null) return;
    if (nombre.trim().isNotEmpty) u.nombre = nombre.trim();
    u.fechaNacimiento = fechaNacimiento;
    u.sexo = sexo;
    u.objetivo = objetivo.trim();
    notifyListeners();
  }

  // ───────── Glucosa ─────────

  List<GlucoseReading> get readings => _d.readings;

  GlucoseReading? get lastReading =>
      readings.isEmpty ? null : readings.first;

  GlucoseReading addReading(int value, GlucoseMoment moment) {
    _require(Permission.registrarGlucosa);
    if (value < 20 || value > 600) {
      throw ArgumentError('Glucosa fuera del rango fisiológico (20–600 mg/dL)');
    }
    final r = GlucoseReading(value, moment, DateTime.now());
    readings.insert(0, r);
    notifyListeners();
    return r;
  }

  /// Lecturas de los últimos 7 días (hoy incluido).
  List<GlucoseReading> get lastWeekReadings {
    final from = dateOnly(DateTime.now()).subtract(const Duration(days: 6));
    return readings.where((r) => !r.at.isBefore(from)).toList();
  }

  /// Promedio diario de los últimos 7 días, del más antiguo a hoy.
  /// Un día sin lecturas devuelve 0.
  List<MapEntry<DateTime, double>> get dailyAverages {
    final today = dateOnly(DateTime.now());
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final day = today.subtract(Duration(days: i));
          final vals =
              readings.where((r) => isSameDay(r.at, day)).map((r) => r.value);
          final avg =
              vals.isEmpty ? 0.0 : vals.reduce((a, b) => a + b) / vals.length;
          return MapEntry(day, avg);
        }()
    ];
  }

  // ───────── Medicamentos ─────────

  List<Medication> get meds => _d.meds;

  int get takenCount => meds.where((m) => m.taken).length;

  Medication? get nextMed {
    for (final m in meds) {
      if (!m.taken) return m;
    }
    return null;
  }

  void takeMed(Medication m) {
    _require(Permission.marcarToma);
    m.taken = true;
    notifyListeners();
  }

  void addMed(Medication m) {
    _require(Permission.agregarMedicamento);
    meds.add(m);
    meds.sort((a, b) => (a.time.hour * 60 + a.time.minute)
        .compareTo(b.time.hour * 60 + b.time.minute));
    notifyListeners();
  }

  // ───────── Recordatorios ─────────

  List<Reminder> get reminders => _d.reminders;

  void toggleReminder(Reminder r, bool value) {
    _require(Permission.administrarRecordatorios);
    r.active = value;
    notifyListeners();
  }

  void addReminder(Reminder r) {
    _require(Permission.administrarRecordatorios);
    reminders.add(r);
    reminders.sort((a, b) {
      final da = DateTime(
          a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
      final db = DateTime(
          b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
      return da.compareTo(db);
    });
    notifyListeners();
  }

  // ───────── Alimentación (catálogo común) ─────────

  final List<FoodItem> foods = [
    const FoodItem(
        id: 'f1', nombre: 'Refrescos y jugos con azúcar', restringido: true),
    const FoodItem(id: 'f2', nombre: 'Pan dulce y galletas', restringido: true),
    const FoodItem(
        id: 'f3', nombre: 'Frituras y comida muy grasosa', restringido: true),
    const FoodItem(
        id: 'f4', nombre: 'Dulces, helados y postres', restringido: true),
    const FoodItem(
        id: 'f5', nombre: 'Verduras al vapor con pollo', restringido: false),
    const FoodItem(
        id: 'f6', nombre: 'Avena sin azúcar con fruta', restringido: false),
    const FoodItem(id: 'f7', nombre: 'Frijoles con nopales', restringido: false),
    const FoodItem(
        id: 'f8',
        nombre: 'Agua natural o de jamaica sin azúcar',
        restringido: false),
  ];

  void addFood(String nombre, {required bool restringido}) {
    _require(Permission.editarAlimentacion);
    foods.add(FoodItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      restringido: restringido,
    ));
    notifyListeners();
  }

  void removeFood(FoodItem f) {
    _require(Permission.editarAlimentacion);
    foods.removeWhere((x) => x.id == f.id);
    notifyListeners();
  }

  // ───────── Motivación ─────────

  int messageIndex = 0;

  String get message => motivationalMessages[messageIndex];

  void nextMessage() {
    messageIndex = (messageIndex + 1) % motivationalMessages.length;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope no encontrado en el árbol de widgets');
    return scope!.notifier!;
  }
}