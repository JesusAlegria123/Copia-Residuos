import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/reporte_model.dart';
import '../services/reporte_service.dart';

class NuevoReporteScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String? distritoInicial;

  const NuevoReporteScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distritoInicial,
  });

  @override
  State<NuevoReporteScreen> createState() => _NuevoReporteScreenState();
}

class _NuevoReporteScreenState extends State<NuevoReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ReporteService _reporteService = ReporteService();

  File? _imagenSeleccionada;
  bool _enviando = false;
  bool _cargandoDistritos = true;
  List<String> _distritos = ReporteService.distritosDefault;
  String? _distritoSeleccionado;

  @override
  void initState() {
    super.initState();
    _distritoSeleccionado = widget.distritoInicial;
    _cargarDistritos();
  }

  Future<void> _cargarDistritos() async {
    final distritos = await _reporteService.obtenerDistritos();
    if (!mounted) return;
    setState(() {
      _distritos = distritos;
      _cargandoDistritos = false;
      if (_distritoSeleccionado != null &&
          !_distritos.contains(_distritoSeleccionado)) {
        _distritoSeleccionado = null;
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (imagen != null && mounted) {
        setState(() => _imagenSeleccionada = File(imagen.path));
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo acceder a la cámara/galería', esError: true);
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFF9333EA)),
              title: Text('Tomar foto', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF9333EA)),
              title: Text('Elegir de galería', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            if (_imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                title: Text('Quitar foto',
                    style: GoogleFonts.poppins(color: const Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagenSeleccionada = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _mostrarMensaje(String mensaje, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
        backgroundColor: esError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _enviarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenSeleccionada == null) {
      _mostrarMensaje('Debes adjuntar una fotografía como evidencia.', esError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);

    try {
      final reporte = await _reporteService.crearReporte(
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        distrito: _distritoSeleccionado!,
        latitud: widget.latitude,
        longitud: widget.longitude,
        foto: _imagenSeleccionada!,
      );

      if (!mounted) return;
      _mostrarMensaje('Reporte registrado correctamente.', esError: false);
      Navigator.pop(context, reporte);
    } on ReporteException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.message, esError: true);
    } catch (_) {
      if (!mounted) return;
      _mostrarMensaje(
        'No se pudo enviar el reporte. Verifica que el backend esté activo.',
        esError: true,
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reportar mal trabajo',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildUbicacionCard(),
            const SizedBox(height: 22),
            _buildTituloField(),
            const SizedBox(height: 18),
            _buildDescripcionField(),
            const SizedBox(height: 18),
            _buildDistritoField(),
            const SizedBox(height: 18),
            _buildCoordenadasCard(),
            const SizedBox(height: 20),
            _buildFotoSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ubicación del incidente',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.address,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Título (opcional)',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tituloController,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration('Ej: Basura mal recogida en la esquina'),
        ),
      ],
    );
  }

  Widget _buildDescripcionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción del incidente *',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 5,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration('Describe qué mal trabajo observaste en la vía pública...'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
            if (v.trim().length < 10) return 'Mínimo 10 caracteres';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDistritoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distrito *',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        _cargandoDistritos
            ? const LinearProgressIndicator(color: Color(0xFF9333EA), minHeight: 2)
            : DropdownButtonFormField<String>(
                value: _distritoSeleccionado,
                dropdownColor: const Color(0xFF1A1A2E),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration('Selecciona el distrito'),
                items: _distritos
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _distritoSeleccionado = v),
                validator: (v) => v == null || v.isEmpty ? 'Selecciona un distrito' : null,
              ),
      ],
    );
  }

  Widget _buildCoordenadasCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location_rounded, color: Colors.white.withOpacity(0.5), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Lat: ${widget.latitude.toStringAsFixed(6)} · Lng: ${widget.longitude.toStringAsFixed(6)}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Evidencia fotográfica *',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _mostrarOpcionesImagen,
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _imagenSeleccionada == null
                    ? Colors.white.withOpacity(0.12)
                    : const Color(0xFF9333EA).withOpacity(0.5),
              ),
            ),
            child: _imagenSeleccionada != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_imagenSeleccionada!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: Colors.white.withOpacity(0.3), size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Toca para adjuntar una foto',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _enviando ? null : _enviarReporte,
        icon: _enviando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded, size: 18),
        label: Text(_enviando ? 'Enviando...' : 'Enviar reporte'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9333EA),
          disabledBackgroundColor: const Color(0xFF9333EA).withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
