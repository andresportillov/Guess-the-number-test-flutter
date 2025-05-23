class GameModel {
  static const Map<String, Map<String, int>> levels = {
    'facil': {'max': 10, 'intentosMax': 5},
    'medio': {'max': 20, 'intentosMax': 8},
    'avanzado': {'max': 100, 'intentosMax': 15},
    'extremo': {'max': 1000, 'intentosMax': 25},
  };

  String dificultad;
  late int numeroSecreto;
  late int _intentosMaximos; // privada
  List<int> intentos = [];
  List<int> mayores = [];
  List<int> menores = [];

  List<Map<String, dynamic>> historial = [];

  bool juegoTerminado = false;
  bool gano = false;

  GameModel({this.dificultad = 'facil'}) {
    reiniciarJuego();
  }

  void reiniciarJuego() {
    final nivel = levels[dificultad]!;
    numeroSecreto = (1 + (nivel['max']! * _randomDouble())).floor();
    _intentosMaximos = nivel['intentosMax']!;
    intentos.clear();
    mayores.clear();
    menores.clear();
    juegoTerminado = false;
    gano = false;
  }

  void setDificultad(String nuevoNivel) {
    if (!levels.containsKey(nuevoNivel)) return;
    dificultad = nuevoNivel;
    reiniciarJuego();
  }

  String? intentar(int numero) {
    if (juegoTerminado)
      return 'El juego ha terminado, reinicia para jugar de nuevo.';
    final max = levels[dificultad]!['max']!;
    if (numero < 1 || numero > max) {
      return 'Número fuera del rango permitido: 1-$max.';
    }
    if (intentos.contains(numero)) {
      return 'Ya intentaste ese número.';
    }

    intentos.add(numero);

    if (numero == numeroSecreto) {
      gano = true;
      juegoTerminado = true;
      _guardarHistorial(true);
      return null;
    } else {
      if (numero > numeroSecreto) {
        mayores.add(numero);
      } else {
        menores.add(numero);
      }

      if (intentos.length >= _intentosMaximos) {
        juegoTerminado = true;
        gano = false;
        _guardarHistorial(false);
      }
      return null;
    }
  }

  void _guardarHistorial(bool acerto) {
    historial.add({
      'dificultad': dificultad,
      'numeroSecreto': numeroSecreto,
      'intentos': List<int>.from(intentos),
      'color': acerto ? 'green' : 'red',
    });
  }

  int get intentosRestantes => _intentosMaximos - intentos.length;
  int get intentosMaximos => _intentosMaximos;

  double _randomDouble() {
    return DateTime.now().microsecondsSinceEpoch.remainder(1000000) / 1000000;
  }
}
