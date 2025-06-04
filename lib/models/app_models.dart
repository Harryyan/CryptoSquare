import 'package:json_annotation/json_annotation.dart';

part 'app_models.g.dart';

@JsonSerializable()
class Banner {
  final int id;
  final String imageUrl;
  final String title;
  final String link;

  Banner({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.link,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => _$BannerFromJson(json);
  Map<String, dynamic> toJson() => _$BannerToJson(this);
}

@JsonSerializable()
class ServiceItem {
  final int id;
  final String title;
  final String description;
  final String iconUrl;
  final String link;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.link,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) =>
      _$ServiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceItemToJson(this);
}

@JsonSerializable()
class JobPost {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final int timeAgo;
  final String? createdAt;
  final List<String> tags;
  final String? jobKey;
  final String? jobType;
  final int? officeMode;
  final int? jobLang;
  bool isFavorite;

  JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.timeAgo,
    this.createdAt,
    required this.tags,
    this.jobKey,
    this.jobType,
    this.officeMode,
    this.jobLang,
    this.isFavorite = false,
  });

  // 获取格式化后的岗位标题（使用 | 或 / 分隔时取第二个部分作为标题）
  String getFormattedTitle() {
    // 检查是否包含 | 分隔符
    if (title.contains('|')) {
      final titleParts = title.split('|');
      if (titleParts.length >= 2) {
        // 取第二个部分作为标题，并去除前后空格
        return titleParts[1].trim();
      }
    }
    
    // 检查是否包含 / 分隔符
    if (title.contains('/')) {
      final titleParts = title.split('/');
      if (titleParts.length >= 2) {
        // 取第二个部分作为标题，并去除前后空格
        return titleParts[1].trim();
      }
    }
    
    // 如果没有分隔符或只有一个部分，返回原始标题
    return title;
  }

  // 获取格式化后的时间显示
  String getFormattedTime() {
    // 如果没有createdAt，则使用timeAgo
    if (createdAt == null) {
      return '$timeAgo分钟前';
    }

    try {
      // 解析时间为UTC时间，避免时区问题
      DateTime postTime;
      if (createdAt!.contains('T')) {
        // ISO 8601格式，如果没有时区信息，则作为UTC处理
        if (createdAt!.endsWith('Z') || createdAt!.contains('+') || createdAt!.contains('-')) {
          postTime = DateTime.parse(createdAt!);
        } else {
          // 如果没有时区信息，添加Z后缀作为UTC时间处理
          postTime = DateTime.parse(createdAt! + 'Z');
        }
      } else {
        // 非ISO格式，尝试直接解析
        postTime = DateTime.parse(createdAt!);
      }
      
      // 确保都转换为UTC进行计算
      final DateTime postTimeUtc = postTime.toUtc();
      final DateTime nowUtc = DateTime.now().toUtc();
      final Duration difference = nowUtc.difference(postTimeUtc);

      // 小于1小时
      if (difference.inHours < 1) {
        final minutes = difference.inMinutes;
        // 防止显示负数分钟
        if (minutes <= 0) {
          return '刚刚';
        }
        return '$minutes分钟前';
      }
      // 小于24小时
      else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      }
      // 小于7天
      else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      }
      // 超过7天，转换为本地时间显示
      else {
        final localTime = postTimeUtc.toLocal();
        return '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // 解析失败时返回默认值
      return '$timeAgo分钟前';
    }
  }

  factory JobPost.fromJson(Map<String, dynamic> json) =>
      _$JobPostFromJson(json);
  Map<String, dynamic> toJson() => _$JobPostToJson(this);
}

@JsonSerializable()
class NewsItem {
  final int id;
  final String title;
  final String source;
  final int timeAgo;
  final String? content;

  NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    this.content,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);
  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
}

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool isLoggedIn;

  User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isLoggedIn = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
