// lib/models/user_model.dart
class UserModel {
  final String? id; // id document của Firestore 
  final String idgv;
  final String fullname;
  final String image; // chuỗi vì lưu ở dạng base64
  final int sumClass;

  UserModel({
    this.id,
    required this.idgv,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  // #IDGV, Fullname, Image, SumClass
  Map<String, dynamic> toMap() => {
        'IDGV': idgv,
        'Fullname': fullname,
        'Image': image,
        'SumClass': sumClass,
      };

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
        id: id,
        idgv: map['IDGV'] ?? '',
        fullname: map['Fullname'] ?? '',
        image: map['Image'] ?? '',
        sumClass: (map['SumClass'] ?? 0) is int
            ? map['SumClass']
            : int.tryParse(map['SumClass'].toString()) ?? 0,
      );
}
