import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_card_event.dart';
part 'add_card_state.dart';

class AddCardBloc extends Bloc<AddCardEvent, AddCardState> {

  AddCardBloc() : super(const AddCardState()) {
    on<CardNumberChanged>(_onCardNumberChanged);
    on<ExpiryDateChanged>(_onExpiryDateChanged);
    on<CardholderNameChanged>(_onCardholderNameChanged);
    on<ScanCardEvent>(_onScanCardEvent);
  }

  Future<void> _onCardNumberChanged(
      CardNumberChanged event, Emitter<AddCardState> emit) async {
    emit(state.copyWith(cardNumber: event.cardNumber));
  }

  Future<void> _onExpiryDateChanged(
      ExpiryDateChanged event, Emitter<AddCardState> emit) async {
    emit(state.copyWith(expiryDate: event.expiryDate));
  }

  Future<void> _onCardholderNameChanged(
      CardholderNameChanged event, Emitter<AddCardState> emit) async {
    emit(state.copyWith(cardholderName: event.cardholderName));
  }

  Future<void> _onScanCardEvent(
      ScanCardEvent event, Emitter<AddCardState> emit) async {
    //TODO
  }
}