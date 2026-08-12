class InventoryItem {
  final int id;
  final String code;
  final String description;
  final String brand;
  final String category;
  final String responsible;
  final String reason;
  final String location;
  final String verification;
  final int booking;
  final int physical;
  final int existence;
  final int unitDiff;
  final String startDate;
  final String endDate;

  InventoryItem({
    required this.id,
    required this.code,
    required this.description,
    required this.brand,
    required this.category,
    required this.responsible,
    required this.reason,
    required this.location,
    required this.verification,
    required this.booking,
    required this.physical,
    required this.existence,
    required this.unitDiff,
    required this.startDate,
    required this.endDate,
  });

  /// Crea una instancia de InventoryItem a partir de un JSON (respuesta de la API)
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '-',
      description: json['description']?.toString() ?? '-',
      brand: json['brand']?.toString() ?? '-',
      category: json['category']?.toString() ?? '-',
      responsible: json['responsible']?.toString() ?? '-',
      reason: json['reason']?.toString() ?? 'S/N',
      location: json['location']?.toString() ?? 'S/N',
      verification: json['verification']?.toString() ?? '',
      booking: int.tryParse(json['booking']?.toString() ?? '0') ?? 0,
      physical: int.tryParse(json['physical']?.toString() ?? '0') ?? 0,
      existence: int.tryParse(json['existence']?.toString() ?? '0') ?? 0,
      unitDiff: int.tryParse(json['unit_diff']?.toString() ?? '0') ?? 0,
      startDate: (json['start_date']?.toString() ?? '-').split(' ')[0],
      endDate: (json['end_date']?.toString() ?? '-').split(' ')[0],
    );
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return code.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        brand.toLowerCase().contains(q) ||
        responsible.toLowerCase().contains(q) ||
        reason.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }
}
