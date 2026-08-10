import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class AdjustmentDialog extends StatefulWidget {
  final InventoryItem item;
  final Function(int diff, String reason) onSave;

  const AdjustmentDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<AdjustmentDialog> createState() => _AdjustmentDialogState();
}

class _AdjustmentDialogState extends State<AdjustmentDialog> {
  // Clave del formulario para manejar las validaciones
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _diffController;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();

    _diffController = TextEditingController(text: widget.item.unitDiff.toString());
    final currentReason = widget.item.reason.toUpperCase();

    if (currentReason == 'FALTANTE' || currentReason == 'SOBRANTE') {
      _selectedReason = currentReason;
    }
  }

  @override
  void dispose() {
    _diffController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final int diff = int.tryParse(_diffController.text) ?? 0;
      Navigator.pop(context);
      widget.onSave(diff, _selectedReason!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajustar Inventario', textAlign: TextAlign.center),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 2),
            const SizedBox(height: 10),
            Text(
              widget.item.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const Divider(),
            const SizedBox(height: 8),
            TextFormField(
              controller: _diffController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de unidades (Diferencia)',
                hintText: 'Ej: 5',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Debe ingresar una cantidad';
                }
                if (int.tryParse(value) == null) {
                  return 'Debe ser un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              decoration: const InputDecoration(
                labelText: 'Tipo de ajuste',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Seleccione...')),
                DropdownMenuItem(value: 'FALTANTE', child: Text('Falta')),
                DropdownMenuItem(value: 'SOBRANTE', child: Text('Sobra')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedReason = val);
                }
              },
              validator: (val) {
                if (val == null) {
                  return 'Debe seleccionar un motivo';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
          child: const Text('GUARDAR', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
