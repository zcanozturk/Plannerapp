import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/pdf_item.dart';
import '../services/pdf_storage_service.dart';

class PdfViewModel extends ChangeNotifier {
  PdfViewModel({PdfStorageService? storageService})
      : _storageService = storageService ?? PdfStorageService();

  final PdfStorageService _storageService;

  List<PdfItem> items = [];

  Future<void> initialize() async {
    items = await _storageService.loadPdfs();
    notifyListeners();
  }

  Future<void> addPdf(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      return;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = source.uri.pathSegments.last;
    final targetPath =
        '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}-$fileName';
    final copied = await source.copy(targetPath);
    final item = PdfItem(
      id: 'pdf-${DateTime.now().millisecondsSinceEpoch}',
      name: fileName,
      path: copied.path,
      addedAt: DateTime.now(),
    );
    items = [item, ...items];
    await _storageService.savePdfs(items);
    notifyListeners();
  }

  Future<void> deletePdf(String id) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final next = [...items]..removeAt(index);
    items = next;
    await _storageService.savePdfs(items);
    notifyListeners();
  }
}
