import 'package:flutter/foundation.dart';

import '../models/note.dart';
import '../services/note_storage_service.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel({NoteStorageService? storageService})
      : _storageService = storageService ?? NoteStorageService();

  final NoteStorageService _storageService;

  List<Note> notes = [];
  List<String> customTags = [];
  String selectedTag = 'Tümü';
  String query = '';

  List<String> get tags {
    final unique = <String>{};
    unique.addAll(customTags);
    for (final note in notes) {
      unique.addAll(note.tags);
    }
    final sorted = unique.toList()..sort();
    return ['Tümü', ...sorted];
  }

  List<Note> get filteredNotes {
    final lowerQuery = query.trim().toLowerCase();
    return notes.where((note) {
      final matchesTag = selectedTag == 'Tümü' ||
          note.tags.contains(selectedTag);
      if (!matchesTag) {
        return false;
      }
      if (lowerQuery.isEmpty) {
        return true;
      }
      final inTitle = note.title.toLowerCase().contains(lowerQuery);
      final inContent = note.content.toLowerCase().contains(lowerQuery);
      return inTitle || inContent;
    }).toList();
  }

  Future<void> initialize() async {
    final stored = await _storageService.loadNotes();
    final storedTags = await _storageService.loadTags();
    if (stored.isNotEmpty) {
      notes = stored;
    } else {
      _seedDefaults();
      await _storageService.saveNotes(notes);
    }
    if (storedTags.isNotEmpty) {
      customTags = storedTags;
    } else {
      customTags = ['İş', 'Kişisel', 'Fikir'];
      await _storageService.saveTags(customTags);
    }
    notifyListeners();
  }

  void setSelectedTag(String tag) {
    if (selectedTag == tag) {
      return;
    }
    selectedTag = tag;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void addNote(Note note) {
    notes = [note, ...notes];
    _storageService.saveNotes(notes);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = notes.indexWhere((item) => item.id == note.id);
    if (index == -1) {
      return;
    }
    final updated = [...notes];
    updated[index] = note;
    notes = updated;
    _storageService.saveNotes(notes);
    notifyListeners();
  }

  void deleteNote(String noteId) {
    final next = notes.where((note) => note.id != noteId).toList();
    if (next.length == notes.length) {
      return;
    }
    notes = next;
    _storageService.saveNotes(notes);
    notifyListeners();
  }

  void addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (customTags.contains(trimmed)) {
      return;
    }
    customTags = [...customTags, trimmed];
    _storageService.saveTags(customTags);
    notifyListeners();
  }

  void _seedDefaults() {
    notes = [
      Note(
        id: 'note-1',
        title: 'Proje Notları',
        content: 'Müşteri talepleri...',
        tags: const ['İş'],
        createdAt: DateTime(2022, 1, 23),
      ),
      Note(
        id: 'note-2',
        title: 'Alışveriş Listesi',
        content: 'Süt, Ekmek, Yumurta',
        tags: const ['Kişisel'],
        createdAt: DateTime(2022, 1, 24),
      ),
      Note(
        id: 'note-3',
        title: 'Yeni Fikirler',
        content: 'Yeni kampanya fikri...',
        tags: const ['Fikir'],
        createdAt: DateTime(2022, 1, 22),
      ),
      Note(
        id: 'note-4',
        title: 'Okunacak Kitaplar',
        content: 'Kitap önerileri listesi',
        tags: const ['Kişisel'],
        createdAt: DateTime(2022, 1, 20),
      ),
      Note(
        id: 'note-5',
        title: 'Toplantı Ajandası',
        content: 'Gündem maddeleri...',
        tags: const ['İş'],
        createdAt: DateTime(2022, 1, 23),
      ),
    ];
  }
}
