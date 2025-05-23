import 'package:flutter/material.dart';
import 'models/game_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adivina el Número',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameModel juego = GameModel();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _mayoresController = ScrollController();
  final ScrollController _menoresController = ScrollController();
  final ScrollController _historialController = ScrollController();
  String error = '';

  void _cambiarDificultad(String nivel) {
    setState(() {
      juego.setDificultad(nivel);
      error = '';
    });
  }

  void _intentar() {
    final input = _controller.text;
    final numero = int.tryParse(input);
    if (numero == null) {
      setState(() => error = 'Por favor ingresa un número válido');
      return;
    }

    final msg = juego.intentar(numero);
    setState(() {
      error = msg ?? '';
    });

    _controller.clear();

    // Auto scroll al final
    Future.delayed(Duration(milliseconds: 100), () {
      if (_mayoresController.hasClients) {
        _mayoresController.jumpTo(_mayoresController.position.maxScrollExtent);
      }
      if (_menoresController.hasClients) {
        _menoresController.jumpTo(_menoresController.position.maxScrollExtent);
      }
      if (_historialController.hasClients) {
        _historialController.jumpTo(
          _historialController.position.maxScrollExtent,
        );
      }
    });
  }

  Widget _buildLista(
    String titulo,
    List<int> valores,
    ScrollController controller,
  ) {
    // Calculamos ancho para que quepan dos columnas con separación
    final anchoColumna =
        (MediaQuery.of(context).size.width - 16 * 3) / 2; // padding y espacio

    return SizedBox(
      width: anchoColumna,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              child: ListView(
                controller: controller,
                children: valores
                    .map((n) => Text('$n', style: TextStyle(fontSize: 16)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📜 Historial de Juegos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Scrollbar(
            controller: _historialController,
            thumbVisibility: true,
            child: ListView(
              controller: _historialController,
              children: juego.historial.reversed.map((item) {
                final color = item['color'] == 'green'
                    ? Colors.green[100]
                    : Colors.red[100];
                final textColor = item['color'] == 'green'
                    ? Colors.green[900]
                    : Colors.red[900];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item['dificultad'].toString().toUpperCase()} → Secreto: ${item['numeroSecreto']} | Intentos: ${item['intentos'].join(", ")}',
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final juegoTerminado = juego.juegoTerminado;

    return Scaffold(
      appBar: AppBar(title: const Text('🎯 Adivina el Número')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nivel de dificultad
            Row(
              children: [
                Text('Dificultad:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: juego.dificultad,
                  items: GameModel.levels.keys.map((nivel) {
                    return DropdownMenuItem(
                      value: nivel,
                      child: Text(nivel[0].toUpperCase() + nivel.substring(1)),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    if (valor != null) _cambiarDificultad(valor);
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() => juego.reiniciarJuego());
                    error = '';
                    _controller.clear();
                  },
                  child: Text('Reiniciar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input de número
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    enabled: !juegoTerminado,
                    decoration: InputDecoration(
                      labelText: 'Ingresa un número...',
                      errorText: error.isNotEmpty ? error : null,
                    ),
                    onSubmitted: (_) => _intentar(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: juegoTerminado ? null : _intentar,
                  child: Text('Intentar'),
                ),
              ],
            ),

            // Mostrar intentos usados y restantes
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    'Intentos usados: ${juego.intentos.length} / ${juego.intentosMaximos}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Intentos restantes: ${juego.intentosRestantes}',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Columnas de "Mayor que" y "Menor que"
            Row(
              children: [
                _buildLista('📈 Mayor que', juego.mayores, _mayoresController),
                const SizedBox(width: 16),
                _buildLista('📉 Menor que', juego.menores, _menoresController),
              ],
            ),

            const SizedBox(height: 24),

            // Historial
            _buildHistorial(),
          ],
        ),
      ),
    );
  }
}
