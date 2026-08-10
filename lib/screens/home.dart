import 'dart:async';
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../widgets/record_card.dart';
import '../widgets/adjustment_dialog.dart';

class InventoryScreen extends StatefulWidget {
  final String responsibleName;
  const InventoryScreen({super.key, required this.responsibleName});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _service = InventoryService();
  final TextEditingController _searchController = TextEditingController();

  List<InventoryItem> _allRecords = [];
  List<InventoryItem> _filteredRecords = [];

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _service.fetchAll(widget.responsibleName);
      if (!mounted) return;
      setState(() {
        _allRecords = data;
        _filteredRecords = data;
        _isLoading = false;
      });
    } on TimeoutException {
      _setError('Tiempo de espera agotado. Verifique su conexión.');
    } catch (e) {
      _setError('Error de conexión o de datos.');
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
  }

  void _filterData() {
    final query = _searchController.text;
    setState(() {
      _filteredRecords = _allRecords.where((item) => item.matchesQuery(query)).toList();
    });
  }

  Future<void> _updateRecord(int id, int diff, String reason, {String? status}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _service.updateRecord(id: id, diff: diff, reason: reason, status: status);
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['mensaje'] ?? 'Registro actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error'), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmCorrect(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Confirmar Inventario?'),
        content: Text('¿Está seguro de verificar "${item.description}" sin diferencias?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateRecord(item.id, 0, 'SIN DIFERENCIAS', status: 'V');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
            child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AdjustmentDialog(
        item: item,
        onSave: (diff, reason) => _updateRecord(item.id, diff, reason, status: 'A'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Registros de Inventario'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar producto, código, marca...',
                prefixIcon: Icon(Icons.search, color: Colors.green.shade600),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.green.shade600),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)));
    }
    if (_filteredRecords.isEmpty) {
      return const Center(child: Text('No se encontraron registros.', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: _filteredRecords.length,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemBuilder: (context, index) {
        final item = _filteredRecords[index];
        return RecordCard(
          item: item,
          onCorrect: () => _confirmCorrect(item),
          onAdjust: () => _showAdjustmentDialog(item),
        );
      },
    );
  }
}
