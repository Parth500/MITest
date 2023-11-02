import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_test/bloc/home/product_event.dart';
import 'package:mi_test/bloc/home/product_state.dart';

import '../../services/localDB/product_db.dart';
import '../../services/models/MAlbum.dart';
import '../../services/models/MProduct.dart';
import '../../services/models/MResponse.dart';
import '../../services/repository/home_repository.dart';
import '../../utils/constant.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  late ProductDB mProductDB;
  List<MAlbum> listProducts = [];

  //Product ----------------------------------------------------------------------
  //Stream - ProductList
  final _productListStreamController = StreamController<List<MProduct>>();

  StreamSink<List<MProduct>> get productListSink =>
      _productListStreamController.sink;

  ProductBloc() : super(HomeProductInitialState()) {
    mProductDB = ProductDB();
    on<HomeProductFetchEvent>((event, emit) async =>
        await productFetchFromDB(event, emit, event.albumId, 1));
    on<HomeProductLoadMoreEvent>((event, emit) async =>
        await productLoadMore(event, emit, event.albumId, event.strIndex));
  }

  //Product List -- Local DB
  productFetchFromDB(
      ProductEvent event, Emitter emit, int albumId, int startIndex) async {
    List<MProduct> mListT = await bindProductFromLocalDB(albumId, startIndex);
    if (mListT.isNotEmpty) {
      callProductSuccessEmit(emit, albumId, mListT, false);
    } else {
      await HomeRepository().getProductList(albumId).then((mResponse) {
        if (mResponse.responseCode == 200) {
          mResponse.data
              .forEach((element) => {mProductDB.insertProducts(element)});
          callProductSuccessEmit(emit, albumId, mResponse.data, false);
        } else {
          //Don't has LocalData and Error
          String errMsg = mResponse.message ?? error_somethingWentWrong;
          emit(HomeProductErrorState(errMsg));
        }
      });
    }
  }

  //Load More Products ----
  Future<void> productLoadMore(
      ProductEvent event, Emitter emit, int albumId, int strIndex) async {
    if (strIndex >= 50) {
      strIndex = 1;
    }
    listProducts.where((element) => (element.id == albumId)).single.pageCount =
        strIndex;

    List<MProduct> mListT = await bindProductFromLocalDB(albumId, strIndex);
    if (mListT.isEmpty) {
      HomeRepository().getProductList(albumId).then((mResponse) async {
        if (mResponse.responseCode == 200) {
          mResponse.data.forEach((element) {
            mProductDB.insertProducts(element);
          });
          mListT = mResponse.data;
        }
      });
    } else {
      callProductSuccessEmit(emit, albumId, mListT, true);
      listProducts.where((element) => (element.id == albumId)).single.isLoadMorePending =
          false;
    }
  }

  callProductSuccessEmit(
      Emitter emit, int albumId, List<MProduct> mListT, bool isLoadMore) {
    List<MProduct> list = [];
    MAlbum mAlbum = listProducts.singleWhere(
        (element) => (element.id == albumId),
        orElse: () => MAlbum());
    if (mAlbum.listProduct.isNotEmpty) {
      list.addAll(mAlbum.listProduct);
    } else {
      listProducts.add(MAlbum.productPosition(
        id: albumId,
        pageCount: 1,
        listProduct: mListT,
      ));
    }
    list.addAll(mListT);
    productListSink.add(list);
    if (!isLoadMore) {
      emit(HomeProductSuccessState(_productListStreamController.stream));
    }
  }

  //Bind UI List with LocalDB
  Future<List<MProduct>> bindProductFromLocalDB(albumId, strIndex) async {
    return await mProductDB.getProductList(albumId, strIndex);
  }

  @override
  Future<void> close() {
    _productListStreamController.close();
    return super.close();
  }
}
