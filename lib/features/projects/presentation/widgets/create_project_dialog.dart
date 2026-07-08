import 'package:flutter/material.dart';

class CreateProjectDialog extends StatefulWidget {
  final Future<void> Function(String title, String description) onCreateProject;

  const CreateProjectDialog({super.key, required this.onCreateProject});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _createProject() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите название проекта')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onCreateProject(title, description);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создать новый проект'),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: _titleController,

              decoration: InputDecoration(
                labelText: 'Название проекта',
                hintText: 'Например: Ремонт квартиры',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),

              enabled: !_isLoading,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,

              decoration: InputDecoration(
                labelText: 'Описание/Адрес объекта (опционально)',

                hintText: 'Например: ул. Пушкина, 23',

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),

              maxLines: 2,

              enabled: !_isLoading,
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),

          child: const Text('Отмена'),
        ),

        ElevatedButton(
          onPressed: _isLoading ? null : _createProject,

          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,

                  child: CircularProgressIndicator(
                    strokeWidth: 2,

                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Создать', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
