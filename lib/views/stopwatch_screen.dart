import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/stopwatch_provider.dart';  // Import the Stopwatch provider

class StopwatchScreen extends ConsumerStatefulWidget {
  const StopwatchScreen({super.key});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends ConsumerState<StopwatchScreen> {
  // Controllers to manage the input for hours, minutes, and seconds
  TextEditingController _hoursController = TextEditingController(text: "00");
  TextEditingController _minutesController = TextEditingController(text: "00");
  TextEditingController _secondsController = TextEditingController(text: "00");

  @override
  Widget build(BuildContext context) {
    final stopwatchState = ref.watch(stopwatchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the formatted time in H:M:S format
            Text(
              stopwatchState.formattedTime,  // Display formatted time
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Start/Stop Button
            ElevatedButton(
              onPressed: () {
                ref.read(stopwatchProvider.notifier).toggleStopwatch();
              },
              child: Text(stopwatchState.isRunning ? 'Stop' : 'Start'),
            ),
            const SizedBox(height: 10),

            // Reset Button
            ElevatedButton(
              onPressed: () {
                ref.read(stopwatchProvider.notifier).resetStopwatch();
              },
              child: const Text('Reset'),
            ),
            const SizedBox(height: 20),

            // Countdown Time Inputs (H:M:S)
            Text('Set Countdown Time'),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hours Field
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'HH'),
                  ),
                ),
                const SizedBox(width: 10),
                // Minutes Field
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'MM'),
                  ),
                ),
                const SizedBox(width: 10),
                // Seconds Field
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _secondsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'SS'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Start Countdown Button
            ElevatedButton(
              onPressed: () {
                // Convert the entered H:M:S format to total seconds
                int totalSeconds = ref.read(stopwatchProvider.notifier).convertToSeconds(
                  '${_hoursController.text}:${_minutesController.text}:${_secondsController.text}'
                );
                ref.read(stopwatchProvider.notifier).startCountdown(totalSeconds);
              },
              child: const Text('Start Countdown'),
            ),
            const SizedBox(height: 20),

            // Stop Countdown Button
            ElevatedButton(
              onPressed: () {
                ref.read(stopwatchProvider.notifier).stopCountdown();
              },
              child: const Text('Stop Countdown'),
            ),
          ],
        ),
      ),
    );
  }
}
