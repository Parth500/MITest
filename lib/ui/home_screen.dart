import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_test/utils/constant.dart';

import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
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
        body: AlbumList(
          homeBloc: homeBloc,
          scrollController: _scrollController,
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
      homeBloc.pageCount += 10;
      homeBloc.add(HomeAlbumLoadMoreEvent(homeBloc.pageCount));
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
  const AlbumList({
    super.key,
    required ScrollController scrollController,
    required this.homeBloc,
  }) : _scrollController = scrollController;

  final HomeBloc homeBloc;
  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: homeBloc,
      builder: (context, state) {
        switch (state.runtimeType) {
          case HomeAlbumInitialState:
            return const Center(child: CircularProgressIndicator());
          case HomeAlbumSuccessState:
            final homeState = state as HomeAlbumSuccessState;
            return VerticalList(
              homeState: homeState,
              scrollController: _scrollController,
            );
          case HomeAlbumErrorState:
            final myState = state as HomeAlbumErrorState;
            return Center(
              child: Text(myState.errMsg),
            );
          default:
            return Container();
        }
      },
    );
  }
}

class VerticalList extends StatelessWidget {
  const VerticalList({
    super.key,
    required this.homeState,
    required this.scrollController,
  });

  final HomeAlbumSuccessState homeState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MAlbum>>(
        stream: homeState.streamAlbumList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data!.length + 1,
              controller: scrollController,
              itemBuilder: (context, index) {
                print("---Index --- $index---");
                return index >= snapshot.data!.length
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
                              snapshot.data![index].title ?? "-",
                              style: const TextStyle(fontSize: 16),
                            ),
                            verticalSpace(8),
                            SizedBox(
                              height: 100,
                              child: HorizontalList(
                                albumId: snapshot.data![index].id!,
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
  final int albumId;
  final int parentIndex;

  const HorizontalList(
      {super.key, required this.albumId, required this.parentIndex});

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  final productScrollController = ScrollController();
  HomeBloc homeBloc = HomeBloc();
  int pageCount = 1;

  @override
  void initState() {
    homeBloc.add(HomeProductFetchEvent(widget.albumId, widget.parentIndex, 1));
    productScrollController.addListener(_onProductScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: homeBloc,
      builder: (context, state) {
        if (state is HomeProductSuccessState) {
          return StreamBuilder<List<MProduct>>(
              stream: state.streamProductList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  pageCount = snapshot.data!.length+1;
                  return ListView.builder(
                      controller: productScrollController,
                      itemCount: snapshot.data!.length + 1,
                      key: PageStorageKey<String>('Page${widget.albumId}'),
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
      homeBloc.add(HomeProductLoadMoreEvent(
          pageCount, widget.parentIndex, widget.albumId));
    }
  }

  bool get _isProductLast {
    if (!productScrollController.hasClients) return false;
    final maxScroll = productScrollController.position.maxScrollExtent;
    final currentScroll = productScrollController.offset;
    return currentScroll >= (maxScroll * 0.95);
  }
}
