part of 'scan_card_bloc.dart';

class ScanCardState extends Equatable {
  final String cardNumber;
  final String expiryDate;
  final bool isScanning;
  final String? scanError;

  const ScanCardState({
    this.cardNumber = '',
    this.expiryDate = '',
    this.isScanning = false,
    this.scanError,
  });

  @override
  List<Object?> get props => [
    cardNumber,
    expiryDate,
    isScanning,
    scanError
  ];

  ScanCardState copyWith({
    String? cardNumber,
    String? expiryDate,
    String? cardholderName,
    String? password,
    bool? isScanning,
    String? scanError,
  }) {
    return ScanCardState(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      isScanning: isScanning ?? this.isScanning,
      scanError: scanError ?? this.scanError,
    );
  }
}
