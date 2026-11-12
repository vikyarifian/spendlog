import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spendlog/models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _dbFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _dbFuture ??= _initDB('spendlog.db');
    _database = await _dbFuture;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        kategori TEXT NOT NULL,
        nominal REAL NOT NULL,
        catatan TEXT,
        nomor_bukti TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kode TEXT UNIQUE NOT NULL
      )
    ''');

    final defaultCategories = [
      {'nama': 'Transport', 'kode': 'TRP'},
      {'nama': 'Parkir', 'kode': 'PRK'},
      {'nama': 'Makan', 'kode': 'MKN'},
      {'nama': 'Tol', 'kode': 'TOL'},
      {'nama': 'Operasional', 'kode': 'OPS'},
      {'nama': 'Lain-lain', 'kode': 'LLN'},
    ];

    for (var cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    final db = await instance.database;
    final monthStr = month.toString().padLeft(2, '0');
    final monthPattern = '$year-$monthStr%';

    final result = await db.query(
      'expenses',
      where: 'tanggal LIKE ?',
      whereArgs: [monthPattern],
      orderBy: 'tanggal DESC, id DESC',
    );

    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<Map<String, double>> getMonthlyCategoryTotals(int year, int month) async {
    final db = await instance.database;
    final monthStr = month.toString().padLeft(2, '0');
    final monthPattern = '$year-$monthStr%';

    final result = await db.rawQuery('''
      SELECT kategori, SUM(nominal) as total
      FROM expenses
      WHERE tanggal LIKE ?
      GROUP BY kategori
    ''', [monthPattern]);

    final Map<String, double> categoryTotals = {};
    for (var row in result) {
      final category = row['kategori'] as String;
      final total = (row['total'] as num).toDouble();
      categoryTotals[category] = total;
    }

    return categoryTotals;
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories', orderBy: 'nama ASC');
  }
}
