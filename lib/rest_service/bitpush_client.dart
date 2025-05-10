import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
part 'bitpush_client.g.dart';

@JsonSerializable()
class BitpushNewsItem {
  const BitpushNewsItem({
    this.id,
    this.author_id,
    this.author,
    // required this.source,
    this.img,
    this.big_img,
    this.title,
    this.link,
    this.category,
    this.cat_id,
    this.cat_ids,
    this.time,
    this.comment_num,
    this.content,
    this.calendar_date,
    this.calendar_scope,
    // required this.tags,
  });

  factory BitpushNewsItem.fromJson(Map<String, dynamic> json) =>
      _$BitpushNewsItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'author_id')
  final String? author_id;

  @JsonKey(name: 'author')
  final String? author;

  // @JsonKey(name: 'source')
  // final bool source;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'big_img')
  final String? big_img;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'category')
  final String? category;

  @JsonKey(name: 'cat_id')
  final String? cat_id;

  @JsonKey(name: 'cat_ids')
  final List<int>? cat_ids;

  @JsonKey(name: 'time')
  final int? time;

  @JsonKey(name: 'comment_num')
  final String? comment_num;

  @JsonKey(name: 'content')
  final String? content;

  @JsonKey(name: 'calendar_date')
  final String? calendar_date;

  @JsonKey(name: 'calendar_scope')
  final String? calendar_scope;

  // @JsonKey(name: 'tags')
  // final dynamic tags;

  Map<String, dynamic> toJson() => _$BitpushNewsItemToJson(this);
}

@JsonSerializable()
class BitpushNewsResponse {
  const BitpushNewsResponse({
    this.code,
    this.message,
    this.data,
    this.page,
    this.total_page,
    this.cursor,
    this.has_more,
    this.item_list,
    this.timestamp,
  });

  factory BitpushNewsResponse.fromJson(Map<String, dynamic> json) {
    // 处理新的API响应格式
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      return BitpushNewsResponse(
        code: json['code'] as int?,
        message: json['message'] as String?,
        page: dataMap['page'] as int?,
        total_page: dataMap['total_page'] as int?,
        cursor: dataMap['cursor'] as int?,
        has_more: dataMap['has_more'] as bool?,
        item_list:
            (dataMap['item_list'] as List<dynamic>?)
                ?.map(
                  (e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
        timestamp: dataMap['timestamp'] as String?,
      );
    } else if (json.containsKey('data') && json['data'] is List<dynamic>) {
      // 旧格式：data字段是数组
      return BitpushNewsResponse(
        data:
            (json['data'] as List<dynamic>?)
                ?.map(
                  (e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );
    } else if (json is List) {
      // 旧格式：直接返回数组
      return BitpushNewsResponse(
        data:
            (json as List)
                .map((e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
    } else {
      // 新格式：顶层对象
      return BitpushNewsResponse(
        code: json['code'] as int?,
        message: json['message'] as String?,
        data: null,
      );
    }
  }

  /// 从字符串响应创建BitpushNewsResponse对象
  static BitpushNewsResponse fromJsonString(String jsonStr) {
    final dynamic decoded = jsonDecode(jsonStr);
    if (decoded is Map<String, dynamic>) {
      return BitpushNewsResponse.fromJson(decoded);
    } else if (decoded is List<dynamic>) {
      return BitpushNewsResponse(
        data:
            decoded
                .map((e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
    } else {
      throw FormatException('Unexpected JSON format');
    }
  }

  final int? code;
  final String? message;
  final List<BitpushNewsItem>? data; // 旧版API兼容
  final int? page;
  final int? total_page;
  final int? cursor;
  final bool? has_more;
  final List<BitpushNewsItem>? item_list; // 新版API
  final String? timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'message': message,
    'data': data,
    'page': page,
    'total_page': total_page,
    'cursor': cursor,
    'has_more': has_more,
    'item_list': item_list,
    'timestamp': timestamp,
  };
}

// 自定义BitpushClient实现，不使用RestApi生成的代码
class BitpushClient {
  final Dio _dio;
  final String baseUrl;

  BitpushClient(Dio dio, {String? baseUrl})
    : _dio = dio,
      baseUrl = baseUrl ?? 'https://www.bitpush.news/' {
    // 配置Dio实例
    _dio.options.baseUrl = this.baseUrl;
    _dio.options.headers = {'Accept': 'application/json'};

    // 添加拦截器处理字符串响应
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.data is String) {
            try {
              // 尝试将字符串响应解析为JSON
              final BitpushNewsResponse parsedResponse =
                  BitpushNewsResponse.fromJsonString(response.data);
              response.data = parsedResponse;
              handler.next(response);
            } catch (e) {
              handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  error: 'Failed to parse response: $e',
                ),
              );
            }
          } else {
            handler.next(response);
          }
        },
      ),
    );
  }

  // 获取新闻数据，支持分页加载
  Future<BitpushNewsResponse> getTagnews({int page = 1, int? cursor}) async {
    try {
      // 构建请求参数
      final Map<String, dynamic> params = {
        'm': 'get_articles',
        'category_id': 1551,
        'show_all': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      // 添加分页参数，优先使用cursor（如果提供）
      if (cursor != null) {
        params['cursor'] = cursor.toString();
      } else {
        params['page'] = page.toString();
      }

      // 创建FormData对象，确保以form-data格式发送请求
      final formData = FormData.fromMap(params);

      // 发送POST请求到API端点，使用FormData
      final response = await _dio.post<dynamic>('webapi.php', data: formData);

      if (response.data is BitpushNewsResponse) {
        return response.data as BitpushNewsResponse;
      } else if (response.data is Map<String, dynamic>) {
        return BitpushNewsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.data is String) {
        return BitpushNewsResponse.fromJsonString(response.data as String);
      } else {
        throw FormatException('Unexpected response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 获取单个新闻详情
  Future<BitpushNewsResponse> getNewsDetail(String newsId) async {
    try {
      // 构建请求参数
      final Map<String, dynamic> params = {
        'm': 'get_article_detail',
        'id': newsId,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      // 创建FormData对象，确保以form-data格式发送请求
      final formData = FormData.fromMap(params);

      // 发送POST请求到API端点，使用FormData
      final response = await _dio.post<dynamic>('webapi.php', data: formData);

      if (response.data is BitpushNewsResponse) {
        return response.data as BitpushNewsResponse;
      } else if (response.data is Map<String, dynamic>) {
        return BitpushNewsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.data is String) {
        return BitpushNewsResponse.fromJsonString(response.data as String);
      } else {
        throw FormatException('Unexpected response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 获取文章列表
  Future<BitpushNewsResponse> getArticleList(FormData formData) async {
    try {
      // 发送POST请求到API端点，使用FormData
      final response = await _dio.post<dynamic>('webapi.php', data: formData);

      if (response.data is BitpushNewsResponse) {
        return response.data as BitpushNewsResponse;
      } else if (response.data is Map<String, dynamic>) {
        return BitpushNewsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.data is String) {
        return BitpushNewsResponse.fromJsonString(response.data as String);
      } else {
        throw FormatException('Unexpected response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 获取全球论坛的"全部"标签数据
  Future<BitpushNewsResponse> getForumArticles({
    int page = 1,
    int? cursor,
    String language = 'zh-CN',
    String platform = 'web',
  }) async {
    try {
      // 构建请求参数
      final Map<String, dynamic> params = {
        'm': 'get_articles',
        'category_id': 0, // 全部分类
        'show_all': 1,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'language': language,
        'platform': platform,
      };

      // 添加分页参数，优先使用cursor（如果提供）
      if (cursor != null) {
        params['cursor'] = cursor.toString();
      } else {
        params['page'] = page.toString();
      }

      // 创建FormData对象，确保以form-data格式发送请求
      final formData = FormData.fromMap(params);

      // 使用通用的getArticleList方法发送请求
      return await getArticleList(formData);
    } catch (e) {
      rethrow;
    }
  }
}
