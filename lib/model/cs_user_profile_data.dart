class UserProfileResp {
  String? message;
  int? code;
  Data? data;

  UserProfileResp({this.message, this.code, this.data});

  UserProfileResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Level {
  int? levelId;
  String? levelName;
  String? levelIcon;
  bool? isVip;

  Level({this.levelId, this.levelName, this.levelIcon, this.isVip});

  Level.fromJson(Map<String, dynamic> json) {
    levelId = json['level_id'];
    levelName = json['level_name'];
    levelIcon = json['level_icon'];
    isVip = json['is_vip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level_id'] = this.levelId;
    data['level_name'] = this.levelName;
    data['level_icon'] = this.levelIcon;
    data['is_vip'] = this.isVip;
    return data;
  }
}

class Data {
  int? project;
  int? like;
  int? words;
  String? avatar;
  String? nickname;
  int? score;
  Level? level;
  String? email;
  int? canDelComment;
  int? isAdmin;
  int? unreadMessage;
  int? unreadChat;

  Data({
    this.project,
    this.like,
    this.words,
    this.avatar,
    this.nickname,
    this.score,
    this.level,
    this.email,
    this.canDelComment,
    this.isAdmin,
    this.unreadMessage,
    this.unreadChat,
  });

  Data.fromJson(Map<String, dynamic> json) {
    project = json['project'];
    like = json['like'];
    words = json['words'];
    avatar = json['avatar'];
    nickname = json['nickname'];
    score = json['score'];
    level = json['level'] != null ? new Level.fromJson(json['level']) : null;
    email = json['email'];
    canDelComment = json['can_del_comment'];
    isAdmin = json['is_admin'];
    unreadMessage = json['unread_message'];
    unreadChat = json['unread_chat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project'] = this.project;
    data['like'] = this.like;
    data['words'] = this.words;
    data['avatar'] = this.avatar;
    data['nickname'] = this.nickname;
    data['score'] = this.score;
    if (this.level != null) {
      data['level'] = this.level!.toJson();
    }
    data['email'] = this.email;
    data['can_del_comment'] = this.canDelComment;
    data['is_admin'] = this.isAdmin;
    data['unread_message'] = this.unreadMessage;
    data['unread_chat'] = this.unreadChat;
    return data;
  }
}
