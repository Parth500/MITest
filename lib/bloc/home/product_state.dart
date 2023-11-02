import '../../services/models/MProduct.dart';

abstract class ProductState {}

//All Product Fetch State
class HomeProductInitialState extends ProductState {}

class HomeProductErrorState extends ProductState {
  String errMsg;

  HomeProductErrorState(this.errMsg);
}

class HomeProductSuccessState extends ProductState {
  Stream<List<MProduct>> streamProductList;

  HomeProductSuccessState(this.streamProductList);
}
