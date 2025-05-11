import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/screens/view_segment/GridView/grid_screen.dart';
import 'package:race_traking_app/ui/screens/view_segment/2step/twoStep_screen.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/widgets/time_display.dart';
import 'package:race_traking_app/model/race.dart';

class RaceTrackingScreen extends StatefulWidget {
  final String segment;

  const RaceTrackingScreen({
    Key? key,
    required this.segment,
  }) : super(key: key);

  @override
  State<RaceTrackingScreen> createState() => _RaceTrackingScreenState();
}

class _RaceTrackingScreenState extends State<RaceTrackingScreen> {
  int _selectedIndex = 0;
  late String _segment;
  
  @override
  void initState() {
    super.initState();
    _segment = widget.segment;
    
    // Ensure segment data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SegmentTimeProvider>(context, listen: false);
      provider.fetchSegmentTimes();
    });
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        centerTitle: true,
        title: Text(
          '$_segment Segment', 
          style: TextStyle(color: RaceColors.white, fontSize: RaceTextStyles.subtitle.fontSize),
        ),
        leading: BackButton(color: RaceColors.white),
      ),
      body: Consumer<SegmentTimeProvider>(
        builder: (context, segmentTimeProvider, child) {
          final segmentTimesValue = segmentTimeProvider.segmentTimesValue;
          
          // Show loading indicator if data is still being fetched
          if (segmentTimesValue.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show error if there was an issue fetching data
          if (segmentTimesValue.isError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${segmentTimesValue.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => segmentTimeProvider.fetchSegmentTimes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Also check the RaceProvider to get race status
          final raceProvider = Provider.of<RaceProvider>(context, listen: true);
          final raceState = raceProvider.currentRace;
          
          // Default to false if race data isn't available
          bool isRaceActive = false;
          
          if (raceState != null && raceState.data != null) {
            // Set race active only if status is started
            isRaceActive = raceState.data!.status == RaceStatus.started;
          }
          
          return Column(
            children: [
              // Header with Segment Info and Timer
              Container(
                padding: const EdgeInsets.symmetric(vertical: RaceSpacings.xs),
                child: Column(
                  children: [
                    const SizedBox(height: RaceSpacings.xs),
                    // Use TimerDisplay widget for real-time clock
                    TimerDisplay(
                      isRunning: isRaceActive,
                      onTick: null,
                    ),
                  ],
                ),
              ),

              // Custom Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _buildTabButton(
                      title: 'Grid View',
                      index: 0,
                    ),
                    _buildTabButton(
                      title: '2-Step View',
                      index: 1,
                    ),
                  ],
                ),
              ),

              // Content with Segment Context
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    ParticipantGrid(
                      segmentName: _segment,
                      onTimeRecorded: () {
                        // When Grid changes data, refresh TwoStepView by forcing a rebuild
                        segmentTimeProvider.fetchSegmentTimes();
                      },
                    ),
                    TwoStepView(segment: _segment),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? RaceColors.primary : RaceColors.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              color: isSelected ? RaceColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}