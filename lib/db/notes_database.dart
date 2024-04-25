import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:midterm2_shafina/model/note.dart';

class NotesDatabase{
  //global field
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  //private constructor
  NotesDatabase._init();

  //create new db
  Future<Database> get database async{
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database! ;
  }

  Future<Database> _initDB(String filepath) async{
    //where its store the db to local storage
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async{
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';
    final doubleType = 'REAL NOT NULL';

    await db.execute("""
      CREATE TABLE $tableNotes (
        ${NoteFields.id} $idType,
        ${NoteFields.isImportant} $boolType,
        ${NoteFields.number} $integerType,
        ${NoteFields.title} $textType,
        ${NoteFields.description} $textType,
        ${NoteFields.time} $textType,
        ${NoteFields.rating} $doubleType DEFAULT 1
      )
    """);
  }

  Future<Note> create(Note note) async{
    final db = await instance.database;

    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  // Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     // Add the 'rating' column if it doesn't exist
  //     await db.execute("ALTER TABLE notes ADD COLUMN ${NoteFields.rating} REAL NOT NULL DEFAULT 1");
  //   }
  // }

  Future<Note> readNote(int id) async{
    final db = await instance.database;
    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty){
      return Note.fromJson(maps.first);
    }
    else{
      throw Exception('ID $id not found');
    }

  }

  Future<List<Note>> readAllNotes() async{
    final db = await instance.database;

    final orderBy = '${NoteFields.time} ASC';
    // final result  = await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');
    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note) async{
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async{
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],

    );
  }

  Future close() async{
    final db = await instance.database;

    db.close();
  }



}