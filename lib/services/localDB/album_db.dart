import 'package:mi_test/services/localDB/my_local_db.dart';
import 'package:mi_test/services/models/MAlbum.dart';

const String tableAlbum = "TBL_Album";
const String tb_al_columnId = "id";
const String tb_al_columnTitle = "title";
const String tb_al_columnUserId = "userId";

class AlbumDB {
  final createAlbumTable = '''
              CREATE TABLE $tableAlbum(
                    $tb_al_columnId INTEGER PRIMARY KEY,
                    $tb_al_columnTitle TEXT,
                    $tb_al_columnUserId INTEGER)
              ''';

  //--------------- Album Table -----------------//

  //Insert in Album Table
  insertAlbums(MAlbum mAlbumInfo) async {
    var db = await MyLocalDB.database;

    MAlbum? mAlbum = await getAlbum(mAlbumInfo);

    if (mAlbum == null) {
      await db.insert(tableAlbum, mAlbumInfo.toJson());
    } else {
      String whereString = '$tb_al_columnId = ?';

      List<dynamic> whereArguments = [mAlbumInfo.id];

      await db.update(tableAlbum, mAlbumInfo.toJson(),
          where: whereString, whereArgs: whereArguments);
    }
  }

  //Get Album
  Future<MAlbum?> getAlbum(MAlbum mAlbumInfo) async {
    var db = await MyLocalDB.database;

    String whereString = '$tb_al_columnId = ?';
    List<dynamic> whereArguments = [mAlbumInfo.id];

    var result = await db.query(tableAlbum,
        where: whereString, whereArgs: whereArguments);
    return (result.isNotEmpty) ? MAlbum.fromJson(result[0]) : null;
  }

  //GetAll From Album Table
  Future<List<MAlbum>> getAlbumList(int startId) async {
    var db = await MyLocalDB.database;

    String whereString = '$tb_al_columnId >= ?';
    List<dynamic> whereArguments = [startId];

    var result = await db.query(tableAlbum,
        where: whereString, whereArgs: whereArguments, limit: 10);
    return result.map((e) => MAlbum.fromJson(e)).toList();
  }

  //GetAll From Album Table
  Future<int> getTotalCount() async {
    var db = await MyLocalDB.database;
    var result = await db.query(tableAlbum);
    return result.length;
  }

  //Remove Albums Table
  void clearAlbumsTable() async {
    var db = await MyLocalDB.database;
    await db.delete(tableAlbum);
  }
}
