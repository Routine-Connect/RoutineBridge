class User {

  final int id;
  final String email;
  final String nickname;
  final String gender;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.gender,
    this.profileImage,
    });

    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      gender: json['gender'],
      profileImage: json['profile_image'],
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? nickname,
    String? gender,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage, // 이미지 변경 시 덮어씌움
    );
  }
}