import '../models/MProduct.dart';
import 'my_local_db.dart';

const String tableProduct = "TBL_Product";
const String tb_pr_columnId = "id";
const String tb_pr_columnTitle = "title";
const String tb_pr_columnAlbumId = "albumId";
const String tb_pr_columnURL = "url";
const String tb_pr_columnThumbnailURL = "thumbnailUrl";

class ProductDB {
  final createProductTable = '''
              CREATE TABLE $tableProduct(
                    $tb_pr_columnId INTEGER PRIMARY KEY,
                    $tb_pr_columnTitle TEXT,
                    $tb_pr_columnAlbumId INTEGER,
                    $tb_pr_columnURL TEXT,
                    $tb_pr_columnThumbnailURL TEXT)
              ''';

  //--------------- Product Table -----------------//

  //Insert in Product Table
  insertProducts(MProduct mProductInfo) async {
    var db = await MyLocalDB.database;

    MProduct? mProduct = await getProductByInfo(mProductInfo);

    if (mProduct == null) {
      await db.insert(tableProduct, mProductInfo.toJson());
    } else {
      String whereString = '$tb_pr_columnId = ?';

      List<dynamic> whereArguments = [mProductInfo.id];

      await db.update(tableProduct, mProductInfo.toJson(),
          where: whereString, whereArgs: whereArguments);
    }
  }

  //Get Product
  Future<MProduct?> getProductByInfo(MProduct mProductInfo) async {
    var db = await MyLocalDB.database;

    String whereString = '$tb_pr_columnId = ?';
    List<dynamic> whereArguments = [mProductInfo.id];

    var result = await db.query(tableProduct,
        where: whereString, whereArgs: whereArguments);
    return (result.isNotEmpty) ? MProduct.fromJson(result[0]) : null;
  }

  //GetAll From Product Table
  Future<List<MProduct>> getProductList(int albumId, int startId) async {
    var db = await MyLocalDB.database;

    String whereString = '$tb_pr_columnAlbumId = ? AND $tb_pr_columnId >= ?';
    List<dynamic> whereArguments = [albumId, startId];

    var result = await db.query(tableProduct,
        where: whereString, whereArgs: whereArguments, limit: 10);
    return result.map((e) => MProduct.fromJson(e)).toList();
  }

  //Remove Products Table
  void clearProductsTable() async {
    var db = await MyLocalDB.database;
    await db.delete(tableProduct);
  }
}
