abstract class ProductEvent {}

//Load More Products Events
class HomeProductLoadMoreEvent extends ProductEvent {
  int strIndex;
  int parentIndex;
  int albumId;

  HomeProductLoadMoreEvent(this.strIndex, this.parentIndex, this.albumId);
}

//All Product Fetch Events
class HomeProductFetchEvent extends ProductEvent {
  int albumId;
  int parentIndex;
  int strIndex;

  HomeProductFetchEvent(this.albumId, this.parentIndex, this.strIndex);
}
