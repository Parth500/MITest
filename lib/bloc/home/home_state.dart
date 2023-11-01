import 'dart:async';

import 'package:equatable/equatable.dart';

import '../../services/models/MAlbum.dart';
import '../../services/models/MProduct.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

//All Album Fetch State
class HomeAlbumInitialState extends HomeState {}

class HomeAlbumErrorState extends HomeState {
  final String errMsg;

  HomeAlbumErrorState(this.errMsg);

  @override
  List<Object> get props => [errMsg];
}

class HomeAlbumSuccessState extends HomeState {
  Stream<List<MAlbum>> streamAlbumList;

  HomeAlbumSuccessState(this.streamAlbumList);
}

//All Product Fetch State
class HomeProductInitialState extends HomeState {}

class HomeProductErrorState extends HomeState {
  String errMsg;

  HomeProductErrorState(this.errMsg);
}

class HomeProductSuccessState extends HomeState {
  Stream<List<MProduct>> streamProductList;

  HomeProductSuccessState(this.streamProductList);
}
