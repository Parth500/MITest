import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

//All Album Fetch Events
class HomeAlbumFetchEvent extends HomeEvent {}

//Load More Album Events
class HomeAlbumLoadMoreEvent extends HomeEvent {
  int strIndex;

  HomeAlbumLoadMoreEvent(this.strIndex);
}

//Load More Products Events
class HomeProductLoadMoreEvent extends HomeEvent {
  int strIndex;
  int parentIndex;
  int albumId;
  HomeProductLoadMoreEvent(this.strIndex, this.parentIndex,this.albumId);
}

//All Product Fetch Events
class HomeProductFetchEvent extends HomeEvent {
  int albumId;
  int parentIndex;
  int strIndex;

  HomeProductFetchEvent(this.albumId,this.parentIndex,this.strIndex);
}
