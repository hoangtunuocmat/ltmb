import 'package:flutter/material.dart';
import 'package:noteapp/model/Note.dart';
import 'package:noteapp/view/note_form.dart';
import 'package:noteapp/db/note_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteForm(
        onSave: (Note note) async {
          try {
            // Retrieve the current user's userId from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getInt('userId');
            if (userId == null) {
              throw Exception('User ID not found. Please log in again.');
            }

            // Create a new Note with the userId
            final noteWithUserId = Note(
              userId: userId,
              title: note.title,
              content: note.content,
              priority: note.priority,
              createdAt: note.createdAt,
              modifiedAt: note.modifiedAt,
              tags: note.tags,
              color: note.color,
            );

            // Save the note to the database
            await NoteDatabaseHelper.instance.createNote(noteWithUserId);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm ghi chú thành công'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back to the previous screen
            Navigator.pop(context, true);
          } catch (e) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi thêm ghi chú: $e'),
                backgroundColor: Colors.red,
              ),
            );

            // Navigate back with a failure indication
            Navigator.pop(context, false);
          }
        },
      ),
    );
  }
}