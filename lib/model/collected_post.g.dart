// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collected_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectedPostResp _$CollectedPostRespFromJson(Map<String, dynamic> json) =>
    CollectedPostResp(
      message: json['message'] as String,
      code: (json['code'] as num).toInt(),
      data: CollectedPostData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CollectedPostRespToJson(CollectedPostResp instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

CollectedPostData _$CollectedPostDataFromJson(Map<String, dynamic> json) =>
    CollectedPostData(
      total: (json['total'] as num).toInt(),
      data:
          (json['data'] as List<dynamic>)
              .map((e) => PostItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      currentPage: json['current_page'] as String,
      order: json['order'] as String,
    );

Map<String, dynamic> _$CollectedPostDataToJson(CollectedPostData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'data': instance.data,
      'current_page': instance.currentPage,
      'order': instance.order,
    };

PostItem _$PostItemFromJson(Map<String, dynamic> json) => PostItem(
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
  ding: (json['ding'] as num).toInt(),
  cai: (json['cai'] as num).toInt(),
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
  isTop: (json['is_top'] as num).toInt(),
  isHot: (json['is_hot'] as num).toInt(),
  contact: json['contact'] as String,
  address: json['address'] as String,
  extension: PostExtension.fromJson(json['extension'] as Map<String, dynamic>),
  catName: json['cat_name'] as String,
  catInfo: CatInfo.fromJson(json['cat_info'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostItemToJson(PostItem instance) => <String, dynamic>{
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
  'ding': instance.ding,
  'cai': instance.cai,
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
  'is_top': instance.isTop,
  'is_hot': instance.isHot,
  'contact': instance.contact,
  'address': instance.address,
  'extension': instance.extension,
  'cat_name': instance.catName,
  'cat_info': instance.catInfo,
};

PostExtension _$PostExtensionFromJson(Map<String, dynamic> json) =>
    PostExtension(
      meta: PostMeta.fromJson(json['meta'] as Map<String, dynamic>),
      tag:
          (json['tag'] as List<dynamic>)
              .map((e) => PostTag.fromJson(e as Map<String, dynamic>))
              .toList(),
      auth: PostAuth.fromJson(json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostExtensionToJson(PostExtension instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'tag': instance.tag,
      'auth': instance.auth,
    };

PostMeta _$PostMetaFromJson(Map<String, dynamic> json) => PostMeta(
  like: (json['like'] as num).toInt(),
  eye: (json['eye'] as num).toInt(),
  dislike: (json['dislike'] as num).toInt(),
);

Map<String, dynamic> _$PostMetaToJson(PostMeta instance) => <String, dynamic>{
  'like': instance.like,
  'eye': instance.eye,
  'dislike': instance.dislike,
};

PostTag _$PostTagFromJson(Map<String, dynamic> json) =>
    PostTag(tag: json['tag'] as String);

Map<String, dynamic> _$PostTagToJson(PostTag instance) => <String, dynamic>{
  'tag': instance.tag,
};

PostAuth _$PostAuthFromJson(Map<String, dynamic> json) => PostAuth(
  nickname: json['nickname'] as String,
  avatar: json['avatar'] as String,
  isOnline: json['is_online'] as bool,
  userKey: json['user_key'] as String,
  userId: (json['user_id'] as num).toInt(),
);

Map<String, dynamic> _$PostAuthToJson(PostAuth instance) => <String, dynamic>{
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
