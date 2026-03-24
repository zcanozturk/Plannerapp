import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NotePdfLinkService {
  static const _key = 'note_pdf_links';

  Future<Map<String, List<String>>> loadLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) {
      final list = value is List
          ? value.map((item) => item.toString()).toList()
          : <String>[];
      return MapEntry(key, list);
    });
  }

  Future<void> saveLinks(Map<String, List<String>> links) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(links));
  }

  Future<List<String>> pdfIdsForNote(String noteId) async {
    final links = await loadLinks();
    return links[noteId] ?? <String>[];
  }

  Future<List<String>> noteIdsForPdf(String pdfId) async {
    final links = await loadLinks();
    return links.entries
        .where((entry) => entry.value.contains(pdfId))
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> setPdfIdsForNote(String noteId, List<String> pdfIds) async {
    final links = await loadLinks();
    links[noteId] = pdfIds;
    await saveLinks(links);
  }

  Future<void> setNoteIdsForPdf(String pdfId, List<String> noteIds) async {
    final links = await loadLinks();
    for (final entry in links.entries) {
      entry.value.remove(pdfId);
    }
    for (final noteId in noteIds) {
      final list = links[noteId] ?? <String>[];
      if (!list.contains(pdfId)) {
        list.add(pdfId);
      }
      links[noteId] = list;
    }
    await saveLinks(links);
  }
}
