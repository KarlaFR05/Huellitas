import 'package:flutter/material.dart';

class OrganizacionVerificadaBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const OrganizacionVerificadaBadge({super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      color: color ?? const Color(0xFF22C55E),
      size: size,
    );
  }
}