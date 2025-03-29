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
    this.isFavorite = false,
  });

  // 获取格式化后的岗位标题（最多显示前三个职位）
  String getFormattedTitle() {
    if (title.contains('|')) {
      final titleParts = title.split('|');
      if (titleParts.length > 3) {
        return titleParts.take(3).join('|');
      }
    }
    return title;
  }

  // 获取格式化后的时间显示
  String getFormattedTime() {
    // 如果没有createdAt，则使用timeAgo
    if (createdAt == null) {
      return '$timeAgo分钟前';
    }

    try {
      final DateTime postTime = DateTime.parse(createdAt!);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(postTime);

      // 小于1小时
      if (difference.inHours < 1) {
        return '${difference.inMinutes}分钟前';
      }
      // 小于24小时
      else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      }
      // 小于7天
      else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      }
      // 超过7天
      else {
        return '${postTime.year}-${postTime.month.toString().padLeft(2, '0')}-${postTime.day.toString().padLeft(2, '0')}';
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
  final List<String> tags;

  NewsItem({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.tags,
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
