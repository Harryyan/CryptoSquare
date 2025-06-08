// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bitpush_client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BitpushNewsItem _$BitpushNewsItemFromJson(Map<String, dynamic> json) =>
    BitpushNewsItem(
      id: (json['id'] as num?)?.toInt(),
      author_id: json['author_id'] as String?,
      author: json['author'] as String?,
      img: json['img'] as String?,
      big_img: json['big_img'] as String?,
      title: json['title'] as String?,
      link: json['link'] as String?,
      category: json['category'] as String?,
      cat_id: json['cat_id'] as String?,
      cat_ids:
          (json['cat_ids'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      time: (json['time'] as num?)?.toInt(),
      comment_num: json['comment_num'] as String?,
      content: json['content'] as String?,
      calendar_date: json['calendar_date'] as String?,
      calendar_scope: json['calendar_scope'] as String?,
    );

Map<String, dynamic> _$BitpushNewsItemToJson(BitpushNewsItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.author_id,
      'author': instance.author,
      'img': instance.img,
      'big_img': instance.big_img,
      'title': instance.title,
      'link': instance.link,
      'category': instance.category,
      'cat_id': instance.cat_id,
      'cat_ids': instance.cat_ids,
      'time': instance.time,
      'comment_num': instance.comment_num,
      'content': instance.content,
      'calendar_date': instance.calendar_date,
      'calendar_scope': instance.calendar_scope,
    };

BitpushNewsResponse _$BitpushNewsResponseFromJson(Map<String, dynamic> json) =>
    BitpushNewsResponse(
      code: (json['code'] as num?)?.toInt(),
      message: json['message'] as String?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      page: (json['page'] as num?)?.toInt(),
      total_page: (json['total_page'] as num?)?.toInt(),
      cursor: (json['cursor'] as num?)?.toInt(),
      has_more: json['has_more'] as bool?,
      item_list:
          (json['item_list'] as List<dynamic>?)
              ?.map((e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      timestamp: json['timestamp'] as String?,
    );

Map<String, dynamic> _$BitpushNewsResponseToJson(
  BitpushNewsResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
  'page': instance.page,
  'total_page': instance.total_page,
  'cursor': instance.cursor,
  'has_more': instance.has_more,
  'item_list': instance.item_list,
  'timestamp': instance.timestamp,
};

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations

class _BitpushNewsClient implements BitpushNewsClient {
  _BitpushNewsClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= 'https://d3qx0f55wsubto.cloudfront.net/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<BitpushNewsResponse> getWebNews(
    int categoryId,
    int timestamp,
    int page,
    int showAll,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'category_id': categoryId,
      r'timestamp': timestamp,
      r'page': page,
      r'show_all': showAll,
    };
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<BitpushNewsResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v3/news/webnews',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BitpushNewsResponse _value;
    try {
      _value = BitpushNewsResponse.fromJson(_result.data!);
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
