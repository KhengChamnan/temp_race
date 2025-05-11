import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/screens/view_segment/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';
import 'package:race_traking_app/utils/two_step_helper.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/model/segment_time.dart';

class TwoStepView extends StatefulWidget {
  final String segment;
  const TwoStepView({Key? key,required this.segment,}) : super(key: key);

  @override
  State<TwoStepView> createState() => _TwoStepViewState();
}

class _TwoStepViewState extends State<TwoStepView> {
  int? selectedIndex;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  List<SegmentTime> finishTimes = [];
  Map<int, String> selectedBibs = {};
  // Track temporary entries that aren't from the database yet
  List<SegmentTime> temporaryEntries = [];
  
  // Get current page items
  List<SegmentTime> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return finishTimes.sublist(
      startIndex,
      endIndex > finishTimes.length ? finishTimes.length : endIndex
    );
  }

  // Calculate total pages
  int get _totalPages => (finishTimes.length / _itemsPerPage).ceil();

  String _getPageRange() {
    if (finishTimes.isEmpty) return "0-0";
    final start = (_currentPage * _itemsPerPage) + 1;
    final end = (_currentPage + 1) * _itemsPerPage;
    return '$start-${end > finishTimes.length ? finishTimes.length : end}';
  }

  void _markTime() {
    // Get the current time
    final now = DateTime.now();
    
    // Format the time in a readable format with hours, minutes, seconds and milliseconds
    final timeString = TwoStepHelper.formatDetailedTime(now);
    
    setState(() {
      // Create a new temporary SegmentTime object
      final newEntry = SegmentTime(
        participantBibNumber: "",
        segmentName: widget.segment,
        startTime: now, // Use the same time for start/end for temporary entries
        endTime: now,
      );
      
      // Add to the beginning of the list
      temporaryEntries.insert(0, newEntry);
      finishTimes.insert(0, newEntry);
      
      // Make sure we're on the first page to see the new entry
      _currentPage = 0;
      
      // Clear any selection
      selectedIndex = null;
    });
  }

  void _loadFinishTimes() {
   // To be implemented
  }

  @override
  void initState() {
    super.initState();
    // Load finish times when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFinishTimes();
    });
  }

  Future<void> _showBibSelectionDialog(int index) async {
   // To be implemented
  }

  void _resetSelection(int index) {
   // To be implemented
  }

  void _deleteFinishTime(int index) {
    setState(() {
      // Convert the index from page-specific to global index
      final globalIndex = _currentPage * _itemsPerPage + index;
      final itemToDelete = finishTimes[globalIndex];
      
      // Remove the item from the finishTimes list
      finishTimes.removeAt(globalIndex);
      
      // If it's a temporary entry, also remove from temporaryEntries
      if (temporaryEntries.contains(itemToDelete)) {
        temporaryEntries.remove(itemToDelete);
      }
      
      // Remove any selected bib associated with this index
      selectedBibs.remove(globalIndex);
      
      // Reset selectedIndex
      selectedIndex = null;
      
      // Check if current page is now empty and we need to go back a page
      if (_currentPageItems.isEmpty && _currentPage > 0) {
        _currentPage--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SegmentTimeProvider>(
      builder: (context, provider, child) {
        // Update finish times when provider updates, but preserve temporary entries
        if (provider.segmentTimesValue.isSuccess && provider.segmentTimesValue.data != null) {
          // Get updated data from provider
          final updatedFinishTimes = TwoStepHelper.extractFinishTimes(
            provider.segmentTimesValue.data!,
            widget.segment
          );
          
          // Create a combined list with temporary entries first, then provider data
          List<SegmentTime> mergedFinishTimes = [];
          
          // Add temporary entries first
          if (temporaryEntries.isNotEmpty) {
            mergedFinishTimes.addAll(temporaryEntries);
          }
          
          // Then add provider data - excluding any that match temporary entries 
          // (comparing by endTime would work for this purpose)
          final temporaryEndTimes = temporaryEntries
              .map((item) => item.endTime)
              .whereType<DateTime>()
              .toSet();
              
          final filteredFinishTimes = updatedFinishTimes.where((item) =>
              item.endTime != null && !temporaryEndTimes.contains(item.endTime))
              .toList();
              
          mergedFinishTimes.addAll(filteredFinishTimes);
          
          // Update state
          finishTimes = mergedFinishTimes;
        }
        
        return Column(
          children: [
            // Mark Time button
            SizedBox(height: RaceSpacings.xs,),
            ElevatedButton(
              onPressed: _markTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: RaceColors.primary,
                foregroundColor: RaceColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RaceSpacings.radius),
                ),
              ),
              child: Text('Mark Time',
                  style: TextStyle(fontSize: RaceTextStyles.subtitle.fontSize)),
            ),

            // Pagination Controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical:RaceSpacings.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 0 && finishTimes.isNotEmpty
                        ? () {
                            setState(() {
                              _currentPage--;
                              selectedIndex = null;
                            });
                          }
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: RaceColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(RaceSpacings.radius),
                    ),
                    child: Text(
                      _getPageRange(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: RaceColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1 && finishTimes.isNotEmpty
                        ? () {
                            setState(() {
                              _currentPage++;
                              selectedIndex = null;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),

            // Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: RaceSpacings.xs),
              child: Row(
                children: [
                  HeaderRow(title: 'No.', flex: 1),
                  HeaderRow(title: 'Finish Time', flex: 2),
                  HeaderRow(title: 'BIB', flex: 2),
                  SizedBox(width: 50),
                ],
              ),
            ),
            const Divider(),

            // List of finish times
            Expanded(
              child: finishTimes.isEmpty
              ? Center(
                  child: Text(
                    'No finish times recorded yet',
                    style: TextStyle(fontSize: 16, color: RaceColors.darkGrey),
                  ),
                )
              : ListView.builder(
                  itemCount: _currentPageItems.length,
                  itemBuilder: (context, index) {
                    final globalIndex = _currentPage * _itemsPerPage + index;
                    final item = _currentPageItems[index];
                    final isTemporary = temporaryEntries.contains(item);
                    
                    // Format the time for display
                    final displayTime = item.endTime != null 
                        ? TwoStepHelper.formatDetailedTime(item.endTime!)
                        : '--:--:--';
                    
                    return Dismissible(
                      key: Key('${item.segmentName}_${item.endTime?.millisecondsSinceEpoch ?? index}_${index}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteFinishTime(index);
                      },
                      child: TwoStepListTile(
                        number: (index + 1).toString().padLeft(2, '0'),
                        finishTime: displayTime,
                        isSelected: globalIndex == selectedIndex,
                        isTemporary: isTemporary,
                        selectedBib: item.participantBibNumber.isNotEmpty 
                            ? item.participantBibNumber 
                            : selectedBibs[globalIndex],
                        onSelectBib: () => _showBibSelectionDialog(index),
                        onReset: () => _resetSelection(index),
                      ),
                    );
                  },
                ),
            ),
          ],
        );
      }
    );
  }
}