import 'package:flutter/material.dart';
import 'package:untitled/page_manager.dart';
import 'package:untitled/services/service_locator.dart';

import 'notifiers/progress_notifier.dart';

class MyWidget extends StatelessWidget {
  // Get the the seconds from current minute.
  //
  // TODO: Make this your actual progress indicator
  // Stream<int> getSecondsFromCurrentMinute() async* {
  //   final now = DateTime.now();
  //   final seconds = now.second;
  //   yield seconds;
  //   await Future.delayed(Duration(seconds: 1 - seconds));
  //   yield* getSecondsFromCurrentMinute();
  // }

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
        valueListenable: pageManager.progressNotifier,
        builder: (_, value, __) {
          return FractionallySizedBox(
            heightFactor: .15,
            widthFactor: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song cover
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                ),

                // Padding
                const SizedBox(width: 15),

                // Play button and progress indicator
                //
              Container(
                width: 40,
                height: 40,
                child: Stack(
                  children: [
                    // the circle showing progress
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: value.total.inSeconds / value.current.inSeconds,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.red,
                          ),
                          backgroundColor: Colors.red.withOpacity(0.15),
                        ),
                      ),
                    ),
                    // the play arrow, inside the circle
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        child: IconButton(
                          icon: Icon(
                            Icons.play_arrow,
                            color: Colors.red,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),


                const SizedBox(width: 8),

                SizedBox(
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.skip_next,
                      color: Colors.red,
                    ),
                  ),
                ),

                //
                const SizedBox(width: 8),

                SizedBox(
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.menu,
                      color: Colors.red,
                      size: 35,
                    ),
                  ),
                ),

                // Extra padding at the end of the row
                const SizedBox(width: 30),
              ],
            ),
          );
        });
  }
}
