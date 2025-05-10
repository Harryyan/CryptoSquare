// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleListResponse _$ArticleListResponseFromJson(Map<String, dynamic> json) =>
    ArticleListResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          json['data'] == null
              ? null
              : ArticleListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArticleListResponseToJson(
  ArticleListResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

ArticleListData _$ArticleListDataFromJson(Map<String, dynamic> json) =>
    ArticleListData(
      total: (json['total'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ArticleItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      currentPage: json['current_page'] as String?,
      catName: json['cat_name'] as String?,
      catInfo:
          json['cat_info'] == null
              ? null
              : ArticleCategoryInfo.fromJson(
                json['cat_info'] as Map<String, dynamic>,
              ),
      loginUid: (json['login_uid'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ArticleListDataToJson(ArticleListData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'data': instance.data,
      'current_page': instance.currentPage,
      'cat_name': instance.catName,
      'cat_info': instance.catInfo,
      'login_uid': instance.loginUid,
    };

ArticleItemExtension _$ArticleItemExtensionFromJson(
  Map<String, dynamic> json,
) => ArticleItemExtension(
  meta:
      json['meta'] == null
          ? null
          : ArticleExtensionMeta.fromJson(json['meta'] as Map<String, dynamic>),
  tag: json['tag'] as List<dynamic>?,
  auth:
      json['auth'] == null
          ? null
          : ArticleAuthInfo.fromJson(json['auth'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ArticleItemExtensionToJson(
  ArticleItemExtension instance,
) => <String, dynamic>{
  'meta': instance.meta,
  'tag': instance.tag,
  'auth': instance.auth,
};

ArticleItem _$ArticleItemFromJson(Map<String, dynamic> json) => ArticleItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  content: json['content'] as String?,
  user: (json['user'] as num?)?.toInt(),
  status: (json['status'] as num?)?.toInt(),
  type: json['type'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  lang: (json['lang'] as num?)?.toInt(),
  lastView: (json['last_view'] as num?)?.toInt(),
  lastViewUser: (json['last_view_user'] as num?)?.toInt(),
  replyNums: (json['reply_nums'] as num?)?.toInt(),
  replyUser: json['reply_user'] as String?,
  replyTime: (json['reply_time'] as num?)?.toInt(),
  catId: (json['cat_id'] as num?)?.toInt(),
  origin: json['origin'] as String?,
  originLink: json['origin_link'] as String?,
  createTime: (json['create_time'] as num?)?.toInt(),
  profile: json['profile'] as String?,
  hasTag: (json['has_tag'] as num?)?.toInt(),
  sh5: (json['sh5'] as num?)?.toInt(),
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  address: json['address'] as String?,
  extension:
      json['extension'] == null
          ? null
          : ArticleItemExtension.fromJson(
            json['extension'] as Map<String, dynamic>,
          ),
  link: json['link'] as String?,
  cover: json['cover'] as String?,
);

Map<String, dynamic> _$ArticleItemToJson(ArticleItem instance) =>
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
      'extension': instance.extension,
      'link': instance.link,
      'cover': instance.cover,
    };
