import 'package:flutter_test/flutter_test.dart';
import 'package:vida_en_balance/state.dart';

void main() {
  group('Autenticación', () {
    test('inicia sesión con una cuenta demo', () async {
      final s = AppState();
      expect(await s.signIn('cliente@demo.com', 'Demo1234'), isNull);
      expect(s.isSignedIn, isTrue);
      expect(s.user!.role, UserRole.cliente);
    });

    test('rechaza contraseña incorrecta', () async {
      final s = AppState();
      expect(await s.signIn('cliente@demo.com', 'mala'), isNotNull);
      expect(s.isSignedIn, isFalse);
    });

    test('valida contraseña y correo', () {
      expect(validatePassword('corta1'), isNotNull);
      expect(validatePassword('soloLetras'), isNotNull);
      expect(validatePassword('Segura123'), isNull);
      expect(isValidEmail('a@b.com'), isTrue);
      expect(isValidEmail('sin-arroba'), isFalse);
    });

    test('el registro de operador exige un código válido', () async {
      final s = AppState();
      final err = await s.register(
          nombre: 'Ana',
          correo: 'ana@test.com',
          password: 'Segura123',
          role: UserRole.operador,
          linkCode: 'X');
      expect(err, isNotNull);
    });
  });

  group('Roles y estado', () {
    test('cada rol ve los mismos datos del cliente', () async {
      final s = AppState();
      await s.signIn('operador@demo.com', 'Demo1234');
      final antes = s.readings.length;
      s.addReading(100, GlucoseMoment.ayunas);
      expect(s.readings.length, antes + 1);
    });

    test('el administrador no puede registrar glucosa', () async {
      final s = AppState();
      await s.signIn('admin@demo.com', 'Demo1234');
      expect(() => s.addReading(100, GlucoseMoment.ayunas), throwsStateError);
    });

    test('un cliente nuevo empieza con listas vacías', () async {
      final s = AppState();
      await s.register(
          nombre: 'Nuevo',
          correo: 'nuevo@test.com',
          password: 'Segura123',
          role: UserRole.cliente);
      expect(s.readings, isEmpty);
      expect(s.meds, isEmpty);
      expect(s.reminders, isEmpty);
    });
  });
}
