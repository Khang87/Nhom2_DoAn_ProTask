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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT UNIQUE,
            uid TEXT,
            phone TEXT,
            photoUrl TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE projects(
            id TEXT PRIMARY KEY,
            name TEXT,
            description TEXT,
            ownerId TEXT,
            members TEXT,
            progress REAL,
            deadline TEXT,
            color INTEGER,
            link TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            projectId TEXT,
            title TEXT,
            description TEXT,
            assigneeId TEXT,
            status TEXT,
            deadline TEXT,
            isDone INTEGER,
            FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE projects(
              id TEXT PRIMARY KEY,
              name TEXT,
              description TEXT,
              ownerId TEXT,
              members TEXT,
              progress REAL,
              deadline TEXT,
              color INTEGER,
              link TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE tasks(
              id TEXT PRIMARY KEY,
              projectId TEXT,
              title TEXT,
              description TEXT,
              assigneeId TEXT,
              status TEXT,
              deadline TEXT,
              isDone INTEGER,
              FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
            )
          ''');
          await db.execute('ALTER TABLE users ADD COLUMN photoUrl TEXT');
        }
      },
    );
  }

  // --- PROJECT OPERATIONS ---
  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    return await db.insert('projects', project, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await database;
    return await db.query('projects');
  }

  Future<int> deleteProject(String id) async {
    final db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // --- TASK OPERATIONS ---
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTasksByProject(String projectId) async {
    final db = await database;
    return await db.query('tasks', where: 'projectId = ?', whereArgs: [projectId]);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<int> updateTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
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