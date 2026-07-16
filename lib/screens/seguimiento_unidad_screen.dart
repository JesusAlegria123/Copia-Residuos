import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'unidad_recoleccion.dart';

class SeguimientoUnidadScreen extends StatefulWidget {
  final UnidadRecoleccion unidad;

  const SeguimientoUnidadScreen({super.key, required this.unidad});

  @override
  State<SeguimientoUnidadScreen> createState() =>
      _SeguimientoUnidadScreenState();
}

class _SeguimientoUnidadScreenState extends State<SeguimientoUnidadScreen> {
  GoogleMapController? _mapController;
  Timer? _timer;

  late final List<LatLng> _puntosInterpolados;
  int _indiceActual = 0;
  bool _avanzando = true;
  DateTime _ultimaActualizacion = DateTime.now();

  // ──────────────────────────────────────────────────────────────
  // SIMULACIÓN: estos dos valores controlan qué tan "suave" y qué
  // tan rápido se mueve la unidad. En la versión REAL, este Timer
  // se reemplaza por un listener a Firebase (o tu backend) que
  // actualiza _posicionActual cada vez que llegue una nueva
  // coordenada del GPS del vehículo.
  // ──────────────────────────────────────────────────────────────
  static const int _pasosPorTramo = 18;
  static const Duration _intervalo = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _puntosInterpolados =
        _generarRutaSuave(widget.unidad.puntosRuta, _pasosPorTramo);
    _timer = Timer.periodic(_intervalo, (_) => _avanzarSimulacion());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  List<LatLng> _generarRutaSuave(List<LatLng> puntos, int pasos) {
    final List<LatLng> resultado = [];
    for (int i = 0; i < puntos.length - 1; i++) {
      final a = puntos[i];
      final b = puntos[i + 1];
      for (int p = 0; p < pasos; p++) {
        final t = p / pasos;
        resultado.add(LatLng(
          a.latitude + (b.latitude - a.latitude) * t,
          a.longitude + (b.longitude - a.longitude) * t,
        ));
      }
    }
    resultado.add(puntos.last);
    return resultado;
  }

  void _avanzarSimulacion() {
    if (!mounted) return;
    setState(() {
      if (_avanzando) {
        _indiceActual++;
        if (_indiceActual >= _puntosInterpolados.length - 1) {
          _indiceActual = _puntosInterpolados.length - 1;
          _avanzando = false;
        }
      } else {
        _indiceActual--;
        if (_indiceActual <= 0) {
          _indiceActual = 0;
          _avanzando = true;
        }
      }
      _ultimaActualizacion = DateTime.now();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_puntosInterpolados[_indiceActual]),
    );
  }

  String _tiempoTranscurrido() {
    final segundos =
        DateTime.now().difference(_ultimaActualizacion).inSeconds;
    if (segundos < 2) return 'justo ahora';
    return 'hace $segundos s';
  }

  double _hueDesdeColor(Color color) => HSLColor.fromColor(color).hue;

  @override
  Widget build(BuildContext context) {
    final posicionActual = _puntosInterpolados[_indiceActual];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.unidad.nombre,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: posicionActual,
                zoom: 15.5,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: {
                Marker(
                  markerId: MarkerId(widget.unidad.id),
                  position: posicionActual,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      _hueDesdeColor(widget.unidad.color)),
                  infoWindow: InfoWindow(
                    title: widget.unidad.nombre,
                    snippet: widget.unidad.ruta,
                  ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId('${widget.unidad.id}_ruta'),
                  points: widget.unidad.puntosRuta,
                  color: widget.unidad.color.withOpacity(0.6),
                  width: 4,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapType: MapType.normal,
            ),
          ),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF4ADE80).withOpacity(0.6),
                        blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('En vivo',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF4ADE80),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                'Actualizado ${_tiempoTranscurrido()}',
                style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.unidad.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    color: widget.unidad.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.unidad.nombre,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('Ruta: ${widget.unidad.ruta}',
                        style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}