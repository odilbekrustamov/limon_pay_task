

import 'package:get_it/get_it.dart';

import 'camera_service.dart';
import 'card_text_recognition_service.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton<CameraService>(() => CameraService());
  locator
      .registerLazySingleton<CardTextRecognitionService>(() => CardTextRecognitionService());
}
