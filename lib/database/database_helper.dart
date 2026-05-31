import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'protask.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            uid TEXT,
            phone TEXT -- Thêm cột này
          )
        ''');
      },
    );
  }
  // Thêm vào class DatabaseHelper
  Future<int> updateUserField(String email, String field, String value) async {
    final db = await database;
    return await db.update(
      'users',
      {field: value},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // 🔥 Thêm hoặc cập nhật user (dùng cho Firebase sync)
  Future<void> insertOrUpdateUser({
    required String email,
    required String uid,
    String? username,
    String? phone, // Thêm tham số phone
  }) async {
    final db = await database;
    final existingUser = await getUserByEmail(email);

    if (existingUser == null) {
      await db.insert('users', {
        'email': email,
        'uid': uid,
        'username': username ?? '',
        'phone': phone ?? '', // Lưu phone khi tạo mới
      });
    } else {
      await db.update(
        'users',
        {
          'uid': uid,
          'username': username ?? existingUser['username'],
          'phone': phone ?? existingUser['phone'], // Cập nhật phone nếu có
        },
        where: 'email = ?',
        whereArgs: [email],
      );
    }
  }

  // 🔥 Lấy user theo email (QUAN TRỌNG)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // 🔥 Lấy user theo UID (xịn hơn nếu dùng Firebase)
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // 🔥 Xóa toàn bộ user (logout sạch)
  Future<void> clearAllUsers() async {
    final db = await database;
    await db.delete('users');
    print("Đã xóa sạch dữ liệu SQLite!");
  }

  // 🔥 Xóa 1 user
  Future<void> deleteUser(String email) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}