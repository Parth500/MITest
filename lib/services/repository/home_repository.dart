import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mi_test/services/models/MAlbum.dart';
import 'package:mi_test/services/models/MProduct.dart';
import '../../utils/common_utils.dart';
import '../../utils/constant.dart';
import '../models/MResponse.dart';

class HomeRepository {
  Future<MResponse> getAlbumList() async {
    MResponse myResponse = MResponse();
    bool isInternetAvailable = await checkInternet();
    try {
      if (isInternetAvailable) {
        var response = await http.get(
          Uri.parse('$API_URL$API_ENDPOINT_GETALBUMS'),
        );

        if (response.statusCode == 200) {
          List<MAlbum> mList = jsonDecode(response.body)
              .map<MAlbum>((element) => MAlbum.fromJson(element))
              .toList();
          myResponse = MResponse(responseCode: 200, data: mList);
        } else {
          myResponse =
              MResponse(responseCode: 400, message: error_somethingWentWrong);
        }
      } else {
        myResponse =
            MResponse(responseCode: 403, message: error_noInternetMessage);
      }
    } catch (e) {
      myResponse = MResponse(responseCode: 501, message: e.toString());
    }
    return myResponse;
  }

  Future<MResponse> getProductList(int albumId) async {
    MResponse myResponse = MResponse();
    bool isInternetAvailable = await checkInternet();
    try {
      if (isInternetAvailable) {
        var response = await http.get(
          Uri.parse('$API_URL$API_ENDPOINT_GETPRODUCT?albumId=$albumId'),
        );

        if (response.statusCode == 200) {
          List<MProduct> mList = jsonDecode(response.body)
              .map<MProduct>((element) => MProduct.fromJson(element))
              .toList();
          myResponse = MResponse(responseCode: 200, data: mList);
        } else {
          myResponse =
              MResponse(responseCode: 400, message: error_somethingWentWrong);
        }
      } else {
        myResponse =
            MResponse(responseCode: 403, message: error_noInternetMessage);
      }
    } catch (e) {
      myResponse = MResponse(responseCode: 501, message: e.toString());
    }
    return myResponse;
  }
}
