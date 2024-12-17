import 'package:bloc/bloc.dart';

class CardDetailsCubit extends Cubit<Map<String, String>> {
  CardDetailsCubit() : super({'cardNumber': '', 'expiryDate': ''});

  void updateCardDetails(String cardNumber, String expiryDate) {
    emit({'cardNumber': cardNumber, 'expiryDate': expiryDate});
  }
}
