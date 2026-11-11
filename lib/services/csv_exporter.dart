import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spendlog/models/expense.dart';

class CsvExporter {
  static String exportToCsv(List<Expense> expenses) {
    final List<String> rows = [];
    rows.add('ID,Tanggal,Kategori,Nominal,Catatan,Nomor Bukti,Created At');

    for (var expense in expenses) {
      final id = expense.id != null ? expense.id.toString() : '';
      final tanggal = _cleanField(expense.tanggal);
      final kategori = _cleanField(expense.kategori);
      final nominal = expense.nominal.toStringAsFixed(0);
      final catatan = _cleanField(expense.catatan ?? '');
      final nomorBukti = _cleanField(expense.nomorBukti ?? '');
      final createdAt = _cleanField(expense.createdAt);

      rows.add('$id,$tanggal,$kategori,$nominal,$catatan,$nomorBukti,$createdAt');
    }

    return rows.join('\n');
  }

  static Future<File> saveCsvToLocalFile(String csvContent, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    return await file.writeAsString(csvContent);
  }

  static String _cleanField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }
}
