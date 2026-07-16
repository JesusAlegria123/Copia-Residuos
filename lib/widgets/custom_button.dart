import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Botón principal animado con gradiente morado y estado de carga
class CustomButton extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final double ancho;
  final IconData? icono;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.ancho = double.infinity,
    this.icono,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 130),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) => _animController.reverse(),
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          width: widget.ancho,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF6B21A8), Color(0xFF9333EA), Color(0xFFB06EF5)],
              stops: [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B21A8).withOpacity(0.55),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: widget.cargando ? null : widget.onPressed,
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.transparent,
              child: Center(
                child: widget.cargando
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icono != null) ...[
                      Icon(widget.icono,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.texto,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}