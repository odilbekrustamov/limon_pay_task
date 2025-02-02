import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scan_card_event.dart';
part 'scan_card_state.dart';

class ScanCardBloc extends Bloc<ScanCardEvent, ScanCardState> {

  ScanCardBloc() : super(const ScanCardState()) {
    on<ScanCardEvent>(_onScanCardEvent);
  }


  Future<void> _onScanCardEvent(
      ScanCardEvent event, Emitter<ScanCardState> emit) async {
    //TODO
  }
}