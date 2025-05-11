import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/participants/participant_screen.dart';
import 'package:race_traking_app/ui/screens/race_controll/race_controll.dart';
import 'package:race_traking_app/ui/screens/tracking_time/tracking_time.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/screens/resultBoard/resultBoard_screen.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;

  const Navbar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navBarItem(
            context,
            Icons.people,
            'Participant',
            selectedIndex == 0,
            const ParticipantScreen(),
          ),
          _navBarItem(
            context,
            Icons.flag,
            'Race',
            selectedIndex == 1,
            const TimerScreen(),
          ),
          _navBarItem(
            context,
            Icons.timer,
            'Track Time',
            selectedIndex == 2,
            const TrackingTimeScreen(),
          ),
          _navBarItem(
            context,
            Icons.leaderboard,
            'Result board',
            selectedIndex == 3,
            const ResultBoardScreen(),
          ),
        ],
      ),
    );
  }

  Widget _navBarItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected,
    Widget targetScreen,
  ) {
    return InkWell(
      onTap: () {
        if (!isSelected) {
          // Use PageRouteBuilder for smooth transition
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  targetScreen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var  offsetAnimation = animation.drive(tween);

                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? RaceColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? RaceColors.primary : Colors.grey,
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? RaceColors.primary : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
