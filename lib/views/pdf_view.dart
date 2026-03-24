import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../models/note.dart';
import '../models/pdf_item.dart';
import '../services/note_pdf_link_service.dart';
import '../viewmodels/notes_view_model.dart';
import '../viewmodels/pdf_view_model.dart';
import 'notes_view.dart';

class PdfView extends StatelessWidget {
  const PdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return const PdfLibraryView();
  }
}

class PdfLibraryView extends StatefulWidget {
  const PdfLibraryView({super.key});

  @override
  State<PdfLibraryView> createState() => _PdfLibraryViewState();
}

class _PdfLibraryViewState extends State<PdfLibraryView> {
  late final PdfViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PdfViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final path = result?.files.single.path;
    if (path == null) {
      return;
    }
    await _viewModel.addPdf(path);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('PDF'),
            centerTitle: true,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: _pickPdf,
                icon: const Icon(Icons.upload_file),
                tooltip: 'PDF yükle',
              ),
            ],
          ),
          body: SafeArea(
            child: _viewModel.items.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz PDF yok. Sağ üstten yükleyebilirsin.',
                      style: TextStyle(color: Color(0xFF6B6B6B)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _viewModel.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _viewModel.items[index];
                      return _PdfListItem(
                        item: item,
                        onOpen: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PdfReaderView(item: item),
                            ),
                          );
                        },
                        onDelete: () => _viewModel.deletePdf(item.id),
                      );
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _pickPdf,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class _PdfListItem extends StatelessWidget {
  const _PdfListItem({
    required this.item,
    required this.onOpen,
    required this.onDelete,
  });

  final PdfItem item;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final fileName = item.name.isEmpty ? 'PDF' : item.name;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFE6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf,
                    color: Color(0xFFCC3E30)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfReaderView extends StatefulWidget {
  const PdfReaderView({super.key, required this.item});

  final PdfItem item;

  @override
  State<PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<PdfReaderView> {
  late final PdfControllerPinch _controller;
  late final NotesViewModel _notesViewModel;
  late final NotePdfLinkService _linkService;
  List<String> _linkedNoteIds = [];

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.item.path),
    );
    _notesViewModel = NotesViewModel()..initialize();
    _linkService = NotePdfLinkService();
    _loadLinkedNotes();
  }

  Future<void> _loadLinkedNotes() async {
    final ids = await _linkService.noteIdsForPdf(widget.item.id);
    if (!mounted) {
      return;
    }
    setState(() => _linkedNoteIds = ids);
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesViewModel.dispose();
    super.dispose();
  }

  Future<void> _openNoteSelector() async {
    await _notesViewModel.initialize();
    final selected = [..._linkedNoteIds];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Not bağla',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    if (_notesViewModel.notes.isEmpty)
                      const Text('Henüz not yok.'),
                    if (_notesViewModel.notes.isNotEmpty)
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _notesViewModel.notes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final note = _notesViewModel.notes[index];
                            final isSelected = selected.contains(note.id);
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    selected.add(note.id);
                                  } else {
                                    selected.remove(note.id);
                                  }
                                });
                              },
                              title: Text(
                                note.title.isEmpty ? 'Başlıksız Not' : note.title,
                              ),
                              subtitle: Text(
                                note.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _linkService.setNoteIdsForPdf(
                            widget.item.id,
                            selected,
                          );
                          if (mounted) {
                            setState(() => _linkedNoteIds = [...selected]);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final exists = File(widget.item.path).existsSync();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name.isEmpty ? 'PDF' : widget.item.name),
        actions: [
          IconButton(
            onPressed: _openNoteSelector,
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: 'Notları bağla',
          ),
        ],
      ),
      body: exists
          ? PdfViewPinch(
              controller: _controller,
            )
          : const Center(
              child: Text(
                'Dosya bulunamadı.',
                style: TextStyle(color: Color(0xFF6B6B6B)),
              ),
            ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _notesViewModel,
        builder: (context, _) {
          final byId = {
            for (final note in _notesViewModel.notes) note.id: note
          };
          final linkedNotes = _linkedNoteIds
              .map((id) => byId[id])
              .whereType<Note>()
              .toList();
          if (linkedNotes.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F4EF),
              border: Border(
                top: BorderSide(color: Color(0xFFE6E6E6)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'Notlar:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  ...linkedNotes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          note.title.isEmpty ? 'Başlıksız Not' : note.title,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NoteDetailView(
                                note: note,
                                viewModel: _notesViewModel,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openNoteSelector,
                    child: const Text('Yönet'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
