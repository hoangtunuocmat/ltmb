import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/model/Note.dart';
import 'package:noteapp/view/detail_note.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/db/theme_provider.dart';
import 'package:share_plus/share_plus.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool isGridView;

  const NoteListItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    this.isGridView = false,
  }) : super(key: key);

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color getPriorityColor(int priority, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (priority) {
      case 1:
        return isDarkMode ? Colors.lightGreen[300]! : Colors.lightGreen;
      case 2:
        return isDarkMode ? Colors.blueAccent[100]! : Colors.blueAccent;
      case 3:
        return isDarkMode ? Colors.redAccent[100]! : Colors.redAccent;
      default:
        return isDarkMode ? Colors.grey[700]! : Colors.grey;
    }
  }

  String getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Cao';
      default:
        return 'Không rõ';
    }
  }

  IconData getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icons.low_priority;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.priority_high;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailNote(note: note)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black54 : const Color(0x22000000),
              blurRadius: 10,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  getPriorityIcon(note.priority),
                  color: getPriorityColor(note.priority, context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: isGridView ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 80),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: getPriorityColor(note.priority, context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getPriorityLabel(note.priority),
                    style: TextStyle(
                      fontSize: 10,
                      color: getPriorityColor(note.priority, context),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              maxLines: isGridView ? 2 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isGridView ? 13 : 15,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                height: 1.5,
              ),
            ),
            if (!isGridView && note.tags != null && note.tags!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: note.tags!.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[100],
                    labelStyle: const TextStyle(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(note.createdAt),
                  style: TextStyle(
                    fontSize: isGridView ? 10 : 12,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: isDarkMode ? Colors.blueAccent[100] : Colors.blueAccent,
                          size: isGridView ? 20 : 24,
                        ),
                        onPressed: onEdit,
                        tooltip: 'Sửa ghi chú',
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: isDarkMode ? Colors.redAccent[100] : Colors.redAccent,
                          size: isGridView ? 20 : 24,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xoá'),
                              content: const Text('Bạn có chắc chắn muốn xoá ghi chú này?'),
                              actions: [
                                TextButton(
                                  child: const Text('Huỷ'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text('Xoá'),
                                  onPressed: () {
                                    onDelete();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (!isGridView)
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.green, size: 24),
                          onPressed: () {
                            final content = '''
                        📝 ${note.title}
                         ${note.content}

                        📅 Ngày tạo: ${formatDate(note.createdAt)}
                        🔺 Mức độ ưu tiên: ${getPriorityLabel(note.priority)}
                         ${note.tags != null && note.tags!.isNotEmpty ? '🏷️ Nhãn: ${note.tags!.join(', ')}' : ''}
                            ''';
                            Share.share(content, subject: note.title);
                          },
                          tooltip: 'Chia sẻ',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}