import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class RecordCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onCorrect;
  final VoidCallback onAdjust;

  const RecordCard({
    super.key,
    required this.item,
    required this.onCorrect,
    required this.onAdjust,
  });

  Color _getReasonColor(String reason) {
    final upperReason = reason.toUpperCase();
    if (upperReason.contains('FALTANTE')) return Colors.red.shade600;
    if (upperReason.contains('SOBRANTE')) return Colors.green.shade600;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final hasVerification = item.verification.trim().isNotEmpty && item.verification != 'null';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.code,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Chip(
                  label: Text(
                    item.reason,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: _getReasonColor(item.reason),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Detalles del producto
            Text(item.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Marca: ${item.brand}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            Text("Categoría: ${item.category}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            Text("Ubicación: ${item.location}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(item.responsible, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      if (hasVerification) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined, size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hasVerification ? item.verification : 'Sin diferencias',
                                style: const TextStyle(fontSize: 13, color: Colors.blue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          const TextSpan(text: "Dif: "),
                          TextSpan(
                            text: "${item.unitDiff}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.unitDiff == 0 ? Colors.green.shade700 : Colors.red,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("${item.startDate} / ${item.endDate}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            if (!hasVerification) ...[
              const Divider(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('VERIFICAR'),
                      onPressed: onCorrect,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(color: Colors.green.shade700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('AJUSTAR'),
                      onPressed: onAdjust,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
