import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_test/bloc/home/product_bloc.dart';
import 'package:mi_test/bloc/home/product_state.dart';
import 'package:mi_test/utils/constant.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../bloc/home/product_event.dart';
import '../bloc/internet_bloc.dart';
import '../bloc/internet_state.dart';
import '../services/models/MAlbum.dart';
import '../services/models/MProduct.dart';
import '../utils/common_utils.dart';
import '../utils/constant_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  HomeBloc homeBloc = HomeBloc();

  @override
  void initState() {
    homeBloc.add(HomeAlbumFetchEvent());
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
        ),
        body: BlocProvider(
          create: (context) => InternetBloc(),
          child: AlbumList(
            homeBloc: homeBloc,
            scrollController: _scrollController,
          ),
        ));
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      if (!homeBloc.isLoadMorePending) {
        homeBloc.isLoadMorePending = true;
        homeBloc.pageCount += 10;
        homeBloc.add(HomeAlbumLoadMoreEvent(homeBloc.pageCount));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.95);
  }
}

class AlbumList extends StatelessWidget {
  AlbumList({
    super.key,
    required ScrollController scrollController,
    required this.homeBloc,
  }) : _scrollController = scrollController;

  final HomeBloc homeBloc;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetBloc, InternetState>(
      listener: (context, state) {
        if (homeBloc.state is HomeAlbumErrorState) {
          if (state is InternetGainedState) {
            snackBar(context, success_internetAvailableMessage, false);
            homeBloc.add(HomeAlbumFetchEvent());
          }
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: homeBloc,
        builder: (context, state) {
          switch (state.runtimeType) {
            case HomeAlbumInitialState:
              return const Center(child: CircularProgressIndicator());
            case HomeAlbumSuccessState:
              final homeState = state as HomeAlbumSuccessState;
              return VerticalList(
                  homeBloc: homeBloc,
                  homeState: homeState,
                  scrollController: _scrollController);
            case HomeAlbumErrorState:
              final myState = state as HomeAlbumErrorState;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 35),
                    verticalSpace(16),
                    Text(
                      myState.errMsg,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              );
            default:
              return Container();
          }
        },
      ),
    );
  }
}

class VerticalList extends StatelessWidget {
  const VerticalList({
    super.key,
    required this.homeState,
    required this.scrollController,
    required this.homeBloc,
  });

  final HomeBloc homeBloc;
  final HomeAlbumSuccessState homeState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MAlbum>>(
        stream: homeState.streamAlbumList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MAlbum> list = snapshot.data!;
            return ListView.separated(
              itemCount: list.length + 1,
              controller: scrollController,
              itemBuilder: (context, index) {
                return index >= list.length
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list[index].title ?? "-",
                              style: const TextStyle(fontSize: 16),
                            ),
                            verticalSpace(8),
                            SizedBox(
                              height: 100,
                              child: HorizontalList(
                                mAlbum: snapshot.data![index],
                                parentIndex: index,
                              ),
                            ),
                          ],
                        ),
                      );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  height: 1,
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text(error_somethingWentWrong);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class HorizontalList extends StatefulWidget {
  final int parentIndex;
  final MAlbum mAlbum;

  const HorizontalList(
      {super.key, required this.parentIndex, required this.mAlbum});

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  final productScrollController = ScrollController();
  ProductBloc productBloc = ProductBloc();
  int pageCount = 1;

  @override
  void initState() {
    productBloc
        .add(HomeProductFetchEvent(widget.mAlbum.id!, widget.parentIndex, 1));
    productScrollController.addListener(_onProductScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      bloc: productBloc,
      builder: (context, state) {
        if (state is HomeProductInitialState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is HomeProductSuccessState) {
          return StreamBuilder<List<MProduct>>(
              stream: state.streamProductList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  pageCount = snapshot.data!.length + 1;
                  return ListView.builder(
                      controller: productScrollController,
                      itemCount: snapshot.data!.length + 1,
                      key: PageStorageKey<String>(
                          'Page${widget.parentIndex}${widget.mAlbum.id!}'),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return index >= snapshot.data!.length
                            ? const Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data![index].thumbnailUrl!,
                                  errorWidget: (context, url, error) {
                                    return const Icon(Icons.error);
                                  },
                                ));
                      });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        } else if (state is HomeProductErrorState) {
          return Center(
            child: Text(state.errMsg),
          );
        }
        return Container();
      },
    );
  }

  @override
  void dispose() {
    productScrollController
      ..removeListener(_onProductScroll)
      ..dispose();
    super.dispose();
  }

  void _onProductScroll() {
    if (_isProductLast) {
      MAlbum myProductAlbum = productBloc.listProducts.singleWhere(
          (element) => (element.id == widget.mAlbum.id),
          orElse: () => MAlbum());
      if (!myProductAlbum.isLoadMorePending) {
        productBloc.listProducts
            .where((element) => (element.id == widget.mAlbum.id))
            .single
            .isLoadMorePending = true;
        productBloc.add(HomeProductLoadMoreEvent(myProductAlbum.pageCount + 10,
            widget.parentIndex, widget.mAlbum.id!));
      }
    }
  }

  bool get _isProductLast {
    if (!productScrollController.hasClients) return false;
    final maxScroll = productScrollController.position.maxScrollExtent;
    final currentScroll = productScrollController.offset;
    return currentScroll >= (maxScroll * 0.95);
  }
}
