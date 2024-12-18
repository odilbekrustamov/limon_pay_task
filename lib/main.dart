import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limon_pay/presentation/bloc/add_card/add_card_bloc.dart';
import 'package:limon_pay/presentation/card_details_cubit.dart';
import 'package:limon_pay/presentation/screens/add_card_screen.dart';
import 'package:limon_pay/theme/theme.dart';

import 'core/service/locator.dart';
import 'nfc_screen.dart';

void main() {
  setupServices();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (context) => CardDetailsCubit()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo', theme: appTheme,
      // home: const NfcScreen()
      home: BlocProvider(
        create: (_) => AddCardBloc(),
        child: const AddCardScreen(),
      ),
    );
  }
}
