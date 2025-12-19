import 'package:flutter/material.dart';

class FileTypeSelector extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;

  const FileTypeSelector({
    super.key,
    required this.onChanged,
    this.initialValue = "web",
  });

  @override
  State<FileTypeSelector> createState() => _FileTypeSelectorState();
}

class _FileTypeSelectorState extends State<FileTypeSelector> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue;
  }

  void _updateAvailability(String value) {
    setState(() => _selectedType = value);
    widget.onChanged(value);
  }

  Widget _option(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedType,
          onChanged: (value) => _updateAvailability(value!),
        ),
        Text(label),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _option("web", "Web"),
              _option("pdf", "PDF"),
              _option("doc", "Doc"),
              _option("ppt", "PPT"),
              _option("xls", "Excel"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Selected: $_selectedType",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
