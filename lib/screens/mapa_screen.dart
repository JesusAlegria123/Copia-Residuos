import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';
import 'Nuevo_reporte_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  String _address = 'Selecciona un punto en el mapa';
  String? _distrito;
  bool _isLoading = true;
  bool _isSelecting = false;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentLocation();
    if (!mounted) return;

    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = latLng;
        _selectedPosition = latLng;
        _isLoading = false;
        _isSelecting = false;
      });
      _addMarker(latLng);
      _getAddress(latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo obtener tu ubicación. Verifica el GPS y los permisos.',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: position,
            infoWindow: const InfoWindow(title: 'Ubicación seleccionada'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );
    });
  }

  Future<void> _getAddress(LatLng position) async {
    final address = await _locationService.getAddressFromLatLng(
      position.latitude,
      position.longitude,
    );
    final distrito = await _locationService.getDistritoFromLatLng(
      position.latitude,
      position.longitude,
    );
    if (!mounted) return;
    setState(() {
      _address = address;
      _distrito = distrito;
    });
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _isSelecting = true;
    });
    _addMarker(position);
    _getAddress(position);
  }

  void _openInGoogleMaps() {
    if (_selectedPosition != null) {
      _locationService.openInGoogleMaps(
        _selectedPosition!.latitude,
        _selectedPosition!.longitude,
      );
    }
  }

  Future<void> _continuarConReporte() async {
    if (_selectedPosition == null) return;

    final reporteData = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => NuevoReporteScreen(
          latitude: _selectedPosition!.latitude,
          longitude: _selectedPosition!.longitude,
          address: _address,
          distritoInicial: _distrito,
        ),
      ),
    );

    // Si el usuario completó y envió el formulario, devolvemos el reporte al listado.
    if (reporteData != null && mounted) {
      Navigator.pop(context, reporteData);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Mapa · Reporte de Ubicación',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Color(0xFF9333EA)),
            onPressed: _getCurrentLocation,
            tooltip: 'Mi ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9333EA),
                strokeWidth: 2.5,
              ),
            )
          else if (_currentPosition == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo obtener la ubicación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 16.0,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onTap: _onMapTap,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),
                ),
                _buildInfoPanel(),
              ],
            ),
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
              Icon(
                Icons.location_on_rounded,
                color: _isSelecting
                    ? const Color(0xFF9333EA)
                    : const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _address,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                  _selectedPosition == null ? null : _openInGoogleMaps,
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: Text('Ver en Google Maps',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
              _selectedPosition == null ? null : _continuarConReporte,
              icon: const Icon(Icons.report_problem_rounded, size: 18),
              label: const Text('Reportar este lugar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                disabledBackgroundColor:
                const Color(0xFF9333EA).withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}