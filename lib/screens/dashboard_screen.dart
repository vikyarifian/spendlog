import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendlog/models/expense.dart';
import 'package:spendlog/services/csv_exporter.dart';
import 'package:spendlog/services/database_helper.dart';
import 'package:spendlog/screens/add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Expense> _expenses = [];
  Map<String, double> _categoryTotals = {};
  bool _isLoading = true;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final expenses = await DatabaseHelper.instance.getExpensesForMonth(
      _selectedDate.year,
      _selectedDate.month,
    );
    final totals = await DatabaseHelper.instance.getMonthlyCategoryTotals(
      _selectedDate.year,
      _selectedDate.month,
    );

    setState(() {
      _expenses = expenses;
      _categoryTotals = totals;
      _isLoading = false;
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + increment,
        1,
      );
    });
    _loadData();
  }

  Future<void> _exportCsv() async {
    if (_expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diexport')),
      );
      return;
    }

    final csvData = CsvExporter.exportToCsv(_expenses);
    final monthStr = DateFormat('yyyy_MM').format(_selectedDate);
    final filename = 'kasbon_export_$monthStr.csv';
    final file = await CsvExporter.saveCsvToLocalFile(csvData, filename);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File CSV berhasil disimpan: ${file.path}')),
      );
    }
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadData();
  }

  double get _totalExpense {
    return _categoryTotals.values.fold(0.0, (sum, val) => sum + val);
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasbon & Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Total Pengeluaran Bulan Ini',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormatter.format(_totalExpense),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  if (_categoryTotals.isNotEmpty) ...[
                    const Divider(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: _categoryTotals.entries.map((entry) {
                        return Chip(
                          label: Text(
                            '${entry.key}: ${_currencyFormatter.format(entry.value)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.shade50,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada catatan pengeluaran.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF00897B),
                                child: Text(
                                  expense.kategori.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                _currencyFormatter.format(expense.nominal),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${expense.tanggal} | ${expense.kategori}'),
                                  if (expense.catatan != null && expense.catatan!.isNotEmpty)
                                    Text(
                                      'Catatan: ${expense.catatan}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  if (expense.nomorBukti != null && expense.nomorBukti!.isNotEmpty)
                                    Text(
                                      'No. Bukti: ${expense.nomorBukti}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  if (expense.id != null) {
                                    _deleteExpense(expense.id!);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kasbon'),
      ),
    );
  }
}
