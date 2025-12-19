import 'package:flutter/material.dart';

class AvailabilitySelector extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  final bool initialValue;

  const AvailabilitySelector({
    super.key,
    required this.onChanged,
    this.initialValue = true,
  });

  @override
  State<AvailabilitySelector> createState() => _AvailabilitySelectorState();
}

class _AvailabilitySelectorState extends State<AvailabilitySelector> {
  late bool _availability;

  @override
  void initState() {
    super.initState();
    _availability = widget.initialValue;
  }

  void _updateAvailability(bool value) {
    setState(() => _availability = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: _availability,
              onChanged: (value) => _updateAvailability(value!),
            ),
            const Text("Online"),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: _availability,
              onChanged: (value) => _updateAvailability(value!),
            ),
            const Text("Offline"),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Selected: ${_availability ? "Online" : "Offline"}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
