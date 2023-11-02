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
}

class HomeAlbumSuccessState extends HomeState {
  final Stream<List<MAlbum>> streamAlbumList;

  HomeAlbumSuccessState(this.streamAlbumList);
}
