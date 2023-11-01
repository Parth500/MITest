import 'package:equatable/equatable.dart';

class MAlbum extends Equatable {
  int? userId;
  int? id;
  String? title;

  MAlbum({
    this.userId,
    this.id,
    this.title,
  });

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
