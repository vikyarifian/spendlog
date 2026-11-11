class Expense {
  final int? id;
  final String tanggal;
  final String kategori;
  final double nominal;
  final String? catatan;
  final String? nomorBukti;
  final String createdAt;

  Expense({
    this.id,
    required this.tanggal,
    required this.kategori,
    required this.nominal,
    this.catatan,
    this.nomorBukti,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tanggal': tanggal,
      'kategori': kategori,
      'nominal': nominal,
      'catatan': catatan,
      'nomor_bukti': nomorBukti,
      'created_at': createdAt,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      tanggal: map['tanggal'] as String,
      kategori: map['kategori'] as String,
      nominal: (map['nominal'] as num).toDouble(),
      catatan: map['catatan'] as String?,
      nomorBukti: map['nomor_bukti'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Expense copyWith({
    int? id,
    String? tanggal,
    String? kategori,
    double? nominal,
    String? catatan,
    String? nomorBukti,
    String? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      nominal: nominal ?? this.nominal,
      catatan: catatan ?? this.catatan,
      nomorBukti: nomorBukti ?? this.nomorBukti,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
