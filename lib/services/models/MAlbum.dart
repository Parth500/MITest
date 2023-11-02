import 'package:equatable/equatable.dart';

import 'MProduct.dart';

class MAlbum extends Equatable {
  int? userId;
  int? id;
  String? title;

  int pageCount = 1;
  List<MProduct> listProduct = [];
  bool isLoadMorePending = false;

  MAlbum({
    this.userId,
    this.id,
    this.title,
  });

  MAlbum.productPosition(
      {this.id, required this.pageCount, required this.listProduct});

  factory MAlbum.fromJson(Map<String, dynamic> json) => MAlbum(
        userId: json["userId"],
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "id": id,
        "title": title,
      };

  @override
  List<Object?> get props => [userId, id, title];
}
