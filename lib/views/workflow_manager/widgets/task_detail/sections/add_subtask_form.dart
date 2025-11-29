import 'package:flutter/material.dart';
import '../../../../../config/constants/app_colors.dart';
import '../../../../../models/actor.dart';

/// Form to add a new subtask
/// Single Responsibility: Handle subtask creation input
class AddSubtaskForm extends StatefulWidget {
  final List<Actor> availableActors;
  final Function(String, String?) onAdd;

  const AddSubtaskForm({
    super.key,
    required this.availableActors,
    required this.onAdd,
  });

  @override
  State<AddSubtaskForm> createState() => _AddSubtaskFormState();
}

class _AddSubtaskFormState extends State<AddSubtaskForm> {
  final _controller = TextEditingController();
  String? _selectedActorId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      widget.onAdd(name, _selectedActorId);
      _controller.clear();
      setState(() => _selectedActorId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add a subtask...',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _handleAdd(),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _selectedActorId,
            hint: const Icon(Icons.person_add_outlined, size: 20),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Icon(Icons.person_off_outlined, size: 20),
              ),
              ...widget.availableActors.map((actor) {
                return DropdownMenuItem<String>(
                  value: actor.id,
                  child: Text(actor.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedActorId = value);
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _handleAdd,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

