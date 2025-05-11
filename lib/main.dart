import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_participant_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_race_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_segment_time_repository.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/providers/race_result_board_provider.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/ui/screens/participants/participant_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_segment_time_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create repositories
    final raceRepository = FirebaseRaceRepository();
    final participantRepository = FirebaseParticipantRepository();
    final segmentTimeRepository = FirebaseSegmentTimeRepository(raceRepository: raceRepository);

    final raceResultBoardRepository = FirebaseRaceResultBoardRepository(
      raceRepository: raceRepository,
      participantRepository: participantRepository,
      segmentTimeRepository: segmentTimeRepository,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ParticipantProvider(participantRepository)
        ),
        ChangeNotifierProvider(
          create: (context) => RaceProvider(raceRepository: raceRepository)
        ),
        ChangeNotifierProvider(
          create: (context) => SegmentTimeProvider(repository: segmentTimeRepository)
        ),
        ChangeNotifierProvider(
          create: (context) => RaceResultBoardProvider(raceResultBoardRepository: raceResultBoardRepository)
        ),
      ],
      child: MaterialApp(
        title: 'Race Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5E64D1),
          ),
        ),
        home: const ParticipantScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}