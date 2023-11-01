import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:meta/meta.dart';

import '../utils/common_utils.dart';
import 'internet_event.dart';
import 'internet_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? connectivitySubscription;

  InternetBloc() : super(InternetInitialState()) {
    on<InternetGainedEvent>((event, emit) {
      emit(InternetGainedState());
    });
    on<InternetLostEvent>((event, emit) {
      emit(InternetLostState());
    });

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        await internetService().then((response) {
          if (response) {
            add(InternetGainedEvent());
          } else {
            add(InternetLostEvent());
          }
        });
      } else {
        add(InternetLostEvent());
      }
    });
  }

  @override
  Future<void> close() {
    connectivitySubscription?.cancel();
    return super.close();
  }
}
