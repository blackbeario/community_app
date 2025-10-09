import 'package:flutter/material.dart';

class EditableBio extends StatefulWidget {
  final String? bio;
  final Function(String) onSave;

  const EditableBio({
    super.key,
    required this.bio,
    required this.onSave,
  });

  @override
  State<EditableBio> createState() => _EditableBioState();
}

class _EditableBioState extends State<EditableBio> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.bio);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    setState(() => _isEditing = false);
    widget.onSave(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: _isEditing ? _buildEditMode() : _buildDisplayMode(),
    );
  }

  Widget _buildEditMode() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          maxLines: 5,
          maxLength: 140,
          style: TextStyle(height: 1.25),
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onSubmitted: (_) => _saveAndClose(),
          onEditingComplete: () => _saveAndClose(),
          onTapOutside: (event) => _saveAndClose(),
        ),
      ],
    );
  }

  Widget _buildDisplayMode() {
    return InkWell(
      onTap: () => setState(() => _isEditing = true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.bio ?? 'No bio yet. Tap to add one.',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.bio != null ? Colors.black87 : Colors.grey,
                  height: 1.25
                ),
              ),
            ),
            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
