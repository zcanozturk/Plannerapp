import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pdf_item.dart';

class PdfStorageService {
  static const _pdfsKey = 'pdf_items';

  Future<List<PdfItem>> loadPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pdfsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => PdfItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePdfs(List<PdfItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_pdfsKey, encoded);
  }
}
