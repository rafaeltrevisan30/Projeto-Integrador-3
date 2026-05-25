import 'package:flutter/material.dart';

class StoryController extends ChangeNotifier {
  final Map<int, Set<String>> _dialogosMostrados = {
    0: {},
    1: {},
    2: {},
    3: {},
    4: {},
  };

  Set<String> getDialogosMostrados(int regionIndex) {
    return _dialogosMostrados[regionIndex] ?? {};
  }

  void marcarDialogoVisto(int regionIndex, String fase) {
    _dialogosMostrados[regionIndex]?.add(fase);
    notifyListeners();
  }

  bool jaMostrou(int regionIndex, String fase) {
    return _dialogosMostrados[regionIndex]?.contains(fase) ?? false;
  }

  bool completouRegiao(int regionIndex) {
    final fases = _dialogosMostrados[regionIndex] ?? {};
    return fases.contains('inicio') &&
        fases.contains('meio') &&
        fases.contains('fim');
  }
}
