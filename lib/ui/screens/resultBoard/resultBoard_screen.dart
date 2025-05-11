import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/providers/race_result_board_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/screens/resultBoard/widget/resultBoard_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';
import 'package:race_traking_app/ui/widgets/loading_indicator.dart';
import 'package:race_traking_app/ui/widgets/error_view.dart';

class ResultBoardScreen extends StatefulWidget {
  const ResultBoardScreen({Key? key}) : super(key: key);

  @override
  State<ResultBoardScreen> createState() => _ResultBoardScreenState();
}

class _ResultBoardScreenState extends State<ResultBoardScreen> {
  int _rowsPerPage = 5;
  int _currentPage = 1;
  
  String _getCurrentRange(int totalItems) {
    final startIndex = ((_currentPage - 1) * _rowsPerPage) + 1;
    final endIndex = _currentPage * _rowsPerPage;
    final actualEnd = endIndex > totalItems ? totalItems : endIndex;
    return '$startIndex-$actualEnd';
  }
  
  @override
  void initState() {
    super.initState();
    // Fetch race result board on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the providers
      final raceResultBoardProvider = Provider.of<RaceResultBoardProvider>(context, listen: false);
      final raceProvider = Provider.of<RaceProvider>(context, listen: false);
      
      // If we have the current race, generate the result board
      if (raceProvider.currentRace?.isSuccess == true) {
        final race = raceProvider.currentRace!.data!;
        raceResultBoardProvider.generateRaceResultBoard(race);
      } else {
        // Otherwise just fetch the current result board
        raceResultBoardProvider.fetchCurrentRaceResultBoard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RaceColors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: RaceColors.primary,
            width: double.infinity,
            child: Center(
              child: Text(
              'RESULT BOARD',
              style: RaceTextStyles.body.copyWith(
                color: RaceColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            ),
          ),

          // Race Result Board Content
          Expanded(
            child: Consumer<RaceResultBoardProvider>(
              builder: (context, provider, child) {
                final asyncValue = provider.currentRaceResultBoard;
                
                // Loading state
                if (asyncValue == null || asyncValue.isLoading) {
                  return const Center(
                    child: LoadingIndicator()
                  );
                }
                
                // Error state
                if (asyncValue.isError) {
                  return Center(
                    child: ErrorView(
                      error: asyncValue.error.toString(),
                      onRetry: () {
                        provider.fetchCurrentRaceResultBoard();
                      },
                    ),
                  );
                }
                
                // Success state
                final raceResultBoard = asyncValue.data!;
                final results = raceResultBoard.resultItems;
                final totalItems = results.length;
                
                if (results.isEmpty) {
                  return const Center(child: Text('No results available'));
                }
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: RaceColors.lightGrey),
                              top: BorderSide(color: RaceColors.lightGrey),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                HeaderRow(title: 'Rank', flex: 1),
                                HeaderRow(title: 'BIB', flex: 1),
                                HeaderRow(title: 'Name', flex: 2),
                                HeaderRow(title: 'Cycle Time', flex: 1),
                                HeaderRow(title: 'Run Time', flex: 1),
                                HeaderRow(title: 'Swim Time', flex: 1),
                                HeaderRow(title: 'Duration', flex: 1),
                              ],
                            ),
                          ),
                        ),

                        // Table Content
                        Expanded(
                          child: ListView.builder(
                            itemCount: _getPageItemCount(totalItems),
                            itemBuilder: (context, index) {
                              final resultIndex = ((_currentPage - 1) * _rowsPerPage) + index;
                              if (resultIndex >= results.length) {
                                return null;
                              }

                              return ResultListTile(
                                result: results[resultIndex],
                                isEven: resultIndex % 2 == 0,
                                onEdit: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Editing result for ${results[resultIndex].participantName}')
                                    ),
                                  );
                                },
                                onDelete: () => _deleteResult(resultIndex, provider, results),
                              );
                            },
                          ),
                        ),

                        // Pagination Controls
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: RaceColors.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Row per page',
                                    style: TextStyle(color: RaceColors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: RaceColors.white),
                                      borderRadius: BorderRadius.circular(RaceSpacings.radius),
                                    ),
                                    child: DropdownButton<int>(
                                      value: _rowsPerPage,
                                      dropdownColor: RaceColors.primary,
                                      iconEnabledColor: RaceColors.white,
                                      style: TextStyle(color: RaceColors.white),
                                      underline: Container(),
                                      items: [5, 10, 20, 50].map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value'),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _rowsPerPage = newValue;
                                            // Adjust current page to maintain approximate scroll position
                                            _currentPage = ((_currentPage - 1) * _rowsPerPage ~/ newValue) + 1;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${_getCurrentRange(totalItems)} of $totalItems',
                                    style: TextStyle(color: RaceColors.white),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_left, color: RaceColors.white),
                                    onPressed: _currentPage > 1
                                        ? () {
                                            setState(() {
                                              _currentPage--;
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right, color: RaceColors.white),
                                    onPressed: (_currentPage * _rowsPerPage) < totalItems
                                        ? () {
                                            setState(() {
                                              _currentPage++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation
          const Navbar(
            selectedIndex: 3,
          ),
        ],
      ),
    );
  }

  // Calculate the total number of pages based on the number of items and rows per page
  int _getPageItemCount(int totalItems) {
    final remainingItems = totalItems - ((_currentPage - 1) * _rowsPerPage);
    return remainingItems < _rowsPerPage ? remainingItems : _rowsPerPage;
  }

  void _deleteResult(int index, RaceResultBoardProvider provider, List<RaceResultItem> results) {
    final deletedResult = results[index];
    
    // Note: In a real implementation, you would call a method on the repository
    // to delete the result. Since we don't have that functionality in the repository,
    // we'll just show a snackbar notification.
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Result deletion not implemented'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}