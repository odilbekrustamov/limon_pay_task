part of 'add_card_bloc.dart';

class AddCardState extends Equatable {
  final String cardNumber;
  final String expiryDate;
  final String cardholderName;
  final bool isScanning;
  final String? scanError;

  const AddCardState({
    this.cardNumber = '',
    this.expiryDate = '',
    this.cardholderName = '',
    this.isScanning = false,
    this.scanError,
  });

  @override
  List<Object?> get props => [
    cardNumber,
    expiryDate,
    cardholderName,
    isScanning,
    scanError
  ];

  AddCardState copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    String? password,
    bool? isScanning,
    String? scanError,
  }) {
    return AddCardState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cardholderName: cardholderName ?? this.cardholderName,
      isScanning: isScanning ?? this.isScanning,
      scanError: scanError ?? this.scanError,
    );
  }
}
