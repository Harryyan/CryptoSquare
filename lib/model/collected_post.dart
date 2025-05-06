import 'package:json_annotation/json_annotation.dart';

part 'collected_post.g.dart';

@JsonSerializable()
class CollectedPostResp {
  final String message;
  final int code;
  final CollectedPostData data;

  CollectedPostResp({
    required this.message,
    required this.code,
    required this.data,
  });

  factory CollectedPostResp.fromJson(Map<String, dynamic> json) =>
      _$CollectedPostRespFromJson(json);

  Map<String, dynamic> toJson() => _$CollectedPostRespToJson(this);
}

@JsonSerializable()
class CollectedPostData {
  final int total;
  final List<PostItem> data;
  @JsonKey(name: 'current_page')
  final String currentPage;
  final String order;

  CollectedPostData({
    required this.total,
    required this.data,
    required this.currentPage,
    required this.order,
  });

  factory CollectedPostData.fromJson(Map<String, dynamic> json) =>
      _$CollectedPostDataFromJson(json);

  Map<String, dynamic> toJson() => _$CollectedPostDataToJson(this);
}

@JsonSerializable()
class PostItem {
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
  final int ding;
  final int cai;
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
  @JsonKey(name: 'is_top')
  final int isTop;
  @JsonKey(name: 'is_hot')
  final int isHot;
  final String contact;
  final String address;
  final PostExtension extension;
  @JsonKey(name: 'cat_name')
  final String catName;
  @JsonKey(name: 'cat_info')
  final CatInfo catInfo;

  PostItem({
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
    required this.ding,
    required this.cai,
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
    required this.isTop,
    required this.isHot,
    required this.contact,
    required this.address,
    required this.extension,
    required this.catName,
    required this.catInfo,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) =>
      _$PostItemFromJson(json);

  Map<String, dynamic> toJson() => _$PostItemToJson(this);
}

@JsonSerializable()
class PostExtension {
  final PostMeta meta;
  final List<PostTag> tag;
  final PostAuth auth;

  PostExtension({required this.meta, required this.tag, required this.auth});

  factory PostExtension.fromJson(Map<String, dynamic> json) =>
      _$PostExtensionFromJson(json);

  Map<String, dynamic> toJson() => _$PostExtensionToJson(this);
}

@JsonSerializable()
class PostMeta {
  final int like;
  final int eye;
  final int dislike;

  PostMeta({required this.like, required this.eye, required this.dislike});

  factory PostMeta.fromJson(Map<String, dynamic> json) =>
      _$PostMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PostMetaToJson(this);
}

@JsonSerializable()
class PostTag {
  final String tag;

  PostTag({required this.tag});

  factory PostTag.fromJson(Map<String, dynamic> json) =>
      _$PostTagFromJson(json);

  Map<String, dynamic> toJson() => _$PostTagToJson(this);
}

@JsonSerializable()
class PostAuth {
  final String nickname;
  final String avatar;
  @JsonKey(name: 'is_online')
  final bool isOnline;
  @JsonKey(name: 'user_key')
  final String userKey;
  @JsonKey(name: 'user_id')
  final int userId;

  PostAuth({
    required this.nickname,
    required this.avatar,
    required this.isOnline,
    required this.userKey,
    required this.userId,
  });

  factory PostAuth.fromJson(Map<String, dynamic> json) =>
      _$PostAuthFromJson(json);

  Map<String, dynamic> toJson() => _$PostAuthToJson(this);
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
