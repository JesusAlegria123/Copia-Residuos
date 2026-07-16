import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de texto personalizado con diseño glassmorphism oscuro
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool esPassword;
  final String? Function(String?)? validator;
  final TextInputType tipoTeclado;
  final TextInputAction accionTeclado;
  final VoidCallback? onEditingComplete;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.esPassword = false,
    this.validator,
    this.tipoTeclado = TextInputType.text,
    this.accionTeclado = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _mostrarPassword = false;
  bool _enFoco = false;

  late AnimationController _animController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _enFoco = hasFocus);
        if (hasFocus) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              // Borde con brillo al enfocar
              boxShadow: _enFoco
                  ? [
                BoxShadow(
                  color: const Color(0xFF9333EA)
                      .withOpacity(0.35 * _glowAnim.value),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.esPassword && !_mostrarPassword,
              keyboardType: widget.tipoTeclado,
              textInputAction: widget.accionTeclado,
              onEditingComplete: widget.onEditingComplete,
              validator: widget.validator,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.3,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText.toUpperCase(),
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(
                    widget.prefixIcon,
                    color: _enFoco
                        ? const Color(0xFF9333EA)
                        : Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                ),
                suffixIcon: widget.esPassword
                    ? IconButton(
                  icon: Icon(
                    _mostrarPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withOpacity(0.35),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _mostrarPassword = !_mostrarPassword);
                  },
                )
                    : null,
                filled: true,
                fillColor: _enFoco
                    ? Colors.white.withOpacity(0.10)
                    : Colors.white.withOpacity(0.06),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFF9333EA),
                    width: 1.8,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}