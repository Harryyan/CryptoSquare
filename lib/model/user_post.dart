import 'package:json_annotation/json_annotation.dart';

part 'user_post.g.dart';

@JsonSerializable()
class UserPostResp {
  final String message;
  final int code;
  final UserPostData data;

  UserPostResp({required this.message, required this.code, required this.data});

  factory UserPostResp.fromJson(Map<String, dynamic> json) =>
      _$UserPostRespFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostRespToJson(this);
}

@JsonSerializable()
class UserPostData {
  final int total;
  final List<UserPostItem> data;
  @JsonKey(name: 'current_page')
  final String currentPage;

  UserPostData({
    required this.total,
    required this.data,
    required this.currentPage,
  });

  factory UserPostData.fromJson(Map<String, dynamic> json) =>
      _$UserPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserPostDataToJson(this);
}

@JsonSerializable()
class UserPostItem {
  final int id;
  final String title;
  final String content;
  final int user;
  final int status;
  final String type;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final int lang;
  @JsonKey(name: 'last_view')
  final int lastView;
  @JsonKey(name: 'last_view_user')
  final int lastViewUser;
  @JsonKey(name: 'reply_nums')
  final int replyNums;
  @JsonKey(name: 'reply_user')
  final String replyUser;
  @JsonKey(name: 'reply_time')
  final int replyTime;
  @JsonKey(name: 'cat_id')
  final int catId;
  final String origin;
  @JsonKey(name: 'origin_link')
  final String originLink;
  @JsonKey(name: 'create_time')
  final int createTime;
  final String profile;
  @JsonKey(name: 'has_tag')
  final int hasTag;
  final int sh5;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final String address;
  final String link;
  final String cover;
  final UserPostExtension extension;

  UserPostItem({
    required this.id,
    required this.title,
    required this.content,
    required this.user,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.lang,
    required this.lastView,
    required this.lastViewUser,
    required this.replyNums,
    required this.replyUser,
    required this.replyTime,
    required this.catId,
    required this.origin,
    required this.originLink,
    required this.createTime,
    required this.profile,
    required this.hasTag,
    required this.sh5,
    required this.startTime,
    required this.endTime,
    required this.address,
    required this.link,
    required this.cover,
    required this.extension,
  });

  factory UserPostItem.fromJson(Map<String, dynamic> json) {
    final extension = json['extension'] ?? {};
    return UserPostItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      user: json['user'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      lang: json['lang'] as int? ?? 0,
      lastView: json['last_view'] as int? ?? 0,
      lastViewUser: json['last_view_user'] as int? ?? 0,
      replyNums: json['reply_nums'] as int? ?? 0,
      replyUser: json['reply_user'] as String? ?? '',
      replyTime: json['reply_time'] as int? ?? 0,
      catId: json['cat_id'] as int? ?? 0,
      origin: json['origin'] as String? ?? '',
      originLink: json['origin_link'] as String? ?? '',
      createTime: json['create_time'] as int? ?? 0,
      profile: json['profile'] as String? ?? '',
      hasTag: json['has_tag'] as int? ?? 0,
      sh5: json['sh5'] as int? ?? 0,
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      address: json['address'] as String? ?? '',
      link: json['link'] as String? ?? '',
      cover: json['cover'] as String? ?? '',
      extension: UserPostExtension.fromJson(extension is Map<String, dynamic> ? extension : {}),
    );
  }

  Map<String, dynamic> toJson() => _$UserPostItemToJson(this);
}

@JsonSerializable()
class UserPostExtension {
  final UserPostMeta meta;
  final List<UserPostTag> tag;
  final UserPostAuth auth;

  UserPostExtension({required this.meta, required this.tag, required this.auth});

  factory UserPostExtension.fromJson(Map<String, dynamic> json) {
    return UserPostExtension(
      meta: json['meta'] != null ? UserPostMeta.fromJson(json['meta'] as Map<String, dynamic>) : UserPostMeta(like: 0, eye: 0, dislike: 0),
      tag: (json['tag'] as List?)?.map((e) {
        if (e is String) return UserPostTag(tag: e);
        if (e is Map && e['tag'] != null) return UserPostTag(tag: e['tag'].toString());
        return UserPostTag(tag: '');
      }).where((e) => e.tag.isNotEmpty).toList() ?? [],
      auth: json['auth'] != null ? UserPostAuth.fromJson(json['auth'] as Map<String, dynamic>) : UserPostAuth(nickname: '', avatar: '', isOnline: false, userKey: '', userId: 0),
    );
  }

  Map<String, dynamic> toJson() => _$UserPostExtensionToJson(this);
}

@JsonSerializable()
class UserPostMeta {
  final int like;
  final int eye;
  final int dislike;

  UserPostMeta({required this.like, required this.eye, required this.dislike});

  factory UserPostMeta.fromJson(Map<String, dynamic> json) {
    return UserPostMeta(
      like: json['like'] as int? ?? 0,
      eye: json['eye'] as int? ?? 0,
      dislike: json['dislike'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$UserPostMetaToJson(this);
}

@JsonSerializable()
class UserPostTag {
  final String tag;
  UserPostTag({required this.tag});
  factory UserPostTag.fromJson(Map<String, dynamic> json) => UserPostTag(tag: json['tag'] as String? ?? '');
  Map<String, dynamic> toJson() => _$UserPostTagToJson(this);
}

@JsonSerializable()
class UserPostAuth {
  final String nickname;
  final String avatar;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'user_key')
  final String userKey;
  @JsonKey(name: 'user_id')
  final int userId;

  UserPostAuth({required this.nickname, required this.avatar, required this.isOnline, required this.userKey, required this.userId});

  factory UserPostAuth.fromJson(Map<String, dynamic> json) {
    return UserPostAuth(
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      userKey: json['user_key'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$UserPostAuthToJson(this);
}

@JsonSerializable()
class CatInfo {
  final String title;
  @JsonKey(name: 'cat_slug')
  final String catSlug;

  CatInfo({required this.title, required this.catSlug});

  factory CatInfo.fromJson(Map<String, dynamic> json) =>
      _$CatInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CatInfoToJson(this);
}
