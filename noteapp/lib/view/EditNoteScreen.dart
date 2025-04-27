import 'package:flutter/material.dart';
import 'package:noteapp/model/Note.dart';
import 'package:noteapp/view/note_form.dart';
import 'package:noteapp/db/note_database.dart';

class EditNoteScreen extends StatelessWidget {
  final Note note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoteForm(
        note: note,
        onSave: (Note updatedNote) async {
          try {
            // Ensure the userId is preserved
            final noteToSave = updatedNote.copyWith(
              id: note.id,
              userId: note.userId, // Preserve the original userId
            );

            // Cập nhật thông tin ghi chú trong cơ sở dữ liệu
            await NoteDatabaseHelper.instance.updateNote(noteToSave);

            // Hiển thị thông báo cập nhật thành công
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật ghi chú thành công'),
                backgroundColor: Colors.green,
              ),
            );

            // Đóng màn hình và trả về `true` để báo rằng cập nhật thành công
            Navigator.pop(context, true);
          } catch (e) {
            // Hiển thị thông báo lỗi nếu có vấn đề xảy ra
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật ghi chú: $e'),
                backgroundColor: Colors.red,
              ),
            );

            // Đóng màn hình và trả về `false` để báo lỗi
            Navigator.pop(context, false);
          }
        },
      ),
    );
  }
}