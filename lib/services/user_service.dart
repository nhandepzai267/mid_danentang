// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Conditional import: tự động chọn đúng implementation theo platform
import 'csv_exporter_mobile.dart'
    if (dart.library.html) 'csv_exporter_web.dart';

class UserService {
  // Đổi đề: chỉ cần đổi tên collection ở đây
  static const String collectionName = 'GiangVien';

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection(collectionName);

  // Lấy danh sách realtime
  Stream<List<UserModel>> getUsers() {
    return _col.snapshots().map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addUser(UserModel u) => _col.add(u.toMap());

  Future<void> updateUser(UserModel u) => _col.doc(u.id).update(u.toMap());

  Future<void> deleteUser(String id) => _col.doc(id).delete();

  // Đăng nhập
  Future<UserModel?> login(String idgv, String fullname) async {
    final q = await _col
        .where('IDGV', isEqualTo: idgv)
        .where('Fullname', isEqualTo: fullname)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return UserModel.fromMap(q.docs.first.id, q.docs.first.data());
  }

  // Tạo nội dung CSV
  String _buildCsv(List<UserModel> users) {
    final buffer = StringBuffer();
    buffer.writeln('IDGV,Fullname,SumClass');
    for (final u in users) {
      final idgv = '"${u.idgv.replaceAll('"', '""')}"';
      final fullname = '"${u.fullname.replaceAll('"', '""')}"';
      buffer.writeln('$idgv,$fullname,${u.sumClass}');
    }
    return buffer.toString();
  }

  // Xuất CSV — tự động web hay mobile qua conditional import
  Future<void> exportCsv() async {
    final snap = await _col.get();
    final users =
        snap.docs.map((d) => UserModel.fromMap(d.id, d.data())).toList();
    final csvContent = _buildCsv(users);
    await exportCsvPlatform(csvContent);
  }
}
