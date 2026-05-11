class User {

  final int id;
  final String email;
  final String nickname;
  final String gender;
  final String? profileImage;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.gender,
    this.profileImage,
    required this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      gender: json['gender'],
      profileImage: json['profileImage'],
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? gender,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage, // 이미지 변경 시 덮어씌움
      createdAt: createdAt ?? this.createdAt,
    );
  }
}