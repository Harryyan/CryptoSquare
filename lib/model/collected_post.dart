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
  final String summary;
  final String cover;
  final String createdAt;
  final int comments;
  final String userNickname;
  final String userAvatar;
  final String link;
  final List<String> tags;
  final int catId;
  final int status;
  final String type;
  final int lang;
  @JsonKey(name: 'last_view')
  final int lastView;
  @JsonKey(name: 'last_view_user')
  final int lastViewUser;
  @JsonKey(name: 'reply_time')
  final int replyTime;
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
    required this.summary,
    required this.cover,
    required this.createdAt,
    required this.comments,
    required this.userNickname,
    required this.userAvatar,
    required this.link,
    required this.tags,
    required this.catId,
    required this.status,
    required this.type,
    required this.lang,
    required this.lastView,
    required this.lastViewUser,
    required this.replyTime,
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

  factory PostItem.fromJson(Map<String, dynamic> json) {
    final extension = json['extension'] ?? {};
    final auth = extension['auth'] ?? {};
    final tagList = (extension['tag'] as List?)?.map((e) {
      if (e is String) return e;
      if (e is Map && e['tag'] != null) return e['tag'].toString();
      return '';
    }).where((e) => e.isNotEmpty).toList() ?? [];

    String content = json['content'] as String? ?? '';
    String summary = content.replaceAll(RegExp(r'<[^>]*>'), '');
    if (summary.length > 100) summary = summary.substring(0, 100) + '...';

    return PostItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: content,
      summary: summary,
      cover: json['cover'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      comments: json['reply_nums'] as int? ?? 0,
      userNickname: auth['nickname'] as String? ?? '',
      userAvatar: auth['avatar'] as String? ?? '',
      link: json['link'] as String? ?? '',
      tags: tagList,
      catId: json['cat_id'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      lang: json['lang'] as int? ?? 0,
      lastView: json['last_view'] as int? ?? 0,
      lastViewUser: json['last_view_user'] as int? ?? 0,
      replyTime: json['reply_time'] as int? ?? 0,
      origin: json['origin'] as String? ?? '',
      originLink: json['origin_link'] as String? ?? '',
      createTime: json['create_time'] as int? ?? 0,
      profile: json['profile'] as String? ?? '',
      hasTag: json['has_tag'] as int? ?? 0,
      sh5: json['sh5'] as int? ?? 0,
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      isTop: json['is_top'] as int? ?? 0,
      isHot: json['is_hot'] as int? ?? 0,
      contact: json['contact'] as String? ?? '',
      address: json['address'] as String? ?? '',
      extension: PostExtension.fromJson(extension is Map<String, dynamic> ? extension : {}),
      catName: json['cat_name'] as String? ?? '',
      catInfo: json['cat_info'] != null ? CatInfo.fromJson(json['cat_info'] as Map<String, dynamic>) : CatInfo(title: '', catSlug: ''),
    );
  }

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
