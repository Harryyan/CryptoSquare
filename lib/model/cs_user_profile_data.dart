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

class Data {
  int? project;
  int? like;
  int? words;
  String? avatar;
  String? nickname;
  int? score;
  String? email;
  int? canDelComment;
  int? unreadMessage;

  Data({
    this.project,
    this.like,
    this.words,
    this.avatar,
    this.nickname,
    this.score,
    this.email,
    this.canDelComment,
    this.unreadMessage,
  });

  Data.fromJson(Map<String, dynamic> json) {
    project = json['project'];
    like = json['like'];
    words = json['words'];
    avatar = json['avatar'];
    nickname = json['nickname'];
    score = json['score'];
    email = json['email'];
    canDelComment = json['can_del_comment'];
    unreadMessage = json['unread_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['project'] = this.project;
    data['like'] = this.like;
    data['words'] = this.words;
    data['avatar'] = this.avatar;
    data['nickname'] = this.nickname;
    data['score'] = this.score;
    data['email'] = this.email;
    data['can_del_comment'] = this.canDelComment;
    data['unread_message'] = this.unreadMessage;
    return data;
  }
}
