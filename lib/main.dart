import 'package:flutter/material.dart';
import 'control_panel.dart';

void main() {
  runApp(const MonopolioApp());
}

class MonopolioApp extends StatelessWidget {
  const MonopolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MonopolioHome(),
    );
  }
}

class MonopolioHome extends StatefulWidget {
  const MonopolioHome({super.key});

  @override
  State<MonopolioHome> createState() => _MonopolioHomeState();
}

class _MonopolioHomeState extends State<MonopolioHome> {
  // Inicializamos el controlador
  final StatsController statsController = StatsController();

  void _onPressed() {
    statsController.incrementarDias();
    statsController.incrementarFoco(0.1);
  }

  @override
  void dispose() {
    statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: statsController,
      builder: (BuildContext context, Widget? child) {
        Color colorDinamico = Color.lerp(
          const Color(0xFF263238),
          Colors.black,
          statsController.nivelDeFoco,
        )!;

        return Scaffold(
          backgroundColor: colorDinamico,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CAPITAL DE SOBERANÍA',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '\$${statsController.capitalDeSoberania.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: statsController.estadoEmocional == 'Roca'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'DÍAS DE AUTODISCIPLINA: ${statsController.diasDeSoberania}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),
                NeonButton(
                  text: 'ESTADO: ${statsController.estadoEmocional}',
                  onPressed: _onPressed,
                ),
                const SizedBox(height: 30), // Espacio después del botón
                // Título del historial
                const Text(
                  'LOG DE SOBERANÍA',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // El historial con scroll
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: statsController.historialDeEventos.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            statsController.historialDeEventos[index],
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const NeonButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.7),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.cyanAccent, width: 2.5),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
