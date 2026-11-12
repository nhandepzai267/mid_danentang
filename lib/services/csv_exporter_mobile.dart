// lib/services/csv_exporter_mobile.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportCsvPlatform(String csvContent) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/giang_vien.csv');
  await file.writeAsString(csvContent, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    subject: 'Danh sách giảng viên',
  );
}
