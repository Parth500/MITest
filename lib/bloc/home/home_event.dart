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
  final int strIndex;

  HomeAlbumLoadMoreEvent(this.strIndex);
}
