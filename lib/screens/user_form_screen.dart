// lib/screens/user_form_screen.dart
// Dùng chung cho Thêm (user == null) và Sửa (user != null)
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = UserService();
  late final TextEditingController _idgv;
  late final TextEditingController _fullname;
  late final TextEditingController _sumClass;
  String _image = ''; // base64
  bool _saving = false;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _idgv = TextEditingController(text: widget.user?.idgv ?? '');
    _fullname = TextEditingController(text: widget.user?.fullname ?? '');
    _sumClass = TextEditingController(
        text: widget.user?.sumClass != null
            ? widget.user!.sumClass.toString()
            : '');
    _image = widget.user?.image ?? '';
  }

  @override
  void dispose() {
    _idgv.dispose();
    _fullname.dispose();
    _sumClass.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    setState(() => _image = base64Encode(bytes));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final u = UserModel(
        id: widget.user?.id,
        idgv: _idgv.text.trim(),
        fullname: _fullname.text.trim(),
        image: _image,
        sumClass: int.tryParse(_sumClass.text.trim()) ?? 0,
      );
      if (_isEdit) {
        await _service.updateUser(u);
      } else {
        await _service.addUser(u);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Sửa giảng viên' : 'Thêm giảng viên')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Chọn ảnh
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: _image.isNotEmpty
                      ? MemoryImage(base64Decode(_image))
                      : null,
                  child: _image.isEmpty
                      ? const Icon(Icons.add_a_photo, size: 36)
                      : null,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Bấm vào để chọn ảnh'),
              const SizedBox(height: 16),

              // IDGV
              TextFormField(
                controller: _idgv,
                decoration: const InputDecoration(
                    labelText: 'IDGV (Mã giảng viên)',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập IDGV' : null,
              ),
              const SizedBox(height: 12),

              // Fullname
              TextFormField(
                controller: _fullname,
                decoration: const InputDecoration(
                    labelText: 'Fullname (Họ và tên)',
                    border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
              ),
              const SizedBox(height: 12),

              // SumClass
              TextFormField(
                controller: _sumClass,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'SumClass (Tổng số lớp)',
                    border: OutlineInputBorder()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nhập số lớp';
                  if (int.tryParse(v.trim()) == null) return 'Phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Nút lưu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEdit ? 'Cập nhật' : 'Thêm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
