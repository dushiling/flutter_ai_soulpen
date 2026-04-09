class UserModel {
  UserModel({required this.nickname, this.avatar = ''});

  String nickname;
  String avatar;

  Map<String, dynamic> toJson() => {'nickname': nickname, 'avatar': avatar};

  factory UserModel.fromJson(Map map) {
    return UserModel(
      nickname: map['nickname'] as String? ?? '文案达人',
      avatar: map['avatar'] as String? ?? '',
    );
  }
}
