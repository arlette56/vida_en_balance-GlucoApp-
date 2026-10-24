import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'models.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contrato de autenticación. La app solo depende de esta interfaz: para
/// producción se implementa con Firebase Auth, Supabase o tu propia API
/// y no hay que tocar las pantallas.
abstract class AuthRepository {
  AppUser? findById(int id);

  Future<AppUser> signIn(String correo, String password);

  Future<AppUser> register({
    required String nombre,
    required String correo,
    required String password,
    required UserRole role,
    DateTime? fechaNacimiento,
    String sexo = '',
    String objetivo = '',
    String? linkCode,
  });
}

String hashPassword(String password, String salt) =>
    sha256.convert(utf8.encode('$salt:$password')).toString();

/// Validación de contraseña compartida por la UI y el repositorio.
String? validatePassword(String p) {
  if (p.length < 8) return 'Usa al menos 8 caracteres';
  if (!RegExp(r'[A-Za-z]').hasMatch(p) || !RegExp(r'\d').hasMatch(p)) {
    return 'Combina letras y números';
  }
  return null;
}

bool isValidEmail(String e) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e.trim());

/// Implementación local (en memoria) para desarrollo y demostración.
/// Las cuentas se pierden al cerrar la app y NO ofrece seguridad real:
/// cualquiera con acceso al dispositivo controla los datos.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository() {
    _seedDemo();
  }

  static const demoPassword = 'Demo1234';
  static const demoClienteId = 1;

  final List<AppUser> _users = [];
  int _nextId = 100;
  final _rng = Random.secure();

  void _seedDemo() {
    AppUser mk(int id, String nombre, String correo, UserRole role,
        {String? code, int? patient, String sexo = '', String objetivo = ''}) {
      const salt = 'demo-salt';
      return AppUser(
        id: id,
        nombre: nombre,
        correo: correo,
        role: role,
        salt: salt,
        passwordHash: hashPassword(demoPassword, salt),
        linkCode: code,
        patientId: patient,
        sexo: sexo,
        objetivo: objetivo,
        fechaNacimiento: role.isCliente ? DateTime(1951, 3, 14) : null,
      );
    }

    _users.addAll([
      mk(demoClienteId, 'María Hernández', 'cliente@demo.com',
          UserRole.cliente,
          code: 'VIDA-2026',
          sexo: 'Femenino',
          objetivo: 'Mantener mi glucosa en rango'),
      mk(2, 'Luis Hernández', 'operador@demo.com', UserRole.operador,
          patient: demoClienteId),
      mk(3, 'Ana Torres', 'admin@demo.com', UserRole.administrador,
          patient: demoClienteId),
    ]);
  }

  @override
  AppUser? findById(int id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  AppUser? _byEmail(String correo) {
    final c = correo.trim().toLowerCase();
    for (final u in _users) {
      if (u.correo == c) return u;
    }
    return null;
  }

  @override
  Future<AppUser> signIn(String correo, String password) async {
    final u = _byEmail(correo);
    // Mismo mensaje para correo inexistente y contraseña incorrecta, para
    // no revelar qué correos están registrados.
    if (u == null || u.passwordHash != hashPassword(password, u.salt)) {
      throw const AuthException('Correo o contraseña incorrectos');
    }
    return u;
  }

  @override
  Future<AppUser> register({
    required String nombre,
    required String correo,
    required String password,
    required UserRole role,
    DateTime? fechaNacimiento,
    String sexo = '',
    String objetivo = '',
    String? linkCode,
  }) async {
    if (nombre.trim().isEmpty) {
      throw const AuthException('Escribe tu nombre');
    }
    if (!isValidEmail(correo)) {
      throw const AuthException('Escribe un correo válido');
    }
    final pwError = validatePassword(password);
    if (pwError != null) throw AuthException(pwError);
    if (_byEmail(correo) != null) {
      throw const AuthException('Ya existe una cuenta con ese correo');
    }

    int? patientId;
    if (!role.isCliente) {
      final code = (linkCode ?? '').trim().toUpperCase();
      final owner = _users.where((u) => u.linkCode == code).firstOrNull;
      if (code.isEmpty || owner == null) {
        throw const AuthException(
            'El código de vinculación no es válido. Pídeselo al cliente.');
      }
      patientId = owner.id;
    }

    final salt = _randomString(12);
    final user = AppUser(
      id: _nextId++,
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      role: role,
      salt: salt,
      passwordHash: hashPassword(password, salt),
      fechaNacimiento: fechaNacimiento,
      sexo: sexo,
      objetivo: objetivo.trim(),
      linkCode: role.isCliente ? _newLinkCode() : null,
      patientId: patientId,
    );
    _users.add(user);
    return user;
  }

  String _randomString(int n) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(n, (_) => chars[_rng.nextInt(chars.length)]).join();
  }

  String _newLinkCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sin 0/O/1/I
    String code;
    do {
      code =
          'VIDA-${List.generate(5, (_) => chars[_rng.nextInt(chars.length)]).join()}';
    } while (_users.any((u) => u.linkCode == code));
    return code;
  }
}
