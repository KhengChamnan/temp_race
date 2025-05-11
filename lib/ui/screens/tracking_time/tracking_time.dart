import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/screens/view_segment/race_segment_screen.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/segment_button.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/select_segments_text.dart';
import 'package:race_traking_app/ui/widgets/time_display.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class TrackingTimeScreen extends StatefulWidget {
  const TrackingTimeScreen({Key? key}) : super(key: key);

  @override
  _TrackingTimeScreenState createState() => _TrackingTimeScreenState();
}

class _TrackingTimeScreenState extends State<TrackingTimeScreen> {
  String? _selectedSegment;

  void selectSegment(String segment) {
    setState(() {
      _selectedSegment = segment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        // Get race data from provider
        final raceState = raceProvider.currentRace;
        
        // Default values for loading or error state
        Duration elapsedTime = Duration.zero;
        bool isRaceActive = false;
        
        // If race data is loaded, calculate elapsed time
        if (raceState != null && !raceState.isLoading && !raceState.isError && raceState.data != null) {
          final race = raceState.data!;
          
          // Calculate elapsed time
          if (race.startTime != null) {
            final DateTime endTime = race.status == RaceStatus.finished 
                ? (race.endTime ?? DateTime.now())
                : DateTime.now();
                
            elapsedTime = endTime.difference(race.startTime!);
          }
          
          // Check if race is active
          isRaceActive = race.status == RaceStatus.started;
        }
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: RaceColors.primary,
            title: const Text(
              'TRACK TIME',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          backgroundColor: Colors.white, 
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Timer Display synced with RaceProvider
                TimerDisplay(
                  isRunning: isRaceActive,
                ),
                const SizedBox(height: 40),
                // Race Status Indicator
                
                const SizedBox(height: 40),
                // Select Segments Text
                const SelectSegmentsText(),
                const SizedBox(height: 16),
                // Segment Buttons
                SegmentButton(
                  segment: "Swim",
                  isSelected: _selectedSegment == "swim",
                  onTap: () {
                    selectSegment("swim");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RaceTrackingScreen(segment: "Swim"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SegmentButton(
                  segment: "Cycle",
                  isSelected: _selectedSegment == "cycle",
                  onTap: () {
                    selectSegment("cycle");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RaceTrackingScreen(segment: "Cycle"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                SegmentButton(
                  segment: "Run",
                  isSelected: _selectedSegment == "run",
                  onTap: () {
                    selectSegment("run");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RaceTrackingScreen(segment: "Run"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: const Navbar(selectedIndex: 2),
        );
      },
    );
  }
  

}
