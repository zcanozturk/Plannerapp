import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../models/pdf_item.dart';
import '../viewmodels/pdf_view_model.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openFile(widget.item.path),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exists = File(widget.item.path).existsSync();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name.isEmpty ? 'PDF' : widget.item.name),
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
    );
  }
}
