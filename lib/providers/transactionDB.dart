// import 'dart:io';
// import 'package:dorm_app/model/Userprofile.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sembast/sembast.dart';
// import 'package:sembast/sembast_io.dart';

// class TransactionDB {
//   String dbName;

//   TransactionDB({required this.dbName});

//   Future<Database> openDatabase() async {
//     Directory appDirectory = await getApplicationDocumentsDirectory();
//     String dbLocation = join(appDirectory.path, dbName);
//     DatabaseFactory dbFactory = databaseFactoryIo;
//     Database db = await dbFactory.openDatabase(dbLocation);
//     return db;
//   }

//   Future<int> insertData(UserProfile profile) async {
//     var db = await openDatabase();
//     var store = intMapStoreFactory.store("profiles");

//     var keyID = await store.add(db, {
//       "userfname": profile.firstname,
//       "userlname": profile.lastname,
//       "numphone": profile.numphone,
//     });

//     await db.close();
//     return keyID;
//   }

//   Future<Map<String, Object?>> updateData(UserProfile profile, int id) async {
//     var db = await openDatabase();
//     var store = intMapStoreFactory.store("profiles");

//     var keyID = await store.record(id).update(db, {
//       "userfname": profile.userfname,
//       "userlname": profile.userlname,
//       "numphone": profile.numphone,
//     });

//     await db.close();
//     return keyID!;
//   }

//   Future<List<UserProfile>> loadAllData() async {
//     var db = await openDatabase();
//     var store = intMapStoreFactory.store("profiles");
//     var snapshot = await store.find(db);

//     List<UserProfile> profileList = [];
// for (var record in snapshot) {
//   profileList.add(UserProfile(
//     iduser: int.parse(record['iduser'].toString()),
//     role: int.parse(record['role'].toString()),
//     email: record['email'].toString(),
//     password: record['password'].toString(),
//     userfname: record['userfname'].toString(),
//     userlname: record['userlname'].toString(),
//     numphone: num.parse(record['numphone'].toString()), // If numphone is a number
//   ));
// }


//     await db.close();
//     return profileList;
//   }

//   Future<void> addProfile(UserProfile profile) async {
//     await insertData(profile);
//   }

//   Future<void> initProfiles() async {
//     await loadAllData();
//   }
// }


