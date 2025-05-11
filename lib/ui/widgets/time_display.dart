import 'dart:async';
import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class TimerDisplay extends StatefulWidget {
  final bool isRunning;
  final VoidCallback? onTick;

  const TimerDisplay({
    Key? key, 
    this.isRunning = false,
    this.onTick,
  }) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _setupTimer();
  }
  
  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If running state changed, update the timer
    if (oldWidget.isRunning != widget.isRunning) {
      _setupTimer();
    }
  }
  
  void _setupTimer() {
    // Cancel existing timer if any
    _timer?.cancel();
    
    if (widget.isRunning) {
      // Update UI frequently (100 times per second)
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
        
        // Call the onTick callback if provided
        if (widget.onTick != null) {
          widget.onTick!();
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime;
    
    if (widget.isRunning) {
      // Format current time as hours:minutes:seconds.tenths
      final hours = _currentTime.hour.toString().padLeft(2, '0');
      final minutes = _currentTime.minute.toString().padLeft(2, '0');
      final seconds = _currentTime.second.toString().padLeft(2, '0');
      final tenths = (_currentTime.millisecond ~/ 100); // Get the tenths place
      formattedTime = "$hours:$minutes:$seconds.$tenths";
    } else {
      // Display 00:00:00.0 when not running
      formattedTime = "00:00:00.0";
    }
    
    return Center(
      child: Text(
        formattedTime,
        style: RaceTextStyles.heading.copyWith(
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          color: RaceColors.black,
        ),
      ),
    );
  }
}
