import 'package:equatable/equatable.dart';

class MProduct extends Equatable {
  int? albumId;
  int? id;
  String? title;
  String? url;
  String? thumbnailUrl;

  MProduct({
    this.albumId,
    this.id,
    this.title,
    this.url,
    this.thumbnailUrl,
  });

  factory MProduct.fromJson(Map<String, dynamic> json) => MProduct(
        albumId: json["albumId"],
        id: json["id"],
        title: json["title"],
        url: json["url"],
        thumbnailUrl: json["thumbnailUrl"],
      );

  Map<String, dynamic> toJson() => {
        "albumId": albumId,
        "id": id,
        "title": title,
        "url": url,
        "thumbnailUrl": thumbnailUrl,
      };

  @override
  List<Object?> get props => [albumId, id, title, url, thumbnailUrl];
}
