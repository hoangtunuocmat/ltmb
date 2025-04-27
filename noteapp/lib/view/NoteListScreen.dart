import 'package:flutter/material.dart';
import 'package:noteapp/db/note_database.dart';
import 'package:noteapp/model/Note.dart';
import 'package:noteapp/view/AddNoteScreen.dart';
import 'package:noteapp/view/EditNoteScreen.dart';
import 'package:noteapp/view/NoteListItem.dart';
import 'package:noteapp/view/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/db/theme_provider.dart';

class NoteListScreen extends StatefulWidget {
  final Future<void> Function() onLogout;
  const NoteListScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();
  int? _currentUserId;
  int? _selectedPriority;
  bool _isGridView = false; // Trạng thái chế độ hiển thị (false: List, true: Grid)

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUserIdAndNotes();
  }

  Future<void> _loadUserIdAndNotes() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId');
    if (_currentUserId == null) {
      await widget.onLogout();
      return;
    }
    _loadNotes();
  }

  void _onSearchChanged() {
    _filterNotes();
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _allNotes.where((note) {
        final matchesSearch = query.isEmpty ||
            note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            (note.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false);
        final matchesPriority =
            _selectedPriority == null || note.priority == _selectedPriority;
        return matchesSearch && matchesPriority;
      }).toList();
    });
  }

  void _loadNotes() {
    if (_currentUserId == null) return;
    _notesFuture = NoteDatabaseHelper.instance.getAllNotes(_currentUserId!);
    _notesFuture.then((notes) {
      setState(() {
        _allNotes = notes;
        _filterNotes();
      });
    });
  }

  Future<void> _deleteNote(int id) async {
    await NoteDatabaseHelper.instance.deleteNote(id);
    _loadNotes();
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleLogout();
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ghi Chú Của Bạn',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotes,
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: _toggleViewMode,
            tooltip: _isGridView ? 'Chuyển sang chế độ danh sách' : 'Chuyển sang chế độ lưới',
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Chuyển đổi chế độ tối/sáng',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<int?>(
                  value: _selectedPriority,
                  hint: const Text('Lọc ưu tiên'),
                  items: const [
                    DropdownMenuItem<int?>(value: null, child: Text('Tất cả')),
                    DropdownMenuItem<int>(value: 1, child: Text('Thấp')),
                    DropdownMenuItem<int>(value: 2, child: Text('Trung bình')),
                    DropdownMenuItem<int>(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value;
                      _filterNotes();
                    });
                  },
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Note>>(
              future: _notesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (_filteredNotes.isEmpty) {
                  return const Center(child: Text('Không tìm thấy ghi chú nào.'));
                } else {
                  final notes = _filteredNotes;
                  notes.sort((a, b) => b.priority.compareTo(a.priority));

                  if (_isGridView) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Tỷ lệ chiều rộng/chiều cao
                      ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return NoteListItem(
                          note: note,
                          onDelete: () => _deleteNote(note.id!),
                          onEdit: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNoteScreen(note: note),
                              ),
                            );
                            if (updated == true) {
                              _loadNotes();
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return NoteListItem(
                          note: note,
                          onDelete: () => _deleteNote(note.id!),
                          onEdit: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNoteScreen(note: note),
                              ),
                            );
                            if (updated == true) {
                              _loadNotes();
                            }
                          },
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm ghi chú',
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
          if (created == true) {
            _loadNotes();
          }
        },
      ),
    );
  }
}