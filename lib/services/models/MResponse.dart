class MResponse {
  final int? responseCode;
  final dynamic data;
  String? message;
  bool? isLoadComplete;

  MResponse({this.responseCode, this.data, this.message, this.isLoadComplete});
}
