// lib/services/csv_exporter_web.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> exportCsvPlatform(String csvContent) async {
  final bytes = Uri.encodeFull(csvContent);
  final anchor = html.AnchorElement(
    href: 'data:text/csv;charset=utf-8,$bytes',
  )
    ..setAttribute('download', 'giang_vien.csv')
    ..click();
  anchor.remove();
}
