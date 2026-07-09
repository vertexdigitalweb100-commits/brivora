import 'package:flutter/material.dart';

import '../../domain/models/note.dart';

class CreateNoteDialog extends StatefulWidget {
  final Note? note;
  final Future<void> Function(String title, String content) onSave;

  const CreateNoteDialog({super.key, this.note, required this.onSave});

  @override
  State<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isLoading = false;

  bool get _isEdit => widget.note != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onSave(
        _titleController.text.trim(),
        _contentController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? 'Ошибка редактирования заметки'
                  : 'Ошибка создания заметки',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Редактировать заметку' : 'Новая заметка'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Текст заметки',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEdit ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }
}
