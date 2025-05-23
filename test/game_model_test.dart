import 'package:flutter_test/flutter_test.dart';
import 'package:guess_number_flutter_test_flutter/models/game_model.dart';

void main() {
  group('GameModel', () {
    late GameModel game;

    setUp(() {
      game = GameModel();
    });

    test('Inicializa con dificultad fácil', () {
      expect(game.dificultad, 'facil');
      expect(game.intentos.length, 0);
      expect(game.mayores.length, 0);
      expect(game.menores.length, 0);
      expect(game.intentosMaximos, 5);
    });

    test('Cambiar dificultad a medio actualiza límites', () {
      game.setDificultad('medio');
      expect(game.dificultad, 'medio');
      expect(game.intentosMaximos, 8);
    });

    test('Número fuera de rango muestra error', () {
      game.setDificultad('facil'); // Rango 1-10
      final error = game.intentar(20);
      expect(error, contains('fuera del rango'));
    });

    test('Número repetido muestra advertencia', () {
      final intento = game.numeroSecreto != 5 ? 5 : 6;
      game.intentar(intento);
      final error = game.intentar(intento);
      expect(error, contains('Ya intentaste ese número'));
    });

    test('Adivinar número correcto termina el juego', () {
      final secreto = game.numeroSecreto;
      final error = game.intentar(secreto);
      expect(error, isNull);
      expect(game.juegoTerminado, true);
      expect(game.gano, true);
    });

    test('Superar intentos máximos termina el juego con fallo', () {
      game.setDificultad('facil');
      // Para evitar intentar siempre el mismo número (que causaría error de repetición),
      // intentamos números distintos dentro del rango válido
      final maxIntentos = game.intentosMaximos;
      int intento = 1;
      for (int i = 0; i < maxIntentos; i++) {
        // Evitar intentar el número secreto, para forzar fallo
        if (intento == game.numeroSecreto) intento++;
        game.intentar(intento);
        intento++;
      }
      expect(game.juegoTerminado, true);
      expect(game.gano, false);
    });

    test('Historial guarda juegos anteriores correctamente', () {
      game.setDificultad('facil');
      // Igual que arriba, evitamos repetir el número secreto
      final maxIntentos = game.intentosMaximos;
      int intento = 1;
      for (int i = 0; i < maxIntentos; i++) {
        if (intento == game.numeroSecreto) intento++;
        game.intentar(intento);
        intento++;
      }
      expect(game.historial.isNotEmpty, true);
      final entrada = game.historial.last;
      expect(entrada['dificultad'], 'facil');
      expect(entrada['numeroSecreto'], game.numeroSecreto);
      expect(entrada['color'], 'red');
    });
  });
}
