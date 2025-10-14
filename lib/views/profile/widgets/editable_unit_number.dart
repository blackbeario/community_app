import 'package:flutter/material.dart';

class EditableUnitNumber extends StatefulWidget {
  final String? unitNumber;
  final Function(String) onSave;

  const EditableUnitNumber({
    super.key,
    required this.unitNumber,
    required this.onSave,
  });

  @override
  State<EditableUnitNumber> createState() => _EditableUnitNumberState();
}

class _EditableUnitNumberState extends State<EditableUnitNumber> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.unitNumber);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveAndClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    setState(() {
      _isEditing = false;
    });
    if (_controller.text.trim().isNotEmpty) {
      widget.onSave(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  decoration: InputDecoration(
                    hintText: 'Address',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onSubmitted: (_) => _saveAndClose(),
                  onEditingComplete: () => _saveAndClose(),
                  onTapOutside: (event) => _saveAndClose(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.unitNumber ?? 'Address',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.unitNumber != null ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
