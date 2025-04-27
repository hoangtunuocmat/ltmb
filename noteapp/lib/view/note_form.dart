import 'package:flutter/material.dart';
import 'package:noteapp/model/Note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const NoteForm({Key? key, this.note, required this.onSave}) : super(key: key);

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late List<String> _tags;
  late int _priority;
  late DateTime _createdAt;
  late String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagInputController = TextEditingController();
    _tags = widget.note?.tags ?? [];
    _priority = widget.note?.priority ?? 1;
    _createdAt = widget.note?.createdAt ?? DateTime.now();
    _selectedColor = widget.note?.color ?? '#FFFFFF';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      int userId;
      if (widget.note != null) {
        userId = widget.note!.userId;
      } else {
        final prefs = await SharedPreferences.getInstance();
        userId = prefs.getInt('userId') ?? 0;
        if (userId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Vui lòng đăng nhập lại.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final newNote = Note(
        id: widget.note?.id,
        userId: userId,
        title: _titleController.text,
        content: _contentController.text,
        priority: _priority,
        createdAt: _createdAt,
        modifiedAt: DateTime.now(),
        tags: _tags,
        color: _selectedColor,
      );

      widget.onSave(newNote);
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar for the form
              AppBar(
                title: Text(
                  widget.note == null ? 'Thêm Ghi Chú' : 'Chỉnh Sửa Ghi Chú',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue[700],
                actions: [
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: _submitForm,
                    tooltip: 'Lưu ghi chú',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Content field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Priority dropdown
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Tags input and display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tagInputController,
                    decoration: InputDecoration(
                      labelText: 'Nhập nhãn',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _addTag(_tagInputController.text),
                      ),
                    ),
                    onSubmitted: _addTag,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: Colors.blue[100],
                        labelStyle: const TextStyle(color: Colors.black),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Color picker
              // Row(
              //   children: [
              //     const Text('Màu nền: '),
              //     const SizedBox(width: 8),
              //     GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           _selectedColor = _selectedColor == '#FFFFFF' ? '#FFCDD2' : '#FFFFFF';
              //         });
              //       },
              //       child: Container(
              //         width: 40,
              //         height: 40,
              //         decoration: BoxDecoration(
              //           color: Color(int.parse(_selectedColor!.replaceFirst('#', '0xff'))),
              //           border: Border.all(color: Colors.black),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}