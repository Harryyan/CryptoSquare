// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse<T> _$BaseResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseResponse<T>(
  message: json['message'] as String?,
  code: (json['code'] as num?)?.toInt(),
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$BaseResponseToJson<T>(
  BaseResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

FeaturedJobResponse _$FeaturedJobResponseFromJson(Map<String, dynamic> json) =>
    FeaturedJobResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => JobData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$FeaturedJobResponseToJson(
  FeaturedJobResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

JobListResponse _$JobListResponseFromJson(Map<String, dynamic> json) =>
    JobListResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          json['data'] == null
              ? null
              : JobListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobListResponseToJson(JobListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

JobListData _$JobListDataFromJson(Map<String, dynamic> json) => JobListData(
  list:
      (json['list'] as List<dynamic>?)
          ?.map((e) => JobData.fromJson(e as Map<String, dynamic>))
          .toList(),
  page: (json['page'] as num?)?.toInt(),
  pageSize: (json['page_size'] as num?)?.toInt(),
  totalPage: (json['total_page'] as num?)?.toInt(),
);

Map<String, dynamic> _$JobListDataToJson(JobListData instance) =>
    <String, dynamic>{
      'list': instance.list,
      'page': instance.page,
      'page_size': instance.pageSize,
      'total_page': instance.totalPage,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String?,
  name: json['name'] as String?,
  avatar: json['avatar'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
  'createdAt': instance.createdAt,
};

PostCreateResp _$PostCreateRespFromJson(Map<String, dynamic> json) =>
    PostCreateResp(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data: json['data'],
    );

Map<String, dynamic> _$PostCreateRespToJson(PostCreateResp instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

ScoreConfigResponse _$ScoreConfigResponseFromJson(Map<String, dynamic> json) =>
    ScoreConfigResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data: (json['data'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ScoreConfigItem.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ScoreConfigResponseToJson(
  ScoreConfigResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

ScoreConfigItem _$ScoreConfigItemFromJson(Map<String, dynamic> json) =>
    ScoreConfigItem(
      title: json['title'] as String?,
      titleEn: json['title_en'] as String?,
      score: (json['score'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScoreConfigItemToJson(ScoreConfigItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'title_en': instance.titleEn,
      'score': instance.score,
      'id': instance.id,
    };

JobData _$JobDataFromJson(Map<String, dynamic> json) => JobData(
  slug: json['slug'] as String?,
  id: (json['id'] as num?)?.toInt(),
  jobKey: json['job_key'] as String?,
  jobTitle: json['job_title'] as String?,
  jobPosition: json['job_position'] as String?,
  createdAt: json['created_at'] as String?,
  tags: json['tags'] as String?,
  jobCompany: json['job_company'] as String?,
  jobSalaryType: (json['job_salary_type'] as num?)?.toInt(),
  jobSalaryUnit: json['job_salary_unit'] as String?,
  jobSalaryCurrency: json['job_salary_currency'] as String?,
  minSalary: (json['min_salary'] as num?)?.toInt(),
  maxSalary: (json['max_salary'] as num?)?.toInt(),
  jobIsCollect: (json['job_is_collect'] as num?)?.toInt() ?? 0,
  jobType: json['job_type'] as String?,
  officeMode: (json['office_mode'] as num?)?.toInt(),
  jobLang: (json['job_lang'] as num?)?.toInt(),
);

Map<String, dynamic> _$JobDataToJson(JobData instance) => <String, dynamic>{
  'slug': instance.slug,
  'id': instance.id,
  'job_key': instance.jobKey,
  'job_title': instance.jobTitle,
  'job_position': instance.jobPosition,
  'created_at': instance.createdAt,
  'tags': instance.tags,
  'job_company': instance.jobCompany,
  'job_salary_type': instance.jobSalaryType,
  'job_salary_unit': instance.jobSalaryUnit,
  'job_salary_currency': instance.jobSalaryCurrency,
  'min_salary': instance.minSalary,
  'max_salary': instance.maxSalary,
  'job_is_collect': instance.jobIsCollect,
  'job_type': instance.jobType,
  'office_mode': instance.officeMode,
  'job_lang': instance.jobLang,
};

JobDetailApply _$JobDetailApplyFromJson(Map<String, dynamic> json) =>
    JobDetailApply(
      isBuyed: json['is_buyed'] as bool?,
      applyStatus: (json['apply_status'] as num?)?.toInt(),
      createTime: (json['create_time'] as num?)?.toInt(),
      expTime: (json['exp_time'] as num?)?.toInt(),
      applyType: json['apply_type'],
      applyVal: json['apply_val'] as String?,
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JobDetailApplyToJson(JobDetailApply instance) =>
    <String, dynamic>{
      'is_buyed': instance.isBuyed,
      'apply_status': instance.applyStatus,
      'create_time': instance.createTime,
      'exp_time': instance.expTime,
      'apply_type': instance.applyType,
      'apply_val': instance.applyVal,
      'score': instance.score,
    };

JobDetailData _$JobDetailDataFromJson(Map<String, dynamic> json) =>
    JobDetailData(
      id: (json['id'] as num?)?.toInt(),
      jobTitle: json['job_title'] as String?,
      jobPosition: json['job_positon'] as String?,
      jobType: json['job_type'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      createTime: (json['create_time'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      lang: (json['lang'] as num?)?.toInt(),
      jobStatus: (json['job_status'] as num?)?.toInt(),
      officeMode: (json['office_mode'] as num?)?.toInt(),
      jobDesc: json['job_desc'] as String?,
      jobWelfare: json['job_welfare'] as String?,
      jobEdu: (json['job_edu'] as num?)?.toInt(),
      minSalary: (json['min_salary'] as num?)?.toInt(),
      maxSalary: (json['max_salary'] as num?)?.toInt(),
      jobLang: (json['job_lang'] as num?)?.toInt(),
      tags: json['tags'] as String?,
      isHot: (json['is_hot'] as num?)?.toInt(),
      jobSalaryCurrency: json['job_salary_currency'] as String?,
      jobSalaryUnit: json['job_salary_unit'] as String?,
      jobSalaryType: (json['job_salary_type'] as num?)?.toInt(),
      jobCompany: json['job_company'] as String?,
      jobKey: json['job_key'] as String?,
      isTop: (json['is_top'] as num?)?.toInt(),
      jobLocation: json['job_location'] as String?,
      lastView: (json['last_view'] as num?)?.toInt(),
      lastViewUser: (json['last_view_user'] as num?)?.toInt(),
      replyNums: (json['reply_nums'] as num?)?.toInt(),
      replyUser: json['reply_user'] as String?,
      ding: (json['ding'] as num?)?.toInt(),
      cai: (json['cai'] as num?)?.toInt(),
      replyTime: (json['reply_time'] as num?)?.toInt(),
      apply:
          json['apply'] == null
              ? null
              : JobDetailApply.fromJson(json['apply'] as Map<String, dynamic>),
      jobIsCollect: (json['job_is_collect'] as num?)?.toInt(),
      jobIsLike: (json['job_is_like'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JobDetailDataToJson(JobDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'job_title': instance.jobTitle,
      'job_positon': instance.jobPosition,
      'job_type': instance.jobType,
      'user_id': instance.userId,
      'create_time': instance.createTime,
      'status': instance.status,
      'lang': instance.lang,
      'job_status': instance.jobStatus,
      'office_mode': instance.officeMode,
      'job_desc': instance.jobDesc,
      'job_welfare': instance.jobWelfare,
      'job_edu': instance.jobEdu,
      'min_salary': instance.minSalary,
      'max_salary': instance.maxSalary,
      'job_lang': instance.jobLang,
      'tags': instance.tags,
      'is_hot': instance.isHot,
      'job_salary_currency': instance.jobSalaryCurrency,
      'job_salary_unit': instance.jobSalaryUnit,
      'job_salary_type': instance.jobSalaryType,
      'job_company': instance.jobCompany,
      'job_key': instance.jobKey,
      'is_top': instance.isTop,
      'job_location': instance.jobLocation,
      'last_view': instance.lastView,
      'last_view_user': instance.lastViewUser,
      'reply_nums': instance.replyNums,
      'reply_user': instance.replyUser,
      'ding': instance.ding,
      'cai': instance.cai,
      'reply_time': instance.replyTime,
      'apply': instance.apply,
      'job_is_collect': instance.jobIsCollect,
      'job_is_like': instance.jobIsLike,
    };

BannerItem _$BannerItemFromJson(Map<String, dynamic> json) => BannerItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  img: json['img'] as String?,
  link: json['link'] as String?,
  orderid: (json['orderid'] as num?)?.toInt(),
);

Map<String, dynamic> _$BannerItemToJson(BannerItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'img': instance.img,
      'link': instance.link,
      'orderid': instance.orderid,
    };

BannerData _$BannerDataFromJson(Map<String, dynamic> json) => BannerData(
  h5:
      (json['h5'] as List<dynamic>?)
          ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  pc:
      (json['pc'] as List<dynamic>?)
          ?.map((e) => BannerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BannerDataToJson(BannerData instance) =>
    <String, dynamic>{'h5': instance.h5, 'pc': instance.pc};

BannerResponse _$BannerResponseFromJson(Map<String, dynamic> json) =>
    BannerResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          json['data'] == null
              ? null
              : BannerData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BannerResponseToJson(BannerResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

TopBannerPop _$TopBannerPopFromJson(Map<String, dynamic> json) => TopBannerPop(
  title: json['title'] as String?,
  intro: json['intro'],
  img: json['img'] as String?,
  tips: json['tips'],
);

Map<String, dynamic> _$TopBannerPopToJson(TopBannerPop instance) =>
    <String, dynamic>{
      'title': instance.title,
      'intro': instance.intro,
      'img': instance.img,
      'tips': instance.tips,
    };

JobCollectData _$JobCollectDataFromJson(Map<String, dynamic> json) =>
    JobCollectData(
      id: (json['id'] as num?)?.toInt(),
      rsType: json['rs_type'] as String?,
      rsId: json['rs_id'] as String?,
      value: (json['value'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$JobCollectDataToJson(JobCollectData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rs_type': instance.rsType,
      'rs_id': instance.rsId,
      'value': instance.value,
      'user_id': instance.userId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

HomeServiceItem _$HomeServiceItemFromJson(Map<String, dynamic> json) =>
    HomeServiceItem(
      id: (json['id'] as num?)?.toInt(),
      icon: json['icon'] as String?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      redirectMsg: json['redirect_msg'] as String?,
      redirectColor: json['redirect_color'] as String?,
      redirectType: json['redirect_type'] as String?,
      redirectLink: json['redirect_link'] as String?,
      pop:
          json['pop'] == null
              ? null
              : TopBannerPop.fromJson(json['pop'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeServiceItemToJson(HomeServiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'title': instance.title,
      'intro': instance.intro,
      'redirect_msg': instance.redirectMsg,
      'redirect_color': instance.redirectColor,
      'redirect_type': instance.redirectType,
      'redirect_link': instance.redirectLink,
      'pop': instance.pop,
    };

ArticleComment _$ArticleCommentFromJson(Map<String, dynamic> json) =>
    ArticleComment(
      id: (json['id'] as num?)?.toInt(),
      content: json['content'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      commentTo: (json['comment_to'] as num?)?.toInt(),
      toType: json['to_type'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      parentComment: (json['parent_comment'] as num?)?.toInt(),
      commentTouid: (json['comment_touid'] as num?)?.toInt(),
      groupid: (json['groupid'] as num?)?.toInt(),
      isDel: (json['is_del'] as num?)?.toInt(),
      updatetime: (json['updatetime'] as num?)?.toInt(),
      user:
          json['user'] == null
              ? null
              : ArticleCommentUser.fromJson(
                json['user'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ArticleCommentToJson(ArticleComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'user_id': instance.userId,
      'comment_to': instance.commentTo,
      'to_type': instance.toType,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'parent_comment': instance.parentComment,
      'comment_touid': instance.commentTouid,
      'groupid': instance.groupid,
      'is_del': instance.isDel,
      'updatetime': instance.updatetime,
      'user': instance.user,
    };

ArticleCommentUser _$ArticleCommentUserFromJson(Map<String, dynamic> json) =>
    ArticleCommentUser(
      id: (json['ID'] as num?)?.toInt(),
      userNicename: json['user_nicename'] as String?,
      userUrl: json['user_url'] as String?,
    );

Map<String, dynamic> _$ArticleCommentUserToJson(ArticleCommentUser instance) =>
    <String, dynamic>{
      'ID': instance.id,
      'user_nicename': instance.userNicename,
      'user_url': instance.userUrl,
    };

ArticleRelatedNews _$ArticleRelatedNewsFromJson(Map<String, dynamic> json) =>
    ArticleRelatedNews(
      id: (json['id'] as num?)?.toInt(),
      link: json['link'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$ArticleRelatedNewsToJson(ArticleRelatedNews instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
      'title': instance.title,
    };

ArticleCategoryInfo _$ArticleCategoryInfoFromJson(Map<String, dynamic> json) =>
    ArticleCategoryInfo(
      title: json['title'] as String?,
      catSlug: json['cat_slug'] as String?,
    );

Map<String, dynamic> _$ArticleCategoryInfoToJson(
  ArticleCategoryInfo instance,
) => <String, dynamic>{'title': instance.title, 'cat_slug': instance.catSlug};

ArticleExtensionMeta _$ArticleExtensionMetaFromJson(
  Map<String, dynamic> json,
) => ArticleExtensionMeta(
  like: (json['like'] as num?)?.toInt(),
  eye: (json['eye'] as num?)?.toInt(),
  dislike: (json['dislike'] as num?)?.toInt(),
);

Map<String, dynamic> _$ArticleExtensionMetaToJson(
  ArticleExtensionMeta instance,
) => <String, dynamic>{
  'like': instance.like,
  'eye': instance.eye,
  'dislike': instance.dislike,
};

ArticleAuthInfo _$ArticleAuthInfoFromJson(Map<String, dynamic> json) =>
    ArticleAuthInfo(
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      isOnline: json['is_online'] as bool?,
      userKey: json['user_key'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ArticleAuthInfoToJson(ArticleAuthInfo instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'is_online': instance.isOnline,
      'user_key': instance.userKey,
      'user_id': instance.userId,
    };

ArticleExtension _$ArticleExtensionFromJson(Map<String, dynamic> json) =>
    ArticleExtension(
      tag: json['tag'] as List<dynamic>?,
      auth:
          json['auth'] == null
              ? null
              : ArticleAuthInfo.fromJson(json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArticleExtensionToJson(ArticleExtension instance) =>
    <String, dynamic>{'tag': instance.tag, 'auth': instance.auth};

ArticleUserExt _$ArticleUserExtFromJson(Map<String, dynamic> json) =>
    ArticleUserExt(
      isFavorite: (json['is_favorite'] as num?)?.toInt(),
      isDing: (json['is_ding'] as num?)?.toInt(),
      isCai: (json['is_cai'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ArticleUserExtToJson(ArticleUserExt instance) =>
    <String, dynamic>{
      'is_favorite': instance.isFavorite,
      'is_ding': instance.isDing,
      'is_cai': instance.isCai,
    };

ArticleDetailData _$ArticleDetailDataFromJson(
  Map<String, dynamic> json,
) => ArticleDetailData(
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
  ding: (json['ding'] as num?)?.toInt(),
  cai: (json['cai'] as num?)?.toInt(),
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
  isTop: (json['is_top'] as num?)?.toInt(),
  isHot: (json['is_hot'] as num?)?.toInt(),
  contact: json['contact'] as String?,
  address: json['address'] as String?,
  trackId: json['track_id'] as String?,
  extension:
      json['extension'] == null
          ? null
          : ArticleExtension.fromJson(
            json['extension'] as Map<String, dynamic>,
          ),
  userext:
      json['userext'] == null
          ? null
          : ArticleUserExt.fromJson(json['userext'] as Map<String, dynamic>),
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => ArticleComment.fromJson(e as Map<String, dynamic>))
          .toList(),
  catInfo:
      json['cat_info'] == null
          ? null
          : ArticleCategoryInfo.fromJson(
            json['cat_info'] as Map<String, dynamic>,
          ),
  link: json['link'] as String?,
  relNews:
      (json['rel_news'] as List<dynamic>?)
          ?.map((e) => ArticleRelatedNews.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ArticleDetailDataToJson(ArticleDetailData instance) =>
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
      'track_id': instance.trackId,
      'extension': instance.extension,
      'userext': instance.userext,
      'comments': instance.comments,
      'cat_info': instance.catInfo,
      'link': instance.link,
      'rel_news': instance.relNews,
    };

ArticleCommentResponse _$ArticleCommentResponseFromJson(
  Map<String, dynamic> json,
) => ArticleCommentResponse(
  message: json['message'] as String?,
  code: (json['code'] as num?)?.toInt(),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ArticleCommentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ArticleCommentResponseToJson(
  ArticleCommentResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

ArticleCommentItem _$ArticleCommentItemFromJson(
  Map<String, dynamic> json,
) => ArticleCommentItem(
  id: (json['id'] as num?)?.toInt(),
  content: json['content'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  commentTo: (json['comment_to'] as num?)?.toInt(),
  toType: json['to_type'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  parentComment: (json['parent_comment'] as num?)?.toInt(),
  commentTouid: (json['comment_touid'] as num?)?.toInt(),
  groupid: (json['groupid'] as num?)?.toInt(),
  isDel: (json['is_del'] as num?)?.toInt(),
  updatetime: (json['updatetime'] as num?)?.toInt(),
  reply:
      (json['reply'] as List<dynamic>?)
          ?.map((e) => ArticleCommentReply.fromJson(e as Map<String, dynamic>))
          .toList(),
  currentUserCanDel: (json['current_user_can_del'] as num?)?.toInt(),
  user:
      json['user'] == null
          ? null
          : ArticleCommentUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ArticleCommentItemToJson(ArticleCommentItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'user_id': instance.userId,
      'comment_to': instance.commentTo,
      'to_type': instance.toType,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'parent_comment': instance.parentComment,
      'comment_touid': instance.commentTouid,
      'groupid': instance.groupid,
      'is_del': instance.isDel,
      'updatetime': instance.updatetime,
      'reply': instance.reply,
      'current_user_can_del': instance.currentUserCanDel,
      'user': instance.user,
    };

ArticleCommentReply _$ArticleCommentReplyFromJson(Map<String, dynamic> json) =>
    ArticleCommentReply(
      id: (json['id'] as num?)?.toInt(),
      content: json['content'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      commentTo: (json['comment_to'] as num?)?.toInt(),
      toType: json['to_type'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      parentComment: (json['parent_comment'] as num?)?.toInt(),
      commentTouid: (json['comment_touid'] as num?)?.toInt(),
      groupid: (json['groupid'] as num?)?.toInt(),
      isDel: (json['is_del'] as num?)?.toInt(),
      updatetime: (json['updatetime'] as num?)?.toInt(),
      user:
          json['user'] == null
              ? null
              : ArticleCommentUser.fromJson(
                json['user'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$ArticleCommentReplyToJson(
  ArticleCommentReply instance,
) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'user_id': instance.userId,
  'comment_to': instance.commentTo,
  'to_type': instance.toType,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'parent_comment': instance.parentComment,
  'comment_touid': instance.commentTouid,
  'groupid': instance.groupid,
  'is_del': instance.isDel,
  'updatetime': instance.updatetime,
  'user': instance.user,
};

CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) => CategoryItem(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$CategoryItemToJson(CategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_en': instance.nameEn,
    };

StudentViewResponse _$StudentViewResponseFromJson(Map<String, dynamic> json) =>
    StudentViewResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => StudentViewItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$StudentViewResponseToJson(
  StudentViewResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'code': instance.code,
  'data': instance.data,
};

StudentViewItem _$StudentViewItemFromJson(Map<String, dynamic> json) =>
    StudentViewItem(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      link: json['link'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$StudentViewItemToJson(StudentViewItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'intro': instance.intro,
      'link': instance.link,
      'img': instance.img,
    };

CourseListResponse _$CourseListResponseFromJson(Map<String, dynamic> json) =>
    CourseListResponse(
      message: json['message'] as String?,
      code: (json['code'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => CourseItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$CourseListResponseToJson(CourseListResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': instance.code,
      'data': instance.data,
    };

CourseItem _$CourseItemFromJson(Map<String, dynamic> json) => CourseItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  intro: json['intro'] as String?,
  link: json['link'] as String?,
  img: json['img'] as String?,
  price: (json['price'] as num?)?.toInt(),
);

Map<String, dynamic> _$CourseItemToJson(CourseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'intro': instance.intro,
      'link': instance.link,
      'img': instance.img,
      'price': instance.price,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://d3qx0f55wsubto.cloudfront.net/api';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<BaseResponse<List<Task>>> getTasks() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseResponse<List<Task>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/tasks',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<List<Task>> _value;
    try {
      _value = BaseResponse<List<Task>>.fromJson(
        _result.data!,
        (json) =>
            json is List<dynamic>
                ? json
                    .map<Task>((i) => Task.fromJson(i as Map<String, dynamic>))
                    .toList()
                : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<FeaturedJobResponse> getFeaturedJobs(
    String platform,
    String pageSize,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'PLATFORM': platform,
      r'page_size': pageSize,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FeaturedJobResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/job/index/jobhot',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FeaturedJobResponse _value;
    try {
      _value = FeaturedJobResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BannerResponse> getBanners(int lang, String platform) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'lang': lang,
      r'PLATFORM': platform,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BannerResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/job/index/banner_new',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BannerResponse _value;
    try {
      _value = BannerResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse<List<HomeServiceItem>>> getHomeServices() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseResponse<List<HomeServiceItem>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v3/index/topbanner',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<List<HomeServiceItem>> _value;
    try {
      _value = BaseResponse<List<HomeServiceItem>>.fromJson(
        _result.data!,
        (json) =>
            json is List<dynamic>
                ? json
                    .map<HomeServiceItem>(
                      (i) =>
                          HomeServiceItem.fromJson(i as Map<String, dynamic>),
                    )
                    .toList()
                : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse<JobDetailData>> getJobDetail(
    String jobKey,
    int lang,
    String platformStr,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'lang': lang,
      r'PLATFORM': platformStr,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseResponse<JobDetailData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/job/detail/${jobKey}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<JobDetailData> _value;
    try {
      _value = BaseResponse<JobDetailData>.fromJson(
        _result.data!,
        (json) => JobDetailData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse<JobCollectData>> collectJob(String jobKey) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'jobkey': jobKey};
    final _options = _setStreamType<BaseResponse<JobCollectData>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v3/job/collect',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<JobCollectData> _value;
    try {
      _value = BaseResponse<JobCollectData>.fromJson(
        _result.data!,
        (json) => JobCollectData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse<ArticleDetailData>> getArticleDetail(
    String id,
    int lang,
    String platform,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'lang': lang,
      r'PLATFORM': platform,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BaseResponse<ArticleDetailData>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article/detail/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<ArticleDetailData> _value;
    try {
      _value = BaseResponse<ArticleDetailData>.fromJson(
        _result.data!,
        (json) => ArticleDetailData.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ArticleCommentResponse> getArticleComments(
    String articleId,
    int lang,
    String platform,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'lang': lang,
      r'PLATFORM': platform,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ArticleCommentResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article/comment/${articleId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ArticleCommentResponse _value;
    try {
      _value = ArticleCommentResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ArticleListResponse> getArticleList(
    int catId,
    int pageSize,
    int page,
    int lang,
    String platform,
    String? keyword,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'cat_id': catId,
      r'page_size': pageSize,
      r'page': page,
      r'lang': lang,
      r'PLATFORM': platform,
      r'keyword': keyword,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ArticleListResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ArticleListResponse _value;
    try {
      _value = ArticleListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<JobListResponse> getJobList(
    String platform, {
    int pageSize = 30,
    int page = 1,
    String keyword = '',
    int lang = 1,
    String jobType = '',
    int officeMode = -1,
    int jobLang = -1,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'PLATFORM': platform,
      r'page_size': pageSize,
      r'page': page,
      r'keyword': keyword,
      r'lang': lang,
      r'job_type': jobType,
      r'office_mode': officeMode,
      r'job_lang': jobLang,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<JobListResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/job/index/job_list',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late JobListResponse _value;
    try {
      _value = JobListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ScoreConfigResponse> getScoreConfig() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ScoreConfigResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v3/job/scoreconfig',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ScoreConfigResponse _value;
    try {
      _value = ScoreConfigResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ArticleCommentPostResponse> postArticleComment(
    String articleId,
    String platform,
    String comment,
    int? commentId,
    int lang,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'PLATFORM': platform,
      'comment': comment,
      'comment_id': commentId,
      'lang': lang,
    };
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<ArticleCommentPostResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article/comment/${articleId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ArticleCommentPostResponse _value;
    try {
      _value = ArticleCommentPostResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostCreateResp> createPost(
    String title,
    String tag,
    int catId,
    int lang,
    String origin,
    String originLink,
    String body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'title': title,
      'tag': tag,
      'cat_id': catId,
      'lang': lang,
      'origin': origin,
      'origin_link': originLink,
      'body': body,
    };
    final _options = _setStreamType<PostCreateResp>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PostCreateResp _value;
    try {
      _value = PostCreateResp.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PostCreateResp> updatePost(
    String id,
    String title,
    String tag,
    int catId,
    int lang,
    String origin,
    String originLink,
    String body,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {
      'title': title,
      'tag': tag,
      'cat_id': catId,
      'lang': lang,
      'origin': origin,
      'origin_link': originLink,
      'body': body,
    };
    final _options = _setStreamType<PostCreateResp>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs-article/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PostCreateResp _value;
    try {
      _value = PostCreateResp.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<BaseResponse<dynamic>> applyJobCharge(String jobkey) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'jobkey': jobkey};
    final _options = _setStreamType<BaseResponse<dynamic>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/job/charge/apply',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BaseResponse<dynamic> _value;
    try {
      _value = BaseResponse<dynamic>.fromJson(
        _result.data!,
        (json) => json as dynamic,
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CSBBSCategoryResp> category(int lang) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'lang': lang};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CSBBSCategoryResp>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/bbs/category',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CSBBSCategoryResp _value;
    try {
      _value = CSBBSCategoryResp.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<StudentViewResponse> getStudentViewList() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<StudentViewResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v3/job/student_view',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late StudentViewResponse _value;
    try {
      _value = StudentViewResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CourseListResponse> getCourseList() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<CourseListResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v3/job/course_list',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CourseListResponse _value;
    try {
      _value = CourseListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
