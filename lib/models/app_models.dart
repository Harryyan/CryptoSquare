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
  final List<String> tags;

  JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.timeAgo,
    required this.tags,
  });

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
