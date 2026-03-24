import 'package:flutter/material.dart';

import '../models/note.dart';
import '../viewmodels/notes_view_model.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = NotesViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Color _tagBackground(String tag) {
    switch (tag) {
      case 'İş':
        return const Color(0xFFE6F0FF);
      case 'Kişisel':
        return const Color(0xFFE8F8EE);
      case 'Fikir':
        return const Color(0xFFF1E8FF);
      default:
        return const Color(0xFFEDEDED);
    }
  }

  Color _tagForeground(String tag) {
    switch (tag) {
      case 'İş':
        return const Color(0xFF2D6CDF);
      case 'Kişisel':
        return const Color(0xFF2E8B57);
      case 'Fikir':
        return const Color(0xFF7A4CC2);
      default:
        return const Color(0xFF6B6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final notes = _viewModel.filteredNotes;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notlar'),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TagManagerView(viewModel: _viewModel),
                    ),
                  );
                },
                icon: const Icon(Icons.sell_outlined),
                tooltip: 'Tag yönetimi',
              ),
              IconButton(
                onPressed: () {
                  final tag = _viewModel.tags.length > 1
                      ? _viewModel.tags[1]
                      : 'İş';
                  final note = Note(
                    id: 'note-${DateTime.now().millisecondsSinceEpoch}',
                    title: '',
                    content: '',
                    tags: tag == 'Tümü' ? const ['İş'] : [tag],
                    createdAt: DateTime.now(),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NoteDetailView(
                        note: note,
                        viewModel: _viewModel,
                        isNew: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                tooltip: 'Not ekle',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _viewModel.tags.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tag = _viewModel.tags[index];
                        final isSelected = tag == _viewModel.selectedTag;
                        return ChoiceChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (_) => _viewModel.setSelectedTag(tag),
                          selectedColor: const Color(0xFF2D6CDF),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: const Color(0xFFF4F4F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _viewModel.setQuery,
                    decoration: InputDecoration(
                      hintText: 'Ara...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          note: note,
                          dateLabel: _formatDate(note.createdAt),
                          tagBackground: _tagBackground,
                          tagForeground: _tagForeground,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => NoteDetailView(
                                  note: note,
                                  viewModel: _viewModel,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.dateLabel,
    required this.tagBackground,
    required this.tagForeground,
    required this.onTap,
  });

  final Note note;
  final String dateLabel;
  final Color Function(String tag) tagBackground;
  final Color Function(String tag) tagForeground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE6E6E6)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: note.tags.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'Etiket yok',
                            style: TextStyle(
                              color: Color(0xFF6B6B6B),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ]
                    : note.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: tagBackground(tag),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: tagForeground(tag),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoteDetailView extends StatelessWidget {
  const NoteDetailView({
    super.key,
    required this.note,
    required this.viewModel,
    this.isNew = false,
  });

  final Note note;
  final NotesViewModel viewModel;
  final bool isNew;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return _NoteDetailBody(
      note: note,
      viewModel: viewModel,
      isNew: isNew,
      formatDate: _formatDate,
    );
  }
}

class _NoteDetailBody extends StatefulWidget {
  const _NoteDetailBody({
    required this.note,
    required this.viewModel,
    required this.isNew,
    required this.formatDate,
  });

  final Note note;
  final NotesViewModel viewModel;
  final bool isNew;
  final String Function(DateTime date) formatDate;

  @override
  State<_NoteDetailBody> createState() => _NoteDetailBodyState();
}

class _NoteDetailBodyState extends State<_NoteDetailBody> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late List<String> _selectedTags;
  late Note _currentNote;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedTags = [...widget.note.tags];
    _currentNote = widget.note;
    _isEditing = widget.isNew;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (_selectedTags.isEmpty) {
      _selectedTags = ['İş'];
    }
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final updated = Note(
      id: widget.note.id,
      title: title.isEmpty ? 'Başlıksız Not' : title,
      content: content,
      tags: _selectedTags,
      createdAt: DateTime.now(),
    );
    if (widget.isNew) {
      widget.viewModel.addNote(updated);
    } else {
      widget.viewModel.updateNote(updated);
    }
    setState(() {
      _currentNote = updated;
      _isEditing = false;
    });
  }

  void _deleteNote() {
    widget.viewModel.deleteNote(widget.note.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Not'),
            centerTitle: true,
            actions: [
              if (!_isEditing)
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                ),
              if (_isEditing)
                TextButton(
                  onPressed: _saveNote,
                  child: const Text('Done'),
                ),
              if (!widget.isNew)
                IconButton(
                  onPressed: _deleteNote,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isEditing
                      ? TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Not başlığı',
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          _currentNote.title.isEmpty
                              ? 'Başlıksız Not'
                              : _currentNote.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _isEditing
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: widget.viewModel.tags
                                    .where((tag) => tag != 'Tümü')
                                    .map(
                                      (tag) => FilterChip(
                                        label: Text(tag),
                                        selected: _selectedTags.contains(tag),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedTags = [
                                                ..._selectedTags,
                                                tag
                                              ];
                                            } else {
                                              _selectedTags = _selectedTags
                                                  .where(
                                                      (item) => item != tag)
                                                  .toList();
                                            }
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: _currentNote.tags.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDEDED),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Text(
                                            'Etiket yok',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                          ),
                                        ),
                                      ]
                                    : _currentNote.tags
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEDEDED),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Text(
                                              tag,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6B6B6B),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TagManagerView(
                                  viewModel: widget.viewModel,
                                ),
                              ),
                            );
                          },
                          child: const Text('Tag ekle'),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Text(
                        widget.formatDate(_currentNote.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _isEditing
                          ? TextField(
                              controller: _contentController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Not içeriği...',
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF333333),
                              ),
                            )
                          : Text(
                              _currentNote.content,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Color(0xFF333333),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TagManagerView extends StatefulWidget {
  const TagManagerView({super.key, required this.viewModel});

  final NotesViewModel viewModel;

  @override
  State<TagManagerView> createState() => _TagManagerViewState();
}

class _TagManagerViewState extends State<TagManagerView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    widget.viewModel.addTag(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final tags =
            widget.viewModel.tags.where((tag) => tag != 'Tümü').toList();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tag Yönetimi'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Yeni tag',
                      suffixIcon: IconButton(
                        onPressed: _addTag,
                        icon: const Icon(Icons.add),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: tags.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE6E6E6)),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
