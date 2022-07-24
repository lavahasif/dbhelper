import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'doggie_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // Define a function that inserts dogs into the database
  Future<void> insertDog(Dog dog) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Dog>> dogs() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  Future<void> updateDog(Dog dog) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    await db.update(
      'dogs',
      dog.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [dog.id],
    );
  }

  Future<void> deleteDog(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the Dog from the database.
    await db.delete(
      'dogs',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

  // Create a Dog and add it to the dogs table
  var fido = const Dog(
    id: 0,
    name: 'Fido',
    age: 35,
  );

  await insertDog(fido);

  // Now, use the method above to retrieve all the dogs.
  print(await dogs()); // Prints a list that include Fido.

  // Update Fido's age and save it to the database.
  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + 7,
  );
  await updateDog(fido);

  // Print the updated results.
  print(await dogs()); // Prints Fido with age 42.

  // Delete Fido from the database.
  await deleteDog(fido.id);

  // Print the list of dogs (empty).
  print(await dogs());
}

class Dog {
  final int id;
  final String name;
  final int age;

  const Dog({
    required this.id,
    required this.name,
    required this.age,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}

class DbHelper {
  //podesavanje singltona 1/3
  static final DbHelper _dbHelper = DbHelper._internal();

  //table name
  String tblName = "todo";

  //columns
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";

  //podesavanje singltona 2/3
  DbHelper._internal();

  //podesavanje singltona 3/3
  factory DbHelper() {
    return _dbHelper;
  }

  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  //za ovo koristimo 'dart:io';
  Future<Database> initializeDb() async {
    // Directory dir = await getDatabasesPath;
    var s = await getDatabasesPath();
    String path = s + "todos.db";
    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblName($colId INTEGER PRIMARY KEY, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)");
  }

  Future<int?> insertTodo(Todo todo) async {
    Database? db = await this.db;
    var result = await db?.insert(tblName, todo.toMap());
    return result;
  }

  Future<List<Map<String, Object?>>?> getTodos() async {
    Database? db = await this.db;
    var result =
        await db?.rawQuery("SELECT * FROM $tblName order by $colPriority ASC");
    return result;
  }

  Future<int?> getCount() async {
    Database? db = await this.db;
    var list = (await db?.rawQuery("SELECT COUNT(*) FROM $tblName"));
    var result = Sqflite.firstIntValue(list!);
    return result;
  }

  Future<int?> updateTodo(Todo todo) async {
    Database? db = await this.db;
    var result = await db?.update(tblName, todo.toMap(),
        where: "$colId = ?", whereArgs: [todo.id]);
    return result;
  }

  Future<int?> deleteTodo(int id) async {
    Database? db = await this.db;
    var result = await db?.rawDelete("DELETE FROM $tblName WHERE $colId =  $id");
    return result;
  }
}

class Todo {
  //_ se stavlja zato da budu privatni
  int? _id;
  String? _title;
  String? _description;
  String? _date;
  int? _priority;

  //postavljanje konstruktora, ne moze isti vise puta, opcioni ide u []
  Todo(this._title, this._priority, this._date, this._description);

  Todo.withId(
      this._id, this._title, this._priority, this._date, this._description);

  //geteri
  int? get id => _id;

  String? get title => _title;

  String? get description => _description;

  String? get date => _date;

  int? get priority => _priority;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["title"] = _title;
    map["description"] = _description;
    map["priority"] = _priority;
    map["date"] = _date;

    if (_id != null) {
      map["id"] = _id;
    }

    return map;
  }

  Todo.fromObject(dynamic o) {
    _id = o["id"] ?? "";
    _title = o["title"] ?? "";
    _description = o["description"] ?? "";
    _date = o["date"] ?? "";
    _priority = o["priority"] ?? "";
  }
}
