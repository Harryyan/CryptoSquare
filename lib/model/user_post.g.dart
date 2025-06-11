// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPostResp _$UserPostRespFromJson(Map<String, dynamic> json) => UserPostResp(
  message: json['message'] as String,
  code: (json['code'] as num).toInt(),
  data: UserPostData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserPostRespToJson(UserPostResp instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

UserPostData _$UserPostDataFromJson(Map<String, dynamic> json) => UserPostData(
  total: (json['total'] as num).toInt(),
  data:
      (json['data'] as List<dynamic>)
          .map((e) => UserPostItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  currentPage: json['current_page'] as String,
);

Map<String, dynamic> _$UserPostDataToJson(UserPostData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'data': instance.data,
      'current_page': instance.currentPage,
    };

UserPostItem _$UserPostItemFromJson(Map<String, dynamic> json) => UserPostItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  user: (json['user'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  type: json['type'] as String,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  lang: (json['lang'] as num).toInt(),
  lastView: (json['last_view'] as num).toInt(),
  lastViewUser: (json['last_view_user'] as num).toInt(),
  replyNums: (json['reply_nums'] as num).toInt(),
  replyUser: json['reply_user'] as String,
  replyTime: (json['reply_time'] as num).toInt(),
  catId: (json['cat_id'] as num).toInt(),
  origin: json['origin'] as String,
  originLink: json['origin_link'] as String,
  createTime: (json['create_time'] as num).toInt(),
  profile: json['profile'] as String,
  hasTag: (json['has_tag'] as num).toInt(),
  sh5: (json['sh5'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  address: json['address'] as String,
  link: json['link'] as String,
  cover: json['cover'] as String,
  extension: UserPostExtension.fromJson(
    json['extension'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserPostItemToJson(UserPostItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'user': instance.user,
      'status': instance.status,
      'type': instance.type,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'lang': instance.lang,
      'last_view': instance.lastView,
      'last_view_user': instance.lastViewUser,
      'reply_nums': instance.replyNums,
      'reply_user': instance.replyUser,
      'reply_time': instance.replyTime,
      'cat_id': instance.catId,
      'origin': instance.origin,
      'origin_link': instance.originLink,
      'create_time': instance.createTime,
      'profile': instance.profile,
      'has_tag': instance.hasTag,
      'sh5': instance.sh5,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'address': instance.address,
      'link': instance.link,
      'cover': instance.cover,
      'extension': instance.extension,
    };

UserPostExtension _$UserPostExtensionFromJson(Map<String, dynamic> json) =>
    UserPostExtension(
      meta: UserPostMeta.fromJson(json['meta'] as Map<String, dynamic>),
      tag:
          (json['tag'] as List<dynamic>)
              .map((e) => UserPostTag.fromJson(e as Map<String, dynamic>))
              .toList(),
      auth: UserPostAuth.fromJson(json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPostExtensionToJson(UserPostExtension instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'tag': instance.tag,
      'auth': instance.auth,
    };

UserPostMeta _$UserPostMetaFromJson(Map<String, dynamic> json) => UserPostMeta(
  like: (json['like'] as num).toInt(),
  eye: (json['eye'] as num).toInt(),
  dislike: (json['dislike'] as num).toInt(),
);

Map<String, dynamic> _$UserPostMetaToJson(UserPostMeta instance) =>
    <String, dynamic>{
      'like': instance.like,
      'eye': instance.eye,
      'dislike': instance.dislike,
    };

UserPostTag _$UserPostTagFromJson(Map<String, dynamic> json) =>
    UserPostTag(tag: json['tag'] as String);

Map<String, dynamic> _$UserPostTagToJson(UserPostTag instance) =>
    <String, dynamic>{'tag': instance.tag};

UserPostAuth _$UserPostAuthFromJson(Map<String, dynamic> json) => UserPostAuth(
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String,
  isOnline: json['is_online'] as bool,
  userKey: json['user_key'] as String,
  userId: (json['user_id'] as num).toInt(),
);

Map<String, dynamic> _$UserPostAuthToJson(UserPostAuth instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'is_online': instance.isOnline,
      'user_key': instance.userKey,
      'user_id': instance.userId,
    };

CatInfo _$CatInfoFromJson(Map<String, dynamic> json) => CatInfo(
  title: json['title'] as String,
  catSlug: json['cat_slug'] as String,
);

Map<String, dynamic> _$CatInfoToJson(CatInfo instance) => <String, dynamic>{
  'title': instance.title,
  'cat_slug': instance.catSlug,
};
