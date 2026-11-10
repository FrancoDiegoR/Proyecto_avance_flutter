import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Etiqueta "SAFE" / "CRITICAL": texto de color sobre fondo suave del mismo color.
class StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const StatusPill(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(text.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

/// Icono dentro de un cuadrado redondeado de color suave.
class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconTile(this.icon, {this.color = AppColors.blue, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}

/// Tarjeta pequena de metrica ("Zones 4").
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatCard(this.label, this.value, {this.valueColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }
}

/// Mensaje de error con boton para reintentar.
class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetry(this.message, this.onRetry, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

/// Icono segun el nombre de la zona (igual que en Android).
IconData zoneIcon(String name) {
  final text = name.toLowerCase();
  if (['fryer', 'freidora'].any(text.contains)) return Icons.local_fire_department_outlined;
  if (['storage', 'cylinder', 'warehouse', 'almac'].any(text.contains)) return Icons.inventory_2_outlined;
  if (['bar', 'dessert'].any(text.contains)) return Icons.local_bar_outlined;
  if (['dining', 'comedor'].any(text.contains)) return Icons.restaurant_outlined;
  if (['kitchen', 'cocina'].any(text.contains)) return Icons.kitchen_outlined;
  return Icons.sensors;
}
