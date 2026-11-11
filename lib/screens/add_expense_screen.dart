import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendlog/models/expense.dart';
import 'package:spendlog/services/database_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  final _nomorBuktiController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['nama'] as String;
      }
      _isLoadingCategories = false;
    });
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _catatanController.dispose();
    _nomorBuktiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final nominal = double.tryParse(_nominalController.text.trim()) ?? 0.0;
    final tanggalStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final nowStr = DateTime.now().toIso8601String();

    final expense = Expense(
      tanggal: tanggalStr,
      kategori: _selectedCategory!,
      nominal: nominal,
      catatan: _catatanController.text.trim().isEmpty ? null : _catatanController.text.trim(),
      nomorBukti: _nomorBuktiController.text.trim().isEmpty ? null : _nomorBuktiController.text.trim(),
      createdAt: nowStr,
    );

    await DatabaseHelper.instance.insertExpense(expense);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tanggal'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                      ),
                      items: _categories.map((cat) {
                        final nama = cat['nama'] as String;
                        return DropdownMenuItem<String>(
                          value: nama,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      validator: (val) => val == null ? 'Pilih kategori' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal (Rp)',
                        prefixText: 'Rp ',
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nominal wajib diisi';
                        }
                        if (double.tryParse(val.trim()) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomorBuktiController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Bukti / Kuitansi (opsional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveExpense,
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
