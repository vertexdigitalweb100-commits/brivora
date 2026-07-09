import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/create_note_dialog.dart';

class NotesScreen extends StatefulWidget {
  final String projectId;

  const NotesScreen({super.key, required this.projectId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Заметки')),
            body: Center(child: Text(provider.error!)),
          );
        }

        if (provider.notes.isEmpty) {
          return _buildEmptyState();
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Заметки')),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final note = provider.notes[index];

              return _buildNoteCard(note);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateDialog,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 70),
            SizedBox(height: 16),
            Text(
              'Пока нет заметок',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Создайте первую заметку'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${note.updatedAt.day}.${note.updatedAt.month}.${note.updatedAt.year}",
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "edit") {
                        _showEditDialog(note);
                      }

                      if (value == "delete") {
                        await context.read<NotesProvider>().deleteNote(note);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Редактировать"),
                      ),
                      PopupMenuItem(value: "delete", child: Text("Удалить")),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return CreateNoteDialog(
          onSave: (title, content) async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) return;

            final now = DateTime.now();

            final note = Note(
              id: '',
              projectId: widget.projectId,
              ownerId: user.uid,
              title: title,
              content: content,
              createdAt: now,
              updatedAt: now,
            );

            await context.read<NotesProvider>().createNote(note);
          },
        );
      },
    );
  }

  void _showEditDialog(Note note) {
    showDialog(
      context: context,
      builder: (_) {
        return CreateNoteDialog(
          note: note,
          onSave: (title, content) async {
            final updatedNote = note.copyWith(
              title: title,
              content: content,
              updatedAt: DateTime.now(),
            );

            await context.read<NotesProvider>().updateNote(updatedNote);
          },
        );
      },
    );
  }
}
