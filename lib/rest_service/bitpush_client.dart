import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
part 'bitpush_client.g.dart';

@JsonSerializable()
class BitpushNewsItem {
  const BitpushNewsItem({
    this.id,
    this.img,
    this.big_img,
    this.title,
    this.link,
    this.tags,
    this.time,
    this.content,
  });

  factory BitpushNewsItem.fromJson(Map<String, dynamic> json) =>
      _$BitpushNewsItemFromJson(json);

  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'img')
  final String? img;

  @JsonKey(name: 'big_img')
  final String? big_img;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'link')
  final String? link;

  @JsonKey(name: 'tags')
  final String? tags;

  @JsonKey(name: 'time')
  final int? time;

  @JsonKey(name: 'content')
  final String? content;

  Map<String, dynamic> toJson() => _$BitpushNewsItemToJson(this);
}

@JsonSerializable()
class BitpushNewsResponse {
  const BitpushNewsResponse({this.data});

  factory BitpushNewsResponse.fromJson(Map<String, dynamic> json) {
    // 处理直接返回数组的情况
    if (json.containsKey('data')) {
      // 原有格式：包含data字段的对象
      return BitpushNewsResponse(
        data:
            (json['data'] as List<dynamic>?)
                ?.map(
                  (e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
      );
    } else {
      // 新格式：直接返回数组
      return BitpushNewsResponse(
        data:
            (json as List<dynamic>?)
                ?.map(
                  (e) => BitpushNewsItem.fromJson(e as Map<String, dynamic>),
                )
                .toList(),
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

  final List<BitpushNewsItem>? data;

  Map<String, dynamic> toJson() => <String, dynamic>{'data': data};
}

// 自定义BitpushClient实现，不使用RestApi生成的代码
class BitpushClient {
  final Dio _dio;
  final String baseUrl;

  BitpushClient(Dio dio, {String? baseUrl})
    : _dio = dio,
      baseUrl = baseUrl ?? 'https://www.bitpush.news/api/' {
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

  // 获取新闻数据
  Future<BitpushNewsResponse> getTagnews() async {
    try {
      final response = await _dio.get<dynamic>('/tagnews.php');
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
}
