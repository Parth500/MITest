import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_test/services/localDB/album_db.dart';
import 'package:mi_test/services/localDB/product_db.dart';
import 'package:mi_test/services/models/MAlbum.dart';
import 'package:mi_test/services/models/MProduct.dart';
import 'package:mi_test/services/models/MResponse.dart';
import 'package:mi_test/services/repository/home_repository.dart';
import 'package:mi_test/utils/constant.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  late AlbumDB mAlbumDB;
  late ProductDB mProductDB;

  //Album ----------------------------------------------------------------------
  List<MAlbum> mList = [];
  int pageCount = 1;
  int totalAlbumListCount = 1;

  //Stream - AlbumList
  final _albumListStreamController = StreamController<List<MAlbum>>();

  StreamSink<List<MAlbum>> get albumListSink => _albumListStreamController.sink;

  //Product ----------------------------------------------------------------------
  //Stream - ProductList
  final _productListStreamController = StreamController<List<MProduct>>();

  StreamSink<List<MProduct>> get productListSink =>
      _productListStreamController.sink;

  HomeBloc() : super(HomeInitial()) {
    mAlbumDB = AlbumDB();
    mProductDB = ProductDB();
    on<HomeAlbumFetchEvent>((event, emit) => albumFetchFromDB(event, emit, 1));
    on<HomeAlbumLoadMoreEvent>(
        (event, emit) => albumLoadMoreData(event, emit, event.strIndex));
    on<HomeProductFetchEvent>(
        (event, emit) => productFetchFromDB(event, emit, event.albumId, 1));
    on<HomeProductLoadMoreEvent>((event, emit) => productLoadMoreData(
        event, emit, event.albumId, event.parentIndex, event.strIndex));
  }

  //Album List -- Local DB
  albumFetchFromDB(HomeEvent event, Emitter emit, int strIndex) async {
    bool value = await bindDataFromLocalDB(strIndex);
    if (value) {
      emit(HomeAlbumSuccessState(_albumListStreamController.stream));
      albumFetchApiCall(event, emit, strIndex, true);
    } else {
      albumFetchApiCall(event, emit, strIndex, false);
    }
  }

  //Load More LocalDB Data
  albumLoadMoreData(HomeEvent event, Emitter emit, strIndex) async {
    bool value = await bindDataFromLocalDB(strIndex);
    if (!value) {
      await albumFetchApiCall(event, emit, strIndex, true);
      if (strIndex >= totalAlbumListCount) {
        pageCount = 1;
        add(HomeAlbumLoadMoreEvent(pageCount));
      }
    }
  }

  //Bind UI List with LocalDB
  Future<bool> bindDataFromLocalDB(strIndex) async {
    List<MAlbum> mListT = await mAlbumDB.getAlbumList(strIndex);
    if (mListT.isNotEmpty) {
      mList.addAll(mListT);
      albumListSink.add(mList);
      return true;
    }
    return false;
  }

  //Album List -- API Call
  albumFetchApiCall(
      HomeEvent event, Emitter emit, int strIndex, bool hasLocalData) async {
    MResponse mResponse = await HomeRepository().getAlbumList();
    if (mResponse.responseCode == 200) {
      await mResponse.data
          .forEach((element) => {mAlbumDB.insertAlbums(element)});
      totalAlbumListCount = mResponse.data.length;
      if (!hasLocalData) albumFetchFromDB(event, emit, strIndex);
    } else {
      //Don't has LocalData and Error
      if (!hasLocalData) {
        String errMsg = mResponse.message ?? error_somethingWentWrong;
        emit(HomeAlbumErrorState(errMsg));
      }
    }
  }

  //Product List -- Local DB
  productFetchFromDB(
      HomeEvent event, Emitter emit, int albumId, int startIndex) async {
    bool value = await bindProductFromLocalDB(albumId, startIndex);
    if (value) {
      emit(HomeProductSuccessState(_productListStreamController.stream));
    } else {
      productFetchApiCall(event, emit, albumId, false, startIndex);
    }
  }

  //Load More LocalDB Data
  productLoadMoreData(HomeEvent event, Emitter emit, int albumId,
      int parentIndex, int strIndex) async {
    bool value = await bindProductFromLocalDB(albumId, strIndex);
    if (!value) {
      await productFetchApiCall(event, emit, albumId, true, strIndex);
      if (strIndex >= totalAlbumListCount) {
        add(HomeProductLoadMoreEvent(pageCount, parentIndex, albumId));
      }
    }
  }

  //Bind UI List with LocalDB
  Future<bool> bindProductFromLocalDB(int albumId, int strIndex) async {
    List<MProduct> mListT = await mProductDB.getProductList(albumId, strIndex);
    if (mListT.isNotEmpty) {
      var map = <int, List<MProduct>>{albumId: mListT};
      productListSink.add(mListT);
      return true;
    }
    return false;
  }

  //Product List -- API Call
  productFetchApiCall(HomeEvent event, Emitter emit, int albumId,
      bool hasLocalData, int strIndex) async {
    MResponse mResponse = await HomeRepository().getProductList(albumId);
    if (mResponse.responseCode == 200) {
      mResponse.data.forEach((element) => {mProductDB.insertProducts(element)});
      if (!hasLocalData) productFetchFromDB(event, emit, albumId, strIndex);
    } else {
      //Don't has LocalData and Error
      if (!hasLocalData) {
        String errMsg = mResponse.message ?? error_somethingWentWrong;
        emit(HomeProductErrorState(errMsg));
      }
    }
  }

  @override
  Future<void> close() {
    _albumListStreamController.close();
    _productListStreamController.close();
    return super.close();
  }
}
