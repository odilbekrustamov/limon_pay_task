part of 'add_card_bloc.dart';

abstract class AddCardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardNumberChanged extends AddCardEvent {
  final String cardNumber;

  CardNumberChanged(this.cardNumber);

  @override
  List<Object?> get props => [cardNumber];
}

class ExpiryDateChanged extends AddCardEvent {
  final String expiryDate;

  ExpiryDateChanged(this.expiryDate);

  @override
  List<Object?> get props => [expiryDate];
}

class CardholderNameChanged extends AddCardEvent {
  final String cardholderName;

  CardholderNameChanged(this.cardholderName);

  @override
  List<Object?> get props => [cardholderName];
}

class ScanCardEvent extends AddCardEvent {}