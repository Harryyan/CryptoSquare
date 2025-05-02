class CSUserResp {
  String? message;
  int? code;

  CSUserResp({this.message, this.code});

  CSUserResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['code'] = this.code;
    return data;
  }
}

class CSUserAvatarResp {
  String? message;
  int? code;
  Data? data;

  CSUserAvatarResp({this.message, this.code, this.data});

  CSUserAvatarResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    code = json['code'];
  }
}

class CSUserLoginResp {
  String? message;
  Data? data;
  int? code;

  CSUserLoginResp({this.message, this.data, this.code});

  CSUserLoginResp.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['code'] = this.code;
    return data;
  }
}

class Data {
  String? secret;
  UserPermission? userPermission;
  int? gradeExptime;
  int? iD;
  String? userLogin;
  int? wikiEdit;
  String? avatar;
  int? canDelComment;
  int? gradePre;
  String? nickname;
  String? inviteCode;
  String? email;
  int? grade;

  Data({
    this.secret,
    this.userPermission,
    this.gradeExptime,
    this.iD,
    this.userLogin,
    this.wikiEdit,
    this.avatar,
    this.canDelComment,
    this.gradePre,
    this.nickname,
    this.inviteCode,
    this.email,
    this.grade,
  });

  Data.fromJson(Map<String, dynamic> json) {
    secret = json['secret'];
    userPermission =
        json['user_permission'] != null
            ? new UserPermission.fromJson(json['user_permission'])
            : null;
    gradeExptime = json['grade_exptime'];
    iD = json['ID'];
    userLogin = json['user_login'];
    wikiEdit = json['wiki_edit'];
    avatar = json['avatar'];
    canDelComment = json['can_del_comment'];
    gradePre = json['grade_pre'];
    nickname = json['nickname'];
    inviteCode = json['invite_code'];
    email = json['email'];
    grade = json['grade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['secret'] = this.secret;
    if (this.userPermission != null) {
      data['user_permission'] = this.userPermission!.toJson();
    }
    data['grade_exptime'] = this.gradeExptime;
    data['ID'] = this.iD;
    data['user_login'] = this.userLogin;
    data['wiki_edit'] = this.wikiEdit;
    data['avatar'] = this.avatar;
    data['can_del_comment'] = this.canDelComment;
    data['grade_pre'] = this.gradePre;
    data['nickname'] = this.nickname;
    data['invite_code'] = this.inviteCode;
    data['email'] = this.email;
    data['grade'] = this.grade;
    return data;
  }
}

class UserPermission {
  int? translate;
  int? create;
  int? edit;

  UserPermission({this.translate, this.create, this.edit});

  UserPermission.fromJson(Map<String, dynamic> json) {
    translate = json['translate'];
    create = json['create'];
    edit = json['edit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['translate'] = this.translate;
    data['create'] = this.create;
    data['edit'] = this.edit;
    return data;
  }
}
