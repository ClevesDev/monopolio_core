import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';

// 1. Añadimos ChangeNotifier para que la UI "escuche"
class StatsController extends ChangeNotifier {
  int diasDeSoberania = 0;
  double nivelDeFoco = 0.0;
  String estadoEmocional = 'Vulnerable';

  // Variable para el capital y el timer
  double capitalDeSoberania = 0.0;
  List<String> historialDeEventos = [];
  Timer? _timer;

  // 2. El Constructor inicia la carga y el motor
  StatsController() {
    loadStats().then((_) {
      iniciarMotorDeCapital();
    });
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    diasDeSoberania = prefs.getInt('diasDeSoberania') ?? 0;
    nivelDeFoco = prefs.getDouble('nivelDeFoco') ?? 0.0;
    // También cargamos el capital
    capitalDeSoberania = prefs.getDouble('capitalDeSoberania') ?? 0.0;
    _actualizarEstado();
    notifyListeners(); // Avisamos a la UI que ya cargamos datos
  }

  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('diasDeSoberania', diasDeSoberania);
    await prefs.setDouble('nivelDeFoco', nivelDeFoco);
    await prefs.setDouble('capitalDeSoberania', capitalDeSoberania);
  }

  // 3. El Motor: Genera capital cada segundo
  void iniciarMotorDeCapital() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // --- LÓGICA DE PENALIZACIÓN ---
      if (estadoEmocional == 'Vulnerable' && capitalDeSoberania > 0) {
        // Te restamos el doble de lo que ganas por segundo.
        // Es más fácil perder que ganar.
        capitalDeSoberania -= 0.02;
      }
      // ------------------------------

      if (estadoEmocional == 'Roca') {
        capitalDeSoberania += 0.01;
      }
      // --- LÍNEA NUEVA: LA DEGRADACIÓN ---
      // Bajamos el foco un 1% cada segundo para obligarte a estar presente
      nivelDeFoco = (nivelDeFoco - 0.01).clamp(0.0, 1.0);
      _actualizarEstado();
      // ----------------------------------

      notifyListeners(); // Avisamos a la UI de ambos cambios
    });
  }

  void incrementarFoco(double incremento) {
    // Subimos el valor del incremento porque ahora compites contra la caída
    nivelDeFoco = (nivelDeFoco + 0.15).clamp(0.0, 1.0);
    _actualizarEstado();
    saveStats();
    notifyListeners();
  }

  void incrementarDias() {
    diasDeSoberania++;
    saveStats();
    notifyListeners();
  }

  void _actualizarEstado() {
    String estadoAnterior = estadoEmocional;

    if (nivelDeFoco >= 1.0) {
      estadoEmocional = 'Roca';

      if (estadoAnterior == 'Vulnerable') {
        final ahora = DateTime.now();

        historialDeEventos.insert(
          0,
          "${ahora.hour}:${ahora.minute}:${ahora.second} - ASCENSO A ROCA",
        );

        if (historialDeEventos.length > 20) {
          historialDeEventos.removeLast();
        }

        notifyListeners();
      }
    } else {
      estadoEmocional = 'Vulnerable';
    }
  }

  // Limpieza al cerrar la app
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
