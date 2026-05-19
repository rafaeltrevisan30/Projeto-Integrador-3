import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/ambiente.dart';

class PontosController extends ChangeNotifier {

  double lati = 0.0;
  double long = 0.0;
  String erro = '';
  bool loading = true;
  StreamSubscription<Position>? _positionStream;
  List<Ambiente> ambientes = [];
  String? pontoAtual;

  PontosController() {
    inicializar();
  }

  Future<void> inicializar() async {
    await carregarAmbientes();
    await getPosicao();
    monitoramento();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> carregarAmbientes() async {

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('ambientes')
              .get();

      ambientes = snapshot.docs.map((doc) {

        final data = doc.data();
        return Ambiente.fromFirestore(data);
      }).toList();

    } catch (e) {

      erro = 'Erro ao carregar ambientes';

      debugPrint(e.toString());
    }

    notifyListeners();
  }

  Future<void> getPosicao() async {

    loading = true;
    notifyListeners();

    try {

      Position posicao =
          await _posicaoAtual();

      lati = posicao.latitude;
      long = posicao.longitude;

    } catch (e) {
      erro = 'Erro ao obter localização';
    }

    loading = false;

    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {

    LocationPermission permissao;

    bool ativado =
        await Geolocator
            .isLocationServiceEnabled();

    if (!ativado) {
      return Future.error(
        'Por favor, habilite a localização',
      );
    }

    permissao =
        await Geolocator.checkPermission();

    if (permissao ==
        LocationPermission.denied) {

      permissao =
          await Geolocator.requestPermission();

      if (permissao ==
          LocationPermission.denied) {

        return Future.error(
          'Precisamos da localização',
        );
      }
    }

    if (permissao ==
        LocationPermission.deniedForever) {

      return Future.error(
        'Permissão negada permanentemente',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  void onEntrouNaArea(Ambiente amb) {
    debugPrint(
      'Entrou em ${amb.nome}',
    );
  }

  void onSaiuDaArea() {
    debugPrint(
      'Saiu da área',
    );
  }

  String? pontoAtual;
  Ambiente? ambienteAtual;

  void verificarProximidade() {

    for (var amb in ambientes) {

      double distancia =
          Geolocator.distanceBetween(
        lati,
        long,
        amb.latitude,
        amb.longitude,
      );

      if (distancia <= amb.raioMetros) {

        if (pontoAtual != amb.id) {
          pontoAtual = amb.id;
          ambienteAtual = amb;

          onEntrouNaArea(amb);
          notifyListeners();
        }
        return;
      }
    }

    if (pontoAtual != null) {
      onSaiuDaArea();
      pontoAtual = null;
      ambienteAtual = null;
      notifyListeners();
    }
  }

  void atualizarLocalizacao(
    double novaLat,
    double novaLong,
  ) {

    lati = novaLat;

    long = novaLong;

    verificarProximidade();
  }

  void monitoramento() {
    _positionStream =
        Geolocator.getPositionStream(

      locationSettings:
          const LocationSettings(

        accuracy:
            LocationAccuracy.high,

        distanceFilter: 5,
      ),

    ).listen((Position position) {

      atualizarLocalizacao(
        position.latitude,
        position.longitude,
      );
    });
  }
}