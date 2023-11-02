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

  //Album ----------------------------------------------------------------------
  List<MAlbum> mList = [];
  int pageCount = 1;
  int totalAlbumListCount = 1;
  bool isLoadMorePending = false;

  //Stream - AlbumList
  final _albumListStreamController = StreamController<List<MAlbum>>();

  StreamSink<List<MAlbum>> get albumListSink => _albumListStreamController.sink;

  HomeBloc() : super(HomeInitial()) {
    mAlbumDB = AlbumDB();
    on<HomeAlbumFetchEvent>(
        (event, emit) async => await albumFetch(event, emit, 1));
    on<HomeAlbumLoadMoreEvent>(
        (event, emit) => albumLoadMore(event, emit, event.strIndex));
  }

  Future<void> albumFetch(HomeEvent event, Emitter emit, int strIndex) async {
    //Step 1 -- Check LocalDB ->
    //Step 2 -- Data Available -> Then Load the Data into Stream and Emit
    //Step 3 -- Data is Not Available -> Make Api Call and
    emit(HomeAlbumInitialState());
    List<MAlbum> mListT = await bindDataFromLocalDB(strIndex);
    if (mListT.isEmpty) {
      await HomeRepository().getAlbumList().then((mResponse) async {
        if (mResponse.responseCode == 200) {
          mResponse.data.forEach((element) {
            mAlbumDB.insertAlbums(element);
          });
          totalAlbumListCount = mResponse.data.length;
          mListT = mResponse.data;
          callAlbumSuccessEmit(emit, mListT, false);
        } else {
          String errMsg = mResponse.message ?? error_somethingWentWrong;
          emit(HomeAlbumErrorState(errMsg));
        }
      });
    } else {
      callAlbumSuccessEmit(emit, mListT, false);
      await HomeRepository().getAlbumList().then((mResponse) async {
        if (mResponse.responseCode == 200) {
          totalAlbumListCount = mResponse.data.length;
          mResponse.data.forEach((element) {
            mAlbumDB.insertAlbums(element);
          });
        }
      });
    }
  }

  Future<void> albumLoadMore(
      HomeEvent event, Emitter emit, int strIndex) async {
    //Step 1 -- Check LocalDB ->
    //Step 2 -- Data Available -> Then Load the Data into Stream and Emit
    //Step 3 -- Data is Not Available -> Make Api Call and Step 2
    print("---- AlbumLoadMore --- $strIndex=$totalAlbumListCount");
    if (strIndex >= totalAlbumListCount) {
      pageCount = 1;
      strIndex = 1;
    }
    print("---- AlbumLoadMore 11111--- $strIndex,$isLoadMorePending");
    List<MAlbum> mListT = await bindDataFromLocalDB(strIndex);
    if (mListT.isEmpty) {
      HomeRepository().getAlbumList().then((mResponse) async {
        if (mResponse.responseCode == 200) {
          mResponse.data.forEach((element) {
            mAlbumDB.insertAlbums(element);
          });
          totalAlbumListCount = mResponse.data.length;
          mListT = mResponse.data;
        }
      });
    } else {
      callAlbumSuccessEmit(emit, mListT, true);
      isLoadMorePending = false;
    }
  }

  callAlbumSuccessEmit(Emitter emit, List<MAlbum> mListT, bool isLoadMore) {
    mList.addAll(mListT);
    albumListSink.add(mList);
    if (!isLoadMore) {
      emit(HomeAlbumSuccessState(_albumListStreamController.stream));
    }
  }

  //Bind UI List with LocalDB
  Future<List<MAlbum>> bindDataFromLocalDB(strIndex) async {
    return await mAlbumDB.getAlbumList(strIndex);
  }
}
