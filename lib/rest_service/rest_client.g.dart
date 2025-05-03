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
};

JobDetailApply _$JobDetailApplyFromJson(Map<String, dynamic> json) =>
    JobDetailApply(
      isBuyed: json['is_buyed'] as bool?,
      applyStatus: (json['apply_status'] as num?)?.toInt(),
      createTime: (json['create_time'] as num?)?.toInt(),
      expTime: (json['exp_time'] as num?)?.toInt(),
      applyType: json['apply_type'] as String?,
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
    JobCollectData(status: (json['status'] as num?)?.toInt());

Map<String, dynamic> _$JobCollectDataToJson(JobCollectData instance) =>
    <String, dynamic>{'status': instance.status};

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

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl, this.errorLogger});

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
    final _data = {'job_key': jobKey};
    final _options = _setStreamType<BaseResponse<JobCollectData>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/job/collect',
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
